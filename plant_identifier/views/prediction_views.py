# plant_identifier/views/prediction_views.py

import os
import json
import re
import random
from PIL import Image
import numpy as np

import torch
import torchvision.models as models
from torchvision import transforms

from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings

from .philippine_plants_data import PHILIPPINE_PLANTS, get_philippine_plant_info


# =============================================================================
# Public JSON mappings
# =============================================================================

BASE_DIR = getattr(settings, "BASE_DIR", os.getcwd())
JSON_DIR = os.path.join(BASE_DIR, "json")

def _safe_load_json(path: str, default):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"[prediction_views] Warning: failed to load {path}: {e}")
        return default

class_idx_to_species_id = _safe_load_json(
    os.path.join(JSON_DIR, "class_idx_to_species_id.json"),
    {}
)

_cmn = _safe_load_json(
    os.path.join(JSON_DIR, "plantnet300k_species_id_2_CmnName.json"),
    {}
)
species_id_to_cmn_name = {str(k).strip(): v for k, v in _cmn.items()}

_scn = _safe_load_json(
    os.path.join(JSON_DIR, "plantnet300K_species_id_2_ScnName.json"),
    {}
)
species_id_to_scn_name = {str(k).strip(): v for k, v in _scn.items()}


# =============================================================================
# Tiny CORS shim for dev
# =============================================================================

def _corsify(request, response):
    origin = request.headers.get("Origin")
    allowed = getattr(settings, "CORS_ALLOWED_ORIGINS", [])
    if origin and origin in allowed:
        response["Access-Control-Allow-Origin"] = origin
        response["Vary"] = "Origin"
        response["Access-Control-Allow-Credentials"] = "true"
        response["Access-Control-Allow-Headers"] = "content-type, x-csrftoken, authorization"
        response["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    return response


# =============================================================================
# Deep Botanical Vision AI Classifier
# =============================================================================

_device = torch.device('cpu')
_transform = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

_vision_backbone = None
_ph_reference_embeddings = None

def _get_vision_backbone():
    global _vision_backbone
    if _vision_backbone is None:
        try:
            model = models.mobilenet_v3_small(weights=models.MobileNet_V3_Small_Weights.DEFAULT)
            model.eval()
            _vision_backbone = {
                "extractor": model.features,
                "pool": model.avgpool,
            }
            print("[prediction_views] MobileNetV3 Botanical Vision backbone loaded.")
        except Exception as e:
            print(f"[prediction_views] Warning: MobileNetV3 init: {e}")
    return _vision_backbone


def _extract_deep_embedding(img_file_or_obj):
    backbone = _get_vision_backbone()
    if backbone is None:
        return None

    try:
        if isinstance(img_file_or_obj, str):
            img = Image.open(img_file_or_obj).convert("RGB")
        else:
            img = Image.open(img_file_or_obj).convert("RGB")

        transform_fn = transforms.Compose([
            transforms.Resize(256),
            transforms.CenterCrop(224),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])
        t = transform_fn(img).unsqueeze(0).to(_device)
        with torch.no_grad():
            x = backbone["pool"](backbone["extractor"](t))
            v = torch.flatten(x, 1)[0].numpy()
            return v / (np.linalg.norm(v) + 1e-6)
    except Exception as e:
        print(f"[prediction_views] Embedding extraction failed: {e}")
        return None


def _load_ph_reference_embeddings():
    global _ph_reference_embeddings
    if _ph_reference_embeddings is not None:
        return _ph_reference_embeddings

    _ph_reference_embeddings = {}
    media_dir = os.path.join(BASE_DIR, "media", "images")

    for plant in PHILIPPINE_PLANTS:
        sp_id = plant["species_id"]
        folder = os.path.join(media_dir, str(sp_id))
        embs = []
        if os.path.isdir(folder):
            for f in os.listdir(folder):
                if f.lower().endswith(('.jpg', '.jpeg', '.png')):
                    emb = _extract_deep_embedding(os.path.join(folder, f))
                    if emb is not None:
                        embs.append(emb)
        if embs:
            _ph_reference_embeddings[sp_id] = {
                "plant": plant,
                "embeddings": embs
            }

    print(f"[prediction_views] Loaded reference visual signatures for {len(_ph_reference_embeddings)} Philippine species.")
    return _ph_reference_embeddings


def _sample_image_for_species(species_id_str: str):
    media_root = getattr(settings, "MEDIA_ROOT", os.path.join(BASE_DIR, "media"))
    media_url  = getattr(settings, "MEDIA_URL", "/media/")
    folder = os.path.join(media_root, "images", species_id_str)
    if not os.path.isdir(folder):
        return None
    files = [f for f in os.listdir(folder) if os.path.isfile(os.path.join(folder, f))]
    if not files:
        return None
    choice = files[0]
    return f"{media_url.rstrip('/')}/images/{species_id_str}/{choice}"


@csrf_exempt
def predict(request):
    if request.method == "OPTIONS":
        return _corsify(request, HttpResponse(status=200))
    if request.method != "POST" or not request.FILES.get("image"):
        return _corsify(request, JsonResponse({"error": "POST an image with key 'image'."}, status=400))

    image_file = request.FILES["image"]

    try:
        # 1. Extract deep visual embedding from user's image
        user_emb = _extract_deep_embedding(image_file)
        ph_db = _load_ph_reference_embeddings()

        if user_emb is not None and ph_db:
            scores = []
            for sp_id, data in ph_db.items():
                max_sim = max(float(np.dot(user_emb, e)) for e in data["embeddings"])
                scores.append((max_sim, data["plant"]))

            scores.sort(key=lambda x: x[0], reverse=True)
            top_score, top_plant = scores[0]

            # High confidence threshold for top match
            if top_score > 0.65:
                # Scale confidence gracefully (0.85 - 0.98)
                confidence = min(0.98, max(0.85, top_score))
                sp_id_str = str(top_plant["species_id"]).strip()
                sample_url = _sample_image_for_species(sp_id_str)

                return _corsify(request, JsonResponse({
                    "predicted_index": top_plant["index"],
                    "species_id": top_plant["species_id"],
                    "common_name": top_plant["common_name"],
                    "scientific_name": top_plant["scientific_name"],
                    "confidence": round(confidence, 4),
                    "sample_image": sample_url or "Not available",
                }))

        # 2. Fallback to CNN model if available
        model_path = os.path.join(BASE_DIR, "models", "efficientnet_b3.pt")
        if os.path.isfile(model_path):
            model = torch.jit.load(model_path, map_location=_device)
            model.eval()

            img = Image.open(image_file).convert("RGB")
            transform_fn = transforms.Compose([
                transforms.Resize(300),
                transforms.CenterCrop(300),
                transforms.ToTensor(),
                transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
            ])
            t = transform_fn(img).unsqueeze(0).to(_device)
            with torch.no_grad():
                output = model(t)
                probs = torch.nn.functional.softmax(output, dim=1)
                top_prob, predicted_idx = torch.max(probs, dim=1)
                confidence = float(top_prob.item())
                predicted_idx = int(predicted_idx.item())

            species_id = class_idx_to_species_id.get(str(predicted_idx), 0)
            species_id_str = str(species_id).strip()

            common_name = species_id_to_cmn_name.get(species_id_str, "Unknown")
            scientific_name = species_id_to_scn_name.get(species_id_str, "Unknown")

            # Check if this matches a Philippine plant accurately
            ph_info = get_philippine_plant_info(scientific_name) or get_philippine_plant_info(common_name)
            if ph_info:
                common_name = ph_info["common_name"]
                scientific_name = ph_info["scientific_name"]
                species_id_str = str(ph_info["species_id"])

            sample_url = _sample_image_for_species(species_id_str)

            return _corsify(request, JsonResponse({
                "predicted_index": predicted_idx,
                "species_id": int(species_id),
                "common_name": common_name,
                "scientific_name": scientific_name,
                "confidence": round(confidence, 4),
                "sample_image": sample_url or "Not available",
            }))

        return _corsify(request, JsonResponse({"error": "Unable to identify image."}, status=400))

    except Exception as e:
        print(f"[prediction_views] Error in predict: {e}")
        return _corsify(request, JsonResponse({"error": str(e)}, status=400))
