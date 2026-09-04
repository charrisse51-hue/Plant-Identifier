import json
import os

import requests
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt

from .botanical_ai_engine import generate_plant_answer


OLLAMA_HOST = (os.getenv('OLLAMA_HOST', 'http://127.0.0.1:11434') or '').rstrip('/')
CHAT_MODEL = os.getenv('OLLAMA_CHAT_MODEL', 'llama3.2:1b')


@csrf_exempt
def chat(request):
    if request.method == 'OPTIONS':
        return HttpResponse(status=200)
    if request.method != 'POST':
        return JsonResponse({'error': 'POST required'}, status=405)

    try:
        payload = json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON request.'}, status=400)

    message = payload.get('message', '').strip() if isinstance(payload.get('message'), str) else ''
    plant_name = payload.get('plantName', '').strip() if isinstance(payload.get('plantName'), str) else ''
    scientific_name = payload.get('scientificName', '').strip() if isinstance(payload.get('scientificName'), str) else ''
    if not message:
        return JsonResponse({'error': 'A message is required.'}, status=400)

    # First attempt: Try local Ollama model if available
    reply = None
    source = 'botanical_ai'

    if OLLAMA_HOST:
        context = f' Focus on {plant_name} ({scientific_name}).' if plant_name or scientific_name else ''
        prompt = (
            'You are a concise, knowledgeable, friendly botanical expert and plant assistant. '
            'Give practical advice on plant care, recommendations, troubleshooting, identification, and safety. '
            f'{context}\nUser: {message}\nAssistant:'
        )
        try:
            response = requests.post(
                f'{OLLAMA_HOST}/api/generate',
                json={'model': CHAT_MODEL, 'prompt': prompt, 'stream': False, 'keep_alive': '10m'},
                timeout=10,
            )
            if response.status_code == 200:
                ollama_reply = (response.json() or {}).get('response', '').strip()
                if ollama_reply:
                    reply = ollama_reply
                    source = 'ollama'
        except Exception:
            # Fall back directly to the built-in botanical expert AI engine
            pass

    # Second attempt: Use built-in expert botanical knowledge engine
    if not reply:
        reply = generate_plant_answer(message, plant_name=plant_name, scientific_name=scientific_name)
        source = 'botanical_ai'

    return JsonResponse({'reply': reply, 'source': source})

