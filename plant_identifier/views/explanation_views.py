import json
import os
import re

import requests
from django.conf import settings
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .philippine_plants_data import get_philippine_plant_info


TEXT_MODEL = os.getenv('OLLAMA_TEXT_MODEL', 'Allen_Rodas11/llama3-plant')
OLLAMA_HOST = (os.getenv('OLLAMA_HOST', 'http://127.0.0.1:11434') or '').rstrip('/')
OLLAMA_TIMEOUT_SECONDS = int(os.getenv('OLLAMA_TIMEOUT_SECONDS', '45'))


def _corsify(request, response):
    origin = request.headers.get('Origin')
    if origin and origin in getattr(settings, 'CORS_ALLOWED_ORIGINS', []):
        response['Access-Control-Allow-Origin'] = origin
        response['Vary'] = 'Origin'
        response['Access-Control-Allow-Credentials'] = 'true'
        response['Access-Control-Allow-Headers'] = 'content-type, x-csrftoken, authorization'
        response['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    return response


def _scientific_name(value):
    if not isinstance(value, str):
        return None
    match = re.search(r'\b([A-Z][a-z-]+\s+[a-z][a-z-]+)\b', value)
    return match.group(1) if match else None


def _format_philippine_explanation(ph_plant):
    med = "\n".join([f"- {m}" for m in ph_plant.get("medicinal_uses", [])])
    cul = "\n".join([f"- {c}" for c in ph_plant.get("culinary_uses", [])])
    tox = "\n".join([f"- {t}" for t in ph_plant.get("toxicity_risks", [])])
    cul_sig = "\n".join([f"- {s}" for s in ph_plant.get("cultural_significance", [])])
    eco = "\n".join([f"- {e}" for e in ph_plant.get("ecological_role", [])])
    cult = "\n".join([f"- {g}" for g in ph_plant.get("cultivation_tips", [])])

    return f"""**Medicinal Uses:**
{med}

**Culinary Uses:**
{cul}

**Toxicity Risks:**
{tox}

**Cultural Significance:**
{cul_sig}

**Ecological Role:**
{eco}

**Cultivation Tips:**
{cult}"""


def _fallback_explanation(scientific_name, common_name):
    plant_name = common_name.strip() or scientific_name
    return f'''**Medicinal Uses:**
- {plant_name} is identified as {scientific_name}; this app cannot verify medicinal use without a reliable source.
- Do not use any part of this plant as medicine without advice from a qualified health professional.
- Confirm the species with an authoritative source before handling or using it.

**Culinary Uses:**
- Edibility has not been verified for {plant_name}.
- Do not eat the leaves, flowers, fruit, seeds, sap, or roots unless an authoritative local source confirms they are safe.
- Keep unknown plant material away from children and pets.

**Toxicity Risks:**
- Treat {plant_name} as potentially irritating or toxic until its identity and safety are independently confirmed.
- Avoid tasting the plant or touching sap with bare skin; wash hands after handling it.
- Contact local poison-control or veterinary services after suspected ingestion or a serious reaction.

**Cultural Significance:**
- Cultural uses and local names can vary by region and community in the Philippines.
- Consult local Philippine botanical gardens, herbaria, or knowledgeable community sources for verified cultural information.

**Ecological Role:**
- Plants provide habitat and resources for organisms in Philippine tropical ecosystems.
- Ecological impact depends on location; a species can be beneficial in its native range and invasive elsewhere.
- Avoid moving or planting unidentified species in Philippine natural protected areas.

**Cultivation Tips:**
- Confirm growing requirements suited for Philippine wet (Tag-ulan) and dry (Tag-araw) tropical seasons.
- Use gloves when handling an unidentified plant and keep it separate from edible plants.
- Check local Philippine environmental guidance before propagating or sharing it.'''


def _generate_explanation(scientific_name, common_name):
    prompt = f'''You are a Philippine botanical expert. Give concise, practical information about {scientific_name} ({common_name}) in the context of the Philippines.

Use exactly these headings, each with 3 short bullet points beginning with '- ':
**Medicinal Uses:**
**Culinary Uses:**
**Toxicity Risks:**
**Cultural Significance:**
**Ecological Role:**
**Cultivation Tips:**

Do not invent medical or culinary uses. State when information is not well-established.'''
    response = requests.post(
        f'{OLLAMA_HOST}/api/generate',
        json={'model': TEXT_MODEL, 'prompt': prompt, 'stream': False, 'keep_alive': '10m'},
        timeout=OLLAMA_TIMEOUT_SECONDS,
    )
    response.raise_for_status()
    return (response.json() or {}).get('response', '').strip()


@csrf_exempt
def explain_llm(request):
    if request.method == 'OPTIONS':
        return _corsify(request, HttpResponse(status=200))
    if request.method != 'POST':
        return _corsify(request, JsonResponse({'error': 'POST required'}, status=405))

    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return _corsify(request, JsonResponse({'error': 'Invalid JSON request.'}, status=400))

    raw_sci = payload.get('scientificName', '')
    common_name = payload.get('commonName', '') if isinstance(payload.get('commonName'), str) else ''
    scientific_name = _scientific_name(raw_sci) or raw_sci

    if not scientific_name and not common_name:
        return _corsify(request, JsonResponse({'error': 'A valid plant or scientific name is required.'}, status=400))

    # 1. Check if it is a Philippine Flora database match
    ph_match = get_philippine_plant_info(scientific_name) or get_philippine_plant_info(common_name)
    if ph_match:
        explanation = _format_philippine_explanation(ph_match)
        return _corsify(request, JsonResponse({
            'explanation': explanation,
            'source': 'philippine_flora_database',
            'model': 'PhilippineBotanicalEngine/v2',
        }, status=200))

    # 2. Try Ollama LLM
    try:
        explanation = _generate_explanation(scientific_name, common_name)
        source = 'ollama'
        if not explanation:
            raise RuntimeError('The local model returned no text.')
    except Exception as error:
        explanation = _fallback_explanation(scientific_name, common_name)
        source = 'safety_fallback'
        error_detail = str(error)
    else:
        error_detail = None

    result = {'explanation': explanation, 'source': source, 'model': TEXT_MODEL}
    if error_detail:
        result['details'] = error_detail
    return _corsify(request, JsonResponse(result, status=200))
