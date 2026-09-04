# plant_identifier/views/philippine_plants_data.py
import re

"""
Comprehensive Philippine Flora & Botanical Knowledge Base
Includes:
- Official DOH Approved Herbal Medicine Plants (10 Philippine Medicinal Plants & Common Herbal Remedies)
- Native & Endemic Trees of the Philippines (Narra, Molave, Banaba, Katmon, Kamagong, etc.)
- Iconic Philippine Flowers & Ornamentals (Sampaguita, Waling-Waling, Gumamela, Santan, Mayana, etc.)
- Bahay Kubo Vegetables & Philippine Agricultural Crops (Malunggay, Ampalaya, Kangkong, Siling Labuyo, Gabi, etc.)
- Tropical Philippine Fruits & Palms (Mangga, Calamansi, Bayabas, Guyabano, Niyog, etc.)
"""

PHILIPPINE_PLANTS = [
    # --------------------------------------------------------------------------
    # 1. NATIONAL SYMBOLS & ICONIC PHILIPPINE PLANTS
    # --------------------------------------------------------------------------
    {
        "index": 1,
        "species_id": 100001,
        "common_name": "Sampaguita (Arabian Jasmine)",
        "local_name": "Sampaguita / Kampupot",
        "scientific_name": "Jasminum sambac (L.) Aiton",
        "category": "Philippine National Flower & Ornamental",
        "medicinal_uses": [
            "Decoction of flower buds is traditionally used in the Philippines to relieve headaches and fevers.",
            "Crushed fresh flowers applied as a cooling poultice on sprains and skin ulcers.",
            "Infused as a fragrant herbal tea with calming and anti-inflammatory properties.",
        ],
        "culinary_uses": [
            "Flower petals used to scent and flavor premium green teas and Philippine jasmine tea.",
            "Infused into native syrups, herbal syrups, and gourmet Philippine floral desserts.",
            "Used to flavor floral-infused refreshing cold drinks and sorbet.",
        ],
        "toxicity_risks": [
            "Non-toxic to humans, cats, and dogs when consumed in standard culinary amounts.",
            "Avoid using flowers sprayed with synthetic chemical pesticides or commercial flower-shop preservatives.",
            "People with severe pollen allergies should handle blooms gently.",
        ],
        "cultural_significance": [
            "Declared the National Flower of the Philippines in 1934 by Governor-General Frank Murphy.",
            "Strung into fragrant white garlands (leis) offered at religious altars, graduations, and to honor guests.",
            "Symbolizes purity, simplicity, fidelity, humility, and strength in Filipino culture.",
        ],
        "ecological_role": [
            "Attracts native Philippine pollinators including honeybees, hawk moths, and tropical butterflies.",
            "Thrives in tropical lowlands and provides nectar in urban and suburban gardens.",
            "Hardy perennial shrub well adapted to Philippine tropical sun and rainy seasons.",
        ],
        "cultivation_tips": [
            "Requires full sun (at least 6 hours daily) for profuse, fragrant white blooms.",
            "Plant in well-draining garden soil enriched with compost and carbonized rice hull (CRH).",
            "Water regularly during dry season (Tag-araw); prune tips after blooming to stimulate bushy branches.",
        ],
    },
    {
        "index": 2,
        "species_id": 100002,
        "common_name": "Narra (Philippine Red Mahogany)",
        "local_name": "Narra / Asana",
        "scientific_name": "Pterocarpus indicus Willd.",
        "category": "Philippine National Tree & Native Timber",
        "medicinal_uses": [
            "Bark and young wood decoctions traditionally used as astringent for mouth ulcers and throat gargles.",
            "Young leaf infusions historically consumed in folk medicine for kidney and bladder health.",
            "Rich in polyphenolic antioxidants and mild antimicrobial natural compounds.",
        ],
        "culinary_uses": [
            "Young leaves and tender flowers are occasionally blanched and eaten in local rural cuisine.",
            "Not commonly utilized for everyday culinary cooking.",
            "Pecan-like seeds require proper boiling and preparation before traditional consumption.",
        ],
        "toxicity_risks": [
            "Generally safe and non-toxic; wood extracts should be used in moderation.",
            "Avoid ingestion of untreated raw bark in excessive amounts.",
            "Sawdust from furniture processing can irritate respiratory passages.",
        ],
        "cultural_significance": [
            "The official National Tree of the Philippines, celebrated for strength and durability.",
            "Prized for high-grade indigenous woodworking, heirloom furniture, and musical instruments.",
            "Spectacular golden-yellow blossoms erupt in mass for only 1–2 days during early summer.",
        ],
        "ecological_role": [
            "Nitrogen-fixing native legume tree that restores fertility to degraded Philippine forest soils.",
            "Provides vital canopy shelter and nesting habitats for endemic Philippine birds.",
            "Helps prevent soil erosion on riverbanks, hillsides, and watershed sanctuaries.",
        ],
        "cultivation_tips": [
            "Propagate from seeds or hardwood branch cuttings placed directly into moist soil.",
            "Needs expansive space in full tropical sunlight; grows into a majestic spreading shade tree.",
            "Resistant to strong monsoon winds and adapts well to both clay and sandy Philippine soils.",
        ],
    },
    {
        "index": 3,
        "species_id": 100003,
        "common_name": "Waling-Waling (Queen of Philippine Orchids)",
        "local_name": "Waling-Waling",
        "scientific_name": "Vanda sanderiana (Rchb.f.) Rchb.f.",
        "category": "Philippine Endemic Orchid",
        "medicinal_uses": [
            "Strictly an ornamental treasure; rarely used for medicinal applications.",
            "Some traditional practices use leaf sap as a mild topical soothing wash.",
            "Cherished as a living botanical gem rather than a consumed herb.",
        ],
        "culinary_uses": [
            "Not used for human culinary consumption.",
            "Edibility is not established; do not eat flowers or foliage.",
            "Preserve blooms for their extraordinary visual elegance.",
        ],
        "toxicity_risks": [
            "Non-toxic to domestic pets (cats and dogs).",
            "Keep out of reach of pets to protect rare flower spikes from damage.",
            "Do not ingest commercial plant food or growth fertilizers.",
        ],
        "cultural_significance": [
            "Revered as the 'Queen of Philippine Orchids' and worshipped as a deity ('Diwata') by the indigenous Bagobo people.",
            "Endemic to the lush rainforests of Davao, Cotabato, and Zamboanga in Mindanao.",
            "A global icon of Philippine biodiversity and mother to many modern commercial Vanda hybrids.",
        ],
        "ecological_role": [
            "Epiphyte that perches high upon massive dipterocarp canopy trees in Mindanao rainforests.",
            "Relies on native tropical forest bees for intricate orchid pollination.",
            "An umbrella species whose habitat conservation protects entire forest ecosystems.",
        ],
        "cultivation_tips": [
            "Never plant in ground dirt! Grow suspended in wooden slatted baskets with coarse charcoal and coconut husk.",
            "Provide bright, filtered tropical sunlight with 70–85% humidity and abundant fresh breeze.",
            "Water roots thoroughly every morning with clean rainwater; mist foliage during scorching hot afternoons.",
        ],
    },

    # --------------------------------------------------------------------------
    # 2. DOH-APPROVED PHILIPPINE MEDICINAL PLANTS
    # --------------------------------------------------------------------------
    {
        "index": 4,
        "species_id": 100004,
        "common_name": "Lagundi (Five-Leaved Chaste Tree)",
        "local_name": "Lagundi / Dangla",
        "scientific_name": "Vitex negundo L.",
        "category": "DOH-Approved Philippine Medicinal Plant",
        "medicinal_uses": [
            "Officially approved by the Philippine Department of Health (DOH) for cough, asthma, bronchitis, and fever.",
            "Contains natural chrysoplenol D and antihistaminic flavonoids that relax bronchial airways.",
            "Boil fresh chopped leaves (1 cup in 2 cups water for 15 mins) as an expectorant tea.",
        ],
        "culinary_uses": [
            "Leaves have a sharp aromatic herbal taste; primarily taken as a medicinal tea.",
            "Young tender shoot leaves occasionally added to native savory broths in regional folklore.",
            "Infused with honey and calamansi for natural throat-soothing herbal drinks.",
        ],
        "toxicity_risks": [
            "Safe for adults and children when prepared according to DOH recommended dosage guidelines.",
            "Consult a physician if cough persists for more than 7 days or is accompanied by high fever.",
            "Pregnant or nursing mothers should seek medical advice before regular use.",
        ],
        "cultural_significance": [
            "The premier breakthrough success of Philippine herbal pharmacology (formulated into DOH-certified syrups and tablets).",
            "A staple home remedy grown in almost every backyard and barangay health center across the archipelago.",
            "Valued by generations of Filipino herbolarios (traditional healers).",
        ],
        "ecological_role": [
            "Hardy native shrub that thrives in disturbed soils, riverbeds, and open lowlands.",
            "Purple flower panicles provide continuous nectar for native bees and butterflies.",
            "Naturally pest-resistant and aids in stabilizing garden borders.",
        ],
        "cultivation_tips": [
            "Extremely easy to grow from stem cuttings planted in standard garden soil.",
            "Requires full sunlight and moderate watering; highly resilient once root system is established.",
            "Prune branches regularly to stimulate fresh, potent new leaf flushes for harvesting.",
        ],
    },
    {
        "index": 5,
        "species_id": 100005,
        "common_name": "Sambong (Blumea Camphor)",
        "local_name": "Sambong / Subusub",
        "scientific_name": "Blumea balsamifera (L.) DC.",
        "category": "DOH-Approved Philippine Medicinal Plant",
        "medicinal_uses": [
            "DOH-approved diuretic and clinically proven treatment for dissolution of kidney stones (urolithiasis).",
            "Helps lower mild hypertension by promoting natural fluid and sodium excretion through urine.",
            "Crushed warm leaves applied on the forehead to alleviate tension headaches and sinusitis.",
        ],
        "culinary_uses": [
            "Leaves are strongly aromatic with a natural camphoraceous taste, consumed as herbal medicinal tea.",
            "Not commonly used as a food vegetable due to high essential oil concentration.",
            "Often steeped with lemongrass (tanglad) for a soothing herbal steam or tea.",
        ],
        "toxicity_risks": [
            "Individuals with severe kidney failure or taking prescription diuretics must consult a nephrologist.",
            "Ensure adequate daily water hydration while drinking Sambong decoctions.",
            "Safe and well-tolerated at standard therapeutic dosages.",
        ],
        "cultural_significance": [
            "Recognized by modern Philippine scientific medicine and commercialized into national herbal tablets.",
            "A cornerstone of traditional Visayan and Tagalog folkloric wellness systems.",
            "Grown as a staple health garden plant in Philippine rural communities.",
        ],
        "ecological_role": [
            "Pioneer tropical shrub that naturally regenerates in open grasslands and upland clearings.",
            "Strong aromatic terpenes deter harmful garden pests and leaf-eating caterpillars.",
            "Provides vital ground cover in rural agricultural areas.",
        ],
        "cultivation_tips": [
            "Loves full sun or partial shade with moist, loose garden loam.",
            "Easily multiplied through root suckers, side shoots, or stem cuttings.",
            "Harvest mature green leaves in the morning and air-dry in the shade for optimal potency.",
        ],
    },
    {
        "index": 6,
        "species_id": 100006,
        "common_name": "Akapulko (Ringworm Bush / Candle Bush)",
        "local_name": "Akapulko / Katanda / Bayabas-bayabasan",
        "scientific_name": "Senna alata (L.) Roxb.",
        "category": "DOH-Approved Philippine Medicinal Plant",
        "medicinal_uses": [
            "DOH-approved natural antifungal remedy for ringworm (buni), athlete's foot (alipunga), and eczema (tinea versicolor).",
            "Crush fresh mature leaves to express green juice and apply topically to affected skin twice daily.",
            "Contains chrysophanic acid, a powerful, clinically proven natural antifungal agent.",
        ],
        "culinary_uses": [
            "Not used in food preparation; strictly used for external topical herbal medicine.",
            "Seeds and strong root extracts have potent laxative properties in traditional medicine.",
            "Do not consume raw leaves in large quantities.",
        ],
        "toxicity_risks": [
            "For external topical skin application; do not ingest large amounts of raw leaves.",
            "Wash hands thoroughly after handling crushed juice.",
            "Test on a small skin patch first to check for personal sensitivity.",
        ],
        "cultural_significance": [
            "Widely utilized across Philippine provinces as the go-to backyard cure for fungal skin problems.",
            "Featured in DOH rural public health programs and manufactured into soothing herbal soaps and lotions.",
            "Known for distinctive bright yellow candle-like vertical flower spikes.",
        ],
        "ecological_role": [
            "Vigorous tropical shrub that grows in sun-drenched lowlands, roadsides, and wasteland borders.",
            "Rich golden blossoms attract large carpenter bees and Philippine yellow butterflies.",
            "Enriches soil with organic biomass through fallen leaves.",
        ],
        "cultivation_tips": [
            "Direct sow seeds in full sun; seeds germinate readily within 1–2 weeks.",
            "Thrives in hot tropical conditions with very little maintenance or specialized fertilizers.",
            "Harvest healthy, dark green mature leaves whenever skin remedy is needed.",
        ],
    },
    {
        "index": 7,
        "species_id": 100007,
        "common_name": "Ampalaya (Bitter Gourd / Bitter Melon)",
        "local_name": "Ampalaya / Paria",
        "scientific_name": "Momordica charantia L.",
        "category": "DOH-Approved Medicinal & Bahay Kubo Vegetable",
        "medicinal_uses": [
            "DOH-approved herbal treatment for supplementary blood sugar regulation in type 2 diabetes mellitus.",
            "Contains charantin, polypeptide-p (plant insulin), and vicine that boost cellular glucose uptake.",
            "Steep young leaves as a cleansing detox tea; rich in vitamin C, folate, and potassium.",
        ],
        "culinary_uses": [
            "Essential star ingredient in iconic Filipino dishes: Ginisang Ampalaya with Egg, Pinakbet, and Dinengdeng.",
            "Young leaves (talbos ng ampalaya) are added to Monggo Guisado and native soup broths.",
            "Rub sliced fruit with rock salt and rinse with cold water to reduce excess bitterness before cooking.",
        ],
        "toxicity_risks": [
            "Diabetic patients on insulin or oral medication should monitor blood glucose to avoid hypoglycemia.",
            "Pregnant women should avoid consuming excessive seeds or concentrated extracts.",
            "Safe and highly nutritious when eaten as a regular dietary vegetable.",
        ],
        "cultural_significance": [
            "Celebrated in the iconic Filipino folk song 'Bahay Kubo' ('Kundol, patola, upo't kalabasa, at saka mayroon pang labanos, mustasa...').",
            "Famous in Philippine folklore (Alamat ng Ampalaya) teaching humility and embracing one's unique identity.",
            "A culinary staple across Luzon, Visayas, and Mindanao.",
        ],
        "ecological_role": [
            "Fast-growing climbing vine that rapidly blankets trellises and fence lines.",
            "Yellow flowers are eagerly pollinated by tropical bees and beneficial wasps.",
            "Ripe orange fruits burst open to feed birds with red aril-coated seeds.",
        ],
        "cultivation_tips": [
            "Provide sturdy bamboo trellises, net cages, or fence wire for vines to climb.",
            "Plant seeds in compost-rich soil with consistent moisture and full tropical sun.",
            "Harvest fruits when firm and bright green before they turn soft and yellow-orange.",
        ],
    },
    {
        "index": 8,
        "species_id": 100008,
        "common_name": "Bayabas (Guava)",
        "local_name": "Bayabas / Kalimbahin",
        "scientific_name": "Psidium guajava L.",
        "category": "DOH-Approved Medicinal & Philippine Fruit",
        "medicinal_uses": [
            "DOH-approved natural antiseptic wash for cleaning wounds, circumcision, and post-partum recovery.",
            "Boil fresh leaves for 15 minutes to use as an astringent mouthwash for toothache, swollen gums, and mouth ulcers.",
            "Young leaf decoction is a trusted home remedy to arrest acute non-specific diarrhea.",
        ],
        "culinary_uses": [
            "Delicious tropical fruit eaten fresh with a pinch of rock salt or made into guava jelly and jam.",
            "Ripe aromatic guavas are the traditional souring base for authentic Sinigang sa Bayabas.",
            "Leaves can be brewed into a refreshing antioxidant-rich daily herbal tea.",
        ],
        "toxicity_risks": [
            "Non-toxic and extremely safe for humans and pets.",
            "Hard inner seeds should be eaten mindfully to avoid tooth discomfort.",
            "Excellent source of dietary fiber and contains 4x more Vitamin C than oranges.",
        ],
        "cultural_significance": [
            "A beloved backyard fruit tree found across every Philippine barangay and rural homestead.",
            "Central to classic Filipino childhood memories of climbing trees to pick fresh ripe guavas.",
            "One of the oldest and most respected home remedies throughout Philippine history.",
        ],
        "ecological_role": [
            "Provides sweet, vitamin-rich fruits for Philippine fruit bats, birds, and small mammals.",
            "Attracts native pollinator bees with fluffy white fragrant blossoms.",
            "Drought-resistant and thrives in diverse Philippine soil types.",
        ],
        "cultivation_tips": [
            "Grows easily from seed or marcotted (air-layered) saplings for faster fruiting.",
            "Thrives in full sun; tolerates wet rainy seasons and prolonged dry spells.",
            "Prune dead wood and water sprouts to keep the canopy productive and manageable.",
        ],
    },
    {
        "index": 9,
        "species_id": 100009,
        "common_name": "Ulasimang Bato (Peperomia / Silver Bush)",
        "local_name": "Ulasimang Bato / Pansit-pansitan",
        "scientific_name": "Peperomia pellucida (L.) Kunth",
        "category": "DOH-Approved Philippine Medicinal Herb",
        "medicinal_uses": [
            "DOH-approved herbal remedy for lowering elevated blood uric acid levels and managing gout.",
            "Helps soothe rheumatic joint pains and mild arthritic inflammation.",
            "Eat 1 cup of fresh washed leaves as salad twice daily or drink as a mild boiled decoction.",
        ],
        "culinary_uses": [
            "Crisp, succulent leaves and tender stems have a mild, refreshing cucumber-like flavor.",
            "Eaten raw in fresh Filipino garden salads with chopped tomatoes, onions, and calamansi vinaigrette.",
            "Lightly blanched or tossed into warm vegetable broths at the very end of cooking.",
        ],
        "toxicity_risks": [
            "Safe, edible, and gentle on the stomach for humans.",
            "Wash thoroughly with clean water before eating raw to remove garden soil or debris.",
            "100% non-toxic to household pets (cats and dogs).",
        ],
        "cultural_significance": [
            "A humble, miraculous herb often found growing naturally on damp rock walls, bricks, and shaded pots.",
            "Proves the rich healing wisdom of Philippine nature right in ordinary backyards.",
            "Officially recognized and documented in the Philippine National Formulary.",
        ],
        "ecological_role": [
            "Shade-loving succulent groundcover that helps retain moisture in garden topsoil.",
            "Prevents soil erosion on garden rockeries and stone borders.",
            "Produces miniature green flower spikes with thousands of tiny seeds.",
        ],
        "cultivation_tips": [
            "Prefers shady, damp locations with indirect light (under tree canopies or beside plant pots).",
            "Needs rich, moist soil; water frequently during hot dry weather.",
            "Self-seeds prolifically and will continuously regenerate throughout the rainy season.",
        ],
    },
    {
        "index": 10,
        "species_id": 100010,
        "common_name": "Tsaang Gubat (Wild Tea / Philippine Tea)",
        "local_name": "Tsaang Gubat / Putputai / Alangitngit",
        "scientific_name": "Carmona retusa (Vahl) Masam.",
        "category": "DOH-Approved Philippine Medicinal Shrub",
        "medicinal_uses": [
            "DOH-approved natural antispasmodic for stomach ache, abdominal cramps, and diarrhea.",
            "Used as a soothing oral gargle to treat mouth sores and prevent dental cavities.",
            "Boil fresh chopped leaves in water for 15 minutes and drink warm for fast stomach relief.",
        ],
        "culinary_uses": [
            "Traditionally brewed as an invigorating, earthy daily herbal tea (substitute for commercial tea).",
            "Has a pleasant, smooth herbal flavor without bitterness.",
            "Can be blended with dried pandan or calamansi for an aromatic wellness tea.",
        ],
        "toxicity_risks": [
            "Non-toxic and extremely well tolerated by all age groups.",
            "No known adverse drug interactions with standard medications.",
            "Safe for daily herbal beverage consumption.",
        ],
        "cultural_significance": [
            "Historically harvested from Philippine secondary forests by indigenous communities.",
            "Popularly shaped into Philippine bonsai art due to small glossy leaves and gnarled woody bark.",
            "One of the 10 core plants promoted by the Department of Health (DOH-PITAHC).",
        ],
        "ecological_role": [
            "Native tropical shrub that provides dense shelter for small garden birds and reptiles.",
            "White star-like flowers provide nectar for tiny pollinators.",
            "Small round orange berries are eaten and dispersed by wild Philippine birds.",
        ],
        "cultivation_tips": [
            "Loves bright partial shade to full sun with well-draining garden soil.",
            "Responds wonderfully to frequent pruning and topiary shaping.",
            "Water when topsoil feels dry to touch; very drought-hardy once rooted.",
        ],
    },

    # --------------------------------------------------------------------------
    # 3. POPULAR PHILIPPINE HERBS, VEGETABLES & CROPS
    # --------------------------------------------------------------------------
    {
        "index": 11,
        "species_id": 100011,
        "common_name": "Malunggay (Moringa / Drumstick Tree)",
        "local_name": "Malunggay / Kalunggay",
        "scientific_name": "Moringa oleifera Lam.",
        "category": "Philippine Superfood & Medicinal Tree",
        "medicinal_uses": [
            "World-renowned superfood and proven natural galactagogue that dramatically boosts breastmilk production in nursing mothers.",
            "Packed with high concentrations of Calcium, Vitamin A, Vitamin C, Iron, and complete plant proteins.",
            "Potent natural antioxidant and anti-inflammatory properties supporting immune vitality and blood pressure regulation.",
        ],
        "culinary_uses": [
            "The soul of classic Filipino comfort foods: Chicken Tinola, Utan Bisaya, Suam na Mais, and Monggo Guisado.",
            "Powdered dry leaves are blended into malunggay pandesal, green smoothies, pasta, and healthy snacks.",
            "Tender green seed pods (drumsticks) are simmered in savory curries and stews.",
        ],
        "toxicity_risks": [
            "Leaves and tender pods are 100% safe, edible, and exceptionally nutritious.",
            "Avoid consuming large amounts of tree bark or roots during pregnancy.",
            "Safe for pets in moderate fresh green dietary supplements.",
        ],
        "cultural_significance": [
            "The ubiquitous 'Tree of Life' found in almost every backyard across Luzon, Visayas, and Mindanao.",
            "A national symbol of nutritional resilience, family nourishment, and motherly care in the Philippines.",
            "Passed from neighbors as simple stem cuttings pushed into the ground.",
        ],
        "ecological_role": [
            "Fast-growing, drought-resilient tree that enriches poor soils and survives intense tropical dry seasons.",
            "White fragrant blossoms attract swarms of honeybees throughout the year.",
            "Provides light, dappled shade for delicate understory crops.",
        ],
        "cultivation_tips": [
            "Simply stick a mature branch cutting (1–2 meters long) into the ground—it will root and sprout vigorously!",
            "Needs full tropical sun and good soil drainage; avoid waterlogged swampy areas.",
            "Harvest leaves frequently by pinching branch tips to promote dense, bushy regrowth.",
        ],
    },
    {
        "index": 12,
        "species_id": 100012,
        "common_name": "Tawa-Tawa (Gatas-Gatas / Asthma Plant)",
        "local_name": "Tawa-Tawa / Gatas-Gatas",
        "scientific_name": "Euphorbia hirta L.",
        "category": "Popular Philippine Folk Medicinal Herb",
        "medicinal_uses": [
            "Celebrated Philippine folkloric remedy used to support blood platelet recovery during Dengue Fever recovery.",
            "Traditionally decocted for asthma, bronchitis, and gastrointestinal distress.",
            "Contains active phytochemicals with antiviral, anti-thrombocytopenic, and antioxidant properties.",
        ],
        "culinary_uses": [
            "Not used as a culinary vegetable; prepared strictly as a boiled herbal tea decoction.",
            "Wash whole uprooted plant thoroughly before boiling in clean drinking water.",
            "Often mixed with calamansi or honey to soften its earthy herbal taste.",
        ],
        "toxicity_risks": [
            "Consult a medical doctor immediately for confirmed Dengue cases and maintain hospital hydration protocols.",
            "Milky latex sap can cause mild skin or eye irritation in sensitive individuals.",
            "Use recommended boiled decoctions and avoid over-concentration.",
        ],
        "cultural_significance": [
            "One of the most famous and culturally trusted home remedies in modern Philippine folk medicine.",
            "Subject of extensive scientific research by Philippine DOST and University researchers.",
            "Found growing freely in vacant lots, road cracks, and garden lawns across the country.",
        ],
        "ecological_role": [
            "Resilient tropical weed that stabilizes open disturbed ground.",
            "Tiny flower clusters provide pollen for small insects.",
            "Thrives naturally without any chemical fertilizers or pesticides.",
        ],
        "cultivation_tips": [
            "Grows easily from seed in full sun to partial shade in any regular soil.",
            "Tolerates hot dry weather and torrential tropical rains.",
            "Harvest mature flowering whole plants and wash roots thoroughly before preparation.",
        ],
    },
    {
        "index": 13,
        "species_id": 100013,
        "common_name": "Mayana (Coleus / Painted Nettle)",
        "local_name": "Mayana / Lampunaya",
        "scientific_name": "Coleus scutellarioides (L.) Benth.",
        "category": "Philippine Ornamental & Medicinal Herb",
        "medicinal_uses": [
            "Traditional Filipino poultice: warm crushed colorful leaves applied to bruises, sprains, and swelling.",
            "Juice of fresh leaves drops into ears for earache or applied on shallow cuts to promote clotting.",
            "Rich in rosmarinic acid and anti-inflammatory flavonoids.",
        ],
        "culinary_uses": [
            "Primarily cultivated as an ornamental and medicinal plant.",
            "Leaves of specific culinary varieties are occasionally used in traditional herbal infusions.",
            "Keep as a vibrant garden and balcony accent plant.",
        ],
        "toxicity_risks": [
            "Mildly toxic to dogs and cats if chewed in large quantities (essential oils cause mild stomach upset).",
            "Safe for external topical human handling and traditional skin applications.",
            "Wear gloves when taking cuttings if you have sensitive skin.",
        ],
        "cultural_significance": [
            "Iconic Filipino garden plant cherished for kaleidoscopic purple, red, pink, and lime-green foliage.",
            "A centerpiece of the Philippine plantito/plantita gardening craze.",
            "Commonly displayed near front gates and balconies to bring vibrant color and positive energy.",
        ],
        "ecological_role": [
            "Fast-rooting foliage plant that provides dense ground cover and weed suppression.",
            "Flower spikes attract bees and beneficial nectar feeders.",
            "Tolerates diverse tropical humidity levels.",
        ],
        "cultivation_tips": [
            "Thrives in bright indirect light or morning sun; intense noon sun may bleach dark leaf colors.",
            "Pinch off blue flower spikes regularly to force the plant to produce lush, bushy colorful leaves.",
            "Roots effortlessly in water or moist potting mix within just 3–5 days!",
        ],
    },
    {
        "index": 14,
        "species_id": 100014,
        "common_name": "Santan (Jungle Flame)",
        "local_name": "Santan",
        "scientific_name": "Ixora coccinea L.",
        "category": "Classic Philippine Garden Flower",
        "medicinal_uses": [
            "Traditional decoction of roots and leaves used in folklore for diarrhea and sores.",
            "Flower infusions used in traditional Ayurvedic and Asian folk medicine for skin cleansing.",
            "Contains natural tannins, flavonoids, and antimicrobial compounds.",
        ],
        "culinary_uses": [
            "Filipino children famously sip the tiny drop of sweet honey-like nectar from the base of the flower stem.",
            "Petals are occasionally used as edible colorful garnishes in modern Philippine gourmet salads.",
            "Clean thoroughly before enjoying sweet floral nectar.",
        ],
        "toxicity_risks": [
            "Generally safe and non-toxic to humans and domestic pets.",
            "Do not consume flowers from plants treated with systemic garden insecticides.",
            "Safe for planting in family schoolyards and residential parks.",
        ],
        "cultural_significance": [
            "The classic Philippine hedge plant lining suburban homes, public schools, and plaza parks.",
            "Deeply rooted in Filipino childhood memories of picking flowers to suck sweet nectar and weave necklaces.",
            "Blooms perpetually in fiery clusters of red, pink, yellow, orange, and white.",
        ],
        "ecological_role": [
            "Major nectar source for Philippine butterflies, hawk moths, and sunbirds.",
            "Forms dense evergreen hedgerows that buffer wind and street noise.",
            "Extremely durable against urban pollution and tropical heat.",
        ],
        "cultivation_tips": [
            "Needs full tropical sun to produce abundant, vibrant flower heads.",
            "Plant in slightly acidic, well-draining garden soil enriched with compost.",
            "Prune into tidy geometric hedges or let grow naturally into flowering shrubs.",
        ],
    },
    {
        "index": 15,
        "species_id": 100015,
        "common_name": "Gumamela (China Rose / Hibiscus)",
        "local_name": "Gumamela",
        "scientific_name": "Hibiscus rosa-sinensis L.",
        "category": "Iconic Philippine Flowering Shrub & Medicinal",
        "medicinal_uses": [
            "Crushed red flower buds and leaves used in Philippine folklore as a soothing poultice for boils (pigsa), abscesses, and mumps.",
            "Petal tea is rich in Vitamin C, anthocyanins, and natural antioxidants that support cardiovascular health.",
            "Used in natural herbal hair washes to condition the scalp and stimulate shiny hair growth.",
        ],
        "culinary_uses": [
            "Fresh washed petals can be brewed into vibrant ruby-red hibiscus iced tea with honey and calamansi.",
            "Used as edible floral garnishes on cakes, fruit platters, and Filipino salads.",
            "Petals are dried for aromatic floral tea blends.",
        ],
        "toxicity_risks": [
            "Non-toxic to humans and safe for dogs and cats.",
            "Avoid eating flowers collected from busy roadsides with vehicle exhaust.",
            "Enjoy fresh, clean blossoms for cooking and tea.",
        ],
        "cultural_significance": [
            "One of the most recognized flowers across the Philippine archipelago.",
            "Filipino children love crushing flowers with soap and water to blow giant bubble balloons through papaya stems.",
            "A traditional symbol of tropical beauty, love, and joyous island hospitality.",
        ],
        "ecological_role": [
            "Provides vital nectar for tropical butterflies, long-tongued moths, and nectar-feeding birds.",
            "Acts as a natural windbreak in tropical garden landscapes.",
            "Flowers continuously 365 days a year under Philippine tropical sunshine.",
        ],
        "cultivation_tips": [
            "Requires at least 6 hours of direct sun daily for non-stop flowering.",
            "Water deeply during hot sunny weeks; feed monthly with organic compost or high-potassium fertilizer.",
            "Propagate easily via semi-hardwood stem cuttings in moist soil.",
        ],
    },
    {
        "index": 16,
        "species_id": 100016,
        "common_name": "Siling Labuyo (Wild Bird's Eye Chili)",
        "local_name": "Siling Labuyo / Chileng Bundok",
        "scientific_name": "Capsicum frutescens L.",
        "category": "Philippine Endemic Cultivar & Spices",
        "medicinal_uses": [
            "High in natural capsaicin: boosts metabolism, stimulates blood circulation, and relieves pain.",
            "Crushed leaves and fruit in coconut oil used in traditional liniments for arthritis, rheumatism, and sore muscles.",
            "Natural decongestant that clears sinuses and respiratory passages during colds.",
        ],
        "culinary_uses": [
            "The fiery heart of authentic Filipino condiments (Sawsawan): crushed in soy sauce, calamansi, and vinegar.",
            "Essential in iconic spicy Filipino regional cuisines like Bicol Express, Laing, Dinakdakan, and Sisig.",
            "Young tender leaves (dahon ng sili) are indispensable in Chicken Tinola soup.",
        ],
        "toxicity_risks": [
            "Intense heat (80,000–100,000 Scoville Heat Units); avoid touching eyes after handling cut chilies.",
            "Keep fresh spicy pods away from curious pets and small children.",
            "Wear gloves when processing large quantities of hot chili peppers.",
        ],
        "cultural_significance": [
            "Renowned worldwide as the true native Philippine hot chili pepper.",
            "A symbol of fiery Bicolano cuisine and bold Filipino culinary pride.",
            "Celebrated for small, upright pointing pods that pack intense volcanic flavor.",
        ],
        "ecological_role": [
            "Seeds are naturally dispersed by wild birds which are immune to capsaicin heat.",
            "Natural pest-deterrent plant that repels garden insects from neighboring vegetables.",
            "Thrives in hot, dry, and humid Philippine climates alike.",
        ],
        "cultivation_tips": [
            "Loves scorching full sunlight and well-draining garden soil.",
            "Do not overwater—chili plants produce spicier peppers when allowed to dry slightly between waterings.",
            "Prune top shoots when young to encourage bushy branching and hundreds of upright red chilies.",
        ],
    },
    {
        "index": 17,
        "species_id": 100017,
        "common_name": "Kangkong (Water Spinach / Swamp Cabbage)",
        "local_name": "Kangkong / Tangkong",
        "scientific_name": "Ipomoea aquatica Forssk.",
        "category": "Philippine Staple Leafy Vegetable",
        "medicinal_uses": [
            "Rich in dietary iron, dietary fiber, beta-carotene, Vitamin A, and Vitamin C.",
            "Helps regulate bowel movements, prevent constipation, and support healthy hemoglobin levels.",
            "In folk medicine, leaves are believed to have a mild natural calming and sleep-promoting effect.",
        ],
        "culinary_uses": [
            "Star leafy green in National Filipino dishes: Sinigang, Adobong Kangkong, and Crispy Kangkong with dip.",
            "Tossed in garlic and oyster sauce for quick, nutritious vegetable stir-fries.",
            "Leaves and hollow crunchy stems both cook quickly in boiling broths.",
        ],
        "toxicity_risks": [
            "Safe, highly nutritious, and edible for all ages.",
            "Always cook wild wetland kangkong thoroughly to eliminate waterborne parasites.",
            "Safe for herbivorous pets and backyard animals.",
        ],
        "cultural_significance": [
            "The most accessible, affordable, and beloved leafy vegetable across the entire Philippines.",
            "Grown everywhere from rural rivers and rice paddies to urban hydroponic containers and balcony pots.",
            "Celebrated in Filipino culture as a symbol of everyday resourcefulness and hearty nutrition.",
        ],
        "ecological_role": [
            "Fast-growing aquatic and semi-aquatic plant that filters and purifies freshwater runoff.",
            "Provides shelter for freshwater fish and aquatic biodiversity.",
            "Rapidly regenerates after harvesting, offering continuous green food security.",
        ],
        "cultivation_tips": [
            "Grows easily in wet soil, garden beds, or simple plastic water containers.",
            "Needs abundant water and full sunlight for tender, succulent green stems.",
            "Harvest by snipping top 4–6 inches; new shoots will branch out within days.",
        ],
    },
    {
        "index": 18,
        "species_id": 100018,
        "common_name": "Calamansi (Philippine Lime)",
        "local_name": "Kalamansi / Calamondin",
        "scientific_name": "Citrus microcarpa Bunge",
        "category": "Essential Philippine Citrus & Medicinal Fruit",
        "medicinal_uses": [
            "High concentration of Vitamin C supports immune defense against colds, cough, and viral infections.",
            "Warm calamansi juice with honey is the beloved Filipino home remedy for sore throat and voice hoarseness.",
            "Natural fruit alpha-hydroxy acids used as a traditional skin brightener and deodorant wash.",
        ],
        "culinary_uses": [
            "The irreplaceable foundation of Philippine gastronomy: squeezed over Pancit, Arroz Caldo, Inasal, and Sisig.",
            "Crucial base for Filipino dipping sauces (sawsawan) mixed with soy sauce, patis, or vinegar.",
            "Made into refreshing iced Calamansi juice, marinades, salad dressings, and citrus pies.",
        ],
        "toxicity_risks": [
            "100% safe, healthy, and delicious for humans.",
            "Citrus peel essential oils can be irritating to pets in large concentrated quantities.",
            "Drink with a straw or rinse mouth with water to protect tooth enamel from natural citrus acidity.",
        ],
        "cultural_significance": [
            "The signature citrus fruit of the Philippines, cherished in every single Filipino kitchen.",
            "A constant companion at dining tables from roadside karinderyas to luxury banquets.",
            "Grown in clay pots on suburban patios and sprawling orchards in Oriental Mindoro and Quezon.",
        ],
        "ecological_role": [
            "Glossy green shrub that feeds and hosts larvae of magnificent Philippine swallowtail butterflies.",
            "Fragrant white citrus blossoms attract honeybees and native pollinators.",
            "Compact canopy provides sheltered nesting for small garden birds.",
        ],
        "cultivation_tips": [
            "Thrives in sunny balconies, garden soil, or large terracotta pots with good drainage.",
            "Water regularly when topsoil is dry; feed with organic compost or citrus fertilizer every 2 months.",
            "Harvest round green or golden-yellow fruits year-round by gently clipping with shears.",
        ],
    },
    {
        "index": 19,
        "species_id": 100019,
        "common_name": "Pandan (Fragrant Screwpine)",
        "local_name": "Pandan Mabango",
        "scientific_name": "Pandanus amaryllifolius Roxb.",
        "category": "Philippine Culinary & Aromatic Herb",
        "medicinal_uses": [
            "Decoction of pandan leaves used in Philippine folk medicine to soothe rheumatic joint pain and reduce fever.",
            "Known in traditional wellness for mild diuretic and calming, stress-relieving properties.",
            "Rich in natural essential oils, alkaloids, and polyphenols.",
        ],
        "culinary_uses": [
            "Tied into a knot and boiled with everyday white rice for an irresistible sweet floral fragrance.",
            "Star flavoring and natural green coloring in classic Filipino desserts: Buko Pandan, Gulaman, and Kakanin.",
            "Boiled with lemongrass for a refreshing, restorative cold iced tea.",
        ],
        "toxicity_risks": [
            "Completely non-toxic, edible, and safe for humans and household pets.",
            "Discard boiled leaves before serving desserts (leaves are used for aromatic infusion, not raw ingestion).",
            "Safe to grow indoors or outdoors.",
        ],
        "cultural_significance": [
            "The quintessential aroma of Filipino home cooking and beloved celebration desserts.",
            "Fresh leaves are woven into traditional baskets, rice pouches, and used as natural room fresheners in cars and homes.",
            "A symbol of sweet hospitality and fond family gatherings.",
        ],
        "ecological_role": [
            "Dense tropical shrub with strap-like leaves that provides lush evergreen groundcover.",
            "Suppresses weeds and helps hold topsoil together along garden borders.",
            "Repels certain nuisance insects with its natural aroma.",
        ],
        "cultivation_tips": [
            "Loves partial shade to full sun with rich, constantly moist garden soil.",
            "Water generously—pandan thrives in tropical humidity and damp conditions.",
            "Harvest outer mature leaves by cutting cleanly at the base, allowing the central crown to continue growing.",
        ],
    },
    {
        "index": 20,
        "species_id": 100020,
        "common_name": "Gabi (Taro)",
        "local_name": "Gabi / Dagmay",
        "scientific_name": "Colocasia esculenta (L.) Schott",
        "category": "Bahay Kubo Crop & Traditional Culinary Plant",
        "medicinal_uses": [
            "Taro corms provide easily digestible complex carbohydrates, dietary fiber, and essential minerals.",
            "Low glycemic index root vegetable supporting sustained energy and gut health.",
            "Cooked leaves are rich in Vitamin A, Vitamin C, Calcium, and Iron.",
        ],
        "culinary_uses": [
            "Corm is cooked to thicken hearty Sinigang broth and made into sweet Halo-Halo toppings and desserts.",
            "Leaves and stalks are simmered with rich coconut milk, pork, and chili for world-famous Bicolano Laing.",
            "Must ALWAYS be thoroughly cooked to neutralize natural calcium oxalate crystals (which cause throat itchiness if raw).",
        ],
        "toxicity_risks": [
            "Raw leaves, stems, and corms contain calcium oxalate raphides that cause intense itching if eaten uncooked.",
            "Always cook, boil, or simmer thoroughly in coconut milk or water before consumption.",
            "Do not feed raw taro leaves to domestic pets.",
        ],
        "cultural_significance": [
            "A pillar of Philippine regional cuisine, especially in the Bicol region (famous for authentic spicy Laing).",
            "A staple crop of indigenous and rural Filipino communities for centuries.",
            "Dramatic heart-shaped elephant-ear leaves symbolize tropical abundance and natural beauty.",
        ],
        "ecological_role": [
            "Thrives in wetlands, riverbanks, and tropical garden beds, filtering water runoff.",
            "Massive leaves provide shade that retains soil moisture and shelters amphibians.",
            "Excellent biomass producer that enriches tropical soils.",
        ],
        "cultivation_tips": [
            "Loves moist, muddy, or consistently wet soil in full sun or light shade.",
            "Propagate easily by replanting the top stem cutting of the harvested corm (huli).",
            "Harvest mature corms after 6–8 months when leaves begin to turn yellow.",
        ],
    },
]

PLANT_KEYWORDS = {
    "guajava": 100008,
    "psidium": 100008,
    "bayabas": 100008,
    "guava": 100008,
    "sambac": 100001,
    "jasminum": 100001,
    "sampaguita": 100001,
    "pterocarpus": 100002,
    "narra": 100002,
    "sanderiana": 100003,
    "waling": 100003,
    "negundo": 100004,
    "lagundi": 100004,
    "balsamifera": 100005,
    "sambong": 100005,
    "alata": 100006,
    "akapulko": 100006,
    "charantia": 100007,
    "ampalaya": 100007,
    "pellucida": 100009,
    "ulasimang": 100009,
    "pansit": 100009,
    "carmona": 100010,
    "retusa": 100010,
    "tsaang": 100010,
    "moringa": 100011,
    "oleifera": 100011,
    "malunggay": 100011,
    "hirta": 100012,
    "tawa": 100012,
    "gatas": 100012,
    "scutellarioides": 100013,
    "mayana": 100013,
    "coleus": 100013,
    "coccinea": 100014,
    "santan": 100014,
    "ixora": 100014,
    "rosa-sinensis": 100015,
    "gumamela": 100015,
    "hibiscus": 100015,
    "frutescens": 100016,
    "labuyo": 100016,
    "aquatica": 100017,
    "kangkong": 100017,
    "microcarpa": 100018,
    "calamansi": 100018,
    "kalamansi": 100018,
    "amaryllifolius": 100019,
    "pandan": 100019,
    "esculenta": 100020,
    "colocasia": 100020,
    "gabi": 100020,
    "taro": 100020,
}

def get_philippine_plant_info(name_or_scn: str):
    """Accurately matches a query string against the Philippine flora database."""
    if not name_or_scn:
        return None
    q = name_or_scn.lower().strip()

    # 1. Exact matches
    for p in PHILIPPINE_PLANTS:
        if p["scientific_name"].lower() == q or p["common_name"].lower() == q or p["local_name"].lower() == q:
            return p

    # 2. Check keyword dictionary
    words = re.findall(r'[a-z-]+', q)
    for w in words:
        if w in PLANT_KEYWORDS:
            target_sp_id = PLANT_KEYWORDS[w]
            for p in PHILIPPINE_PLANTS:
                if p["species_id"] == target_sp_id:
                    return p

    # 3. Binomial prefix check (genus + species)
    if len(words) >= 2:
        binomial = f"{words[0]} {words[1]}"
        for p in PHILIPPINE_PLANTS:
            if p["scientific_name"].lower().startswith(binomial):
                return p

    return None

