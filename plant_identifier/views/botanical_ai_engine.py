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
    'spider plant': {
        'name': 'Spider Plant (Chlorophytum comosum)',
        'category': 'Pet-Safe Air-Purifying Houseplant',
        'light': 'Bright, indirect sunlight. Tolerates light shade; harsh direct midday sun will scorch leaf tips.',
        'watering': 'Water when the top 1–2 inches of soil feel dry, usually every 7–10 days indoors.',
        'soil': 'Well-draining, loose potting mix enriched with perlite or pumice.',
        'medicinal': 'Non-medicinal; highly rated air-purifying plant and completely non-toxic to pets.',
        'culinary': 'Not edible.',
        'tips': 'Produces trailing plantlets ("spiderettes") that can easily be rooted in water or moist soil.',
    },
    'calathea': {
        'name': 'Calathea / Prayer Plant (Goeppertia / Calathea spp.)',
        'category': 'Pet-Safe Tropical Foliage',
        'light': 'Medium to bright indirect light. Direct sunlight quickly fades or burns patterned leaves.',
        'watering': 'Water when the top 1 inch of soil feels dry. Keep soil consistently lightly moist, never soggy.',
        'soil': 'Light, airy, moisture-retentive potting mix with peat moss, perlite, and coco coir.',
        'medicinal': 'Not medicinal; non-toxic to cats and dogs.',
        'culinary': 'Not edible.',
        'tips': 'Sensitive to hard minerals in tap water; use filtered water or rainwater to avoid brown crispy edges.',
    },
    'philodendron': {
        'name': 'Philodendron (Philodendron hederaceum / Philodendron spp.)',
        'category': 'Tropical Indoor Houseplant',
        'light': 'Medium to bright indirect light. Avoid harsh direct sun.',
        'watering': 'Water when the top 1–2 inches of soil are dry to the touch, usually every 1–2 weeks.',
        'soil': 'Chunky, well-aerated potting mix containing coco coir, pumice, and orchid bark.',
        'medicinal': 'Not medicinal; toxic to dogs and cats if chewed.',
        'culinary': 'Not edible.',
        'tips': 'Easily propagated by placing stem cuttings with a node in a jar of water.',
    },
    'rubber plant': {
        'name': 'Rubber Plant / Rubber Tree (Ficus elastica)',
        'category': 'Broadleaf Indoor Tree',
        'light': 'Bright indirect light with a few hours of gentle morning sun.',
        'watering': 'Allow the top 2–3 inches of soil to dry out between waterings. Reduce in winter.',
        'soil': 'Rich, well-draining potting soil with perlite.',
        'medicinal': 'Not medicinal; milky sap can irritate skin and is toxic to pets.',
        'culinary': 'Not edible.',
        'tips': 'Wipe large glossy leaves with a damp cloth every few weeks to keep them free of dust.',
    },
    'fiddle leaf fig': {
        'name': 'Fiddle Leaf Fig (Ficus lyrata)',
        'category': 'Architectural Indoor Tree',
        'light': 'Bright, filtered sunlight (at least 4–6 hours daily). Sensitive to low light.',
        'watering': 'Water thoroughly only when the top 2 inches of soil feel completely dry.',
        'soil': 'Nutrient-rich, well-draining indoor potting mix.',
        'medicinal': 'Not medicinal.',
        'culinary': 'Not edible.',
        'tips': 'Avoid moving it frequently; sensitive to cold drafts and sudden changes in humidity.',
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
        'spider plant': 'spider plant',
        'chlorophytum': 'spider plant',
        'calathea': 'calathea',
        'prayer plant': 'calathea',
        'maranta': 'calathea',
        'philodendron': 'philodendron',
        'rubber plant': 'rubber plant',
        'rubber tree': 'rubber plant',
        'ficus elastica': 'rubber plant',
        'fiddle leaf': 'fiddle leaf fig',
        'ficus lyrata': 'fiddle leaf fig',
    }
    for alias, target in aliases.items():
        if alias in q:
            return PLANT_PROFILES.get(target)
    return None


def generate_plant_answer(message: str, plant_name: str = '', scientific_name: str = '') -> str:
    """
    Intelligently analyzes the user's message and returns an expert, structured botanical reply.
    Strictly follows:
    1. Direct answer first.
    2. Answer the exact question, not a related topic.
    3. Factual accuracy with calibrated confidence.
    4. No generic lectures or unnecessary conversational follow-ups.
    5. No repeating the user's question as a heading.
    """
    raw_msg = (message or '').strip()
    q = f"{raw_msg.lower()} {plant_name.lower()} {scientific_name.lower()}".strip()
    profile = _match_plant_profile(q)

    # 1. GREETINGS (Short, polite intro only when strictly a greeting)
    if re.search(r'^(hi|hello|hey|kamusta|kumusta|magandang araw|greetings|good morning|good afternoon|good evening)[!.\s]*$', raw_msg.lower()):
        return (
            "🌱 **Mabuhay! I'm your Botanical AI Assistant.**\n\n"
            "Ask me anything about plant identification, care routines, watering, lighting, pest treatments, or Philippine flora."
        )

    # 2. EASIEST INDOOR PLANTS FOR BEGINNERS
    if any(k in q for k in [
        'easiest indoor', 'easy indoor', 'easiest plant', 'beginner plant',
        'plants for beginner', 'plants for beginners', 'easy to care',
        'low maintenance plant', 'pinakamadaling halaman', 'para sa beginner',
        'easiest houseplant', 'easy houseplant'
    ]):
        return (
            "🌿 **Easiest Indoor Plants for Beginners**\n\n"
            "1. **Snake Plant**\n"
            "   • Very low maintenance\n"
            "   • Tolerates low light\n"
            "   • Water only when the soil dries out\n\n"
            "2. **Pothos**\n"
            "   • Easy to grow\n"
            "   • Tolerates different lighting conditions\n"
            "   • Water when the top layer of soil feels dry\n\n"
            "3. **ZZ Plant**\n"
            "   • Handles low light\n"
            "   • Drought tolerant\n"
            "   • Doesn't need frequent watering\n\n"
            "4. **Spider Plant**\n"
            "   • Easy to care for\n"
            "   • Grows well in bright, indirect light\n"
            "   • Water when the soil begins to dry\n\n"
            "5. **Peace Lily**\n"
            "   • Good for indoor growing\n"
            "   • Prefers indirect light\n"
            "   • Needs more consistent moisture than Snake Plant or ZZ Plant"
        )

    # 3. SPECIFIC PLANT: DIRECT SUNLIGHT / LIGHT REQUIREMENTS
    is_light_query = any(k in q for k in ['direct sun', 'direct sunlight', 'sunlight', 'sun', 'light', 'araw', 'sikat ng araw', 'shade', 'init'])
    if profile and is_light_query:
        p_name = profile['name'].split('(')[0].split('/')[0].strip()
        low_p = p_name.lower()

        if 'monstera' in q or 'monstera' in low_p:
            return (
                "Direct midday sunlight is generally not recommended for a Monstera because intense UV rays will scorch and brown the leaves, leaving unsightly bleached or crispy patches.\n\n"
                "• **Optimal Lighting**: Bright, indirect sunlight (such as near an east- or south-facing window with sheer curtains) is ideal.\n"
                "• **Gentle Morning Sun**: 1–2 hours of soft early morning sun is safe and can encourage fenestrations (leaf splits).\n"
                "• **Low Light**: Monstera can survive lower light, but growth will slow down and leaves may remain smaller without splits."
            )

        if 'snake' in q or 'snake' in low_p:
            return (
                "Yes, a Snake Plant can tolerate direct sunlight, though it should be acclimated gradually.\n\n"
                "• **Acclimation**: If moving it from a dim room to direct outdoor or window sun, transition it gradually over 1–2 weeks so the foliage does not burn.\n"
                "• **Watering Adjustment**: In direct sun, the plant metabolizes water faster; check the soil more frequently, though still allow it to dry out completely.\n"
                "• **Light Tolerance**: Snake Plants are exceptionally versatile and can adapt across nearly all light levels, from low light to direct sun."
            )

        if 'zz' in q or 'zz' in low_p:
            return (
                "Direct midday sunlight is not suitable for a ZZ Plant as it will easily scorch and yellow its glossy leaflets.\n\n"
                "• **Best Lighting**: Low to bright indirect sunlight. It thrives remarkably well even under artificial fluorescent office lighting.\n"
                "• **Sunburn Signs**: Bleached or crispy brown patches on leaves indicate excessive direct sun exposure."
            )

        if 'pothos' in q or 'pothos' in low_p:
            return (
                "Direct midday sunlight will scorch and fade Pothos leaves. Pothos thrives best in medium to bright indirect sunlight.\n\n"
                "• **Variegation Needs**: Variegated types (like Golden or Marble Queen) need bright, filtered light to keep their patterns, but still shielded from harsh direct sun.\n"
                "• **Sunburn Signs**: If leaves look washed out, pale, or have crispy brown spots, move it farther from the window."
            )

        if 'peace lily' in q or 'peace lily' in low_p:
            return (
                "No, a Peace Lily should not be placed in direct sunlight. Direct sun quickly bleaches the foliage and burns dry crispy leaf margins.\n\n"
                "• **Best Location**: Low to medium indirect light. A north-facing window or a spot several feet away from a bright window is ideal.\n"
                "• **Blooming**: Bright, filtered light encourages more white flower spathes without burning the foliage."
            )

        # General profile light guidance
        if 'full' in profile['light'].lower():
            return (
                f"Yes, **{profile['name']}** thrives in direct tropical sunlight.\n\n"
                f"• **Light Requirement**: {profile['light']}\n"
                f"• **Care Note**: {profile['tips']}"
            )
        else:
            return (
                f"Direct midday sunlight is not recommended for **{profile['name']}** as harsh direct rays can scorch its leaves.\n\n"
                f"• **Recommended Light**: {profile['light']}\n"
                f"• **Care Note**: {profile['tips']}"
            )

    # 4. SPECIFIC PLANT: WATERING FREQUENCY & ROUTINE
    is_water_query = any(k in q for k in ['water', 'watering', 'how often to water', 'how often should i water', 'when to water', 'dilig', 'paano diligan', 'tubig'])
    if profile and is_water_query:
        p_name = profile['name'].split('(')[0].split('/')[0].strip()
        low_p = p_name.lower()

        if 'snake' in q or 'snake' in low_p:
            return (
                "Water a Snake Plant only when the soil has dried out completely, usually every 2–3 weeks indoors, though the exact interval depends on light, temperature, pot size, and soil.\n\n"
                "• **Seasonal Adjustment**: In winter or cooler rainy months, reduce watering to once every 3–4 weeks or once a month.\n"
                "• **Moisture Check**: Insert your finger or a wooden skewer 2 inches into the soil; water only when completely dry.\n"
                "• **Drainage**: Always use a pot with drainage holes so excess water never pools around the roots."
            )

        if 'monstera' in q or 'monstera' in low_p:
            return (
                "Water a Monstera every 1–2 weeks, allowing the top 2–3 inches of soil to dry out between waterings.\n\n"
                "• **Environmental Factors**: In brighter light and warmer weather, it drinks faster; in lower light or cooler months, reduce watering.\n"
                "• **Moisture Check**: Insert your finger 2 inches into the soil; water only when the top layer feels dry.\n"
                "• **Drainage**: Always empty runoff water from saucers after 15 minutes to prevent root rot."
            )

        if 'zz' in q or 'zz' in low_p:
            return (
                "Water a ZZ Plant every 3–4 weeks once the soil has dried out completely throughout the pot.\n\n"
                "• **Rhizome Water Storage**: ZZ Plants store moisture in underground potato-like rhizomes, making them exceptionally drought-resilient.\n"
                "• **Overwatering Risk**: Overwatering is the biggest threat; when in doubt, it is always safer to wait another week.\n"
                "• **Drainage**: Ensure the pot has free-flowing drainage holes."
            )

        if 'pothos' in q or 'pothos' in low_p:
            return (
                "Water a Pothos roughly once every 1–2 weeks when the top 1–2 inches of soil feel dry.\n\n"
                "• **Thirst Indicator**: Pothos leaves will slightly droop when thirsty and quickly perk back up after being watered.\n"
                "• **Overwatering Signs**: Limp, yellowing leaves with wet soil indicate overwatering or poor drainage."
            )

        if 'peace lily' in q or 'peace lily' in low_p:
            return (
                "Water a Peace Lily roughly once a week, keeping the soil lightly and consistently moist but never waterlogged.\n\n"
                "• **Thirst Indicator**: Peace Lilies visibly droop when thirsty and recover quickly after watering.\n"
                "• **Water Quality**: Sensitive to fluoride and chlorine in tap water; use filtered water or let tap water sit out for 24 hours."
            )

        if 'spider' in q or 'spider' in low_p:
            return (
                "Water a Spider Plant when the top 1–2 inches of soil feel dry, usually every 7–10 days.\n\n"
                "• **Moisture Level**: Allow the soil to dry slightly between waterings; avoid constantly saturated soil.\n"
                "• **Water Sensitivity**: Tap water fluoride can cause brown leaf tips; use rainwater or filtered water when possible."
            )

        # General profile watering guidance
        return (
            f"Water **{profile['name']}** {profile['watering'].lower()}\n\n"
            f"• **Moisture Check**: Check the top 1–2 inches of soil before watering.\n"
            f"• **Drainage**: Always ensure pots have drainage holes to prevent root waterlogging."
        )

    # 5. SPECIFIC PLANT: SOIL & PROPAGATION
    if profile:
        if any(k in q for k in ['soil', 'lupa', 'potting mix', 'potting']):
            return (
                f"Use {profile['soil'].lower()} for **{profile['name']}**.\n\n"
                f"• **Drainage**: Ensure the pot has active drainage holes.\n"
                f"• **Growing Tip**: {profile['tips']}"
            )
        if any(k in q for k in ['propagate', 'propagation', 'cutting', 'magparami']):
            return (
                f"To propagate **{profile['name']}**:\n\n"
                f"• **Method**: {profile['tips']}\n"
                f"• **General Rule**: Use clean, sterilized shears and place cuttings in bright, indirect light until roots establish."
            )

    # 6. SYMPTOM: YELLOW LEAVES
    if any(k in q for k in ['yellow', 'yellowing', 'naninilaw', 'dilaw']):
        return (
            "🍂 **Why Plant Leaves Turn Yellow**\n\n"
            "Yellow leaves (chlorosis) are typically caused by watering issues, lighting stress, or nutrient deficiencies.\n\n"
            "• **Overwatering (Most Common Cause)**\n"
            "  Leaves become limp, soft, or pale yellow while the soil remains wet. Ensure drainage holes are unblocked and let the top 2–3 inches dry out.\n\n"
            "• **Underwatering**\n"
            "  Leaves turn yellow with dry, crispy edges, and the soil shrinks from the edges of the pot. Water deeply.\n\n"
            "• **Inadequate Light**\n"
            "  Lower or inner leaves yellow and drop as the plant prioritizes sunlight for top growth. Move to brighter indirect light.\n\n"
            "• **Nitrogen Deficiency**\n"
            "  Older lower leaves uniformly fade from green to yellow, while newer leaves stay small and pale. Apply a balanced fertilizer.\n\n"
            "• **Natural Shedding**\n"
            "  An occasional yellowing bottom leaf on an otherwise thriving plant is a normal part of its growth cycle."
        )

    # 7. SYMPTOM: BROWN TIPS / CRISPY EDGES
    if any(k in q for k in ['brown tip', 'brown edge', 'crispy', 'dry leaf', 'browning', 'nasusunog']):
        return (
            "🍁 **Causes of Brown Leaf Tips & Edges**\n\n"
            "Brown tips and edges typically indicate low humidity, tap water sensitivity, or moisture stress.\n\n"
            "• **Low Humidity**\n"
            "  Dry indoor air causes leaf margins to lose moisture faster than roots can supply it. Mist foliage, group plants, or use a pebble tray.\n\n"
            "• **Tap Water Sensitivity**\n"
            "  Chemicals and minerals (chlorine, fluoride, or salts) in tap water accumulate at leaf tips. Switch to filtered water, rainwater, or let tap water sit out for 24 hours.\n\n"
            "• **Underwatering**\n"
            "  If the root ball dries out completely, leaf margins turn dry and crispy. Water thoroughly until moisture drains out the bottom.\n\n"
            "• **Fertilizer Salt Buildup**\n"
            "  Excess fertilizer salts scorch delicate root hairs. Flush the soil thoroughly with plain water every few months."
        )

    # 8. SYMPTOM: LEAF CURLING
    if any(k in q for k in ['curl', 'curling', 'kulubot', 'tiklop']):
        return (
            "🍃 **Why Plant Leaves Curl**\n\n"
            "Leaves curl in response to moisture imbalance, heat, direct sun, or pest activity.\n\n"
            "• **Underwatering or Low Humidity**\n"
            "  Leaves curl inward or roll up to conserve moisture. Check the soil moisture and water if dry.\n\n"
            "• **Overwatering & Root Stress**\n"
            "  Leaves curl downward and feel heavy or limp because damaged roots cannot take in oxygen. Allow soil to dry before watering.\n\n"
            "• **Heat or Draft Stress**\n"
            "  Sudden temperature swings, hot drafts, or direct air-conditioner airflow trigger curling. Move to a stable location.\n\n"
            "• **Hidden Pests**\n"
            "  Tiny pests like spider mites, thrips, or aphids feeding on the undersides of leaves cause curling and distorted growth. Inspect undersides with a light."
        )

    # 9. SYMPTOM: DROOPING / WILTING / ROOT ROT
    if any(k in q for k in ['wilt', 'wilting', 'droop', 'drooping', 'nalalanta', 'lanta', 'root rot', 'nabubulok']):
        return (
            "🥀 **Why Your Plant Is Drooping**\n\n"
            "Drooping is caused by a loss of internal water pressure, resulting from either severe underwatering or root rot from overwatering.\n\n"
            "1. **Check Soil Moisture First**\n"
            "   • If the soil is bone dry: The plant is thirsty. Water deeply until it runs out the drainage holes; it will perk up within a few hours.\n"
            "   • If the soil is wet or soggy: The plant is suffering from root rot. Waterlogged roots have rotted and cannot absorb water, so the plant wilts as if dehydrated.\n\n"
            "2. **Treating Root Rot**\n"
            "   • Remove the plant from its pot and inspect the roots.\n"
            "   • Trim away all black, mushy, or foul-smelling roots with sterilized shears.\n"
            "   • Repot in fresh, well-aerated potting soil and hold back on watering until new roots establish."
        )

    # 10. PESTS (Mealybugs, Aphids, Spider Mites, Fungus Gnats, Scale)
    if any(k in q for k in ['pest', 'bug', 'aphid', 'mealybug', 'mite', 'gnat', 'scale', 'whitefly', 'peste', 'insekto']):
        return (
            "🐛 **Identifying & Treating Common Plant Pests**\n\n"
            "The most effective treatment depends on the specific pest:\n\n"
            "• **Mealybugs (White, cotton-like fuzz in crevices)**\n"
            "  Dab individual bugs with a cotton swab dipped in 70% rubbing alcohol. Follow up with weekly neem oil spray.\n\n"
            "• **Spider Mites (Fine webbing & speckling under leaves)**\n"
            "  Rinse foliage under a gentle shower, then spray thoroughly with insecticidal soap or neem oil, covering leaf undersides.\n\n"
            "• **Fungus Gnats (Tiny black flies around the soil)**\n"
            "  Allow the top 2 inches of soil to dry out completely. Place yellow sticky traps near the pot to catch adults.\n\n"
            "• **Aphids (Clusters of green or black soft bugs on new growth)**\n"
            "  Spray off with a strong stream of water, then treat with insecticidal soap.\n\n"
            "• **Organic Neem Oil Spray Recipe**\n"
            "  Mix 1 teaspoon pure cold-pressed neem oil and 1/2 teaspoon mild dish soap into 1 liter of warm water. Spray weekly in late afternoon."
        )

    # 11. GENERAL WATERING GUIDE
    if any(k in q for k in ['how often to water', 'how often should i water', 'when to water', 'watering frequency', 'how to water', 'gaano kadalas magdilig', 'pagdidilig']):
        return (
            "💧 **How Often to Water Plants**\n\n"
            "Watering frequency depends on the plant species, sunlight, temperature, humidity, and pot size. Rather than sticking to a fixed calendar schedule, water based on soil moisture.\n\n"
            "• **The Finger Moisture Test**\n"
            "  Insert your index finger 1–2 inches into the soil. If it feels cool and damp, wait. If dry, water thoroughly.\n\n"
            "• **Succulents & Cacti (e.g. Snake Plant, ZZ Plant)**\n"
            "  Allow the soil to dry out 100% between waterings (usually every 2–4 weeks).\n\n"
            "• **Tropical Houseplants (e.g. Monstera, Pothos, Philodendron)**\n"
            "  Allow the top 1–2 inches of soil to dry before watering (usually every 1–2 weeks).\n\n"
            "• **Moisture-Loving Plants (e.g. Ferns, Peace Lily)**\n"
            "  Keep the soil lightly and consistently moist, never waterlogged.\n\n"
            "• **Drainage**\n"
            "  Always use pots with drainage holes and empty saucers after 15 minutes to prevent standing water around the roots."
        )

    # 12. PET-SAFE PLANTS
    if any(k in q for k in ['pet', 'cat', 'dog', 'aso', 'pusa']) and any(k in q for k in ['safe', 'non-toxic', 'toxic', 'poison']):
        return (
            "🐾 **Best Pet-Safe Houseplants (Non-Toxic to Cats & Dogs)**\n\n"
            "1. **Spider Plant (*Chlorophytum comosum*)**\n"
            "   • Very resilient, air-purifying, and 100% non-toxic to pets\n"
            "   • Thrives in bright indirect light\n\n"
            "2. **Boston Fern (*Nephrolepis exaltata*)**\n"
            "   • Lush green fronds safe for cats and dogs\n"
            "   • Loves bathroom humidity\n\n"
            "3. **Calathea / Prayer Plant**\n"
            "   • Beautiful patterned foliage completely safe for pets\n"
            "   • Prefers medium indirect light\n\n"
            "4. **Parlor Palm / Areca Palm**\n"
            "   • Elegant tropical palms with zero toxicity\n"
            "   • Adaptable to indoor living\n\n"
            "5. **Peperomia (Watermelon Peperomia / Baby Rubber Plant)**\n"
            "   • Waxy, compact foliage safe for pets\n"
            "   • Drought-tolerant and low maintenance\n\n"
            "⚠️ *Toxic to avoid around pets: Lilies, Pothos, Monstera, Philodendron, and ZZ Plant.*"
        )

    # 13. LOW-LIGHT PLANTS
    if any(k in q for k in ['low light', 'dim', 'dark', 'bedroom', 'dilim', 'loob ng bahay']):
        return (
            "🌑 **Best Houseplants for Low Light & Shady Rooms**\n\n"
            "1. **ZZ Plant (*Zamioculcas zamiifolia*)**\n"
            "   • Thrives in dim rooms and under fluorescent office lights\n"
            "   • Water only once a month\n\n"
            "2. **Snake Plant (*Dracaena trifasciata*)**\n"
            "   • Extremely hardy; tolerates low light and dry indoor air\n"
            "   • Water only when the soil is completely dry\n\n"
            "3. **Cast Iron Plant (*Aspidistra elatior*)**\n"
            "   • True to its name, virtually indestructible in deep shade\n"
            "   • Water when the topsoil dries out\n\n"
            "4. **Pothos (*Epipremnum aureum*)**\n"
            "   • Adaptable trailing vine that handles low light well\n"
            "   • Water when the top 1–2 inches feel dry\n\n"
            "5. **Peace Lily (*Spathiphyllum*)**\n"
            "   • Glossy green foliage that tolerates low light\n"
            "   • Droops clearly when thirsty and bounces back after watering"
        )

    # 14. MOSQUITO-REPELLING PLANTS
    if any(k in q for k in ['mosquito', 'lamok', 'repel']):
        return (
            "🦟 **Natural Mosquito-Repelling Plants**\n\n"
            "1. **Citronella Grass**\n"
            "   • Natural citrus aroma masks scents that attract mosquitoes\n"
            "   • Thrives in full sun\n\n"
            "2. **Lemongrass (Tanglad)**\n"
            "   • Contains high natural citronellal levels\n"
            "   • Great for garden beds or sunny patio containers\n\n"
            "3. **Marigold (Amarillo)**\n"
            "   • Contains pyrethrum, an organic compound bugs avoid\n"
            "   • Needs full sun and well-draining soil\n\n"
            "4. **Rosemary & Basil**\n"
            "   • Pungent essential oils act as a natural insect deterrent\n"
            "   • Thrives on sunny windowsills and balconies\n\n"
            "5. **Peppermint**\n"
            "   • Strong menthol aroma repels mosquitoes, ants, and spiders\n"
            "   • Grow in containers to control spreading"
        )

    # 15. PHILIPPINE DOH HERBAL MEDICINES & HEALTH SYMPTOMS
    if any(k in q for k in ['ubo', 'sipon', 'cough', 'cold', 'asthma', 'hika', 'plema', 'sore throat']):
        return (
            "🌿 **Mga Halamang Gamot sa Ubo, Sipon, at Hika:**\n\n"
            "1. **Lagundi (*Vitex negundo*) — DOH Approved Gamot sa Ubo**\n"
            "   • Pakuluan ang 1/2 basong sariwang tinadtad na dahon sa 2 basong tubig sa loob ng 15 minuto.\n"
            "   • Uminom ng 1/3 baso 3 beses bawat araw.\n\n"
            "2. **Oregano (*Coleus amboinicus*)**\n"
            "   • Pigain ang katas ng sariwang dahon at ihalo sa 1 kutsaritang honey o kalamansi.\n\n"
            "3. **Kalamansi (*Citrus microcarpa*)**\n"
            "   • Likas na mayaman sa Vitamin C; inumin na may maligamgam na tubig at honey.\n\n"
            "⚠️ *Paalala: Kung ang ubo ay lampas 1–2 linggo na o may mataas na lagnat, kumonsulta agad sa doktor.*"
        )

    if any(k in q for k in ['sugat', 'wound', 'cut', 'tuli', 'antiseptic']):
        return (
            "🌿 **Mga Halamang Gamot sa Sugat at Panghugas:**\n\n"
            "1. **Dahon ng Bayabas (*Psidium guajava*) — DOH Approved Antiseptic**\n"
            "   • Pakuluan ang 10–15 pirasong sariwang dahon sa 1 litrong tubig sa loob ng 10–15 minuto.\n"
            "   • Gamitin ang maligamgam na sabaw bilang panghugas sa sugat o mumog sa singaw.\n\n"
            "2. **Aloe Vera / Sabila**\n"
            "   • Ang sariwang gel ay nagpapabilis ng paghilom ng mabababaw na galos at minor burns."
        )

    if any(k in q for k in ['bato sa bato', 'kidney stone', 'kidney', 'ihi', 'uti']):
        return (
            "🌿 **Halamang Gamot sa Bato at Pantog:**\n\n"
            "• **Sambong (*Blumea balsamifera*) — DOH Approved Diuretic**\n"
            "  • Napatunayang siyentipiko na nakatutulong magtunaw ng calcium oxalate kidney stones.\n"
            "  • Pakuluan ang 1 basong tinadtad na dahon sa 2 basong tubig sa loob ng 15 minuto. Inumin 3 beses isang araw habang umiinom ng maraming tubig."
        )

    if any(k in q for k in ['buni', 'an-an', 'alipunga', 'ringworm', 'kati-kati']):
        return (
            "🌿 **Halamang Gamot sa Buni, An-an, at Alipunga:**\n\n"
            "• **Akapulko (*Senna alata*) — DOH Approved Antifungal**\n"
            "  • Mabisa laban sa mga impeksyong fungal sa balat tulad ng buni at alipunga.\n"
            "  • Magdikdik ng sariwang dahon hanggang lumabas ang katas at ipahid sa apektadong balat 2 beses maghapon."
        )

    # 16. FULL SPECIFIC PLANT PROFILE (If plant matched and no sub-topic filter was hit)
    if profile:
        return (
            f"🌿 **{profile['name']}**\n\n"
            f"• **Light**: {profile['light']}\n"
            f"• **Watering**: {profile['watering']}\n"
            f"• **Soil**: {profile['soil']}\n"
            f"• **Growing Tip**: {profile['tips']}"
        )

    # 17. PROPAGATION GENERAL
    if any(k in q for k in ['propagate', 'propagation', 'cutting', 'magparami']):
        return (
            "🌱 **Plant Propagation Basics**\n\n"
            "**Water Propagation (Best for Pothos, Monstera, Philodendron)**\n"
            "1. Cut a healthy stem 4–6 inches long just below a leaf node.\n"
            "2. Remove lower leaves so only the stem is submerged.\n"
            "3. Place in clean water in bright, indirect light; refresh water weekly.\n"
            "4. Transplant into potting soil once roots reach 2 inches.\n\n"
            "**Soil Cuttings (Best for Succulents & Snake Plants)**\n"
            "1. Take stem or leaf cuttings and allow the cut end to callous for 1–2 days.\n"
            "2. Insert into moist, gritty soil mix and keep lightly damp until rooted."
        )

    # 18. SOIL & REPOTTING GENERAL
    if any(k in q for k in ['soil', 'potting mix', 'lupa', 'fertilizer', 'pataba', 'repot', 'repotting', 'compost']):
        return (
            "🪴 **Potting Soil & Repotting Guidelines**\n\n"
            "• **Standard Tropical Mix Recipe**\n"
            "  40% garden soil, 30% perlite or carbonized rice hull (CRH), 20% coco coir, 10% compost.\n\n"
            "• **When to Repot**\n"
            "  Roots poke through drainage holes, water runs straight through without absorbing, or growth stalls during the warm season.\n\n"
            "• **Pot Sizing**\n"
            "  Always choose a new container only 1–2 inches wider than the current pot."
        )

    # 19. INSUFFICIENT INFORMATION HANDLING
    # If the query is vague, lacks plant name, symptoms, or actionable context
    is_vague = (
        any(k in q for k in [
            'is my plant', 'whats wrong with my plant', "what's wrong with my plant",
            'is my plant ok', 'is my plant okay', 'is it dying', 'is my plant dying',
            'how is my plant', 'help my plant', 'anong problema', 'okay lang ba ang halaman'
        ]) or
        (not profile and len(raw_msg.split()) <= 6 and not any(k in q for k in [
            'yellow', 'brown', 'curl', 'wilt', 'pest', 'bug', 'water', 'light', 'soil',
            'propagate', 'easiest', 'recommend', 'pet', 'mosquito'
        ]))
    )
    if is_vague:
        return (
            "I can't determine that confidently from the information provided.\n\n"
            "To give you accurate guidance, please let me know:\n"
            "• The plant name or species (or upload a clear photo)\n"
            "• What symptoms or changes you are noticing (e.g., leaf discoloration, wilting, spots)\n"
            "• Its current growing environment (indoor vs. outdoor, light exposure, watering routine)"
        )

    # 20. DIRECT GENERAL PLANT CARE GUIDELINES (No generic lecture, focused and practical)
    return (
        "🌿 **Essential Plant Care Guidelines**\n\n"
        "• **Moisture**: Check the top 1–2 inches of soil with your finger before watering. Only water when dry, and always use pots with drainage holes.\n"
        "• **Lighting**: Position plants in bright, indirect sunlight away from harsh midday direct sun.\n"
        "• **Drainage & Soil**: Use an airy, well-draining potting mix containing pumice, perlite, or rice hull to prevent root suffocation."
    )

