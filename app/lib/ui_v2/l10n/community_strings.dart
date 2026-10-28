import 'app_strings.dart';

/// Strings for Round 2: delivery partner (`dl`), messages (`ms`) and barter (`bt`).
/// English, Hindi and Marathi. The Hindi and Marathi words are machine drafts (not yet read by a
/// native speaker). Every getter and method starts with its prefix so nothing clashes.
extension CommunityStrings on AppStrings {
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

  // ---- Delivery partner: states of /delivery ------------------------------------------------------
  String get dlTitle => _t('Delivery partner', 'डिलीवरी पार्टनर', 'डिलिव्हरी पार्टनर');
  String get dlGuestTitle => _t('Sign in to continue', 'आगे बढ़ने के लिए साइन इन करें', 'पुढे जाण्यासाठी साइन इन करा');
  String get dlGuestBody => _t(
        'Sign in or create an account to use this page.',
        'इस पेज का उपयोग करने के लिए साइन इन करें या खाता बनाएँ।',
        'हे पान वापरण्यासाठी साइन इन करा किंवा खाते तयार करा.',
      );
  String get dlNotCfrTitle => _t(
        'Delivery partners are CFR holders',
        'डिलीवरी पार्टनर सीएफआर धारक होते हैं',
        'डिलिव्हरी पार्टनर सीएफआर धारक असतात',
      );
  String get dlNotCfrBody => _t(
        'Only a CFR holder account can apply to be a delivery partner.',
        'डिलीवरी पार्टनर के लिए केवल सीएफआर धारक खाता आवेदन कर सकता है।',
        'डिलिव्हरी पार्टनरसाठी फक्त सीएफआर धारक खाते अर्ज करू शकते.',
      );
  String get dlIntroTitle => _t(
        'Carry forest produce between villages',
        'गाँवों के बीच वनोपज पहुँचाएँ',
        'गावांमध्ये वनोपज पोहोचवा',
      );
  String get dlIntroBody => _t(
        'A delivery partner carries forest produce from the seller\'s village to the buyer. You switch yourself available or not available, and you accept the jobs you want.',
        'डिलीवरी पार्टनर विक्रेता के गाँव से खरीदार तक वनोपज पहुँचाता है। आप खुद उपलब्ध या अनुपलब्ध रहते हैं और जो काम चाहें वही स्वीकार करते हैं।',
        'डिलिव्हरी पार्टनर विक्रेत्याच्या गावातून खरेदीदारापर्यंत वनोपज पोहोचवतो. तुम्ही स्वतः उपलब्ध किंवा अनुपलब्ध राहता आणि हवी ती कामे स्वीकारता.',
      );
  String get dlApplyButton => _t('Apply', 'आवेदन करें', 'अर्ज करा');
  String get dlPendingTitle => _t('Waiting for approval', 'मंज़ूरी का इंतज़ार', 'मंजुरीची प्रतीक्षा');
  String get dlPendingBody => _t(
        'A team member will look at your application. You can take jobs after it is approved.',
        'टीम का एक सदस्य आपका आवेदन देखेगा। मंज़ूरी के बाद आप काम ले सकेंगे।',
        'टीमचा एक सदस्य तुमचा अर्ज पाहील. मंजुरीनंतर तुम्ही कामे घेऊ शकाल.',
      );
  String get dlRejectedTitle => _t('Application not approved', 'आवेदन मंज़ूर नहीं हुआ', 'अर्ज मंजूर झाला नाही');
  String get dlRejectedBody =>
      _t('Your application was not approved.', 'आपका आवेदन मंज़ूर नहीं हुआ।', 'तुमचा अर्ज मंजूर झाला नाही.');
  String get dlPausedTitle => _t('Your partner account is paused', 'आपका पार्टनर खाता रुका हुआ है', 'तुमचे पार्टनर खाते थांबवले आहे');
  String get dlPausedBody => _t(
        'You cannot take new jobs while your account is paused.',
        'खाता रुका होने तक आप नए काम नहीं ले सकते।',
        'खाते थांबवलेले असताना तुम्ही नवीन कामे घेऊ शकत नाही.',
      );
  String get dlReviewNote => _t('Note from the team', 'टीम का नोट', 'टीमची टीप');
  String get dlAvailableLabel => _t('Available for jobs', 'काम के लिए उपलब्ध', 'कामासाठी उपलब्ध');
  String get dlEarnings => _t('Earnings', 'कमाई', 'कमाई');
  String get dlJobsDone => _t('Jobs completed', 'पूरे किए काम', 'पूर्ण केलेली कामे');
  String get dlSegOpen => _t('Open jobs', 'खुले काम', 'खुली कामे');
  String get dlSegMine => _t('My jobs', 'मेरे काम', 'माझी कामे');
  String get dlNoOpenJobs => _t('There are no open jobs right now.', 'अभी कोई खुला काम नहीं है।', 'सध्या कोणतेही खुले काम नाही.');
  String get dlNoMyJobs =>
      _t('You have not taken any jobs yet. Accept one from Open jobs.', 'आपने अभी कोई काम नहीं लिया है। खुले काम में से एक स्वीकार करें।', 'तुम्ही अजून कोणतेही काम घेतलेले नाही. खुल्या कामांतून एक स्वीकारा.');
  String get dlLoadError => _t('Could not load this. Please try again.', 'यह लोड नहीं हो सका। कृपया फिर कोशिश करें।', 'हे लोड करता आले नाही. कृपया पुन्हा प्रयत्न करा.');
  String get dlRetry => _t('Try again', 'फिर कोशिश करें', 'पुन्हा प्रयत्न करा');
  String get dlActionError => _t('Something went wrong. Please try again.', 'कुछ गलत हो गया। कृपया फिर कोशिश करें।', 'काहीतरी चुकले. कृपया पुन्हा प्रयत्न करा.');

  // ---- Delivery partner: jobs ----------------------------------------------------------------------
  String get dlJobTitle => _t('Delivery job', 'डिलीवरी का काम', 'डिलिव्हरीचे काम');
  String get dlJobNotFound => _t('This job is not available any more.', 'यह काम अब उपलब्ध नहीं है।', 'हे काम आता उपलब्ध नाही.');
  String get dlPickup => _t('Pickup', 'उठाने की जगह', 'उचलण्याचे ठिकाण');
  String get dlDrop => _t('Drop', 'पहुँचाने की जगह', 'पोहोचवण्याचे ठिकाण');
  String get dlGoods => _t('Goods', 'माल', 'माल');
  String get dlFee => _t('Fee', 'शुल्क', 'मोबदला');
  String get dlTimeline => _t('Progress', 'प्रगति', 'प्रगती');
  String dlPlace(String village, String taluka) => taluka.isEmpty ? village : '$village, $taluka';
  String dlRoute(String from, String to) => '$from → $to';
  String dlWeightDistance(String kg, String km) => _t('$kg kg · $km km', '$kg किग्रा · $km किमी', '$kg किलो · $km किमी');
  String dlCollectCash(String amount) => _t('Collect cash: $amount', 'नकद लें: $amount', 'रोख घ्या: $amount');
  String get dlCashCollected => _t('Cash collected', 'नकद ले लिया', 'रोख घेतली');
  String get dlAcceptJob => _t('Accept job', 'काम स्वीकारें', 'काम स्वीकारा');
  String get dlAcceptAskTitle => _t('Accept this job?', 'यह काम स्वीकारें?', 'हे काम स्वीकारायचे?');
  String get dlAcceptAskBody => _t(
        'It will move to My jobs and no one else can take it.',
        'यह मेरे काम में चला जाएगा और कोई और इसे नहीं ले सकेगा।',
        'हे माझी कामे मध्ये जाईल आणि दुसरे कोणी ते घेऊ शकणार नाही.',
      );
  String get dlConfirmYes => _t('Yes', 'हाँ', 'होय');
  String get dlCancel => _t('Cancel', 'रद्द करें', 'रद्द करा');
  String get dlStepAskTitle => _t('Update this job?', 'यह काम अपडेट करें?', 'हे काम अपडेट करायचे?');
  String dlStepAskBody(String label) => _t(
        'Mark this job as "$label"?',
        'इस काम को "$label" के रूप में चिह्नित करें?',
        'हे काम "$label" म्हणून चिन्हांकित करायचे?',
      );

  String dlStatusLabel(String status) {
    switch (status) {
      case 'available':
        return _t('Open', 'खुला', 'खुले');
      case 'accepted':
        return _t('Accepted', 'स्वीकारा गया', 'स्वीकारले');
      case 'picked_up':
        return dlStepPickedUp;
      case 'on_the_way':
        return dlStepOnTheWay;
      case 'delivered':
        return dlStepDelivered;
      case 'cancelled':
        return _t('Cancelled', 'रद्द', 'रद्द');
      default:
        return status;
    }
  }

  String get dlStepPickedUp => _t('Picked up', 'उठा लिया', 'उचलले');
  String get dlStepOnTheWay => _t('On the way', 'रास्ते में', 'वाटेत');
  String get dlStepDelivered => _t('Delivered', 'पहुँचा दिया', 'पोहोचवले');

  /// The next button label for a job in [status] (null when there is no next step).
  String? dlNextStepLabel(String status) {
    switch (status) {
      case 'accepted':
        return dlStepPickedUp;
      case 'picked_up':
        return dlStepOnTheWay;
      case 'on_the_way':
        return dlStepDelivered;
      default:
        return null;
    }
  }

  // ---- Delivery partner: apply form ----------------------------------------------------------------
  String get dlApplyTitle => _t('Apply as delivery partner', 'डिलीवरी पार्टनर के रूप में आवेदन', 'डिलिव्हरी पार्टनर म्हणून अर्ज');
  String get dlVehicleType => _t('Vehicle type', 'वाहन का प्रकार', 'वाहनाचा प्रकार');
  String dlVehicleName(String type) {
    switch (type) {
      case 'tempo':
        return _t('Tempo', 'टेम्पो', 'टेम्पो');
      case 'pickup':
        return _t('Pickup truck', 'पिकअप ट्रक', 'पिकअप ट्रक');
      case 'tractor':
        return _t('Tractor', 'ट्रैक्टर', 'ट्रॅक्टर');
      default:
        return _t('Bike', 'बाइक', 'दुचाकी');
    }
  }

  String get dlVehicleNumber => _t('Vehicle number', 'वाहन नंबर', 'वाहन क्रमांक');
  String get dlCapacityKg => _t('Capacity (kg)', 'क्षमता (किग्रा)', 'क्षमता (किलो)');
  String get dlLicenceNumber => _t('Licence number', 'लाइसेंस नंबर', 'परवाना क्रमांक');
  String get dlServiceTalukas => _t('Service talukas', 'सेवा के तालुका', 'सेवेचे तालुके');
  String get dlSubmitApplication => _t('Submit application', 'आवेदन जमा करें', 'अर्ज सादर करा');
  String get dlErrVehicleNumber => _t('Enter your vehicle number.', 'अपना वाहन नंबर लिखें।', 'तुमचा वाहन क्रमांक लिहा.');
  String get dlErrCapacity => _t('Enter a whole number above 0.', '0 से बड़ी पूरी संख्या लिखें।', '0 पेक्षा मोठी पूर्ण संख्या लिहा.');
  String get dlErrLicence => _t('Licence number needs at least 4 characters.', 'लाइसेंस नंबर कम से कम 4 अक्षरों का हो।', 'परवाना क्रमांक किमान 4 अक्षरांचा असावा.');
  String get dlErrTaluka => _t('Choose at least one taluka.', 'कम से कम एक तालुका चुनें।', 'किमान एक तालुका निवडा.');

  // ---- Messages --------------------------------------------------------------------------------------
  String get msTitle => _t('Messages', 'संदेश', 'संदेश');
  String get msMarkAllRead => _t('Mark all read', 'सब पढ़ा हुआ करें', 'सर्व वाचले म्हणून चिन्हांकित करा');
  String get msEmpty => _t('No messages yet.', 'अभी कोई संदेश नहीं है।', 'अजून कोणतेही संदेश नाहीत.');
  String get msEmptyHint => _t(
        'Notices about your requests and orders will show up here.',
        'आपके अनुरोधों और ऑर्डर की सूचनाएँ यहाँ दिखेंगी।',
        'तुमच्या मागण्या आणि ऑर्डरच्या सूचना येथे दिसतील.',
      );
  String get msGuestBody => _t(
        'Sign in or create an account to see your messages.',
        'अपने संदेश देखने के लिए साइन इन करें या खाता बनाएँ।',
        'तुमचे संदेश पाहण्यासाठी साइन इन करा किंवा खाते तयार करा.',
      );
  String get msHindiNote => _t(
        '',
        'सर्वर के संदेश अभी अंग्रेज़ी में दिखाए जाते हैं।',
        '',
      );
  String get msUnreadLabel => _t('Unread', 'अनपढ़ा', 'न वाचलेले');
  String get msLoadError => dlLoadError;

  // ---- Barter -----------------------------------------------------------------------------------------
  String get btTitle => _t('Barter offers', 'वस्तु-विनिमय प्रस्ताव', 'वस्तुविनिमय प्रस्ताव');
  String get btSegIncoming => _t('Offers to me', 'मुझे आए प्रस्ताव', 'मला आलेले प्रस्ताव');
  String get btSegOutgoing => _t('My offers', 'मेरे प्रस्ताव', 'माझे प्रस्ताव');
  String get btEmptyIncoming => _t(
        'No one has made you a barter offer yet.',
        'अभी किसी ने आपको वस्तु-विनिमय प्रस्ताव नहीं भेजा।',
        'अजून कोणीही तुम्हाला वस्तुविनिमय प्रस्ताव पाठवलेला नाही.',
      );
  String get btEmptyOutgoing => _t(
        'You have not made a barter offer yet. Open a product that accepts barter to make one.',
        'आपने अभी कोई प्रस्ताव नहीं भेजा। प्रस्ताव भेजने के लिए वस्तु-विनिमय वाला उत्पाद खोलें।',
        'तुम्ही अजून प्रस्ताव पाठवलेला नाही. प्रस्ताव पाठवण्यासाठी वस्तुविनिमय स्वीकारणारे उत्पादन उघडा.',
      );
  String get btGuestBody => _t(
        'Sign in or create an account to see barter offers.',
        'वस्तु-विनिमय प्रस्ताव देखने के लिए साइन इन करें या खाता बनाएँ।',
        'वस्तुविनिमय प्रस्ताव पाहण्यासाठी साइन इन करा किंवा खाते तयार करा.',
      );
  String get btOffered => _t('Offered', 'दिया जाएगा', 'देऊ केलेले');
  String get btWanted => _t('Wanted', 'चाहिए', 'हवे');
  String btFromParty(String name) => _t('From $name', '$name की ओर से', '$name कडून');
  String btToParty(String name) => _t('To $name', '$name को', '$name यांना');
  String btQuantity(int q, String unit) => unit.isEmpty ? '$q' : '$q $unit';
  String btStatusLabel(String status) {
    switch (status) {
      case 'accepted':
        return _t('Accepted', 'स्वीकार', 'स्वीकारले');
      case 'rejected':
        return _t('Rejected', 'अस्वीकार', 'नाकारले');
      case 'countered':
        return _t('Counter offer', 'जवाबी प्रस्ताव', 'प्रति-प्रस्ताव');
      default:
        return _t('Waiting', 'प्रतीक्षा में', 'प्रतीक्षेत');
    }
  }

  String get btDetailTitle => _t('Barter offer', 'वस्तु-विनिमय प्रस्ताव', 'वस्तुविनिमय प्रस्ताव');
  String get btNotFound => _t('This offer is not available any more.', 'यह प्रस्ताव अब उपलब्ध नहीं है।', 'हा प्रस्ताव आता उपलब्ध नाही.');
  String get btHistory => _t('History', 'इतिहास', 'इतिहास');
  String btVersion(int n) => _t('Version $n', 'संस्करण $n', 'आवृत्ती $n');
  String get btNoteLabel => _t('Note', 'नोट', 'टीप');
  String get btAccept => _t('Accept', 'स्वीकारें', 'स्वीकारा');
  String get btReject => _t('Reject', 'अस्वीकार करें', 'नाकारा');
  String get btCounter => _t('Counter', 'जवाबी प्रस्ताव', 'प्रति-प्रस्ताव');
  String get btAcceptAskTitle => _t('Accept this offer?', 'यह प्रस्ताव स्वीकारें?', 'हा प्रस्ताव स्वीकारायचा?');
  String get btRejectAskTitle => _t('Reject this offer?', 'यह प्रस्ताव अस्वीकार करें?', 'हा प्रस्ताव नाकारायचा?');
  String get btAskBody => _t('This cannot be undone.', 'इसे वापस नहीं किया जा सकता।', 'हे परत घेता येणार नाही.');
  String get btCounterTitle => _t('Counter offer', 'जवाबी प्रस्ताव', 'प्रति-प्रस्ताव');
  String get btSendCounter => _t('Send counter offer', 'जवाबी प्रस्ताव भेजें', 'प्रति-प्रस्ताव पाठवा');
  String get btOfferedItem => _t('What you offer', 'आप क्या दे रहे हैं', 'तुम्ही काय देत आहात');
  String get btOfferedQuantity => _t('Offered quantity', 'दी जाने वाली मात्रा', 'देऊ केलेले प्रमाण');
  String get btWantedQuantity => _t('Wanted quantity', 'चाहिए वाली मात्रा', 'हवे असलेले प्रमाण');
  String get btUnit => _t('Unit', 'इकाई', 'एकक');
  String get btNoteOptional => _t('Note (optional)', 'नोट (वैकल्पिक)', 'टीप (पर्यायी)');
  String get btErrItem => _t('Enter at least 2 characters.', 'कम से कम 2 अक्षर लिखें।', 'किमान 2 अक्षरे लिहा.');
  String get btErrQuantity => _t('Enter a whole number above 0.', '0 से बड़ी पूरी संख्या लिखें।', '0 पेक्षा मोठी पूर्ण संख्या लिहा.');
  String get btNewTitle => _t('Make a barter offer', 'वस्तु-विनिमय प्रस्ताव भेजें', 'वस्तुविनिमय प्रस्ताव पाठवा');
  String btForListing(String title) => _t('For: $title', 'के लिए: $title', 'साठी: $title');
  String get btMissingListing => _t(
        'Open a product that accepts barter and make your offer from there.',
        'वस्तु-विनिमय वाला उत्पाद खोलें और वहीं से अपना प्रस्ताव भेजें।',
        'वस्तुविनिमय स्वीकारणारे उत्पादन उघडा आणि तेथून तुमचा प्रस्ताव पाठवा.',
      );
  String get btSendOffer => _t('Send offer', 'प्रस्ताव भेजें', 'प्रस्ताव पाठवा');
  String get btSent => _t('Offer sent.', 'प्रस्ताव भेज दिया गया।', 'प्रस्ताव पाठवला.');
  String get btActionDone => _t('Done.', 'हो गया।', 'झाले.');
  String get btBackToProducts => _t('Back', 'वापस', 'मागे');
}

