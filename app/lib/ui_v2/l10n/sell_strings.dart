import 'app_strings.dart';

/// Strings for Phase 8 (Sell page: a seller adds and manages listings).
/// English, Hindi and Marathi. The Hindi and Marathi words are machine drafts (not yet read by a
/// native speaker). Kept in its own file so app_strings.dart and shop_extra_strings.dart stay untouched.
/// Every getter and method starts with `sl` to prevent any name clash at merge time.
extension SellStrings on AppStrings {
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

  // ---- Page titles and primary buttons ----------------------------------------------------------
  String get slMyListingsTitle => _t('My listings', 'मेरी सूचियाँ', 'माझ्या याद्या');
  String get slAddListingButton => _t('Add a listing', 'सूची जोड़ें', 'यादी जोडा');
  String get slEditListingTitle => _t('Edit listing', 'सूची बदलें', 'यादी संपादित करा');
  String get slPublishButton => _t('Publish listing', 'सूची प्रकाशित करें', 'यादी प्रकाशित करा');

  // ---- Non-seller gate (/sell for guest or buyer) -----------------------------------------------
  String get slSellerOnlyTitle => _t(
        'Selling is for Gram Sabhas and CFR holders',
        'बिक्री केवल ग्राम सभाओं और सीएफआर धारकों के लिए है',
        'विक्री फक्त ग्रामसभा आणि सीएफआर धारकांसाठी आहे',
      );

  String get slSellerOnlyGuestBody => _t(
        'Sign in with a Gram Sabha or CFR holder account, or create one, to list forest produce.',
        'वनोपज सूचीबद्ध करने के लिए ग्राम सभा या सीएफआर धारक खाते से साइन इन करें या नया खाता बनाएँ।',
        'वनोपज यादीत जोडण्यासाठी ग्रामसभा किंवा सीएफआर धारक खात्याने साइन इन करा किंवा नवीन खाते तयार करा.',
      );

  String get slSellerOnlyBuyerBody => _t(
        'You are signed in as a Buyer. Buyers purchase forest produce from Gram Sabhas and CFR holders.',
        'आप खरीदार के रूप में साइन इन हैं। खरीदार ग्राम सभाओं और सीएफआर धारकों से वनोपज खरीदते हैं।',
        'तुम्ही खरेदीदार म्हणून साइन इन केले आहे. खरेदीदार ग्रामसभा आणि सीएफआर धारकांकडून वनोपज खरेदी करतात.',
      );

  // ---- Empty state on /sell ---------------------------------------------------------------------
  String get slEmptyListings => _t(
        'You have no listings yet. Tap "Add a listing" to list forest produce from your village.',
        'अभी आपकी कोई सूची नहीं है। अपने गाँव की वनोपज जोड़ने के लिए "सूची जोड़ें" दबाएँ।',
        'अजून तुमची कोणतीही यादी नाही. तुमच्या गावातील वनोपज जोडण्यासाठी "यादी जोडा" दाबा.',
      );

  // ---- Listing card chips and actions -----------------------------------------------------------
  String get slStatusActive => _t('Active', 'सक्रिय', 'सक्रिय');
  String get slStatusPaused => _t('Paused', 'रुकी हुई', 'थांबवलेली');
  String get slEditAction => _t('Edit', 'बदलें', 'बदला');
  String get slPauseAction => _t('Pause', 'रोकें', 'थांबवा');
  String get slResumeAction => _t('Resume', 'फिर शुरू करें', 'पुन्हा सुरू करा');
  String get slRemoveAction => _t('Remove', 'हटाएँ', 'काढून टाका');

  // ---- Remove confirmation dialog ---------------------------------------------------------------
  String get slRemoveDialogTitle => _t('Remove listing?', 'सूची हटाएँ?', 'यादी काढून टाकायची?');

  String slRemoveDialogBody(String title) => _t(
        'Remove $title from your listings?',
        'अपनी सूचियों से $title हटाएँ?',
        'तुमच्या याद्यांमधून $title काढून टाकायचे?',
      );

  String get slCancelAction => _t('Cancel', 'रद्द करें', 'रद्द करा');

  // ---- Form sections and labels (/sell/new and /sell/edit/:id) ----------------------------------
  String get slStepChooseProduct => _t('1. Choose the product', '1. उत्पाद चुनें', '1. उत्पादन निवडा');
  String get slFixedProductHeading => _t('1. Product', '1. उत्पाद', '1. उत्पाद');
  String get slProductSearchHint => _t(
        'Search product name...',
        'उत्पाद का नाम खोजें...',
        'उत्पादनाचे नाव शोधा...',
      );
  String get slCatalogPhotoNote => _t(
        'The catalog picture of this product is used on your listing (photo upload is not in this demo).',
        'आपकी सूची में इस उत्पाद का कैटलॉग चित्र दिखाया जाएगा (इस डेमो में फोटो अपलोड नहीं है)।',
        'तुमच्या यादीसाठी या उत्पादनाचे कॅटलॉग चित्र वापरले जाईल (या डेमोमध्ये फोटो अपलोड नाही).',
      );

  String get slStepQuantity => _t('2. Quantity', '2. मात्रा', '2. प्रमाण');

  String slQuantityLabel(String unit) {
    if (unit.isEmpty) {
      return _t('Total quantity (whole number)', 'कुल मात्रा (पूर्ण संख्या)', 'एकूण प्रमाण (पूर्ण संख्या)');
    }
    return _t('Total quantity ($unit)', 'कुल मात्रा ($unit)', 'एकूण प्रमाण ($unit)');
  }

  String slAlreadySoldHint(int sold, String unit) => _t(
        'Already sold: $sold $unit',
        'पहले से बिका: $sold $unit',
        'आधीच विकले: $sold $unit',
      );

  String get slStepPricing => _t('3. Price per unit', '3. प्रति इकाई कीमत', '3. प्रति एकक किंमत');

  String slMrpLabel(String unit) {
    if (unit.isEmpty) {
      return _t('MRP per unit (₹)', 'अधिकतम खुदरा मूल्य प्रति इकाई (₹)', 'कमाल किरकोळ किंमत प्रति एकक (₹)');
    }
    return _t('MRP per $unit (₹)', 'अधिकतम खुदरा मूल्य प्रति $unit (₹)', 'कमाल किरकोळ किंमत प्रति $unit (₹)');
  }

  String slPriceLabel(String unit) {
    if (unit.isEmpty) {
      return _t('Your price per unit (₹)', 'आपकी कीमत प्रति इकाई (₹)', 'तुमची किंमत प्रति एकक (₹)');
    }
    return _t('Your price per $unit (₹)', 'आपकी कीमत प्रति $unit (₹)', 'तुमची किंमत प्रति $unit (₹)');
  }

  String slDiscountLine(int percent) =>
      _t('Discount: $percent%', 'छूट: $percent%', 'सवलत: $percent%');

  String get slStepMinOrder => _t('4. Minimum order', '4. न्यूनतम ऑर्डर', '4. किमान ऑर्डर');

  String slMinOrderLabel(String unit) {
    if (unit.isEmpty) {
      return _t('Minimum order quantity', 'न्यूनतम ऑर्डर मात्रा', 'किमान ऑर्डर प्रमाण');
    }
    return _t('Minimum order ($unit)', 'न्यूनतम ऑर्डर ($unit)', 'किमान ऑर्डर ($unit)');
  }

  String get slStepFulfilment => _t(
        '5. How can buyers get it?',
        '5. खरीदार इसे कैसे प्राप्त कर सकते हैं?',
        '5. खरेदीदारांना हे कसे मिळू शकते?',
      );

  String get slFulfilBoth => _t('Both', 'दोनों', 'दोन्ही');

  String get slFulfilPickupSub => _t(
        'Buyer collects from village',
        'खरीदार गाँव से ले जाएँ',
        'खरेदीदार गावातून नेतील',
      );

  String get slFulfilDeliverySub => _t(
        'Sent by delivery',
        'डिलीवरी से भेजा जाएगा',
        'डिलिव्हरीने पाठवले जाईल',
      );

  String get slFulfilBothSub => _t(
        'Pickup or delivery',
        'स्वयं उठाएँ या डिलीवरी',
        'स्वतः घेऊन जा किंवा डिलिव्हरी',
      );

  String get slStepPreview => _t('6. Live preview', '6. पूर्वावलोकन', '6. थेट पूर्वदृश्य');

  // ---- Validation error messages ----------------------------------------------------------------
  String get slErrProductRequired => _t(
        'Please choose a product from the catalog.',
        'कृपया कैटलॉग से एक उत्पाद चुनें।',
        'कृपया कॅटलॉगमधून एक उत्पादन निवडा.',
      );

  String get slErrQuantityPositive => _t(
        'Enter a whole number greater than 0.',
        '0 से बड़ी पूर्ण संख्या लिखें।',
        '0 पेक्षा मोठी पूर्ण संख्या लिहा.',
      );

  String slErrQuantityBelowSold(int sold, String unit) {
    final suffix = unit.isEmpty ? '$sold' : '$sold $unit';
    return _t(
      'Quantity cannot be less than already sold ($suffix).',
      'मात्रा पहले से बिके ($suffix) से कम नहीं हो सकती।',
      'प्रमाण आधीच विकलेल्या ($suffix) पेक्षा कमी असू शकत नाही.',
    );
  }

  String get slErrMrpPositive => _t(
        'Enter a valid MRP in rupees (greater than 0, up to 2 decimals).',
        'रुपये में सही अधिकतम खुदरा मूल्य लिखें (0 से अधिक, 2 दशमलव तक)।',
        'रुपयांमध्ये योग्य कमाल किरकोळ किंमत लिहा (0 पेक्षा जास्त, 2 दशांशांपर्यंत).',
      );

  String get slErrPricePositive => _t(
        'Enter a valid selling price in rupees (greater than 0, up to 2 decimals).',
        'रुपये में सही बिक्री कीमत लिखें (0 से अधिक, 2 दशमलव तक)।',
        'रुपयांमध्ये योग्य विक्री किंमत लिहा (0 पेक्षा जास्त, 2 दशांशांपर्यंत).',
      );

  String get slErrPriceAboveMrp => _t(
        'Your price cannot be higher than the MRP.',
        'आपकी कीमत अधिकतम खुदरा मूल्य से अधिक नहीं हो सकती।',
        'तुमची किंमत कमाल किरकोळ किमतीपेक्षा जास्त असू शकत नाही.',
      );

  String get slErrMinOrderPositive => _t(
        'Minimum order must be at least 1.',
        'न्यूनतम ऑर्डर कम से कम 1 होना चाहिए।',
        'किमान ऑर्डर किमान 1 असावे.',
      );

  String get slErrMinOrderAboveQuantity => _t(
        'Minimum order cannot be more than the quantity.',
        'न्यूनतम ऑर्डर कुल मात्रा से अधिक नहीं हो सकता।',
        'किमान ऑर्डर एकूण प्रमाणापेक्षा जास्त असू शकत नाही.',
      );

  String get slErrFulfilmentRequired => _t(
        'Choose how buyers can get this product.',
        'चुनें कि खरीदार यह उत्पाद कैसे प्राप्त कर सकते हैं।',
        'खरेदीदारांना हे उत्पादन कसे मिळू शकते ते निवडा.',
      );
}
