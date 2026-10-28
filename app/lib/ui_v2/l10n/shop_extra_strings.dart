import 'app_strings.dart';

/// Strings for the cart pill, the Cart page, the Product page and the sign-in / create-account pages.
/// English, Hindi and Marathi. The Hindi and Marathi words are machine drafts (not yet read by a
/// native speaker). Kept in its own file so app_strings.dart stays untouched.
extension ShopExtraStrings on AppStrings {
  String _t(String en, String hi, String mr) {
    switch (language) {
      case AppLanguage.en:
        return en;
      case AppLanguage.hi:
        return hi;
      case AppLanguage.mr:
        return mr;
    }
  }

  // ---- Cart pill and Cart page ----------------------------------------------------------------
  String get viewCart => _t('View cart', 'कार्ट देखें', 'कार्ट पहा');

  String cartItems(int n) {
    if (n == 1) return _t('1 item', '1 वस्तु', '1 वस्तू');
    return _t('$n items', '$n वस्तुएँ', '$n वस्तू');
  }

  String get cartEmpty => _t('Your cart is empty.', 'आपका कार्ट खाली है।', 'तुमचा कार्ट रिकामा आहे.');
  String get continueShopping => _t('Continue shopping', 'खरीदारी जारी रखें', 'खरेदी सुरू ठेवा');
  String get backLabel => _t('Back', 'वापस', 'मागे');

  // ---- Product page: buy now, bill, choosing a seller -----------------------------------------------
  String get buyNow => _t('Buy now', 'अभी खरीदें', 'आता खरेदी करा');
  String get billTitle => _t('Bill', 'बिल', 'बिल');
  String billLine(String price, int q, String unit) => _t('$price × $q $unit', '$price × $q $unit', '$price × $q $unit');
  String get tapSeller =>
      _t('Tap a seller to choose', 'विक्रेता चुनने के लिए टैप करें', 'विक्रेता निवडण्यासाठी टॅप करा');
  String get sellerSelected => _t('Selected', 'चुना गया', 'निवडला');
  String get buyNeedsSignIn => _t(
        'Sign in to place your order',
        'ऑर्डर देने के लिए साइन इन करें',
        'ऑर्डर देण्यासाठी साइन इन करा',
      );
  String get notNow => _t('Not now', 'अभी नहीं', 'आता नाही');
  String get fulfilPickup => _t('Pickup', 'स्वयं उठाएँ', 'स्वतः घेऊन जा');
  String get fulfilDelivery => _t('Delivery', 'डिलीवरी', 'डिलिव्हरी');

  // ---- Category page, sort and filters, quantity picker --------------------------------------------
  String get sortAndFilter => _t('Sort and filter', 'क्रमबद्ध और फ़िल्टर', 'क्रम आणि फिल्टर');
  String get sortTitle => _t('Sort by', 'क्रमबद्ध करें', 'क्रमवारी');
  String get sortPopular => _t('Popular', 'लोकप्रिय', 'लोकप्रिय');
  String get sortPriceAsc => _t('Price: low to high', 'कीमत: कम से ज़्यादा', 'किंमत: कमी ते जास्त');
  String get sortDiscount => _t('Biggest discount', 'सबसे ज़्यादा छूट', 'सर्वात जास्त सूट');
  String get sortNewest => _t('Newest', 'सबसे नया', 'सर्वात नवीन');
  String get filtersTitle => _t('Filters', 'फ़िल्टर', 'फिल्टर');
  String get priceRangeLabel => _t('Price range', 'कीमत की सीमा', 'किंमत मर्यादा');
  String get onlyDiscounted => _t('Only discounted', 'सिर्फ़ छूट वाले', 'फक्त सवलतीचे');
  String get applyLabel => _t('Apply', 'लागू करें', 'लागू करा');
  String get clearLabel => _t('Clear', 'साफ़ करें', 'साफ करा');
  String get clearFilters => _t('Clear filters', 'फ़िल्टर हटाएँ', 'फिल्टर काढा');

  String resultsCount(int n) {
    if (n == 1) return _t('1 product', '1 उत्पाद', '1 उत्पादन');
    return _t('$n products', '$n उत्पाद', '$n उत्पादने');
  }

  String get pickerTitle => _t('Choose quantity', 'मात्रा चुनें', 'प्रमाण निवडा');
  String pickerTotal(String amount) => _t('Total: $amount', 'कुल: $amount', 'एकूण: $amount');

  String sortLabel(String key) {
    switch (key) {
      case 'priceAsc':
        return sortPriceAsc;
      case 'discount':
        return sortDiscount;
      case 'newest':
        return sortNewest;
      default:
        return sortPopular;
    }
  }

  // ---- Minimum order message (shown when "-" is pressed at the seller's minimum) -------------------
  String get minOrderDialogTitle => _t('Minimum order', 'न्यूनतम ऑर्डर', 'किमान ऑर्डर');

  String minOrderDialogBody(String title, int q, String unit) => _t(
        "The seller's minimum order for $title is $q $unit. You can keep $q $unit in your cart or remove it.",
        '$title के लिए विक्रेता का न्यूनतम ऑर्डर $q $unit है। आप $q $unit कार्ट में रख सकते हैं या हटा सकते हैं।',
        '$title साठी विक्रेत्याचा किमान ऑर्डर $q $unit आहे. तुम्ही $q $unit कार्टमध्ये ठेवू शकता किंवा काढून टाकू शकता.',
      );

  String get keepInCart => _t('Keep in cart', 'कार्ट में रखें', 'कार्टमध्ये ठेवा');
  String get removeFromCart => _t('Remove', 'हटाएँ', 'काढून टाका');

  // ---- Product page --------------------------------------------------------------------------
  String get productSellers => _t('Sellers', 'विक्रेता', 'विक्रेते');
  String get lowestPrice => _t('Lowest price', 'सबसे कम कीमत', 'सर्वात कमी किंमत');
  String get addToCart => _t('Add to cart', 'कार्ट में जोड़ें', 'कार्टमध्ये जोडा');
  String get illustrationTag => _t('Illustration', 'चित्रण', 'चित्रण');

  String qtyLeft(int q, String unit) => _t('$q $unit left', '$q $unit बचा', '$q $unit शिल्लक');

  String soldLeftBar(int sold, int left, String unit) => _t(
        '$sold $unit sold · $left $unit left',
        '$sold $unit बिका · $left $unit बचा',
        '$sold $unit विकले · $left $unit शिल्लक',
      );

  String minOrderText(int q, String unit) =>
      _t('Minimum order: $q $unit', 'न्यूनतम ऑर्डर: $q $unit', 'किमान ऑर्डर: $q $unit');

  // ---- Sign in and create account --------------------------------------------------------------
  String get signInTitle => _t('Sign in', 'साइन इन करें', 'साइन इन करा');
  String get signInSubtitle =>
      _t('Welcome to VanMitra', 'वनमित्र में आपका स्वागत है', 'वनमित्रमध्ये आपले स्वागत आहे');
  String get continueWithGoogle =>
      _t('Continue with Google', 'Google के साथ जारी रखें', 'Google सह सुरू ठेवा');
  String get googleSoon => _t(
        'Google sign-in is coming soon.',
        'Google साइन इन जल्द आ रहा है।',
        'Google साइन इन लवकरच येत आहे.',
      );
  String get orDivider => _t('or', 'या', 'किंवा');
  String get phoneLabel => _t('Mobile number', 'मोबाइल नंबर', 'मोबाईल नंबर');
  String get pinLabel => _t('6-digit PIN', '6 अंकों का पिन', '6 अंकी पिन');
  String get noAccount => _t('New here?', 'नए हैं?', 'नवीन आहात?');
  String get createAccountLink => _t('Create an account', 'खाता बनाएँ', 'खाते तयार करा');
  String get createAccountTitle => _t('Create account', 'खाता बनाएँ', 'खाते तयार करा');
  String get roleLabel => _t('I am a', 'मैं हूँ', 'मी आहे');
  String get roleBuyer => _t('Buyer', 'खरीदार', 'खरेदीदार');
  String get nameLabel => _t('Full name', 'पूरा नाम', 'पूर्ण नाव');
  String get villageLabel => _t('Village', 'गाँव', 'गाव');
  String get chooseVillage => _t('Choose your village', 'अपना गाँव चुनें', 'तुमचे गाव निवडा');
  String get languageLabel => _t('Language', 'भाषा', 'भाषा');
  String get haveAccount => _t('Already have an account?', 'पहले से खाता है?', 'आधीच खाते आहे?');
  String get errName => _t('Enter your full name.', 'अपना पूरा नाम लिखें।', 'तुमचे पूर्ण नाव लिहा.');
  String get errPhone => _t(
        'Enter a valid 10-digit mobile number.',
        'सही 10 अंकों का मोबाइल नंबर लिखें।',
        'बरोबर 10 अंकी मोबाईल नंबर लिहा.',
      );
  String get errPin =>
      _t('PIN must be exactly 6 digits.', 'पिन ठीक 6 अंकों का होना चाहिए।', 'पिन अगदी 6 अंकी असावा.');
  String get errVillage => _t('Choose your village.', 'अपना गाँव चुनें।', 'तुमचे गाव निवडा.');
  String get errNoAccount => _t(
        'No account found. Please create an account.',
        'खाता नहीं मिला। कृपया खाता बनाएँ।',
        'खाते सापडले नाही. कृपया खाते तयार करा.',
      );
  String get errWrongPin => _t('Wrong PIN.', 'गलत पिन।', 'चुकीचा पिन.');
  String get demoNote => _t(
        '',
        '',
        '',
      );
  String helloName(String name) => _t('Hello, $name', 'नमस्ते, $name', 'नमस्कार, $name');
  String get signOut => _t('Sign out', 'साइन आउट', 'साइन आउट');
  String get profileGuestTitle => _t(
        'You are browsing as a guest',
        'आप अतिथि के रूप में देख रहे हैं',
        'तुम्ही पाहुणे म्हणून पाहत आहात',
      );
  String get accountCreated =>
      _t('Account created. Welcome!', 'खाता बन गया। स्वागत है!', 'खाते तयार झाले. स्वागत आहे!');

  /// Role names: buyer, gramsabha, cfrholder.
  String roleName(String role) {
    switch (role) {
      case 'gramsabha':
        return sellerGramSabha;
      case 'cfrholder':
        return sellerCfrHolder;
      default:
        return roleBuyer;
    }
  }
}
