/// Forest Produce Dictionary & Multilingual Resolver.
/// Resolves Hindi, Marathi, and English terms for forest produce, categories,
/// order status notices, and units when server data only contains mr and en.
class ForestProduceDictionary {
  ForestProduceDictionary._();

  static const Map<String, String> _hindiMappings = {
    // Categories
    'medicinal plants': 'औषधीय पौधे एवं जड़ी-बूटियाँ',
    'औषधी वनस्पती': 'औषधीय पौधे एवं जड़ी-बूटियाँ',
    'minor forest produce': 'लघु वनोपज (Minor Forest Produce)',
    'वनोपज (minor forest produce)': 'लघु वनोपज (Minor Forest Produce)',
    'वनोपज': 'लघु वनोपज (Minor Forest Produce)',
    'handicrafts & bamboo': 'हस्तशिल्प एवं बांस उत्पाद',
    'हस्तकला आणि बांबू साहित्य': 'हस्तशिल्प एवं बांस उत्पाद',
    'water & land resources': 'जल एवं भूमि संसाधन',
    'जल आणि भूमी संसाधने': 'जल एवं भूमि संसाधन',
    'other forest produce': 'अन्य वन उत्पाद',
    'इतर वन उत्पादने': 'अन्य वन उत्पाद',

    // Specific Produce
    'pure wild forest honey': 'शुद्ध जंगली शहद (Wild Forest Honey)',
    'शुद्ध रान मध (wild forest honey)': 'शुद्ध जंगली शहद (Wild Forest Honey)',
    'शुद्ध रान मध': 'शुद्ध जंगली शहद',
    'wild forest honey': 'जंगली शहद',
    'रान मध': 'जंगली शहद',

    'sun-dried mahua flowers': 'सूखे महुआ के फूल (Sun-dried Mahua Flowers)',
    'सुकलेली महुआ फुले (dried mahua flowers)': 'सूखे महुआ के फूल (Sun-dried Mahua Flowers)',
    'सुकलेली महुआ फुले': 'सूखे महुआ के फूल',
    'mahua flowers': 'महुआ के फूल',
    'महुआ फुले': 'महुआ के फूल',

    'organic ashwagandha roots': 'जैविक अश्वगंधा जड़ें (Organic Ashwagandha Roots)',
    'अश्वगंधा मुळे (organic ashwagandha roots)': 'जैविक अश्वगंधा जड़ें (Organic Ashwagandha Roots)',
    'अश्वगंधा मुळे': 'अश्वगंधा की जड़ें',

    'handwoven bamboo utility baskets': 'पारंपरिक बांस की टोकरियां (Handwoven Bamboo Baskets)',
    'पारंपारिक बांबू टोपल्या (handwoven bamboo baskets)': 'पारंपरिक बांस की टोकरियां (Handwoven Bamboo Baskets)',
    'पारंपारिक बांबू टोपल्या': 'पारंपरिक बांस की टोकरियां',
    'bamboo baskets': 'बांस की टोकरियां',
    'बांबू टोपल्या': 'बांस की टोकरियां',

    'wild natural forest gum': 'प्राकृतिक वन गोंद (Wild Natural Forest Gum)',
    'नैसर्गिक कडुनिंब डिंक (wild neem & dhavada gum)': 'प्राकृतिक नीम व धावड़ा गोंद (Wild Neem & Dhavada Gum)',
    'नैसर्गिक कडुनिंब डिंक': 'प्राकृतिक नीम व धावड़ा गोंद',
    'forest gum': 'जंगली गोंद',
    'डिंक': 'गोंद',

    'tendu leaves': 'तेंदू पत्ता (Tendu Leaves)',
    'तेंदू पत्ता': 'तेंदू पत्ता (Tendu Leaves)',

    'hirda and beheda': 'हरड़ एवं बहेड़ा (Hirda & Beheda)',
    'हिरडा आणि बेहेडा': 'हरड़ एवं बहेड़ा (Hirda & Beheda)',

    // System Messages & Titles
    'produce handed over!': 'उत्पाद सुपुर्द किया गया!',
    'माल सुपूर्द केला!': 'उत्पाद सुपुर्द किया गया!',
    'order delivered & completed!': 'ऑर्डर सफलतापूर्वक डिलीवर हुआ!',
    'ऑर्डर यशस्वीरीत्या पोहोचली!': 'ऑर्डर सफलतापूर्वक डिलीवर हुआ!',
    'order cancelled': 'ऑर्डर रद्द हुआ',
    'ऑर्डर रद्द झाली': 'ऑर्डर रद्द हुआ',
    'request rejected': 'अनुरोध अस्वीकार किया गया',
    'विनंती नाकारली': 'अनुरोध अस्वीकार किया गया',
    'order approved!': 'ऑर्डर स्वीकृत हुआ!',
    'ऑर्डर मंजूर झाली!': 'ऑर्डर स्वीकृत हुआ!',
    'seller counter-offer': 'विक्रेता की काउंटर ऑफर',
    'विक्रेत्याची प्रति-ऑफर (counter)': 'विक्रेता की काउंटर ऑफर',
    'new barter offer!': 'नया वस्तु विनिमय (Barter) ऑफर!',
    'नवीन वस्तुविनिमय (barter) ऑफर!': 'नया वस्तु विनिमय (Barter) ऑफर!',
  };

  /// Resolves the produce or entity title based on the active language code.
  static String resolveTitle({
    required String? en,
    required String? mr,
    required String locale,
  }) {
    final cleanEn = (en ?? '').trim();
    final cleanMr = (mr ?? '').trim();

    if (locale == 'hi') {
      // 1. Try mapping from English or Marathi
      if (cleanEn.isNotEmpty) {
        final hit = _hindiMappings[cleanEn.toLowerCase()];
        if (hit != null) return hit;
      }
      if (cleanMr.isNotEmpty) {
        final hit = _hindiMappings[cleanMr.toLowerCase()];
        if (hit != null) return hit;
      }

      // 2. Intelligent Devanagari fallbacks
      if (cleanMr.isNotEmpty) {
        return cleanMr;
      }
      return cleanEn.isNotEmpty ? cleanEn : 'वन उत्पाद';
    }

    if (locale == 'mr') {
      return cleanMr.isNotEmpty ? cleanMr : cleanEn;
    }

    // Default to English
    return cleanEn.isNotEmpty ? cleanEn : cleanMr;
  }

  /// Resolves secondary subtitle string based on active locale.
  static String resolveSubtitle({
    required String? en,
    required String? mr,
    required String locale,
  }) {
    final cleanEn = (en ?? '').trim();
    final cleanMr = (mr ?? '').trim();

    if (locale == 'en') {
      return cleanMr;
    }
    return cleanEn;
  }
}
