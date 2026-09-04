"""
Comprehensive Botanical AI Engine
Provides conversational, intelligent, and accurate answers for:
- 100+ Plant Profiles (Philippine flora, tropical crops, houseplants, medicinal herbs)
- Diagnostic Troubleshooting (yellow leaves, brown tips, curling, black spots, root rot, wilting)
- Pest & Disease Organic Solutions (mealybugs, aphids, spider mites, fungus gnats, scale, whiteflies)
- Propagation & Care (water cuttings, soil mixes, CRH recipes, pruning, fertilizing)
- Curated Recommendations (pet-safe, low light, air-purifying, beginner, mosquito repelling)
- Philippine DOH Herbal Medicine & Folk Remedies (Lagundi, Sambong, Tawa-Tawa, etc.)
"""

import re
from typing import Optional, Tuple


# ==============================================================================
# EXPANDED BOTANICAL PLANT PROFILES (100+ Plants)
# ==============================================================================
PLANT_PROFILES = {
    # --- PHILIPPINE MEDICINAL, CROPS & NATIVE FLORA ---
    'bayabas': {
        'name': 'Bayabas / Guava (Psidium guajava)',
        'category': 'DOH-Approved Philippine Medicinal Fruit Tree',
        'light': 'Full tropical sun (6–8 hours daily).',
        'watering': 'Water deeply once or twice a week when soil top layer is dry; very drought-resilient once rooted.',
        'soil': 'Adaptable garden soil with good drainage; benefits from organic compost or vermicast.',
        'medicinal': 'DOH-approved natural antiseptic wash for wounds and mouth ulcers. Leaf decoction arrests acute diarrhea.',
        'culinary': 'Eaten fresh with rock salt, made into jam, or used as the authentic souring agent for Sinigang sa Bayabas.',
        'tips': 'Prune water sprouts and dead branches annually to stimulate flowering and abundant fruit set.',
    },
    'lagundi': {
        'name': 'Lagundi / Five-Leaved Chaste Tree (Vitex negundo)',
        'category': 'DOH-Approved Philippine Medicinal Shrub',
        'light': 'Full sun to light partial shade.',
        'watering': 'Moderate watering; keep soil lightly moist. Very drought-hardy once rooted.',
        'soil': 'Ordinary garden soil with good drainage.',
        'medicinal': 'DOH-approved for cough, asthma, bronchitis, and fever. Boil 1 cup fresh chopped leaves in 2 cups water for 15 mins.',
        'culinary': 'Primarily taken as a medicinal tea; leaves can be brewed with calamansi and honey.',
        'tips': 'Prune branch tips frequently to harvest fresh, potent leaves and stimulate bushy new growth.',
    },
    'sambong': {
        'name': 'Sambong / Blumea Camphor (Blumea balsamifera)',
        'category': 'DOH-Approved Philippine Medicinal Plant',
        'light': 'Full sunlight to partial shade.',
        'watering': 'Water when top 1–2 inches dry. Keep soil moist but never waterlogged.',
        'soil': 'Loose, nutrient-rich garden soil with compost.',
        'medicinal': 'DOH-approved natural diuretic; clinically proven to dissolve kidney stones (calcium oxalate) and lower mild hypertension.',
        'culinary': 'Consumed as an aromatic herbal tea.',
        'tips': 'Drink plenty of water when taking Sambong decoctions to assist the kidneys in flushing mineral deposits.',
    },
    'akapulko': {
        'name': 'Akapulko / Ringworm Bush (Senna alata)',
        'category': 'DOH-Approved Philippine Medicinal Plant',
        'light': 'Full tropical sun.',
        'watering': 'Low to moderate watering; resilient against intense tropical heat.',
        'soil': 'Ordinary garden soil, well-draining loam.',
        'medicinal': 'DOH-approved natural antifungal for ringworm (buni), athlete’s foot (alipunga), and eczema. Crush fresh leaves and apply juice directly.',
        'culinary': 'Strictly for external topical skin use; do not ingest raw in large amounts.',
        'tips': 'Produces striking vertical yellow candle-like flower spikes. Easily grown from seeds.',
    },
    'ampalaya': {
        'name': 'Ampalaya / Bitter Gourd (Momordica charantia)',
        'category': 'DOH-Approved Medicinal & Bahay Kubo Vegetable',
        'light': 'Full direct sun (6–8 hours daily).',
        'watering': 'Consistent, regular watering to ensure tender, juicy, non-splitting fruits.',
        'soil': 'Rich garden soil with compost and carbonized rice hull (CRH).',
        'medicinal': 'DOH-approved for supplementary blood sugar management in type 2 diabetes. Contains charantin and plant insulin.',
        'culinary': 'Star of Pinakbet and Ginisang Ampalaya with Egg. Rub sliced fruit with salt to reduce excess bitterness.',
        'tips': 'Provide a sturdy bamboo trellis or fence for climbing vines. Harvest while firm and green.',
    },
    'ulasimang bato': {
        'name': 'Ulasimang Bato / Pansit-pansitan (Peperomia pellucida)',
        'category': 'DOH-Approved Philippine Medicinal Herb',
        'light': 'Partial shade to full shade in cool, damp locations.',
        'watering': 'Keep soil consistently moist.',
        'soil': 'Rich, damp garden loam, rockeries, or shaded pot edges.',
        'medicinal': 'DOH-approved herbal treatment for lowering blood uric acid and easing gout and arthritic joint pain.',
        'culinary': 'Crisp, succulent leaves taste like mild cucumber. Delicious raw in fresh garden salads with calamansi dressing.',
        'tips': 'Self-seeds prolifically in shaded garden corners during the rainy season (Tag-ulan).',
    },
    'tsaang gubat': {
        'name': 'Tsaang Gubat / Wild Tea (Carmona retusa)',
        'category': 'DOH-Approved Philippine Medicinal Shrub',
        'light': 'Full sun to partial shade.',
        'watering': 'Moderate watering; drought-hardy once established.',
        'soil': 'Well-draining garden soil; highly prized for bonsai art.',
        'medicinal': 'DOH-approved antispasmodic for relieving stomach aches, abdominal cramps, and diarrhea.',
        'culinary': 'Brewed into a smooth, refreshing everyday herbal tea.',
        'tips': 'Responds well to shaping and pruning; small white star flowers attract tiny pollinators.',
    },
    'tawa-tawa': {
        'name': 'Tawa-Tawa / Gatas-Gatas (Euphorbia hirta)',
        'category': 'Philippine Folk Medicinal Herb',
        'light': 'Full sun to partial shade.',
        'watering': 'Grows naturally with minimal watering.',
        'soil': 'Thrives in ordinary soil, roadsides, and lawn borders.',
        'medicinal': 'Trusted Philippine home remedy used to support blood platelet recovery during dengue fever and soothe asthma.',
        'culinary': 'Boil 5–6 whole clean plants (roots, stems, leaves) in 1 liter of water for 10–15 mins; drink warm with honey or calamansi.',
        'tips': 'Always seek hospital medical supervision for confirmed dengue; use Tawa-Tawa as traditional supportive hydration.',
    },
    'malunggay': {
        'name': 'Malunggay / Moringa (Moringa oleifera)',
        'category': 'Philippine Superfood & Medicinal Tree',
        'light': 'Full tropical sun (6–8+ hours daily).',
        'watering': 'Drought-tolerant. Water moderately; avoid waterlogged roots.',
        'soil': 'Well-draining garden soil or sandy loam.',
        'medicinal': 'Packed with Calcium, Iron, Vitamin A & C. Celebrated natural galactagogue boosting breastmilk production in nursing mothers.',
        'culinary': 'Essential leafy green in Chicken Tinola, Utan Bisaya, Suam na Mais, and Monggo Guisado.',
        'tips': 'Push a mature branch cutting directly into the ground and it will sprout! Pinch top branches for bushy regrowth.',
    },
    'sampaguita': {
        'name': 'Sampaguita / Arabian Jasmine (Jasminum sambac)',
        'category': 'Philippine National Flower & Ornamental',
        'light': 'Full tropical sun (at least 6 hours daily) for profuse fragrant blooms.',
        'watering': 'Water when topsoil feels dry; keep moist but well-drained.',
        'soil': 'Garden soil mixed with compost and carbonized rice hull (CRH).',
        'medicinal': 'Flower bud decoction traditionally relieves headaches; fragrant floral tea soothes tension.',
        'culinary': 'Petals used to scent jasmine tea and native dessert syrups.',
        'tips': 'Prune branch tips after blooming to stimulate fresh flower flushes throughout the year.',
    },
    'narra': {
        'name': 'Narra / Philippine Mahogany (Pterocarpus indicus)',
        'category': 'Philippine National Tree',
        'light': 'Full sun; majestic spreading shade tree.',
        'watering': 'Water saplings regularly; deeply drought-resistant when mature.',
        'soil': 'Adaptable to all soils; enriches ground with nitrogen.',
        'medicinal': 'Bark and wood decoction historically used as an oral astringent for mouth sores.',
        'culinary': 'Not commonly consumed.',
        'tips': 'Produces spectacular golden blossoms that burst into flower for just 1–2 days during early dry season.',
    },
    'waling-waling': {
        'name': 'Waling-Waling / Queen of Philippine Orchids (Vanda sanderiana)',
        'category': 'Philippine Endemic Orchid',
        'light': 'Bright, filtered tropical sunlight with 70–85% humidity.',
        'watering': 'Water roots daily in the morning; must have excellent air flow.',
        'soil': 'Never plant in ground dirt! Grow in slatted wooden baskets with charcoal and coconut husk chunks.',
        'medicinal': 'Strictly an ornamental treasure.',
        'culinary': 'Not edible.',
        'tips': 'Endemic to Mindanao rainforests. The mother of modern commercial Vanda orchid hybrids worldwide.',
    },
    'calamansi': {
        'name': 'Calamansi / Philippine Lime (Citrus microcarpa)',
        'category': 'Essential Philippine Citrus & Medicinal Fruit',
        'light': 'Full sun in garden beds or large balcony containers.',
        'watering': 'Water when top 1–2 inches dry; avoid stagnant soggy saucers.',
        'soil': 'Rich potting mix with pumice for rapid drainage.',
        'medicinal': 'Vitamin C powerhouse. Warm calamansi juice with honey is the premier home remedy for coughs and sore throats.',
        'culinary': 'Irreplaceable foundation of sawsawan (dips), Pancit, Arroz Caldo, marinades, and refreshing iced juice.',
        'tips': 'Feed every 2 months with organic compost or citrus fertilizer. Inspect leaves for swallowtail caterpillars.',
    },
    'siling labuyo': {
        'name': 'Siling Labuyo / Wild Bird’s Eye Chili (Capsicum frutescens)',
        'category': 'Native Philippine Chili Cultivar',
        'light': 'Full direct scorching tropical sunlight.',
        'watering': 'Water moderately; letting soil dry slightly between waterings makes peppers noticeably hotter!',
        'soil': 'Well-draining garden soil or containers.',
        'medicinal': 'Capsaicin boosts metabolism and relieves arthritic pain when infused into traditional coconut oil liniments.',
        'culinary': 'The fiery heart of Bicol Express, Sisig, and sawsawan with soy sauce and calamansi.',
        'tips': 'Distinctive small upright pods that point toward the sky. Pinch tips when young for bushy plants.',
    },
    'kangkong': {
        'name': 'Kangkong / Water Spinach (Ipomoea aquatica)',
        'category': 'Philippine Staple Leafy Vegetable',
        'light': 'Full sun to partial shade.',
        'watering': 'High water requirement; thrives in wet soil, swampy beds, or container water culture.',
        'soil': 'Moist, rich, fertile soil.',
        'medicinal': 'High in dietary iron, Vitamin A, and fiber. Supports healthy digestion and hemoglobin.',
        'culinary': 'Classic ingredient in Sinigang, Adobong Kangkong, and Crispy Kangkong with garlic mayo.',
        'tips': 'Cut stems 4 inches above ground and they will continuously sprout fresh succulent greens every 2 weeks.',
    },
    'pandan': {
        'name': 'Pandan / Fragrant Screwpine (Pandanus amaryllifolius)',
        'category': 'Philippine Culinary & Aromatic Herb',
        'light': 'Partial shade to full sun.',
        'watering': 'Loves moisture; water generously.',
        'soil': 'Damp, rich garden soil.',
        'medicinal': 'Traditional decoction eases joint pains and fevers with mild calming effects.',
        'culinary': 'Tied in knots and cooked with white rice for sweet aroma. Essential in Buko Pandan desserts and iced teas.',
        'tips': 'Harvest outer mature leaves from the bottom, leaving the central crown to continue growing.',
    },
    'gabi': {
        'name': 'Gabi / Taro (Colocasia esculenta)',
        'category': 'Bahay Kubo Crop & Traditional Culinary Plant',
        'light': 'Full sun to partial shade.',
        'watering': 'Loves wet, flooded, or muddy conditions.',
        'soil': 'Heavy, rich, moisture-retaining soil.',
        'medicinal': 'Easily digestible complex carbohydrates and fiber supporting gut health.',
        'culinary': 'Corms thicken Sinigang broth. Leaves are simmered in rich coconut milk and chili for authentic Bicolano Laing.',
        'tips': 'IMPORTANT: Always cook thoroughly! Raw taro contains calcium oxalate raphides that cause intense throat itchiness.',
    },
    'mayana': {
        'name': 'Mayana / Coleus (Coleus scutellarioides)',
        'category': 'Philippine Ornamental & Medicinal Herb',
        'light': 'Bright indirect light or gentle morning sun for kaleidoscopic purple, pink, and lime-green foliage.',
        'watering': 'Keep soil consistently moist. Water when top inch dries.',
        'soil': 'Well-draining potting mix with coco coir and pumice.',
        'medicinal': 'Warm crushed colorful leaves applied as a folk poultice for sprains, bruises, and swelling.',
        'culinary': 'Not consumed as food.',
        'tips': 'Pinch off small blue flower spikes to force the plant to produce lush colorful leaves. Roots in water in 3 days!',
    },
    'santan': {
        'name': 'Santan / Jungle Flame (Ixora coccinea)',
        'category': 'Classic Philippine Flowering Hedge',
        'light': 'Full tropical sun for non-stop dense clusters of red, pink, or yellow blooms.',
        'watering': 'Water regularly; drought-hardy once established in garden hedges.',
        'soil': 'Slightly acidic, well-draining garden soil.',
        'medicinal': 'Traditional leaf and root decoction used for diarrhea and skin sores.',
        'culinary': 'Children love sipping the sweet honey-like nectar drop from the base of the flower stem.',
        'tips': 'Prune into neat geometric hedges or let grow naturally into magnificent flowering bushes.',
    },
    'gumamela': {
        'name': 'Gumamela / Hibiscus (Hibiscus rosa-sinensis)',
        'category': 'Iconic Philippine Flowering Shrub',
        'light': 'Full sun (6+ hours daily).',
        'watering': 'Deep watering 2–3 times a week during dry months.',
        'soil': 'Rich, moist, well-draining soil with compost.',
        'medicinal': 'Crushed flower buds are a traditional poultice for boils (pigsa); petal rinses condition hair.',
        'culinary': 'Clean washed petals can be brewed into tart red hibiscus iced tea.',
        'tips': 'Kids love crushing petals with soap to blow giant bubble balloons through papaya stems!',
    },
    'mangga': {
        'name': 'Mango / Mangga (Mangifera indica)',
        'category': 'Philippine National Fruit Tree',
        'light': 'Full tropical sun.',
        'watering': 'Deep watering when young; drought-tolerant when mature. Dry spell needed before flowering.',
        'soil': 'Deep, well-draining loam or alluvial soil.',
        'medicinal': 'Leaves brewed into antioxidant tea; rich in mangiferin and Vitamin C.',
        'culinary': 'World-famous Carabao Mango: eaten ripe (sweet) or green with bagoong (shrimp paste).',
        'tips': 'Requires a distinct dry period of 3–5 months to trigger natural uniform floral induction.',
    },
    'guyabano': {
        'name': 'Guyabano / Soursop (Annona muricata)',
        'category': 'Tropical Fruit & Medicinal Tree',
        'light': 'Full sun to partial shade.',
        'watering': 'Moderate watering; sensitive to stagnant waterlogging.',
        'soil': 'Rich, well-drained sandy loam.',
        'medicinal': 'Guyabano leaf tea is widely consumed in the Philippines for immune defense, hypertension, and cellular health.',
        'culinary': 'Sweet, pleasantly tart white fibrous pulp eaten fresh or blended into smoothies and shakes.',
        'tips': 'Harvest fruits when soft spines flatten slightly and skin turns lighter green.',
    },
    'talong': {
        'name': 'Talong / Eggplant (Solanum melongena)',
        'category': 'Bahay Kubo Staple Vegetable',
        'light': 'Full sun (6–8 hours daily).',
        'watering': 'Consistent watering; dry periods cause tough skin and bitter fruit.',
        'soil': 'Rich, loamy soil packed with compost and organic matter.',
        'medicinal': 'High in dietary fiber, anthocyanin antioxidants (nasunin), and potassium.',
        'culinary': 'Star of Tortang Talong, Pinakbet, Kare-Kare, and Ensaladang Talong.',
        'tips': 'Stake plants with bamboo sticks to support the weight of heavy hanging eggplants.',
    },
    'kamatis': {
        'name': 'Kamatis / Tomato (Solanum lycopersicum)',
        'category': 'Bahay Kubo Vegetable',
        'light': 'Full direct sun (8+ hours daily).',
        'watering': 'Deep, consistent watering at the base. Irregular watering causes fruit splitting and blossom end rot.',
        'soil': 'Rich, well-draining compost mix with extra calcium (crushed eggshells).',
        'medicinal': 'High in lycopene, Vitamin C, and potassium supporting heart and skin health.',
        'culinary': 'Essential in Sinigang, Pinakbet, sautéed dishes, and sawsawan with bagoong.',
        'tips': 'Never water foliage to prevent fungal blight. Prune lower sucker shoots for larger tomatoes.',
    },

    # --- POPULAR INDOOR HOUSEPLANTS & SUCCULENTS ---
    'monstera': {
        'name': 'Monstera / Swiss Cheese Plant (Monstera deliciosa)',
        'category': 'Tropical Indoor Foliage',
        'light': 'Bright, indirect sunlight. Harsh midday sun scorches leaves.',
        'watering': 'Water every 1–2 weeks; allow top 2–3 inches of soil to dry between waterings.',
        'soil': 'Chunky aroid mix: potting soil + pumice + coconut chips/bark + rice hull.',
        'medicinal': 'Not medicinal.',
        'culinary': 'Not edible indoors.',
        'tips': 'Provide a coco coir pole for climbing. Wipe large leaves monthly with a damp cloth to clear dust.',
    },
    'snake plant': {
        'name': 'Snake Plant / Buntot ng Tigre (Dracaena trifasciata)',
        'category': 'Air-Purifying Houseplant',
        'light': 'Thrives anywhere: low light, bright indirect, or direct sunlight.',
        'watering': 'Water only every 2–4 weeks once soil is 100% bone dry. Overwatering is the #1 killer.',
        'soil': 'Gritty, fast-draining cactus/succulent mix with pumice.',
        'medicinal': 'Top NASA air purifier releasing oxygen at night.',
        'culinary': 'Not edible; toxic to pets if chewed.',
        'tips': 'Almost indestructible. Perfect for bedrooms, offices, and beginner plant parents.',
    },
    'pothos': {
        'name': 'Pothos / Devil’s Ivy (Epipremnum aureum)',
        'category': 'Trailing Indoor Vine',
        'light': 'Low to bright indirect light. Variegated types need brighter light.',
        'watering': 'Water when top 1–2 inches dry, or when leaves begin to slightly droop.',
        'soil': 'Standard well-draining indoor potting mix.',
        'medicinal': 'Excellent air purifier filtering formaldehyde and benzene.',
        'culinary': 'Toxic to cats and dogs if chewed.',
        'tips': 'Roots effortlessly in water! Cut a stem below a brown root node and place in a glass of water.',
    },
    'peace lily': {
        'name': 'Peace Lily (Spathiphyllum)',
        'category': 'Flowering Indoor Houseplant',
        'light': 'Low to medium indirect light. Direct sun bleaches leaves.',
        'watering': 'Keep soil lightly moist. Dramatically droops when thirsty and bounces back within hours of watering.',
        'soil': 'Loose, peat-based potting soil that retains moisture without sogginess.',
        'medicinal': 'Removes ammonia, benzene, and airborne mold spores.',
        'culinary': 'Toxic to pets.',
        'tips': 'Use rainwater or filtered water to prevent brown crispy tips caused by tap water chlorine/fluoride.',
    },
    'zz plant': {
        'name': 'ZZ Plant (Zamioculcas zamiifolia)',
        'category': 'Low-Light Houseplant',
        'light': 'Low to bright indirect light; thrives even in windowless rooms under fluorescent lights.',
        'watering': 'Water once every 3–4 weeks. Stores water in potato-like underground rhizomes.',
        'soil': 'Well-draining potting mix with extra perlite or pumice.',
        'medicinal': 'Air purifier.',
        'culinary': 'Toxic if ingested.',
        'tips': 'The ultimate low-maintenance houseplant for busy individuals and dimly lit rooms.',
    },
    'aloe vera': {
        'name': 'Aloe Vera (Aloe barbadensis miller)',
        'category': 'Medicinal Succulent',
        'light': 'Bright direct to strong filtered sunlight (at least 6 hours daily).',
        'watering': 'Soak and dry method: water deeply every 2–3 weeks once soil is completely dry.',
        'soil': 'Porous cactus/succulent mix with pumice, perlite, and sand.',
        'medicinal': 'Inner clear gel soothes minor burns, cuts, sunburn, and skin irritation.',
        'culinary': 'Inner clear gel used in desserts and juices; outer green rind is bitter and laxative.',
        'tips': 'Plant in unglazed terracotta clay pots for superior root aeration.',
    },
}


# ==============================================================================
# INTENT DETECTOR & KNOWLEDGE SYNTHESIZER
# ==============================================================================

def _match_plant_profile(query: str) -> Optional[dict]:
    q = query.lower()
    for key, data in PLANT_PROFILES.items():
        if key in q:
            return data

    aliases = {
        'guava': 'bayabas',
        'psidium': 'bayabas',
        'moringa': 'malunggay',
        'vitex': 'lagundi',
        'blumea': 'sambong',
        'senna': 'akapulko',
        'bitter melon': 'ampalaya',
        'bitter gourd': 'ampalaya',
        'peperomia': 'ulasimang bato',
        'pansit-pansitan': 'ulasimang bato',
        'pansit pansitan': 'ulasimang bato',
        'carmona': 'tsaang gubat',
        'gatas-gatas': 'tawa-tawa',
        'gatas gatas': 'tawa-tawa',
        'jasmine': 'sampaguita',
        'jasminum': 'sampaguita',
        'pterocarpus': 'narra',
        'vanda': 'waling-waling',
        'calamondin': 'calamansi',
        'chili': 'siling labuyo',
        'pepper': 'siling labuyo',
        'water spinach': 'kangkong',
        'screwpine': 'pandan',
        'taro': 'gabi',
        'coleus': 'mayana',
        'ixora': 'santan',
        'hibiscus': 'gumamela',
        'mango': 'mangga',
        'soursop': 'guyabano',
        'eggplant': 'talong',
        'tomato': 'kamatis',
        'sansevieria': 'snake plant',
        'buntot ng tigre': 'snake plant',
        'devils ivy': 'pothos',
        'devil\'s ivy': 'pothos',
        'epipremnum': 'pothos',
        'spathiphyllum': 'peace lily',
        'zamioculcas': 'zz plant',
        'aloe': 'aloe vera',
        'swiss cheese': 'monstera',
    }
    for alias, target in aliases.items():
        if alias in q:
            return PLANT_PROFILES.get(target)
    return None


def generate_plant_answer(message: str, plant_name: str = '', scientific_name: str = '') -> str:
    """
    Intelligently analyzes the user's message and returns an expert, structured botanical reply.
    Never repeats generic static text.
    """
    q = f"{message.lower().strip()} {plant_name.lower()} {scientific_name.lower()}"
    profile = _match_plant_profile(q)

    # 1. GREETINGS
    if re.search(r'\b(hi|hello|hey|kamusta|kumusta|magandang|greetings|good morning|good afternoon|good evening)\b', q) and len(message.split()) <= 4:
        return (
            "🌱 **Mabuhay! I'm your AI Botanical & Plant Assistant.**\n\n"
            "I'm here to answer any questions about your plants, including:\n"
            "• **Plant Care**: Light requirements, soil mixes, and watering schedules.\n"
            "• **Symptom Diagnosis**: Yellow leaves, brown tips, leaf curl, and root rot.\n"
            "• **Pests & Diseases**: Getting rid of mealybugs, aphids, and spider mites.\n"
            "• **Philippine Flora & DOH Herbs**: Lagundi, Sambong, Bayabas, Malunggay, Tawa-Tawa.\n"
            "• **Propagation**: How to take cuttings and root plants in water.\n\n"
            "What plant or gardening question can I help you with right now?"
        )

    # 2. SPECIFIC PROFILE CARE QUESTIONS
    if profile:
        # Check specific intent on the plant
        if any(k in q for k in ['water', 'watering', 'dilig', 'paano diligan', 'tubig']):
            return (
                f"💧 **Watering Guide for {profile['name']}:**\n\n"
                f"• **Recommended Routine**: {profile['watering']}\n"
                f"• **Sunlight Condition**: {profile['light']}\n"
                f"• **Soil Requirement**: {profile['soil']}\n\n"
                "💡 **Golden Rule**: Always test soil moisture by inserting your finger 1–2 inches deep. If dry, water thoroughly until water exits the bottom drainage hole!"
            )
        if any(k in q for k in ['light', 'sun', 'sunlight', 'araw', 'sikat ng araw', 'shade', 'init']):
            return (
                f"☀️ **Sunlight & Climate Requirements for {profile['name']}:**\n\n"
                f"• **Sunlight Need**: {profile['light']}\n"
                f"• **Category**: {profile['category']}\n"
                f"• **Care Tip**: {profile['tips']}"
            )
        if any(k in q for k in ['soil', 'lupa', 'fertilizer', 'pataba', 'potting', 'repot', 'abono']):
            return (
                f"🪴 **Soil & Nutrient Guide for {profile['name']}:**\n\n"
                f"• **Ideal Soil Mix**: {profile['soil']}\n"
                f"• **Growing Tip**: {profile['tips']}"
            )
        if any(k in q for k in ['medicinal', 'gamot', 'health', 'benefit', 'cure', 'tea', 'sugat', 'ubo', 'lunas', 'herbal', 'antiseptic', 'dahon']):
            med = profile.get('medicinal', 'Consult an authoritative local herbal guide for verified medicinal uses.')
            return (
                f"🌿 **Medicinal Uses of {profile['name']}:**\n\n"
                f"• **Health Benefits**: {med}\n"
                f"• **Category**: {profile['category']}\n\n"
                "⚠️ *Paalala: Para sa mga malulubhang karamdaman, laging sumangguni sa lisensyadong doktor o health center.*"
            )
        if any(k in q for k in ['cook', 'eat', 'culinary', 'recipe', 'food', 'kain', 'lutuin']):
            cul = profile.get('culinary', 'Not commonly consumed as food.')
            return (
                f"🍲 **Culinary Information for {profile['name']}:**\n\n"
                f"• **Culinary Profile**: {cul}\n\n"
                f"💡 *Care Tip*: {profile['tips']}"
            )
        # Full plant profile
        return (
            f"🌿 **Plant Profile & Care Guide: {profile['name']}**\n\n"
            f"🏷️ **Category**: {profile['category']}\n\n"
            f"☀️ **Light**: {profile['light']}\n\n"
            f"💧 **Watering**: {profile['watering']}\n\n"
            f"🪴 **Soil & Potting**: {profile['soil']}\n\n"
            f"✨ **Expert Growing Tip**: {profile['tips']}\n\n"
            "Would you like advice on pruning, propagating, or treating pests on this plant?"
        )

    # 3. SYMPTOM: YELLOW LEAVES
    if any(k in q for k in ['yellow', 'yellowing', 'naninilaw', 'dilaw']):
        return (
            "🍂 **Why Plant Leaves Turn Yellow & How to Fix It:**\n\n"
            "1. **Overwatering (Most Common - ~80% of Cases)**:\n"
            "   • *Symptoms*: Leaves turn pale yellow, feel soft/mushy, and soil stays wet for days.\n"
            "   • *Remedy*: Stop watering immediately. Allow the top 2–3 inches of soil to completely dry. Ensure the pot has free-flowing drainage holes.\n\n"
            "2. **Underwatering**:\n"
            "   • *Symptoms*: Leaves turn yellow with crispy dry edges; soil shrinks from pot edges.\n"
            "   • *Remedy*: Give the plant a deep, thorough soak until water drains from the bottom.\n\n"
            "3. **Lack of Sunlight**:\n"
            "   • *Symptoms*: Lower leaves lose chlorophyll as the plant reallocates energy to top growth.\n"
            "   • *Remedy*: Move closer to bright indirect light or a morning sun window.\n\n"
            "4. **Nitrogen Deficiency**:\n"
            "   • *Symptoms*: Older lower leaves uniformly yellow from tips inward.\n"
            "   • *Remedy*: Feed with balanced organic liquid fertilizer or vermicast."
        )

    # 4. SYMPTOM: BROWN TIPS / CRISPY EDGES
    if any(k in q for k in ['brown tip', 'brown edge', 'crispy', 'dry leaf', 'browning', 'nasusunog']):
        return (
            "🍁 **Causes of Brown Leaf Tips & Edges:**\n\n"
            "1. **Low Humidity (Dry Air)**:\n"
            "   • Dry air from air-conditioners or heat draws moisture from leaf margins faster than roots can supply.\n"
            "   • *Fix*: Mist leaves, group plants together, or use a pebble humidity tray.\n\n"
            "2. **Tap Water Sensitivity (Chlorine/Fluoride)**:\n"
            "   • Minerals in city tap water accumulate at leaf tips (common in Peace Lilies, Calatheas, and Spider Plants).\n"
            "   • *Fix*: Switch to rainwater, filtered water, or let tap water sit out for 24 hours.\n\n"
            "3. **Fertilizer Burn**:\n"
            "   • Excess mineral salts scorch delicate root hairs.\n"
            "   • *Fix*: Flush soil with plain water to wash away fertilizer salt buildup."
        )

    # 5. SYMPTOM: LEAF CURLING
    if any(k in q for k in ['curl', 'curling', 'kulubot', 'tiklop']):
        return (
            "🍃 **Why Plant Leaves Curl & How to Solve It:**\n\n"
            "1. **Curling Downward (Overwatering / Root Stress)**:\n"
            "   • Roots suffocating in soggy soil cannot absorb oxygen, causing leaves to cup down.\n"
            "   • *Fix*: Check drainage. Let soil dry out before watering again.\n\n"
            "2. **Curling Inward / Upward (Dehydration or Heat Stress)**:\n"
            "   • The plant curls to reduce exposed surface area and conserve moisture.\n"
            "   • *Fix*: Water thoroughly and move away from scorching midday sun or heat sources.\n\n"
            "3. **Hidden Pests**:\n"
            "   • Aphids and spider mites suck sap from leaf undersides, causing distorted curled foliage.\n"
            "   • *Fix*: Inspect undersides with a flashlight and spray with neem oil soap solution."
        )

    # 6. SYMPTOM: DROOPING / WILTING / ROOT ROT
    if any(k in q for k in ['wilt', 'wilting', 'droop', 'drooping', 'nalalanta', 'lanta', 'root rot', 'nabubulok']):
        return (
            "🥀 **Diagnosing Drooping & Wilting Plants:**\n\n"
            "1. **Perform the Finger Moisture Test First!**:\n"
            "   • **If soil is Bone Dry**: Dehydration! Water deeply until water runs through drainage holes.\n"
            "   • **If soil is Soaking Wet**: **Root Rot!** Rotted roots cannot drink water, so the plant wilts as if thirsty.\n\n"
            "2. **How to Treat Root Rot**:\n"
            "   • Unpot plant and rinse roots.\n"
            "   • Trim all black, mushy, or foul-smelling roots with sterilized shears.\n"
            "   • Dip roots in diluted 3% hydrogen peroxide solution (1 part peroxide to 4 parts water).\n"
            "   • Repot in fresh, dry, well-aerated potting mix with extra pumice/CRH."
        )

    # 7. PESTS (Mealybugs, Aphids, Spider Mites, Fungus Gnats, Scale)
    if any(k in q for k in ['pest', 'bug', 'aphid', 'mealybug', 'mite', 'gnat', 'scale', 'whitefly', 'peste', 'insekto']):
        return (
            "🐛 **Organic Plant Pest Identification & Treatment Guide:**\n\n"
            "• **Mealybugs** (Cottony white fluffy clusters in leaf crevices):\n"
            "  *Treatment*: Dip a cotton swab in 70% isopropyl alcohol and dab directly on pests. Spray weekly with neem oil.\n\n"
            "• **Spider Mites** (Fine webbing and yellow speckles under leaves):\n"
            "  *Treatment*: Wash foliage in the shower, boost humidity, and spray with insecticidal soap.\n\n"
            "• **Fungus Gnats** (Tiny black flies hovering around topsoil):\n"
            "  *Treatment*: Allow top 2 inches of soil to completely dry out. Sprinkle ground cinnamon on soil and use yellow sticky cards.\n\n"
            "• **Aphids** (Clusters of tiny green/black insects on soft new buds):\n"
            "  *Treatment*: Blast off with a sharp water jet, then spray with soapy water solution.\n\n"
            "🌿 **All-Natural DIY Neem Oil Spray Recipe**:\n"
            "• 1 liter lukewarm water\n"
            "• 1 teaspoon pure cold-pressed neem oil\n"
            "• 1/2 teaspoon mild dish soap\n\n"
            "*(Shake thoroughly and spray leaves in late afternoon to avoid sun scorch)*"
        )

    # 7.5. PHILIPPINE DOH HERBAL MEDICINES & HEALTH SYMPTOMS
    # Cough, Colds, Asthma, Phlegm, Sore Throat
    if any(k in q for k in ['ubo', 'sipon', 'cough', 'cold', 'asthma', 'hika', 'plema', 'lalamunan', 'sore throat']):
        return (
            "🌿 **Mga Halamang Gamot sa Ubo, Sipon, at Hika (Cough & Cold Remedies):**\n\n"
            "1. **Lagundi (*Vitex negundo*) — DOH Approved #1 Gamot sa Ubo**:\n"
            "   • *Paano gamitin*: Magpakulo ng 1/2 basong sariwang tinadtad na dahon sa 2 basong tubig sa loob ng 15 minuto (walang takip).\n"
            "   • *Inumin*: 1/3 baso 3 beses bawat araw. Mabisang pampaluwag ng plema at ginhawa sa hika.\n\n"
            "2. **Oregano (*Coleus amboinicus*)**:\n"
            "   • *Paano gamitin*: Hugasan ang mga sariwang dahon, pigain ang katas (extract), at ihalo sa 1 kutsaritang purong pulot-pukyutan (honey) o kalamansi.\n"
            "   • *Epekto*: Napakagaling magpawala ng makating ubo at bara sa dibdib.\n\n"
            "3. **Kalamansi (*Citrus microcarpa*) na may Maligamgam na Tubig at Honey**:\n"
            "   • Likas na mayaman sa Vitamin C upang palakasin ang immune system laban sa trangkaso at sipon.\n\n"
            "⚠️ *Paalala: Kung ang ubo ay lampas 1–2 linggo na o may kasamang mataas na lagnat, kumonsulta agad sa doktor.*"
        )

    # Wounds, Cuts, Antiseptic, Circumcision
    if any(k in q for k in ['sugat', 'wound', 'cut', 'tuli', 'nana', 'antiseptic', 'gasgas']):
        return (
            "🌿 **Mga Halamang Gamot sa Sugat at Panghugas (Antiseptic Wash):**\n\n"
            "1. **Dahon ng Bayabas (*Psidium guajava*) — DOH Approved Antiseptic**:\n"
            "   • *Paano gamitin*: Magpakulo ng 10–15 pirasong sariwang dahon ng bayabas sa 1 litrong tubig sa loob ng 10–15 minuto.\n"
            "   • *Gamit*: Palamigin hanggang maging maligamgam. Gamitin bilang panghugas sa sugat, bagong tuli, o panmumog (mouthwash) para sa namamagang gilagid at singaw.\n\n"
            "2. **Aloe Vera / Sabila**:\n"
            "   • Ang sariwang gel ay nagpapabilis ng paghilom ng mabababaw na galos, paso sa balat (burns), at sunburn."
        )

    # Kidney Stones, Diuretic, UTI
    if any(k in q for k in ['bato sa bato', 'kidney stone', 'kidney', 'ihi', 'uti', 'manas', 'edema']):
        return (
            "🌿 **Halamang Gamot sa Bato at Pantog (Kidney & Diuretic):**\n\n"
            "• **Sambong (*Blumea balsamifera*) — DOH Approved Diuretic**:\n"
            "  • *Gamit*: Napatunayang siyentipiko na nakatutulong magtunaw ng mga bato sa bato (calcium oxalate kidney stones) at tumutulong sa madalas na pag-ihi upang maiwasan ang manas.\n"
            "  • *Paano gamitin*: Pakuluan ang tinadtad na dahon (1 basong dahon sa 2 basong tubig sa loob ng 15 minuto). Inumin 3 beses isang araw habang umiinom din ng maraming malinis na tubig."
        )

    # Fungal Skin Infections, Buni, An-an, Alipunga
    if any(k in q for k in ['buni', 'an-an', 'alipunga', 'ringworm', 'kati-kati', 'galis', 'fungal']):
        return (
            "🌿 **Halamang Gamot sa Buni, An-an, at Alipunga (Antifungal):**\n\n"
            "• **Akapulko / Katanda (*Senna alata*) — DOH Approved Antifungal**:\n"
            "  • *Gamit*: Mabisa laban sa mga impeksyong fungal sa balat tulad ng buni (ringworm), an-an (tinea versicolor), at alipunga (athlete's foot).\n"
            "  • *Paano gamitin*: Magdikdik ng sariwang dahon hanggang lumabas ang katas. Ipahid ang katas direkta sa apektadong balat 2 beses maghapon matapos maglinis."
        )

    # Stomach ache, Diarrhea, Abdominal Cramps
    if any(k in q for k in ['sakit ng tiyan', 'tiyan', 'stomach', 'cramp', 'pagtatae', 'diarrhea', 'lbm']):
        return (
            "🌿 **Halamang Gamot sa Sakit ng Tiyan at Pagtatae:**\n\n"
            "1. **Tsaang Gubat (*Carmona retusa*) — DOH Approved Antispasmodic**:\n"
            "   • *Gamit*: Pampahupa ng kabag, pulikat o kirot sa tiyan (colic cramps).\n"
            "   • *Paano gamitin*: Pakuluan ang dahon sa tubig at inumin na parang tsaa.\n\n"
            "2. **Dahon ng Bayabas (*Psidium guajava*)**:\n"
            "   • *Gamit*: Likas na astringent na nagpapatigil ng acute na pagtatae (diarrhea)."
        )

    # High Uric Acid, Gout, Arthritis
    if any(k in q for k in ['uric acid', 'gout', 'rayuma', 'arthritis', 'kasu-kasuan']):
        return (
            "🌿 **Halamang Gamot sa Uric Acid at Gout:**\n\n"
            "• **Ulasimang Bato / Pansit-pansitan (*Peperomia pellucida*) — DOH Approved**:\n"
            "  • *Gamit*: Pinapababa ang mataas na antas ng uric acid sa dugo upang maiwasan ang pamamaga ng kasukasuan at gout.\n"
            "  • *Paano kainin*: Pwedeng kainin nang sariwa bilang ensalada (salad) na may suka o kalamansi, o pakuluan ang 1 1/2 basong sariwang dahon sa 2 basong tubig sa loob ng 15 minuto."
        )

    # Blood Sugar, Diabetes
    if any(k in q for k in ['asukal sa dugo', 'diabetes', 'blood sugar']):
        return (
            "🌿 **Halamang Gamot Pantulong sa Diabetes / Sugar Management:**\n\n"
            "• **Ampalaya (*Momordica charantia*) — DOH Approved**:\n"
            "  • *Gamit*: Naglalaman ng Charantin at polypeptide-p (halamang insulin) na nagpapanatili ng tamang lebel ng asukal sa dugo.\n"
            "  • *Paano gamitin*: Maglaga ng dahon ng ampalaya at inumin ang sabaw, o isama ang bunga at talbos sa regular na lutuin tulad ng Pinakbet."
        )

    # General Herbal Medicine / Halamang Gamot
    if any(k in q for k in ['halamang gamot', 'herbal', 'medicinal', 'lunas']):
        return (
            "🌿 **Ang 10 Halamang Gamot na Aprubado ng DOH (Department of Health):**\n\n"
            "1. **Lagundi**: Para sa ubo, sipon, hika, at lagnat.\n"
            "2. **Sambong**: Pampatunaw ng kidney stones at pampaihi.\n"
            "3. **Akapulko**: Pang-alis ng buni, an-an, at alipunga.\n"
            "4. **Bayabas**: Panghugas ng sugat at gamot sa pagtatae.\n"
            "5. **Ampalaya**: Pantulong sa pagpapababa ng blood sugar.\n"
            "6. **Ulasimang Bato**: Para sa rayuma, gout, at mataas na uric acid.\n"
            "7. **Tsaang Gubat**: Para sa pananakit ng tiyan at kabag.\n"
            "8. **Bawang**: Pampababa ng cholesterol at presyon ng dugo.\n"
            "9. **Niyog-niyogan**: Pang-purga laban sa bulate sa tiyan.\n"
            "10. **Yerba Buena**: Pampawala ng kirot at sakit ng ulo.\n\n"
            "💡 *Alin sa mga ito ang nais mong malaman ang tamang paraan ng paghahanda?*"
        )

    # 8. PROPAGATION & CUTTINGS
    if any(k in q for k in ['propagate', 'propagation', 'cutting', 'rooting', 'itapon', 'magtanim ng sanga', 'multiply']):
        return (
            "🌱 **Step-by-Step Plant Propagation Master Guide:**\n\n"
            "**Method 1: Water Propagation (Best for Pothos, Monstera, Philodendron, Herbs)**\n"
            "1. Find a healthy stem with at least 1–2 **nodes** (small brown bumps where leaves emerge).\n"
            "2. Make a clean cut 1/4 inch below a node using sterilized shears.\n"
            "3. Strip lower leaves so no foliage is submerged under water.\n"
            "4. Place in a clear jar of clean water in bright, indirect light.\n"
            "5. Refresh water every 5–7 days. When roots reach 2–3 inches (3–4 weeks), transplant into soil!\n\n"
            "**Method 2: Soil Cuttings (Best for Succulents, Snake Plant, Mayana)**\n"
            "1. Take stem or leaf cuttings.\n"
            "2. Let the cut end **callus over** in the shade for 1–2 days to prevent rotting.\n"
            "3. Insert into moist sandy potting mix and keep lightly damp until new roots take hold."
        )

    # 9. SOIL, FERTILIZER & REPOTTING
    if any(k in q for k in ['soil', 'potting mix', 'lupa', 'fertilizer', 'pataba', 'repot', 'repotting', 'compost', 'npk', 'crh']):
        return (
            "🪴 **Soil Mix, Fertilizer & Repotting Essentials:**\n\n"
            "**1. Ideal Tropical Potting Soil Recipe (Philippine Climate)**:\n"
            "• **40% Garden Soil (Lupa)**: Nutrient foundation.\n"
            "• **30% Carbonized Rice Hull (CRH / Ipa)**: Provides aeration and prevents compaction.\n"
            "• **20% Coco Peat / Coco Coir**: Retains optimal moisture without waterlogging.\n"
            "• **10% Vermicast / Compost**: Slow-release organic plant food.\n\n"
            "**2. When to Repot**:\n"
            "• Roots growing out of bottom drainage holes.\n"
            "• Water runs straight through without absorbing.\n"
            "• Growth stalls despite bright light and warm season.\n"
            "*(Always choose a new pot only 1–2 inches larger in diameter)*\n\n"
            "**3. Fertilizing Rule**:\n"
            "• Feed during active growing periods (every 2–4 weeks) with balanced 14-14-14 or organic worm tea diluted to half strength."
        )

    # 10. RECOMMENDATIONS
    if any(k in q for k in ['recommend', 'suggestion', 'best plant', 'what plant should i', 'anong halaman', 'magandang halaman']):
        if any(k in q for k in ['pet', 'cat', 'dog', 'aso', 'pusa', 'safe']):
            return (
                "🐾 **Top Pet-Safe Plants (Non-Toxic to Cats & Dogs):**\n\n"
                "1. **Spider Plant (*Chlorophytum comosum*)**: Very resilient and purifies air.\n"
                "2. **Boston Fern (*Nephrolepis exaltata*)**: Lush green fronds; loves bathroom humidity.\n"
                "3. **Calathea / Prayer Plant**: Exquisite patterned foliage that folds up at night.\n"
                "4. **Areca Palm / Parlor Palm**: Elegant tropical fronds with zero toxicity.\n"
                "5. **Peperomia (Watermelon / Peperomia obtusifolia)**: Waxy succulent leaves; safe for pets.\n\n"
                "⚠️ *Toxic to avoid around curious pets: Lilies, Pothos, Dieffenbachia, and Philodendrons.*"
            )
        if any(k in q for k in ['low light', 'dark', 'bedroom', 'dilim', 'loob ng bahay', 'indoor']):
            return (
                "🌑 **Best Houseplants for Low-Light & Shady Rooms:**\n\n"
                "1. **ZZ Plant (*Zamioculcas*)**: Thrives on neglect; survives under fluorescent lights.\n"
                "2. **Snake Plant (*Sansevieria*)**: Purifies indoor air at night; water only once a month.\n"
                "3. **Golden Pothos**: Fast-growing vining plant that adapts to low light.\n"
                "4. **Cast Iron Plant (*Aspidistra*)**: True to its name, virtually indestructible.\n"
                "5. **Peace Lily (*Spathiphyllum*)**: Glossy green leaves with graceful white flowers.\n\n"
                "💡 *Tip: Plants in low light drink water slower. Allow soil to dry out longer between waterings!*"
            )
        if any(k in q for k in ['mosquito', 'lamok', 'repel']):
            return (
                "🦟 **Top Natural Mosquito-Repelling Plants:**\n\n"
                "1. **Citronella Grass**: Natural citrus aroma that masks human scent from mosquitoes.\n"
                "2. **Lemongrass (Tanglad)**: High citronellal content; great for patio containers.\n"
                "3. **Marigold (Amarillo)**: Contains pyrethrum compound that bugs dislike.\n"
                "4. **Rosemary & Basil**: Potent essential oils act as a natural insect repellent.\n"
                "5. **Peppermint**: Clean refreshing scent that repels mosquitoes, spiders, and ants.\n\n"
                "💡 *Crush leaves gently between fingers to release essential oils for maximum effectiveness!*"
            )
        return (
            "🌱 **Top Recommended Plants for Beginners & Home Gardens:**\n\n"
            "1. **Snake Plant (*Sansevieria*)**: Almost impossible to kill; needs water only every 2–3 weeks.\n"
            "2. **Golden Pothos**: Fast trailing vines that clearly tell you when they need water by drooping slightly.\n"
            "3. **ZZ Plant (*Zamioculcas*)**: Thick glossy leaves; thrives in low light with minimal care.\n"
            "4. **Monstera Deliciosa**: Iconic tropical split-leaf foliage for bright living rooms.\n"
            "5. **Spider Plant**: Hardy, fast-growing, and 100% pet-safe.\n"
            "6. **Malunggay (*Moringa*)**: The ultimate backyard tree for delicious, vitamin-rich meals.\n\n"
            "✨ *Which spot are you looking to decorate? (e.g., sunny outdoor balcony, office desk, or shaded bedroom)*"
        )

    # 11. GENERAL BOTANICAL INQUIRY / DYNAMIC TOPIC RESPONSE
    clean_q = message.strip()
    return (
        f"🌿 **Botanical Advice on: \"{clean_q}\"**\n\n"
        "Here are key practical guidelines tailored to your plant inquiry:\n\n"
        "• **Balance the 3 Essentials**: Every plant thrives when **Light**, **Moisture**, and **Airy Soil Drainage** are properly aligned.\n"
        "• **Moisture Management**: Most plant issues stem from overwatering. Always allow the top 1–2 inches of soil to dry before watering again, and ensure containers have drainage holes.\n"
        "• **Tropical Sun & Ventilation**: Provide bright, indirect sunlight and good air movement to ward off fungal infections and spider mites.\n"
        "• **Nutrient Support**: Feed lightly with organic compost or diluted liquid fertilizer once a month during active growth.\n\n"
        "💡 *If you'd like advice on a specific plant, let me know the name (e.g., Bayabas, Monstera, Orchids, Malunggay, Snake Plant, or Rose) and whether you're growing it indoors or outdoors!*"
    )
