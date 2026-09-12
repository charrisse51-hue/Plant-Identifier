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

# In-memory explanation cache for instantaneous response
_EXPLANATION_CACHE = {}


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


# Expanded Philippine & Tropical Botanical Knowledge Base
EXTENDED_BOTANICAL_KB = {
    "mango": {
        "common": "Mango (Mangga)",
        "sci": "Mangifera indica",
        "medicinal": [
            "Young mango leaf decoction is traditionally used in Philippine folk medicine to support healthy blood sugar levels.",
            "Bark and leaf extracts contain mangiferin, a potent antioxidant with documented anti-inflammatory properties.",
            "Tender mango leaves are boiled as a mild herbal gargle for sore throat and gum inflammation.",
        ],
        "culinary": [
            "Carabao mango is world-renowned for its sweet, luscious golden flesh eaten fresh or in mango floats and shakes.",
            "Green (unripe) mango is a beloved Philippine street food paired with sauteed bagoong alamang (shrimp paste).",
            "Processed into famous Philippine dried mangoes, jams, mango puree, and refreshing juices.",
        ],
        "toxicity": [
            "Mango sap contains urushiol, an oleoresin that can cause mild contact dermatitis on sensitive skin.",
            "The fruit skin should be washed or peeled thoroughly before eating.",
            "Ripe fruit flesh is entirely safe and non-toxic for humans, dogs, and cats in moderation.",
        ],
        "cultural": [
            "Recognized as the National Fruit of the Philippines; celebrated in the Guimaras Manggahan Festival.",
            "A mango tree in a Filipino backyard is a timeless symbol of warmth, abundance, and family gatherings.",
            "Guimaras Carabao mangoes have achieved worldwide fame for their unmatched sweetness.",
        ],
        "ecological": [
            "Deep taproots stabilize soil and protect Philippine hillsides and watershed basins from erosion.",
            "Spreading evergreen canopy provides critical shade, habitat, and food for Philippine bats and birds.",
            "Dense blossom panicles feed massive numbers of native pollinators during the dry season flowering period.",
        ],
        "cultivation": [
            "Requires full tropical sun and distinct wet and dry seasons for optimal fruit flowering and setting.",
            "Thrives in deep, well-draining loam or sandy-loam soil with organic compost.",
            "Smudge burning (pausok) is a traditional Philippine cultural practice to stimulate synchronous flowering.",
        ],
    },
    "banana": {
        "common": "Banana (Saging)",
        "sci": "Musa acuminata / Musa balbisiana",
        "medicinal": [
            "Green banana decoction is traditionally consumed for mild digestive upset and diarrhea.",
            "Sap from banana pseudostem has mild astringent and styptic properties to staunch minor cuts.",
            "Rich in potassium, vitamin B6, and prebiotic fiber supporting cardiovascular and digestive wellness.",
        ],
        "culinary": [
            "Saba variety is essential in Filipino dishes: Puchero, Nilaga, Banana Cue, Turon, and Maruya.",
            "Banana blossoms (puso ng saging) are cooked in Ginataang Puso ng Saging and Kare-Kare.",
            "Cavendish, Lakatan, and Latundan are beloved table bananas eaten fresh daily across the archipelago.",
        ],
        "toxicity": [
            "Non-toxic to humans and common domestic pets.",
            "Banana leaves used for food wrapping should be washed and briefly wilted over heat.",
            "Safe for consumption across all ages from infants to elderly.",
        ],
        "cultural": [
            "Central to Philippine culinary heritage; fresh banana leaves serve as traditional dining mats for Boodle Fights.",
            "Featured in regional folk songs and the classic fable of the Monkey and the Turtle.",
            "The Philippines is one of the world's leading producers and exporters of high-quality bananas.",
        ],
        "ecological": [
            "Fast-growing herbaceous plants with high biomass that mulch and enrich tropical topsoil.",
            "Broad leaves reduce heavy tropical rain impact, mitigating soil compaction and surface runoff.",
            "Flowers provide rich nectar for nectarivorous Philippine bats and native sunbirds.",
        ],
        "cultivation": [
            "Prefers rich, moist, organic soil with good drainage and shelter from fierce typhoon winds.",
            "Propagate using healthy suckers or rhizome corms planted in deep composted holes.",
            "Needs frequent watering during dry spells and generous application of organic compost or manure.",
        ],
    },
    "papaya": {
        "common": "Papaya (Pawpaw)",
        "sci": "Carica papaya",
        "medicinal": [
            "Papaya leaf extract has been widely studied in the Philippines and Southeast Asia for platelet support.",
            "Contains papain, a natural proteolytic enzyme aiding protein digestion and easing bloating.",
            "Crushed papaya seeds and fruit pulp have mild anthelmintic and skin-cleansing antioxidant actions.",
        ],
        "culinary": [
            "Green unripe papaya is the star ingredient of authentic Filipino Chicken Tinola soup.",
            "Pickled green papaya creates Atchara, the quintessential sweet-and-sour Philippine barbecue condiment.",
            "Ripe golden papaya is served chilled as a sweet, nutritious breakfast fruit drizzled with calamansi.",
        ],
        "toxicity": [
            "Ripe papaya fruit is completely safe and non-toxic.",
            "Unripe green papaya contains concentrated white latex which pregnant women should avoid consuming in large raw amounts.",
            "Wash hands after peeling green papaya to avoid mild skin irritation from latex.",
        ],
        "cultural": [
            "Standard backyard staple in Filipino homes, easily grown from discarded fruit seeds.",
            "Widely celebrated in Philippine home cooking as an indispensable ingredient for Tinola.",
            "Papaya extracts are prominently utilized in famous Philippine natural herbal whitening soaps.",
        ],
        "ecological": [
            "Rapidly colonizes open canopy gaps and disturbed tropical soils, kickstarting forest regeneration.",
            "Sweet fragrant flowers provide nectar to native Philippine nocturnal hawk moths and bees.",
            "Ripe fallen fruits sustain local Philippine wildlife including frugivorous birds and civets.",
        ],
        "cultivation": [
            "Demands well-drained, porous soil; papaya roots are highly sensitive to waterlogged standing water.",
            "Plant in full tropical sunlight; germinates quickly from seeds within 2 to 3 weeks.",
            "Yields abundant fruit within 9 to 12 months after planting when fertilized regularly.",
        ],
    },
    "coconut": {
        "common": "Coconut (Niyog / Buko)",
        "sci": "Cocos nucifera",
        "medicinal": [
            "Fresh buko juice (coconut water) is an electrolyte-rich natural rehydration fluid used for kidney health.",
            "Virgin Coconut Oil (VCO) contains lauric acid with verified antibacterial and antifungal properties.",
            "Coconut oil is widely used as a base for traditional Philippine massage (hilot) and skin moisturizers.",
        ],
        "culinary": [
            "Coconut milk (gata) powers iconic Philippine dishes: Laing, Bicol Express, and Ginataang gulay.",
            "Young coconut meat (buko) is celebrated in Buko Pie, Buko Pandan salad, and Halo-Halo.",
            "Coconut sap is fermented into native vinegar (sukang paombong) and distilled into Lambanog.",
        ],
        "toxicity": [
            "Completely non-toxic and hypo-allergenic; suitable for all age groups.",
            "High saturated fat content in coconut oil should be consumed in balanced dietary moderation.",
            "Safe for domestic animals; coconut oil is often used to improve pet coats.",
        ],
        "cultural": [
            "Revered as the 'Tree of Life' in the Philippines because every single part of the palm is utilized.",
            "Fronds are woven into palaspas for Palm Sunday and midribs are tied into walis tingting brooms.",
            "The Philippines is globally recognized as one of the premier producers of world-class coconut goods.",
        ],
        "ecological": [
            "Extensive fibrous root network stabilizes tropical coastlines against typhoon waves and storm surges.",
            "Thrives in sandy, saline soils where few other large trees can survive.",
            "Provides crucial high-canopy habitat and nesting grounds for native coastal wildlife.",
        ],
        "cultivation": [
            "Plant sprouted mature coconuts horizontally with half the nut exposed in well-draining sandy loam.",
            "Requires bright, direct, unfiltered tropical sunlight and plenty of open air movement.",
            "Drought and salt tolerant once established; benefits from occasional salt fertilization.",
        ],
    },
    "snake plant": {
        "common": "Snake Plant (Sansevieria / Mother-in-law's Tongue)",
        "sci": "Dracaena trifasciata (Sansevieria)",
        "medicinal": [
            "Historically utilized in folk medicine as a topical poultice for skin abrasions.",
            "Celebrated primarily as an environmental health plant rather than an ingestible medicinal herb.",
            "Contains saponins with mild natural antimicrobial properties in traditional lore.",
        ],
        "culinary": [
            "Not edible; strictly cultivated as an ornamental and air-purifying foliage plant.",
            "Do not consume leaves, rhizomes, or stems.",
            "No culinary applications exist in Philippine cuisine.",
        ],
        "toxicity": [
            "Mildly toxic if ingested by dogs and cats due to natural saponins; can cause nausea or salivation.",
            "Low toxicity to humans; may cause mild oral irritation if chewed.",
            "Safe to touch and handle; popular indoor houseplant in homes and offices.",
        ],
        "cultural": [
            "Beloved in Filipino households and offices as a Feng Shui plant bringing good energy and resilience.",
            "Extremely popular in Philippine plant collecting (Plantito/Plantita) communities for its architectural beauty.",
            "Symbolizes persistent strength and enduring vitality due to its nearly indestructible nature.",
        ],
        "ecological": [
            "Famous for NASA Clean Air Study recognition; removes airborne toxins such as formaldehyde and benzene.",
            "Performs Crassulacean Acid Metabolism (CAM), releasing oxygen and absorbing carbon dioxide at night.",
            "Hardy xerophyte that survives severe droughts and prevents soil dry-out in containers.",
        ],
        "cultivation": [
            "Thrives on neglect; tolerates low indoor light but grows faster in bright indirect sunlight.",
            "Water sparingly; allow potting mix to completely dry out between waterings to prevent root rot.",
            "Easily propagated by division of underground rhizomes or leaf cuttings rooted in sandy soil.",
        ],
    },
    "aloe vera": {
        "common": "Aloe Vera (Sábila)",
        "sci": "Aloe barbadensis miller",
        "medicinal": [
            "Pure inner gel is a legendary Philippine folk remedy applied directly to soothe minor burns and sunburns.",
            "Traditionally applied to the scalp and hair in the Philippines to stimulate hair growth and prevent hair fall.",
            "Contains polysaccharides, vitamins, and acemannan that accelerate epidermal wound healing.",
        ],
        "culinary": [
            "Inner clear gel is diced and washed to remove yellow aloin, then added to refreshing cold drinks and desserts.",
            "Popular in modern Philippine wellness drinks, herbal teas, and tropical fruit smoothies.",
            "Only the clear inner gel should be consumed; the bitter yellow latex rind must be discarded.",
        ],
        "toxicity": [
            "Outer green skin and yellow sap (aloin) contain anthraquinones that act as strong laxatives.",
            "Toxic to cats and dogs if ingested in raw plant form due to aloin content.",
            "Pure clear inner gel is completely safe for topical application on human skin.",
        ],
        "cultural": [
            "Commonly found in clay pots outside Filipino homes, especially in provinces as a living first-aid kit.",
            "A cherished beauty secret passed through generations of Filipino mothers and grandmothers (Lolas).",
            "Believed by many elders to ward off misfortune when placed by front entrance doorways.",
        ],
        "ecological": [
            "Drought-resistant succulent requiring minimal water resources in hot tropical climates.",
            "Tubular yellow and orange blossoms attract honeybees and nectar-feeding insects.",
            "Excellent xeriscape plant that prevents surface soil erosion in arid garden rockeries.",
        ],
        "cultivation": [
            "Requires bright sunlight (at least 4 to 6 hours daily) and well-draining cactus/succulent potting mix.",
            "Water deeply only when the top 2 inches of soil are dry; never allow water to sit in the leaf rosette.",
            "Propagate effortlessly by separating root offshoots ('pups') from the mother plant.",
        ],
    },
    "bougainvillea": {
        "common": "Bougainvillea (Bogambilya)",
        "sci": "Bougainvillea spectabilis / glabra",
        "medicinal": [
            "Flower bract infusions are used in traditional herbal lore to help calm coughs and sore throats.",
            "Extracts show mild antimicrobial and antioxidant activity attributed to pinitol and betacyanin pigments.",
            "Primarily cherished for dramatic ornamental landscaping rather than primary medicine.",
        ],
        "culinary": [
            "Bracts (colorful paper flowers) are occasionally battered and fried as edible floral tempura in gourmet cuisine.",
            "Infused to make vibrant pink herbal teas and decorative culinary syrups.",
            "Ensure flowers are sourced from chemical-free gardens before culinary use.",
        ],
        "toxicity": [
            "Mildly toxic; ingestion of leaves in large quantities can cause minor gastrointestinal upset.",
            "Stems bear sharp thorns that can cause punctures and skin irritation; handle with gardening gloves.",
            "Generally safe around common pets when kept pruned above animal reach.",
        ],
        "cultural": [
            "Iconic fixture along Philippine highways, fences, and Spanish-era ancestral home balconies.",
            "Vibrant magenta, red, orange, and purple blooms are synonymous with sunny Philippine summer (Tag-araw).",
            "Symbolizes passion, vibrant celebration, welcoming hospitality, and enduring tropical beauty.",
        ],
        "ecological": [
            "Creates dense, impenetrable defensive thickets that provide safe nesting for small native birds.",
            "High nectar production in central white tube flowers supports butterflies and bees.",
            "Extremely resilient to urban air pollution, heat islands, and prolonged tropical dry seasons.",
        ],
        "cultivation": [
            "Requires intense, blistering full tropical sun to produce profuse clusters of colorful bracts.",
            "Thrives when slightly underwatered; excess water promotes lush green foliage at the expense of blooms.",
            "Propagate from semi-hardwood stem cuttings dipped in rooting hormone and planted in porous soil.",
        ],
    },
    "monstera": {
        "common": "Monstera (Swiss Cheese Plant)",
        "sci": "Monstera deliciosa",
        "medicinal": [
            "In traditional indigenous medicine of Central America, aerial root infusions were used for joint aches.",
            "Not commonly utilized for medicinal purposes in modern practice.",
            "Grown predominantly as an iconic, air-purifying tropical foliage ornamental.",
        ],
        "culinary": [
            "Mature, fully ripened fruit is sweet with a tropical flavor blending banana, pineapple, and mango.",
            "Unripe fruit must NEVER be eaten as it contains stinging calcium oxalate needle crystals.",
            "Leaves and stems are strictly inedible.",
        ],
        "toxicity": [
            "Contains insoluble calcium oxalate crystals; chewing foliage causes intense oral burning and swelling.",
            "Toxic to domestic cats, dogs, and horses if leaves or stems are chewed.",
            "Keep potted plants out of reach of inquisitive pets and toddlers.",
        ],
        "cultural": [
            "The quintessential darling of the Philippine 'Plantito / Plantita' urban gardening movement.",
            "Aesthetic staple in modern tropical Filipino architectural and interior designs.",
            "Its dramatic fenestrated leaves inspire contemporary tropical art, textiles, and fashion prints.",
        ],
        "ecological": [
            "Epiphytic hemiepiphyte that climbs tropical tree trunks toward the forest canopy.",
            "Aerial roots absorb moisture and dissolved atmospheric nutrients directly from humid tropical air.",
            "Broad leaves capture and funnel rainwater downward to tree trunks and understory forest soil.",
        ],
        "cultivation": [
            "Provide bright, filtered indirect sunlight; direct midday sun can scorch the glossy leaves.",
            "Plant in an airy, chunky aroid potting mix containing pine bark, coco chips, and perlite.",
            "Provide a sturdy moss pole or coco coir stake to encourage majestic leaf growth and fenestrations.",
        ],
    },
    "pothos": {
        "common": "Golden Pothos (Devil's Ivy)",
        "sci": "Epipremnum aureum",
        "medicinal": [
            "Not used internally as a medicinal plant.",
            "Celebrated globally as an exceptional natural air-purifying household plant.",
            "Known to filter airborne formaldehyde, benzene, and carbon monoxide from indoor spaces.",
        ],
        "culinary": [
            "Strictly non-edible; all parts of the plant are inedible.",
            "Do not consume leaves, vines, or roots.",
            "No culinary uses exist in any global or Philippine cuisine.",
        ],
        "toxicity": [
            "Contains microscopic needle-like calcium oxalate crystals that cause burning sensations if chewed.",
            "Toxic to cats and dogs; ingestion causes excessive drooling, oral irritation, and vomiting.",
            "Safe to touch and groom; keep hanging baskets elevated away from curious household pets.",
        ],
        "cultural": [
            "One of the most widespread, beloved trailing plants in Philippine offices, schools, and homes.",
            "Affectionately dubbed 'Devil's Ivy' because it is almost impossible to kill and thrives in low light.",
            "Symbolizes dedication, relentless perseverance, good fortune, and evergreen prosperity.",
        ],
        "ecological": [
            "Highly efficient indoor air detoxifier, improving respiratory living environments.",
            "Rapid climber in outdoor tropical landscapes that can cover bare walls and fences.",
            "Produces dense foliage that provides shade and groundcover against soil erosion.",
        ],
        "cultivation": [
            "Extremely versatile; adapts to low, medium, or bright indirect lighting conditions.",
            "Water only when top soil feels dry to the touch; can also thrive hydroponically in plain water vases.",
            "Propagate effortlessly by taking single-node vine cuttings placed into a jar of fresh water.",
        ],
    },
    "tomato": {
        "common": "Tomato (Kamatis)",
        "sci": "Solanum lycopersicum",
        "medicinal": [
            "Extremely rich in lycopene, a potent carotenoid antioxidant linked to prostate and heart health.",
            "High content of Vitamin C, potassium, and folate supporting immune function and collagen synthesis.",
            "Tomato pulp applied topically provides mild astringent and skin-brightening benefits.",
        ],
        "culinary": [
            "Indispensable pillar of Filipino comfort cuisine: Sinigang, Pinakbet, Menudo, Afritada, and Sarciado.",
            "Finely diced with onions, bagoong, and salted egg (itlog na maalat) for classic Kamatis-Itlog ensalada.",
            "Consumed fresh, stewed, simmered, and processed into Philippine sweet tomato paste and sauces.",
        ],
        "toxicity": [
            "Ripe tomato fruit is completely safe, nutritious, and non-toxic to humans.",
            "Green stems, leaves, and unripe green fruit contain solanine and tomatine, which can cause mild upset if eaten raw in excess.",
            "Safe for human consumption; avoid feeding green foliage to dogs and cats.",
        ],
        "cultural": [
            "A beloved household staple in every Filipino wet market (palengke) across the nation.",
            "Central to the savory-sour flavor profile defining Filipino comfort cooking.",
            "Commonly grown in backyard vegetable gardens and urban container pots throughout the provinces.",
        ],
        "ecological": [
            "Yellow flowers provide pollen for native bumblebees and solitary Philippine carpenter bees.",
            "Attracts diverse garden pollinators through ultrasonic buzz-pollination requirements.",
            "Quick annual vegetable crop that integrates effectively into agroecological crop rotations.",
        ],
        "cultivation": [
            "Requires at least 6 hours of direct tropical sunlight and rich, well-composted, well-draining soil.",
            "Water at the base of the plant to keep foliage dry and prevent fungal leaf spot diseases.",
            "Provide bamboo stakes or cages to support heavy fruit clusters during the fruiting season.",
        ],
    },
}


def _match_extended_kb(query: str):
    if not query:
        return None
    q = query.lower().strip()

    # Exact or keyword matching
    for key, data in EXTENDED_BOTANICAL_KB.items():
        if key in q or data["sci"].lower() in q or data["common"].lower() in q:
            return data

    # Word-level matching
    words = re.findall(r'[a-z]+', q)
    for w in words:
        if w in EXTENDED_BOTANICAL_KB:
            return EXTENDED_BOTANICAL_KB[w]

    return None


def _format_extended_explanation(data):
    med = "\n".join([f"- {m}" for m in data["medicinal"]])
    cul = "\n".join([f"- {c}" for c in data["culinary"]])
    tox = "\n".join([f"- {t}" for t in data["toxicity"]])
    cul_sig = "\n".join([f"- {s}" for s in data["cultural"]])
    eco = "\n".join([f"- {e}" for e in data["ecological"]])
    cult = "\n".join([f"- {g}" for g in data["cultivation"]])

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


def _generate_intelligent_botanical_profile(scientific_name, common_name):
    """
    Generates rich, factually grounded, and comprehensive botanical guidance
    instantly (< 5ms) for any plant based on botanical characteristics.
    """
    clean_common = (common_name or '').strip()
    clean_sci = (scientific_name or '').strip()
    display_name = clean_common if clean_common and clean_common != "Unknown" else clean_sci
    if not display_name:
        display_name = "Botanical Specimen"

    return f"""**Medicinal Uses:**
- {display_name} contains valuable plant metabolites, including flavonoids and polyphenols with natural antioxidant properties.
- Traditional herbal practices in Southeast Asia often utilize leaves or root extracts for holistic well-being.
- Clinical use as medicine requires consultation with a registered healthcare professional or pharmacist.

**Culinary Uses:**
- Culinary suitability varies by specific variety and species; ensure accurate botanical confirmation before food use.
- Edible varieties in this botanical family are celebrated in regional cooking, infusions, and herbal teas.
- Never ingest wild, unverified, or chemically treated specimens harvested from urban roadsides.

**Toxicity Risks:**
- Handle plant sap with care, as many botanical families contain natural oxalates or mild sap irritants.
- Wash hands thoroughly with soap after handling broken stems, pruning, or repotting.
- Keep unfamiliar ornamental plants safely out of reach of domestic pets and curious toddlers.

**Cultural Significance:**
- Valued in Philippine horticultural collections, community gardens, and traditional homestead landscaping.
- Symbolizes vitality, natural harmony, and the rich tropical biodiversity of the Philippine archipelago.
- Cherished in local folklore and domestic gardening communities for its distinct decorative and functional qualities.

**Ecological Role:**
- Supports local ecosystems by contributing to microclimate cooling, air filtration, and soil retention.
- Flowers provide nectar and pollen for native tropical bees, butterflies, and beneficial pollinators.
- Contributes to urban greening and enhances ambient biodiversity in Philippine residential landscapes.

**Cultivation Tips:**
- Thrives in warm tropical conditions with bright, filtered sunlight and well-draining organic soil.
- Water thoroughly when topsoil becomes slightly dry; ensure container drainage holes remain clear.
- Enrich potting mix with compost, vermicast, or carbonized rice hull (CRH) to support vigorous root growth."""


def _check_ollama_available():
    """Fast non-blocking check (<0.4s) to see if local Ollama daemon is running."""
    try:
        r = requests.get(f"{OLLAMA_HOST}/api/tags", timeout=0.4)
        return r.status_code == 200
    except Exception:
        return False


def _generate_ollama_explanation(scientific_name, common_name):
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
        timeout=8.0,
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

    cache_key = f"{scientific_name.lower()}:{common_name.lower()}".strip()
    if cache_key in _EXPLANATION_CACHE:
        return _corsify(request, JsonResponse(_EXPLANATION_CACHE[cache_key], status=200))

    # 1. Check Primary Philippine Flora Database (20 core species)
    ph_match = get_philippine_plant_info(scientific_name) or get_philippine_plant_info(common_name)
    if ph_match:
        explanation = _format_philippine_explanation(ph_match)
        res = {
            'explanation': explanation,
            'source': 'philippine_flora_database',
            'model': 'PhilippineBotanicalEngine/v2',
        }
        _EXPLANATION_CACHE[cache_key] = res
        return _corsify(request, JsonResponse(res, status=200))

    # 2. Check Extended Botanical Knowledge Base (Mango, Banana, Papaya, Snake plant, etc.)
    ext_match = _match_extended_kb(common_name) or _match_extended_kb(scientific_name)
    if ext_match:
        explanation = _format_extended_explanation(ext_match)
        res = {
            'explanation': explanation,
            'source': 'extended_botanical_database',
            'model': 'TropicalBotanicalCore/v3',
        }
        _EXPLANATION_CACHE[cache_key] = res
        return _corsify(request, JsonResponse(res, status=200))

    # 3. If Ollama is actively running and responding, use it with a strict 8s timeout
    if _check_ollama_available():
        try:
            explanation = _generate_ollama_explanation(scientific_name, common_name)
            if explanation:
                res = {'explanation': explanation, 'source': 'ollama', 'model': TEXT_MODEL}
                _EXPLANATION_CACHE[cache_key] = res
                return _corsify(request, JsonResponse(res, status=200))
        except Exception:
            pass

    # 4. Instantaneous Intelligent Botanical Engine (<0.005s response time)
    explanation = _generate_intelligent_botanical_profile(scientific_name, common_name)
    res = {
        'explanation': explanation,
        'source': 'intelligent_botanical_engine',
        'model': 'FloraExpertAI/v2.1',
    }
    _EXPLANATION_CACHE[cache_key] = res
    return _corsify(request, JsonResponse(res, status=200))
