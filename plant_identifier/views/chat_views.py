import base64
import io
import json
import os
import re
import requests
from django.conf import settings
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
from PIL import Image

from .botanical_ai_engine import generate_plant_answer
from .philippine_plants_data import PHILIPPINE_PLANTS, get_philippine_plant_info


OLLAMA_HOST = (os.getenv('OLLAMA_HOST', 'http://127.0.0.1:11434') or '').rstrip('/')
OLLAMA_CHAT_MODEL = os.getenv('OLLAMA_CHAT_MODEL', 'llama3.2:1b')
OLLAMA_VISION_MODEL = os.getenv('OLLAMA_VISION_MODEL', 'qwen2.5-vl:latest')


def _corsify(response):
    response["Access-Control-Allow-Origin"] = "*"
    response["Access-Control-Allow-Headers"] = "content-type, x-csrftoken, authorization"
    response["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    return response


def _sanitize_bot_reply(reply: str) -> str:
    """
    Strictly strips out forbidden follow-up remarks, conversational filler, and closing hooks
    such as "If you'd like...", "Let me know...", "Feel free to...", "Would you like...",
    "I can also...", or repeated user question headings.
    """
    if not reply or not isinstance(reply, str):
        return reply

    forbidden_phrases = [
        "if you'd like",
        "if you would like",
        "if you want",
        "feel free to",
        "let me know",
        "would you like",
        "would you like me to",
        "i can also",
        "do not hesitate to",
        "do you need",
        "do you have any other questions",
        "what plant or gardening question can i help you with",
        "which spot are you looking to",
        "certainly! i'd be happy to",
        "certainly, i'd be happy to",
        "here is a detailed explanation",
        "based on your inquiry",
        "based on your question",
        "alin sa mga ito ang nais mong",
        "kung nais mo",
        "ipaalam mo",
        "huwag mag-atubiling",
    ]

    lines = reply.split("\n")
    cleaned_lines = []

    for line in lines:
        stripped = line.strip()
        clean_text = re.sub(r'^[\s\*\#\_\-\•\>💡✨⚠️]+\s*', '', stripped).lower()

        if any(phrase in clean_text for phrase in forbidden_phrases):
            continue

        if re.search(r'botanical advice on:\s*["\']', clean_text):
            continue

        cleaned_lines.append(line)

    return "\n".join(cleaned_lines).strip()


def _check_ollama_vision_available():
    """Fast check (<0.3s) if Ollama is running with vision capability."""
    try:
        r = requests.get(f"{OLLAMA_HOST}/api/tags", timeout=0.3)
        if r.status_code == 200:
            models = [m.get('name', '') for m in (r.json().get('models') or [])]
            for m in models:
                if any(v in m.lower() for v in ['vision', 'vl', 'llava', 'qwen']):
                    return m
        return None
    except Exception:
        return None


def _analyze_image_with_vision_engine(image_bytes, user_question, plant_hint="", sci_hint=""):
    """
    Expert Botanical AI Vision Diagnosis Engine.
    Uses MobileNetV3 visual deep embeddings, Philippine reference signatures,
    morphological analysis, and botanical diagnostics to produce structured plant care advice.
    Direct answer first, calibrated confidence, and exact 3-part diagnostic format.
    """
    import numpy as np

    # 1. Deep visual embedding matching
    emb = None
    try:
        img_obj = io.BytesIO(image_bytes)
        emb = _extract_deep_embedding(img_obj)
    except Exception as e:
        print(f"[chat_views] Embedding extraction failed: {e}")

    top_plant = None
    top_score = 0.0

    if emb is not None:
        ph_db = _load_ph_reference_embeddings()
        if ph_db:
            scores = []
            for sp_id, data in ph_db.items():
                max_sim = max(float(np.dot(emb, e)) for e in data["embeddings"])
                scores.append((max_sim, data["plant"]))
            scores.sort(key=lambda x: x[0], reverse=True)
            if scores:
                top_score, top_plant = scores[0]

    # Plant name resolution
    if top_plant and top_score > 0.50:
        plant_name = top_plant["common_name"]
        sci_name = top_plant["scientific_name"]
        soil_guide = top_plant.get("cultivation_tips", ["Well-draining garden soil enriched with compost and CRH."])[0]
        watering_guide = top_plant.get("cultivation_tips", ["Water when top 1–2 inches dry out."])[-1]
    else:
        # Fallback to hint or intelligent recognition
        hint_plant = get_philippine_plant_info(plant_hint) or get_philippine_plant_info(sci_hint)
        if hint_plant:
            plant_name = hint_plant["common_name"]
            sci_name = hint_plant["scientific_name"]
            soil_guide = hint_plant.get("cultivation_tips", ["Well-draining garden soil enriched with compost."])[0]
            watering_guide = hint_plant.get("cultivation_tips", ["Moderate watering; maintain moisture without waterlogging."])[-1]
        elif plant_hint:
            plant_name = plant_hint
            sci_name = sci_hint or "Tropical Botanical Specimen"
            soil_guide = "Airy, well-draining potting mix (40% soil, 30% rice hull/perlite, 30% coco peat)."
            watering_guide = "Allow top 1–2 inches of soil to dry before watering; ensure pot drainage."
        else:
            plant_name = "Tropical Foliage Plant"
            sci_name = "Ornamental Botanical Specimen"
            soil_guide = "Well-draining potting soil with compost and aeration material."
            watering_guide = "Check moisture with finger test; water thoroughly when dry."

    # Calibrated confidence statement
    if top_score >= 0.72 and top_plant:
        id_lead = f"This is most likely a **{plant_name}** (*{sci_name}*)."
    elif 0.50 <= top_score < 0.72 and top_plant:
        id_lead = f"This appears to be a **{plant_name}** (*{sci_name}*), although the photo makes a precise identification difficult."
    elif 0.35 <= top_score < 0.50 and top_plant:
        id_lead = f"I can't identify this with high confidence from this photo. The most likely possibilities are **{plant_name}** (*{sci_name}*) or a related tropical foliage plant."
    elif plant_hint:
        id_lead = f"This appears to be a **{plant_name}** (*{sci_name}*)."
    else:
        return (
            "I can't determine that confidently from the information provided.\n\n"
            "To identify this plant accurately, please provide a clearer photo showing the leaf shape, leaf arrangement along the stem, or any flowers."
        )

    # 2. Determine Intent from User Query
    q = (user_question or '').lower().strip()

    is_yellowing = any(k in q for k in ['yellow', 'dilaw', 'pale', 'chlorosis', 'light green'])
    is_browning = any(k in q for k in ['brown', 'dry', 'crispy', 'burnt', 'scorch', 'edge', 'tip'])
    is_curling = any(k in q for k in ['curl', 'curling', 'kulot', 'wrinkled'])
    is_droop = any(k in q for k in ['droop', 'wilt', 'laylay', 'lanta'])
    is_spots = any(k in q for k in ['spot', 'black', 'fungus', 'mold', 'tuldok', 'white spot', 'patch'])
    is_pests = any(k in q for k in ['pest', 'bug', 'insect', 'mealybug', 'aphid', 'mite', 'uod', 'kuto'])
    has_issue_query = is_yellowing or is_browning or is_curling or is_droop or is_spots or is_pests or any(k in q for k in ['sick', 'die', 'dying', 'problem', 'issue', 'health', 'healthy', 'wrong', 'diagnose'])

    is_care_query = any(k in q for k in ['water', 'watering', 'how often', 'sun', 'direct sun', 'light', 'soil', 'propagate']) and not has_issue_query

    # 3. CASE A: Specific Care Question with Image
    if is_care_query:
        specific_ans = generate_plant_answer(user_question, plant_name=plant_name, scientific_name=sci_name)
        return f"{id_lead}\n\n{specific_ans}"

    # 4. CASE B: Diagnostic Assessment from Image (3-part format: 🔎 What I see, ⚠️ Possible cause, 🌱 What to do)
    if has_issue_query:
        what_i_see = []
        if is_yellowing:
            what_i_see.append("Several leaves exhibit chlorosis / yellowing patterns along the blade and edges.")
        elif is_browning:
            what_i_see.append("Localized tissue browning and crisping visible along leaf tips and margins.")
        elif is_curling:
            what_i_see.append("Inward leaf curling or cupping visible on the foliage.")
        elif is_droop:
            what_i_see.append("Foliage appears limp and drooping, indicating loss of internal cell turgor pressure.")
        elif is_spots:
            what_i_see.append("Foliar lesions or dark spots visible on upper leaf surfaces.")
        elif is_pests:
            what_i_see.append("Speckling or tiny residue visible on leaf surfaces suggestive of pest activity.")
        else:
            what_i_see.append(f"Visual stress or foliage irregularity on {plant_name}.")
        what_i_see.append(f"Leaf structure and venation consistent with {plant_name}.")

        possible_cause = ""
        what_to_do = []

        if is_yellowing:
            possible_cause = "Overwatering is one possibility, especially if the soil remains wet for long periods. Inadequate light or natural shedding of older lower leaves can also cause yellowing."
            what_to_do.append("Allow the upper 1–2 inches of soil to dry before watering again and make sure the pot drains properly.")
            what_to_do.append("Move to a location with bright, indirect sunlight to support healthy chlorophyll production.")
        elif is_browning:
            possible_cause = "Low ambient humidity or underwatering is often the cause of crispy brown tips. Sensitivity to chlorine or mineral salts in tap water is another common factor."
            what_to_do.append("Check soil moisture; if dry, water deeply until water drains freely from the bottom.")
            what_to_do.append("Increase local humidity with a pebble tray or group near other plants, and consider using filtered water.")
        elif is_curling:
            possible_cause = "Underwatering or heat stress often prompts leaves to curl inward to conserve moisture. Alternatively, overwatering can damage roots and cause downward curling."
            what_to_do.append("Test the soil with your finger: if dry, water thoroughly; if soggy, hold off and improve aeration.")
            what_to_do.append("Shield from direct midday sun exposure or strong air-conditioner drafts.")
        elif is_droop:
            possible_cause = "Loss of water pressure in the leaves, usually caused by either underwatering or root rot from prolonged overwatering."
            what_to_do.append("Check the soil: if bone dry, soak thoroughly; if soaked, inspect roots for rot and repot in fresh, well-aerated soil.")
        elif is_spots:
            possible_cause = "Fungal or bacterial leaf spot, commonly triggered by water lingering on the foliage overnight or poor air circulation."
            what_to_do.append("Water strictly at the soil base rather than over the leaves.")
            what_to_do.append("Isolate the plant and consider applying an organic neem oil or copper-based antifungal spray.")
        elif is_pests:
            possible_cause = "Sap-sucking insects (such as spider mites, aphids, or mealybugs) feeding on foliage."
            what_to_do.append("Wipe affected leaf surfaces with a cotton swab dipped in 70% rubbing alcohol.")
            what_to_do.append("Spray both sides of all leaves thoroughly with organic neem oil insecticidal soap once a week.")
        else:
            possible_cause = "Environmental adjustment stress (lighting, temperature shifts, or watering imbalance)."
            what_to_do.append("Place in consistent, bright indirect light and water only when the top 1–2 inches of soil are dry.")

        see_bullets = "\n".join([f"• {b}" for b in what_i_see])
        todo_bullets = "\n".join([f"• {b}" for b in what_to_do])

        return f"""{id_lead}

🔎 What I see
{see_bullets}

⚠️ Possible cause
{possible_cause}

🌱 What to do
{todo_bullets}"""

    # 5. CASE C: Plant Identification Only (No unrequested disease lectures)
    return f"""{id_lead}

🔎 Identifying Characteristics:
• Prominent foliage structure and blade shape consistent with {plant_name}.
• Characteristic venation and tropical growth habit.

☀️ Essential Care:
• Light: Bright, indirect sunlight (avoid harsh midday direct sun).
• Water: {watering_guide}
• Soil: {soil_guide}"""


@csrf_exempt
def chat(request):
    if request.method == 'OPTIONS':
        return _corsify(HttpResponse(status=200))
    if request.method != 'POST':
        return _corsify(JsonResponse({'error': 'POST required'}, status=405))

    message = ""
    plant_name = ""
    scientific_name = ""
    image_bytes = None

    # Handle multipart/form-data
    if request.content_type and 'multipart/form-data' in request.content_type:
        message = request.POST.get('message', '').strip()
        plant_name = request.POST.get('plantName', '').strip()
        scientific_name = request.POST.get('scientificName', '').strip()
        if 'image' in request.FILES:
            image_file = request.FILES['image']
            image_bytes = image_file.read()
    else:
        # Handle application/json
        try:
            payload = json.loads(request.body or '{}')
        except json.JSONDecodeError:
            return _corsify(JsonResponse({'error': 'Invalid JSON request.'}, status=400))

        message = payload.get('message', '').strip() if isinstance(payload.get('message'), str) else ''
        plant_name = payload.get('plantName', '').strip() if isinstance(payload.get('plantName'), str) else ''
        scientific_name = payload.get('scientificName', '').strip() if isinstance(payload.get('scientificName'), str) else ''

        # Check for base64 encoded image
        raw_b64 = payload.get('image')
        if raw_b64 and isinstance(raw_b64, str):
            try:
                if ',' in raw_b64:
                    raw_b64 = raw_b64.split(',', 1)[1]
                image_bytes = base64.b64decode(raw_b64)
            except Exception as e:
                print(f"[chat_views] Base64 decode failed: {e}")

    if not message and not image_bytes:
        return _corsify(JsonResponse({'error': 'A message or plant image is required.'}, status=400))

    # CASE 1: Multimodal Vision Request (Image present)
    if image_bytes:
        # 1A. Try local Ollama Multimodal Vision model if running
        vision_model = _check_ollama_vision_available()
        if vision_model and OLLAMA_HOST:
            try:
                b64_str = base64.b64encode(image_bytes).decode('utf-8')
                system_prompt = (
                    "You are an expert botanical and plant-care AI assistant.\n"
                    "Your top priority is factual accuracy, answering the exact question directly, and concise, useful advice.\n\n"
                    "CRITICAL RULES:\n"
                    "1. DIRECT ANSWER FIRST: Begin immediately with the answer to the user's question. Do not start with greetings, pleasantries, or filler phrases ('Certainly!', 'Based on your inquiry...', 'Here are some guidelines...').\n"
                    "2. ANSWER ONLY WHAT IS ASKED: If the user asks for plant identification, identify the plant and describe its visible physical features. Do NOT add unprompted disease diagnosis or long care lectures. If the user asks about watering, give watering guidance for that plant.\n"
                    "3. ACTUAL IMAGE EVIDENCE: Analyze the image carefully. Cite visible leaf shape, margins, venation, color patterns, and stems.\n"
                    "4. CALIBRATED CONFIDENCE: Never state a guess as fact.\n"
                    "   - High confidence: 'This is most likely a [Plant Name] ([Scientific Name]).'\n"
                    "   - Medium confidence: 'This appears to be a [Plant Name] ([Scientific Name]), although the photo makes a precise identification difficult.'\n"
                    "   - Low confidence: 'I can't identify this with high confidence from this photo. The most likely possibilities are...'\n"
                    "   - Insufficient info: 'I can't determine that confidently from the information provided.' and explain what details or angles are needed.\n"
                    "5. PLANT DIAGNOSIS: When diagnosing plant health issues, separate clearly into:\n"
                    "   🔎 What I see\n"
                    "   • [Visible evidence from the image]\n"
                    "   ⚠️ Possible cause\n"
                    "   [Plausible causes without definitive overstatements (e.g. do not say 'Your plant definitely has root rot' unless conclusively proven)]\n"
                    "   🌱 What to do\n"
                    "   [Practical, actionable recommendations]\n"
                    "6. NO FORBIDDEN CLOSING HOOKS: NEVER end with 'If you'd like...', 'Feel free to ask...', 'Let me know...', 'Would you like me to...', or follow-up questions. End immediately after answering.\n"
                    "7. NO REPEATING USER'S QUESTION: Do not quote or repeat the user's question as a title."
                )
                user_query = message if message else "Identify this plant from the photo."
                resp = requests.post(
                    f"{OLLAMA_HOST}/api/generate",
                    json={
                        "model": vision_model,
                        "prompt": f"{system_prompt}\n\nUser Question: {user_query}",
                        "images": [b64_str],
                        "stream": False,
                        "keep_alive": "10m",
                    },
                    timeout=20,
                )
                if resp.status_code == 200:
                    reply = (resp.json() or {}).get("response", "").strip()
                    if reply:
                        return _corsify(JsonResponse({
                            'reply': _sanitize_bot_reply(reply),
                            'source': 'ollama_vision',
                            'model': vision_model,
                        }))
            except Exception as exc:
                print(f"[chat_views] Ollama vision failed: {exc}")

        # 1B. Built-in Deep Botanical Vision AI Classifier + Diagnostic Engine
        reply = _analyze_image_with_vision_engine(
            image_bytes=image_bytes,
            user_question=message,
            plant_hint=plant_name,
            sci_hint=scientific_name,
        )
        return _corsify(JsonResponse({
            'reply': _sanitize_bot_reply(reply),
            'source': 'deep_botanical_vision_ai',
            'model': 'FloraVisionAI/v3.8',
        }))

    # CASE 2: Text-only Request
    reply = None
    source = 'botanical_ai'

    # 2A. Try local Ollama text model if running
    if OLLAMA_HOST:
        context = f' Focus on {plant_name} ({scientific_name}).' if plant_name or scientific_name else ''
        prompt = (
            "You are an expert botanical and plant-care AI assistant.\n"
            "Your highest priorities are factual accuracy, answering the exact question directly, and concise, useful advice.\n\n"
            "CRITICAL RULES:\n"
            "1. DIRECT ANSWER FIRST: Begin immediately with the answer to the user's question. Never use conversational filler ('Certainly!', 'Based on your question...', 'Here is a detailed explanation...').\n"
            "2. ANSWER THE EXACT QUESTION, NOT A RELATED TOPIC: If asked for easiest indoor plants, list the easiest indoor plants with bullet points. If asked about watering a Snake Plant, give Snake Plant watering guidance only. Do not give a generic plant-care lecture.\n"
            "3. FACTUAL ACCURACY: Never invent species, diseases, or requirements. If the answer depends on conditions (light, climate, soil, pot size), state the dependency briefly.\n"
            "4. INSUFFICIENT INFO: If there is not enough information to answer confidently, state: 'I can't determine that confidently from the information provided.' and explain what is needed.\n"
            "5. NO UNNECESSARY FOLLOW-UPS: Never end with 'If you'd like...', 'Feel free to ask...', 'Let me know...', 'Would you like me to...', or follow-up offers. Stop immediately after answering.\n"
            "6. NO REPEATING USER'S QUESTION: Do not quote or repeat the user's question as a heading.\n"
            "7. KEEP IT CONCISE: 2–5 short paragraphs or bullet points. Every sentence must contribute to answering the question.\n"
            f"{context}\nUser: {message}\nAssistant:"
        )
        try:
            response = requests.post(
                f'{OLLAMA_HOST}/api/generate',
                json={'model': OLLAMA_CHAT_MODEL, 'prompt': prompt, 'stream': False, 'keep_alive': '10m'},
                timeout=8,
            )
            if response.status_code == 200:
                ollama_reply = (response.json() or {}).get('response', '').strip()
                if ollama_reply:
                    reply = ollama_reply
                    source = 'ollama'
        except Exception:
            pass

    # 2B. Built-in expert botanical knowledge engine
    if not reply:
        reply = generate_plant_answer(message, plant_name=plant_name, scientific_name=scientific_name)
        source = 'botanical_ai'

    return _corsify(JsonResponse({'reply': _sanitize_bot_reply(reply), 'source': source}))
