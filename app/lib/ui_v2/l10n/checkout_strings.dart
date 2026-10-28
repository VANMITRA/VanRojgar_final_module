import 'app_strings.dart';

/// Strings for the Phase 6 Cart extensions, Seller picker sheet, Checkout page, Guest gate sheet
/// and Request-sent confirmation page.
/// English, Hindi and Marathi. The Hindi and Marathi texts are machine drafts (not yet reviewed by
/// a native speaker). Every getter/method starts with `co` to avoid collisions with Phase 5.
extension CheckoutStrings on AppStrings {
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

  // ---- Cart page additions -------------------------------------------------------------------
  String get coCartApprovalNote => _t(
        'Each seller approves your request, or counters with another quantity or price. Each seller is paid separately.',
        'प्रत्येक विक्रेता आपके अनुरोध को स्वीकार करता है, या दूसरी मात्रा या कीमत का प्रस्ताव देता है। प्रत्येक विक्रेता को अलग से भुगतान किया जाता है।',
        'प्रत्येक विक्रेता तुमची मागणी मंजूर करतो, किंवा दुसरे प्रमाण किंवा किंमत सुचवतो. प्रत्येक विक्रेत्याला स्वतंत्रपणे पैसे दिले जातात.',
      );

  String get coChangeSeller => _t('Change seller', 'विक्रेता बदलें', 'विक्रेता बदला');

  String get coChooseSeller => _t('Choose a seller', 'विक्रेता चुनें', 'विक्रेता निवडा');

  String get coSelectedSeller => _t('Selected', 'चुना गया', 'निवडलेले');

  String get coTotalLabel => _t('Total', 'कुल', 'एकूण');

  String coTotalAmount(String amount) => _t('Total $amount', 'कुल $amount', 'एकूण $amount');

  String coSellerSubtotal(String amount) => _t('Subtotal: $amount', 'उप-योग: $amount', 'उप-एकूण: $amount');

  String get coContinue => _t('Continue', 'आगे बढ़ें', 'पुढे जा');

  String coSellersRequestsSummary(int n) {
    if (n == 1) {
      return _t('1 seller · 1 request', '1 विक्रेता · 1 अनुरोध', '1 विक्रेता · 1 मागणी');
    }
    return _t(
      '$n sellers · $n separate requests',
      '$n विक्रेता · $n अलग अनुरोध',
      '$n विक्रेते · $n स्वतंत्र मागण्या',
    );
  }

  String coQtyAdjustedToMin(int q, String unit) => _t(
        'Quantity raised to minimum order ($q $unit).',
        'मात्रा न्यूनतम ऑर्डर ($q $unit) तक बढ़ाई गई।',
        'प्रमाण किमान ऑर्डरपर्यंत ($q $unit) वाढवले.',
      );

  String coQtyAdjustedToStock(int q, String unit) => _t(
        'Quantity lowered to available stock ($q $unit).',
        'मात्रा उपलब्ध स्टॉक ($q $unit) तक घटाई गई।',
        'प्रमाण उपलब्ध साठ्यापर्यंत ($q $unit) कमी केले.',
      );

  String get coPickup => _t('Pickup', 'स्वयं ले जाएँ', 'स्वतः नेणे');

  String get coDelivery => _t('Delivery', 'डिलीवरी', 'डिलिव्हरी');

  String coOffers(String modes) => _t('Offers: $modes', 'उपलब्ध: $modes', 'उपलब्ध: $modes');

  String coFulfilmentText(String fulfilment) {
    switch (fulfilment) {
      case 'pickup':
        return coPickup;
      case 'delivery':
        return coDelivery;
      default:
        return '$coPickup / $coDelivery';
    }
  }

  /// Localizes a seller's display name so Hindi and Marathi screens never show raw English words
  /// like "Sample Gram Sabha 1" or "Sample CFR holder 3".
  String coSellerName(String rawName, String sellerType, [String sellerId = '']) {
    final trimmed = rawName.trim();
    final typeLabel = sellerType == 'gramsabha' ? sellerGramSabha : sellerCfrHolder;
    if (trimmed.isEmpty) {
      return typeLabel;
    }
    if (language == AppLanguage.en) {
      return trimmed;
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(trimmed)) {
      return trimmed;
    }
    // Check digits in rawName or sellerId.
    final digitsMatch = RegExp(r'\d+').firstMatch(trimmed) ?? RegExp(r'\d+').firstMatch(sellerId);
    final digits = digitsMatch != null ? ' ${digitsMatch.group(0)}' : '';
    // Never prefix sampleBadge to localized seller names.
    return '$typeLabel$digits';
  }

  // ---- Checkout page (/checkout) -------------------------------------------------------------
  String get coCheckoutTitle => _t('Checkout', 'चेकआउट', 'चेकआउट');

  String get coYourRequests => _t('Your requests', 'आपके अनुरोध', 'तुमच्या मागण्या');

  String get coHowReceive => _t(
        'How do you want to receive it?',
        'आप इसे कैसे प्राप्त करना चाहते हैं?',
        'तुम्हाला हे कसे मिळवायचे आहे?',
      );

  String coNotOfferedBy(String sellers) => _t(
        'Not offered by: $sellers',
        'इनके द्वारा उपलब्ध नहीं: $sellers',
        'यांच्याकडून उपलब्ध नाही: $sellers',
      );

  String get coMixedFulfilmentError => _t(
        'These sellers need different ways of receiving. Remove one product or change the seller.',
        'इन विक्रेताओं के पास प्राप्त करने के अलग-अलग तरीके हैं। एक उत्पाद हटाएँ या विक्रेता बदलें।',
        'या विक्रेत्यांकडे मिळवण्याचे वेगवेगळे मार्ग आहेत. एक उत्पादन काढा किंवा विक्रेता बदला.',
      );

  String get coDeliverToVillage => _t('Deliver to village', 'गाँव में डिलीवरी', 'गावात डिलिव्हरी');

  String get coChooseVillageError => _t('Choose a village', 'गाँव चुनें', 'गाव निवडा');

  String get coHowPay => _t('How will you pay?', 'आप भुगतान कैसे करेंगे?', 'तुम्ही पैसे कसे देणार?');

  String get coUpi => _t('UPI', 'UPI', 'UPI');

  String get coCashOnDelivery => _t('Cash on delivery', 'मिलने पर नकद भुगतान', 'मिळाल्यावर रोख पैसे');

  String get coUpiExplanation => _t(
        'You pay by UPI after the seller approves your request.',
        'विक्रेता द्वारा आपका अनुरोध स्वीकार करने के बाद आप UPI से भुगतान करते हैं।',
        'विक्रेत्याने तुमची मागणी मंजूर केल्यानंतर तुम्ही UPI ने पैसे देता.',
      );

  String get coCodExplanation => _t(
        'You pay in cash when you receive your order.',
        'ऑर्डर मिलने पर आप नकद भुगतान करते हैं।',
        'ऑर्डर मिळाल्यावर तुम्ही रोख पैसे देता.',
      );

  String get coNoteLabel => _t(
        'Note for the seller (optional)',
        'विक्रेता के लिए नोट (वैकल्पिक)',
        'विक्रेत्यासाठी टीप (ऐच्छिक)',
      );

  String get coNoteHint => _t(
        'Write a note for the seller...',
        'विक्रेता के लिए नोट लिखें...',
        'विक्रेत्यासाठी टीप लिहा...',
      );

  String get coSendRequest => _t('Send request', 'अनुरोध भेजें', 'मागणी पाठवा');

  String get coQuantityBoundsError => _t(
        'Quantities must be within each seller\'s minimum order and available stock.',
        'मात्रा प्रत्येक विक्रेता के न्यूनतम ऑर्डर और उपलब्ध स्टॉक के भीतर होनी चाहिए।',
        'प्रमाण प्रत्येक विक्रेत्याच्या किमान ऑर्डर आणि उपलब्ध साठ्याच्या मर्यादेत असावे.',
      );

  // ---- Guest gate bottom sheet ---------------------------------------------------------------
  String get coSignInToSendTitle => _t(
        'Sign in to send your request',
        'अपना अनुरोध भेजने के लिए साइन इन करें',
        'तुमची मागणी पाठवण्यासाठी साइन इन करा',
      );

  String get coSignInToSendBody => _t(
        'Your cart and checkout choices will stay saved.',
        'आपका कार्ट और चेकआउट विकल्प सुरक्षित रहेंगे।',
        'तुमचा कार्ट आणि चेकआउट पर्याय सुरक्षित राहतील.',
      );

  String get coNotNow => _t('Not now', 'अभी नहीं', 'आत्ता नाही');

  // ---- Success page (/checkout/done) ---------------------------------------------------------
  String get coRequestSentTitle => _t('Request sent', 'अनुरोध भेजा गया', 'मागणी पाठवली');

  String get coRequestSentSubtitle => _t(
        'Each seller will approve your request, or counter with another quantity or price.',
        'प्रत्येक विक्रेता आपके अनुरोध को स्वीकार करेगा, या दूसरी मात्रा या कीमत का प्रस्ताव देगा।',
        'प्रत्येक विक्रेता तुमची मागणी मंजूर करेल, किंवा दुसरे प्रमाण किंवा किंमत सुचवेल.',
      );

  String get coWaitingForSeller => _t(
        'Waiting for the seller',
        'विक्रेता की प्रतीक्षा में',
        'विक्रेत्याच्या प्रतीक्षेत',
      );

  String get coViewMyRequests => _t('View my requests', 'मेरे अनुरोध देखें', 'माझ्या मागण्या पहा');

  String get coNoRecentRequests => _t(
        'No requests sent in this session yet.',
        'इस सत्र में अभी तक कोई अनुरोध नहीं भेजा गया है।',
        'या सत्रात अजून कोणतीही मागणी पाठवलेली नाही.',
      );
}

