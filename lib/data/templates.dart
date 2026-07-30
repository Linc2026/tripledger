import '../models/template_block.dart';
import '../models/template_model.dart';
const List<TemplateModel> kTemplates = [
  TemplateModel(
    id: 1,
    title: 'Tokyo Cherry Blossom Trail',
    imageUrl: 'assets/templates/template_01.jpg',
    blocks: [
      TemplateBlock.text(
        'Arriving in Tokyo just as the cherry blossoms reached their peak felt like a stroke of serendipity. Shinjuku Gyoen was our first stop — thousands of tourists and locals gathered beneath the pale-pink canopy, picnic sheets spread across every inch of lawn.',
      ),
      TemplateBlock.asset('assets/templates/template_01.jpg'),
      TemplateBlock.text(
        'We wandered from Shinjuku to Harajuku, then through Shibuya\'s famous crossing at dusk. The rhythm of the city is unlike anywhere else: frenetically modern yet somehow quiet when you step into one of its countless side-street alleys.',
      ),
      TemplateBlock.asset('assets/templates/template_01_2.jpg'),
      TemplateBlock.text(
        'Day three took us to Ueno Park, where the sakura petals had begun to fall like soft snow. We ended the evening with yakitori and cold Sapporo at a tiny basement izakaya that seats eight people maximum.',
      ),
      TemplateBlock.asset('assets/templates/template_01_3.jpg'),
      TemplateBlock.text(
        'The last two days were spent in Asakusa — Senso-ji at sunrise with almost no crowds, followed by a leisurely cruise on the Sumida River. Tokyo is a city that rewards patience and aimless wandering in equal measure.',
      ),
    ],
    suggestedDuration: '7 – 10 days',
    estBudget: r'$2,400 – $3,800',
  ),
  TemplateModel(
    id: 2,
    title: 'Tuscany Wine Route',
    imageUrl: 'assets/templates/template_02.jpg',
    blocks: [
      TemplateBlock.text(
        'The drive from Florence to Siena through the Chianti wine country is one of the great slow pleasures of Italian travel. Cypress trees stand like dark sentinels along the hilltop roads, and at each bend there is another sun-warmed vineyard, another medieval village with its shuttered stone facades and faded terracotta rooftops.',
      ),
      TemplateBlock.asset('assets/templates/template_02.jpg'),
      TemplateBlock.text(
        'We arrived at Radda in Chianti in late afternoon and checked into a converted 16th-century farmhouse. The owner brought out a carafe of house Chianti Classico almost immediately, which set the tone for the days that followed.',
      ),
      TemplateBlock.asset('assets/templates/template_02_2.jpg'),
      TemplateBlock.text(
        'Each morning we drove to a different cantina — Antinori, Badia a Coltibuono, Castello di Ama — for tastings that stretched lazily into lunch. By late afternoon we would return to the farmhouse terrace to watch the light go golden across the valley.',
      ),
      TemplateBlock.asset('assets/templates/template_02_3.jpg'),
      TemplateBlock.text(
        'San Gimignano on the final day was a revelation: the medieval towers visible from miles away, the white wine (Vernaccia) ice-cold and sharp, the wild boar ragù at a family trattoria in the lower town.',
      ),
    ],
    suggestedDuration: '8 – 10 days',
    estBudget: r'$2,800 – $4,200',
  ),
  TemplateModel(
    id: 3,
    title: 'Santorini Summer Escape',
    imageUrl: 'assets/templates/template_03.jpg',
    blocks: [
      TemplateBlock.text(
        'The famous blue-domed churches of Oia against a blazing Aegean sky — some images remain clichés because they are simply true. Santorini\'s caldera views at sunset are as extraordinary as promised, the volcanic beaches unlike any in the Mediterranean, and the local Assyrtiko wine bracingly mineral and cold.',
      ),
      TemplateBlock.asset('assets/templates/template_03.jpg'),
      TemplateBlock.text(
        'We based ourselves in Fira and explored the island by ATV, stopping at the black sand beach of Perissa, the ancient ruins of Akrotiri, and the quiet village of Pyrgos before its evening crowds arrived.',
      ),
      TemplateBlock.asset('assets/templates/template_03_2.jpg'),
      TemplateBlock.asset('assets/templates/template_03_3.jpg'),
    ],
    suggestedDuration: '5 – 7 days',
    estBudget: r'$2,000 – $3,500',
  ),
  TemplateModel(
    id: 4,
    title: 'Paris Romantic Weekend',
    imageUrl: 'assets/templates/template_04.jpg',
    blocks: [
      TemplateBlock.text(
        'Two days in Paris is never enough, but it is enough to fall in love with the city all over again. We began at the Marais, wandering through its medieval streets and stopping for café au lait and croissants at a corner bistro that had not changed its menu since 1980.',
      ),
      TemplateBlock.asset('assets/templates/template_04.jpg'),
      TemplateBlock.text(
        'The Louvre in the afternoon was calmer than expected — heading straight for the Richelieu wing avoided the Mona Lisa crowds entirely. By evening, a slow walk along the Seine with a bottle of Beaujolais and a baguette felt like the most natural thing in the world.',
      ),
      TemplateBlock.asset('assets/templates/template_04_2.jpg'),
      TemplateBlock.asset('assets/templates/template_04_3.jpg'),
    ],
    suggestedDuration: '3 – 5 days',
    estBudget: r'$1,500 – $2,500',
  ),
  TemplateModel(
    id: 5,
    title: 'Iceland Northern Lights',
    imageUrl: 'assets/templates/template_05.jpg',
    blocks: [
      TemplateBlock.text(
        'The forecast said moderate auroral activity — what appeared overhead was a cathedral of green and violet light that no photograph, however well exposed, can fully capture. We stood in a field outside Vik, necks craned, watching curtains of color shift and fold for nearly two hours.',
      ),
      TemplateBlock.asset('assets/templates/template_05.jpg'),
      TemplateBlock.text(
        'The rest of the trip was equally elemental: geysers at Geysir, waterfalls at Skógafoss and Seljalandsfoss, the black sand beach at Reynisfjara where the Atlantic crashes in with terrifying indifference. Iceland does not comfort; it overwhelms.',
      ),
      TemplateBlock.asset('assets/templates/template_05_2.jpg'),
      TemplateBlock.asset('assets/templates/template_05_3.jpg'),
    ],
    suggestedDuration: '7 – 10 days',
    estBudget: r'$3,500 – $5,500',
  ),
  TemplateModel(
    id: 6,
    title: 'Bali Spirit Journey',
    imageUrl: 'assets/templates/template_06.jpg',
    blocks: [
      TemplateBlock.text(
        'The moment the plane began its descent over Bali, I knew this trip would be different. The island revealed itself in layers — terraced rice paddies, the dark silhouettes of temple spires, the soft haze that hangs over the coast in the early morning.',
      ),
      TemplateBlock.asset('assets/templates/template_06.jpg'),
      TemplateBlock.text(
        'We spent our first two days in Ubud, waking before dawn to reach the sunrise terrace at Tegallalang before the crowds. The second half of the trip was pure coast: surf lessons at Kuta, a long afternoon at Tanah Lot, and evenings at the night market in Seminyak.',
      ),
      TemplateBlock.asset('assets/templates/template_06_2.jpg'),
      TemplateBlock.asset('assets/templates/template_06_3.jpg'),
    ],
    suggestedDuration: '8 – 12 days',
    estBudget: r'$1,800 – $3,000',
  ),
  TemplateModel(
    id: 7,
    title: 'New Zealand Road Trip',
    imageUrl: 'assets/templates/template_07.jpg',
    blocks: [
      TemplateBlock.text(
        'The South Island of New Zealand is a country-sized national park wearing a thin disguise. Every stretch of road delivers another jaw-dropping vista: the turquoise lakes of the Mackenzie Basin, the sheer walls of Fiordland, the lupine fields of the Tekapo valley ablaze in purple and pink.',
      ),
      TemplateBlock.asset('assets/templates/template_07.jpg'),
      TemplateBlock.text(
        'We drove from Christchurch to Queenstown over twelve days, camping two nights and staying in small towns the rest of the time. The Milford Sound day trip remains one of the most dramatic things I have ever witnessed from a boat.',
      ),
      TemplateBlock.asset('assets/templates/template_07_2.jpg'),
      TemplateBlock.asset('assets/templates/template_07_3.jpg'),
    ],
    suggestedDuration: '10 – 14 days',
    estBudget: r'$3,000 – $4,500',
  ),
  TemplateModel(
    id: 8,
    title: 'Machu Picchu Trek',
    imageUrl: 'assets/templates/template_08.jpg',
    blocks: [
      TemplateBlock.text(
        'The four-day Inca Trail begins gently and ends magnificently. By day two, the altitude (reaching nearly 4,200 metres at Dead Woman\'s Pass) had reduced our group to a slow, silent procession, each step deliberate.',
      ),
      TemplateBlock.asset('assets/templates/template_08.jpg'),
      TemplateBlock.text(
        'By day four, emerging through the Sun Gate at dawn to see Machu Picchu materialize below us in morning cloud felt like reaching the end of something much larger than a hike.',
      ),
      TemplateBlock.asset('assets/templates/template_08_2.jpg'),
      TemplateBlock.asset('assets/templates/template_08_3.jpg'),
    ],
    suggestedDuration: '9 – 12 days',
    estBudget: r'$2,500 – $4,000',
  ),
  TemplateModel(
    id: 9,
    title: 'Kyoto Autumn Leaves',
    imageUrl: 'assets/templates/template_09.jpg',
    blocks: [
      TemplateBlock.text(
        'Kyoto in November is the Japan of imagination made real. The maple trees turn a hundred shades of red and orange and amber, and every temple garden becomes a painting. Eikan-do at dusk, Tofuku-ji on a misty morning, the Philosopher\'s Path carpeted in fallen leaves — the city gives itself over entirely to the season.',
      ),
      TemplateBlock.asset('assets/templates/template_09.jpg'),
      TemplateBlock.text(
        'We spent five days, rising early each morning to reach the gardens before the tour groups, then retreating to quiet teahouses for matcha and wagashi in the afternoons.',
      ),
      TemplateBlock.asset('assets/templates/template_09_2.jpg'),
      TemplateBlock.asset('assets/templates/template_09_3.jpg'),
    ],
    suggestedDuration: '5 – 7 days',
    estBudget: r'$2,000 – $3,200',
  ),
  TemplateModel(
    id: 10,
    title: 'Norwegian Fjords Cruise',
    imageUrl: 'assets/templates/template_10.jpg',
    blocks: [
      TemplateBlock.text(
        'The Geirangerfjord at first light, with waterfalls threading down vertical cliff faces and the water so still it perfectly mirrors the mountains above — this is Norway at its most impossibly beautiful.',
      ),
      TemplateBlock.asset('assets/templates/template_10.jpg'),
      TemplateBlock.text(
        'We traveled by Hurtigruten along the coast, stopping at Bergen, Ålesund, and Tromsø, each city distinct and each harbor framed by peaks still capped with last winter\'s snow.',
      ),
      TemplateBlock.asset('assets/templates/template_10_2.jpg'),
      TemplateBlock.asset('assets/templates/template_10_3.jpg'),
    ],
    suggestedDuration: '10 – 14 days',
    estBudget: r'$4,000 – $6,500',
  ),
  TemplateModel(
    id: 11,
    title: 'Moroccan Desert Odyssey',
    imageUrl: 'assets/templates/template_11.jpg',
    blocks: [
      TemplateBlock.text(
        'The road from Marrakech to the Sahara passes through the Atlas Mountains via the Tizi n\'Tichka pass, a spectacular switchback route with views across barren plateaus and deep red gorges. By the time we reached Merzouga and the great dunes of Erg Chebbi, the landscape had become entirely lunar — vast, silent, and rippled with wind-sculpted sand.',
      ),
      TemplateBlock.asset('assets/templates/template_11.jpg'),
      TemplateBlock.text(
        'A camel ride into the dunes at sunset, a night in a desert camp under stars so dense they formed a solid band across the sky, and a dawn climb to the highest dune: these are experiences that do not fade.',
      ),
      TemplateBlock.asset('assets/templates/template_11_2.jpg'),
      TemplateBlock.asset('assets/templates/template_11_3.jpg'),
    ],
    suggestedDuration: '8 – 10 days',
    estBudget: r'$2,200 – $3,500',
  ),
  TemplateModel(
    id: 12,
    title: 'Maldives Island Hopping',
    imageUrl: 'assets/templates/template_12.jpg',
    blocks: [
      TemplateBlock.text(
        'The Maldives operates on a different logic from most destinations. Here, the journey between islands by speedboat is itself the experience — flying across a lagoon so transparent you can see every coral head six meters below, arriving at another sandbar surrounded by a different palette of blue.',
      ),
      TemplateBlock.asset('assets/templates/template_12.jpg'),
      TemplateBlock.text(
        'We stayed on three islands: a local island for authenticity and excellent snorkeling, a mid-range resort for the overwater bungalow experience, and a luxury atoll for our final two nights. The house reef at the last resort contained more fish than I have ever seen in any ocean.',
      ),
      TemplateBlock.asset('assets/templates/template_12_2.jpg'),
      TemplateBlock.asset('assets/templates/template_12_3.jpg'),
    ],
    suggestedDuration: '7 – 10 days',
    estBudget: r'$4,500 – $8,000',
  ),
  TemplateModel(
    id: 13,
    title: 'Rome Ancient Wonders',
    imageUrl: 'assets/templates/template_13.jpg',
    blocks: [
      TemplateBlock.text(
        'Rome asks you to accept contradiction: that ancient ruins and espresso bars can coexist, that traffic circles around the Colosseum, that the Pantheon is simply open and you just walk in. Once you accept this, the city reveals itself as endlessly generous.',
      ),
      TemplateBlock.asset('assets/templates/template_13.jpg'),
      TemplateBlock.text(
        'We spent a week covering the Forum, the Vatican Museums (booking early morning entry was essential), Trastevere at night, and long lunches wherever a handwritten menu was taped to the window. Cacio e pepe from a trattoria on the Aventine Hill remains the best thing I ate all year.',
      ),
      TemplateBlock.asset('assets/templates/template_13_2.jpg'),
      TemplateBlock.asset('assets/templates/template_13_3.jpg'),
    ],
    suggestedDuration: '5 – 7 days',
    estBudget: r'$2,000 – $3,500',
  ),
  TemplateModel(
    id: 14,
    title: 'Barcelona Architecture Tour',
    imageUrl: 'assets/templates/template_14.jpg',
    blocks: [
      TemplateBlock.text(
        'Gaudí\'s Barcelona is a city-sized architectural argument, and every building makes its case with extraordinary confidence. The Sagrada Família, still unfinished after 140 years, is the obvious centerpiece — but Casa Batlló, Casa Milà, and Palau Güell are equally audacious.',
      ),
      TemplateBlock.asset('assets/templates/template_14.jpg'),
      TemplateBlock.text(
        'Beyond Gaudí, the Eixample district\'s grid conceals dozens of Modernista buildings that reward slow walking and upward glances.',
      ),
      TemplateBlock.asset('assets/templates/template_14_2.jpg'),
      TemplateBlock.asset('assets/templates/template_14_3.jpg'),
    ],
    suggestedDuration: '5 – 7 days',
    estBudget: r'$1,800 – $3,000',
  ),
  TemplateModel(
    id: 15,
    title: 'Swiss Alps Hiking',
    imageUrl: 'assets/templates/template_15.jpg',
    blocks: [
      TemplateBlock.text(
        'The Swiss Alps present a paradox: a landscape so dramatic it seems artificial, yet everything from the cowbells to the wildflowers to the glacier-melt streams is entirely and completely real.',
      ),
      TemplateBlock.asset('assets/templates/template_15.jpg'),
      TemplateBlock.text(
        'We based ourselves in Grindelwald and walked a different trail each day — to First, across to Bachalpsee, up to Kleine Scheidegg, along the Eiger Trail with its vertical north face looming close enough to feel the cold radiating off the rock.',
      ),
      TemplateBlock.asset('assets/templates/template_15_2.jpg'),
      TemplateBlock.asset('assets/templates/template_15_3.jpg'),
    ],
    suggestedDuration: '7 – 10 days',
    estBudget: r'$4,000 – $6,500',
  ),
  TemplateModel(
    id: 16,
    title: 'Bangkok Street Food Trail',
    imageUrl: 'assets/templates/template_16.jpg',
    blocks: [
      TemplateBlock.text(
        'Bangkok is a city best understood through eating, and the best eating happens at street level — at plastic tables on the sidewalk, from carts that appear and disappear with the hours, from shophouses where the same family has been cooking the same dish for three generations.',
      ),
      TemplateBlock.asset('assets/templates/template_16.jpg'),
      TemplateBlock.text(
        'We navigated by recommendation and smell: pad kra pao from a cart near the flower market at 7am, boat noodles in the old town at noon, mango with sticky rice from a woman on Sukhumvit at midnight. The city never stopped feeding us.',
      ),
      TemplateBlock.asset('assets/templates/template_16_2.jpg'),
      TemplateBlock.asset('assets/templates/template_16_3.jpg'),
    ],
    suggestedDuration: '5 – 8 days',
    estBudget: r'$1,200 – $2,200',
  ),
  TemplateModel(
    id: 17,
    title: 'Patagonia Wilderness',
    imageUrl: 'assets/templates/template_17.jpg',
    blocks: [
      TemplateBlock.text(
        'Patagonia exists at the end of the world, and it acts like it. The weather changes in minutes, trails disappear into cloud, and the granite towers of Torres del Paine emerge and vanish with theatrical indifference to the hikers below.',
      ),
      TemplateBlock.asset('assets/templates/template_17.jpg'),
      TemplateBlock.text(
        'The W Trek over five days took us past glaciers the color of old jade, through lenga beech forests turned autumn red, and across lakes so blue they looked painted.',
      ),
      TemplateBlock.asset('assets/templates/template_17_2.jpg'),
      TemplateBlock.asset('assets/templates/template_17_3.jpg'),
    ],
    suggestedDuration: '10 – 14 days',
    estBudget: r'$3,500 – $5,500',
  ),
  TemplateModel(
    id: 18,
    title: 'Amalfi Coast Drive',
    imageUrl: 'assets/templates/template_18.jpg',
    blocks: [
      TemplateBlock.text(
        'The SS163, which hugs the Amalfi Coast from Sorrento to Salerno, is one of the most terrifying and beautiful roads in Europe. It is too narrow for two cars to pass comfortably, perpetually shadowed by cliffs above and dizzying drops to the Tyrrhenian below, yet somehow lined with lemon trees in full fruit.',
      ),
      TemplateBlock.asset('assets/templates/template_18.jpg'),
      TemplateBlock.text(
        'We rented a small Fiat and drove south from Naples, stopping at Positano, Amalfi, Ravello, and eventually Paestum — where three magnificently preserved Greek temples stand in a meadow of wildflowers, largely ignored.',
      ),
      TemplateBlock.asset('assets/templates/template_18_2.jpg'),
      TemplateBlock.asset('assets/templates/template_18_3.jpg'),
    ],
    suggestedDuration: '5 – 8 days',
    estBudget: r'$2,500 – $4,200',
  ),
  TemplateModel(
    id: 19,
    title: 'Prague Medieval Walk',
    imageUrl: 'assets/templates/template_19.jpg',
    blocks: [
      TemplateBlock.text(
        'Prague survived the 20th century with its medieval fabric largely intact, which means its Old Town still looks roughly as it did in the 15th century — a dense network of cobbled lanes, Gothic churches, Baroque palaces, and the odd Art Nouveau café tucked between them.',
      ),
      TemplateBlock.asset('assets/templates/template_19.jpg'),
      TemplateBlock.text(
        'We walked across the Charles Bridge at 6am both mornings, before anyone else arrived, watching the light come up over the city. The castle district above Malá Strana, the Jewish Quarter with its six synagogues, the astronomical clock at noon: Prague delivers exactly what it promises.',
      ),
      TemplateBlock.asset('assets/templates/template_19_2.jpg'),
      TemplateBlock.asset('assets/templates/template_19_3.jpg'),
    ],
    suggestedDuration: '4 – 6 days',
    estBudget: r'$1,500 – $2,500',
  ),
  TemplateModel(
    id: 20,
    title: 'Kenya Safari Adventure',
    imageUrl: 'assets/templates/template_20.jpg',
    blocks: [
      TemplateBlock.text(
        'The Maasai Mara in October, during the tail end of the Great Migration, is Africa distilled to its essential drama. We watched a river crossing at the Mara River on our second day — hundreds of wildebeest plunging into crocodile-filled water with a noise like approaching thunder.',
      ),
      TemplateBlock.asset('assets/templates/template_20.jpg'),
      TemplateBlock.text(
        'By evening, we sat in silence at a fire while a lion called from somewhere in the darkness.',
      ),
      TemplateBlock.asset('assets/templates/template_20_2.jpg'),
      TemplateBlock.asset('assets/templates/template_20_3.jpg'),
    ],
    suggestedDuration: '8 – 12 days',
    estBudget: r'$4,500 – $7,500',
  ),
  TemplateModel(
    id: 21,
    title: 'Canadian Rockies Drive',
    imageUrl: 'assets/templates/template_21.jpg',
    blocks: [
      TemplateBlock.text(
        'The Icefields Parkway between Banff and Jasper is frequently described as the most beautiful drive in the world, and while such superlatives are usually exaggerated, this one is not far off. The 232-kilometre road passes glaciers that calve into turquoise lakes, elk grazing at the roadside, and peaks so large they produce their own weather.',
      ),
      TemplateBlock.asset('assets/templates/template_21.jpg'),
      TemplateBlock.text(
        'We drove it over two days, camping at the Columbia Icefield, and emerged in Jasper to find elk wandering casually through the town centre.',
      ),
      TemplateBlock.asset('assets/templates/template_21_2.jpg'),
      TemplateBlock.asset('assets/templates/template_21_3.jpg'),
    ],
    suggestedDuration: '8 – 12 days',
    estBudget: r'$3,500 – $5,500',
  ),
  TemplateModel(
    id: 22,
    title: 'Greek Islands Sailing',
    imageUrl: 'assets/templates/template_22.jpg',
    blocks: [
      TemplateBlock.text(
        'Seven days on a sailing catamaran through the Cyclades revealed a Greece invisible from the ferry routes: uninhabited coves accessible only by water, tavernas on islands with no road, swimming directly off the hull into 25-meter visibility. We left from Athens, calling at Syros, Paros, Naxos, and Amorgos before the final reach back to Piraeus.',
      ),
      TemplateBlock.asset('assets/templates/template_22.jpg'),
      TemplateBlock.text(
        'The Aegean in September is warm, reliably windy in the afternoons, and less crowded than summer. The night anchorage at Koufonisia, with a crescent moon and phosphorescence in our wake, was worth the entire trip.',
      ),
      TemplateBlock.asset('assets/templates/template_22_2.jpg'),
      TemplateBlock.asset('assets/templates/template_22_3.jpg'),
    ],
    suggestedDuration: '7 – 10 days',
    estBudget: r'$3,000 – $5,500',
  ),
];
