import random
import os
from django.conf import settings
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_GET
from .philippine_plants_data import PHILIPPINE_PLANTS

@csrf_exempt
@require_GET
def random_plants(request):
    try:
        from .prediction_metadata import (
            class_idx_to_species_id,
            species_id_to_cmn_name,
            species_id_to_scn_name,
        )

        results = []

        # 1. First add randomized Philippine flora collection
        shuffled_ph = list(PHILIPPINE_PLANTS)
        random.shuffle(shuffled_ph)

        for plant in shuffled_ph:
            species_id_str = str(plant["species_id"]).strip()
            sample_image_url = None
            species_folder = os.path.join(settings.BASE_DIR, "media", "images", species_id_str)
            if os.path.isdir(species_folder):
                files = [
                    f for f in os.listdir(species_folder)
                    if os.path.isfile(os.path.join(species_folder, f))
                ]
                if files:
                    sample_image_url = f"{settings.MEDIA_URL}images/{species_id_str}/{files[0]}"

            results.append({
                "index": plant["index"],
                "species_id": plant["species_id"],
                "common_name": f"{plant['local_name']} ({plant['common_name']})",
                "scientific_name": plant["scientific_name"],
                "sample_image": sample_image_url or "Not available",
            })

        # 2. Add additional random botanical species from dataset
        remaining_count = max(0, 50 - len(results))
        if remaining_count > 0:
            random_class_indices = random.sample(list(class_idx_to_species_id.keys()), remaining_count)
            for idx in random_class_indices:
                species_id = class_idx_to_species_id[idx]
                species_id_str = str(species_id).strip()

                common_name = species_id_to_cmn_name.get(species_id_str, "Unknown")
                scientific_name = species_id_to_scn_name.get(species_id_str, "Unknown")

                sample_image_url = None
                species_folder = os.path.join(settings.BASE_DIR, "media", "images", species_id_str)
                if os.path.isdir(species_folder):
                    files = [
                        f for f in os.listdir(species_folder)
                        if os.path.isfile(os.path.join(species_folder, f))
                    ]
                    if files:
                        sample_image_url = f"{settings.MEDIA_URL}images/{species_id_str}/{files[0]}"

                results.append({
                    "index": int(idx),
                    "species_id": int(species_id),
                    "common_name": common_name,
                    "scientific_name": scientific_name,
                    "sample_image": sample_image_url or "Not available",
                })

        return JsonResponse({"plants": results}, safe=False)

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)
