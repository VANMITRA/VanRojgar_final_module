import '../data/villages.dart';
import '../models/order_models.dart';
import 'app_strings.dart';

/// Strings for the Orders tab (`/orders`), the Order detail page (`/orders/:id`),
/// and the order action confirmation sheets/dialogs (Phase 7).
///
/// English, Hindi, and Marathi. The Hindi and Marathi texts are machine drafts
/// (not yet reviewed by a native speaker). Every public getter and method starts
/// with `od` so it cannot clash with other phases at merge time.
extension OrdersStrings on AppStrings {
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

  // ---- Guest view on /orders -------------------------------------------------------------------
  String get odGuestTitle => _t(
        'Sign in to see your orders',
        'अपने ऑर्डर देखने के लिए साइन इन करें',
        'तुमच्या ऑर्डर्स पाहण्यासाठी साइन इन करा',
      );

  String get odGuestSubtitle => _t(
        'Track your produce requests, seller approvals, and payment steps.',
        'अपने वनोपज अनुरोध, विक्रेता स्वीकृति और भुगतान चरण देखें।',
        'तुमच्या वनोपज मागण्या, विक्रेता मंजुरी आणि पेमेंट टप्पे पहा.',
      );

  // ---- Segments on /orders ---------------------------------------------------------------------
  String get odSegActive => _t('Active', 'सक्रिय', 'सक्रिय');
  String get odSegPast => _t('Past', 'पिछले', 'मागील');

  String get odSegNewRequests => _t('New requests', 'नए अनुरोध', 'नवीन मागण्या');
  String get odSegInProgress => _t('In progress', 'प्रगति में', 'सुरू असलेले');
  String get odSegDone => _t('Done', 'पूरा हुआ', 'पूर्ण झाले');

  // ---- Empty states on /orders -----------------------------------------------------------------
  String get odEmptyBuyerActive => _t(
        'No active orders right now.',
        'अभी कोई सक्रिय ऑर्डर नहीं है।',
        'सध्या कोणतीही सक्रिय ऑर्डर नाही.',
      );

  String get odEmptyBuyerPast => _t(
        'No past orders yet.',
        'अभी कोई पिछला ऑर्डर नहीं है।',
        'अजून कोणतीही मागील ऑर्डर नाही.',
      );

  String get odEmptySellerNew => _t(
        'No new requests waiting for you.',
        'आपके लिए कोई नया अनुरोध प्रतीक्षा में नहीं है।',
        'तुमच्यासाठी कोणतीही नवीन मागणी प्रलंबित नाही.',
      );

  String get odEmptySellerInProgress => _t(
        'No orders in progress right now.',
        'अभी कोई ऑर्डर प्रगति में नहीं है।',
        'सध्या कोणतीही ऑर्डर सुरू नाही.',
      );

  String get odEmptySellerDone => _t(
        'No completed or closed requests yet.',
        'अभी कोई पूरा या बंद अनुरोध नहीं है।',
        'अजून कोणतीही पूर्ण किंवा बंद मागणी नाही.',
      );

  // ---- Status chip labels ----------------------------------------------------------------------
  String odStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return _t(
          'Waiting for the seller',
          'विक्रेता की प्रतीक्षा में',
          'विक्रेत्याच्या प्रतीक्षेत',
        );
      case OrderStatus.approved:
        return _t('Approved', 'स्वीकृत', 'मंजूर');
      case OrderStatus.countered:
        return _t(
          'Seller sent another offer',
          'विक्रेता ने नया प्रस्ताव भेजा',
          'विक्रेत्याने नवीन प्रस्ताव पाठवला',
        );
      case OrderStatus.rejected:
        return _t('Rejected', 'अस्वीकृत', 'नाकारले');
      case OrderStatus.paymentReported:
        return _t(
          'Payment reported',
          'भुगतान की सूचना दी गई',
          'पेमेंट कळवले',
        );
      case OrderStatus.paymentConfirmed:
        return _t(
          'Payment confirmed',
          'भुगतान की पुष्टि हुई',
          'पेमेंटची पुष्टी झाली',
        );
      case OrderStatus.completed:
        return _t('Completed', 'पूरा हुआ', 'पूर्ण झाले');
      case OrderStatus.cancelled:
        return _t('Cancelled', 'रद्द किया गया', 'रद्द केले');
    }
  }

  // ---- Card & line summaries -------------------------------------------------------------------
  String odProductSummary(List<OrderLine> lines) {
    if (lines.isEmpty) return '';
    final first = lines.first;
    final title = first.localizedTitle(language);
    final unit = first.localizedUnit(language);
    final firstPart = _t(
      '$title x ${first.quantity} $unit',
      '$title × ${first.quantity} $unit',
      '$title × ${first.quantity} $unit',
    );
    final extra = lines.length - 1;
    if (extra <= 0) return firstPart;
    return _t(
      '$firstPart + $extra more',
      '$firstPart + $extra और',
      '$firstPart + $extra इतर',
    );
  }

  // ---- Order detail labels ---------------------------------------------------------------------
  String get odDetailTitle => _t('Order details', 'ऑर्डर विवरण', 'ऑर्डर तपशील');
  String get odNotFound => _t('Order not found.', 'ऑर्डर नहीं मिला।', 'ऑर्डर सापडली नाही.');

  String odOrderIdLabel(String id) {
    final clean = id.replaceFirst(RegExp(r'^ord-', caseSensitive: false), '');
    return _t('Request #$id', 'अनुरोध #$clean', 'मागणी #$clean');
  }

  String get odSellerLabel => _t('Seller', 'विक्रेता', 'विक्रेता');
  String get odBuyerLabel => _t('Buyer', 'खरीदार', 'खरेदीदार');
  String get odItemsHeading => _t('Items', 'वस्तुएँ', 'वस्तू');
  String get odTotalLabel => _t('Total', 'कुल', 'एकूण');
  String get odDeliveryPrefLabel => _t('Delivery preference', 'सुपुर्दगी विकल्प', 'वितरण पर्याय');
  String get odDropVillageLabel => _t('Drop village', 'सुपुर्दगी गाँव', 'वितरण गाव');
  String get odPaymentMethodLabel => _t('Payment method', 'भुगतान का तरीका', 'पेमेंट पद्धत');

  String odPaymentMethodText(String method) {
    if (method == 'upi') {
      return _t(
        'UPI (after seller approval)',
        'UPI (विक्रेता की स्वीकृति के बाद)',
        'UPI (विक्रेत्याच्या मंजुरीनंतर)',
      );
    }
    return _t(
      'Cash on receipt',
      'प्राप्ति पर नकद',
      'मिळाल्यावर रोख',
    );
  }

  String get odPaymentRefLabel => _t('Payment reference', 'भुगतान संदर्भ', 'पेमेंट संदर्भ');
  String get odNoteLabel => _t('Note', 'टिप्पणी', 'टीप');
  String get odRejectionReasonLabel =>
      _t('Reason for rejection', 'अस्वीकृति का कारण', 'नाकारण्याचे कारण');

  String get odCounterOfferHeading =>
      _t('Seller offer', 'विक्रेता का प्रस्ताव', 'विक्रेत्याचा प्रस्ताव');

  String odCounterOfferSummary(int qty, String unit, String price) => _t(
        '$qty $unit at $price per $unit',
        '$qty $unit, $price प्रति $unit पर',
        '$qty $unit, $price प्रति $unit दराने',
      );

  String get odTimelineHeading => _t('Status timeline', 'स्थिति समयरेखा', 'स्थिती कालरेषा');

  // ---- Buyer action labels & sheets ------------------------------------------------------------
  String get odBtnCancelRequest => _t('Cancel request', 'अनुरोध रद्द करें', 'मागणी रद्द करा');
  String get odCancelConfirmTitle =>
      _t('Cancel this request?', 'क्या यह अनुरोध रद्द करें?', 'ही मागणी रद्द करायची का?');
  String get odCancelConfirmBody => _t(
        'The seller has not responded yet. Once cancelled, this request cannot be reopened.',
        'विक्रेता ने अभी उत्तर नहीं दिया है। रद्द करने के बाद इसे फिर से नहीं खोला जा सकता।',
        'विक्रेत्याने अद्याप प्रतिसाद दिलेला नाही. एकदा रद्द केल्यावर ही मागणी पुन्हा उघडता येणार नाही.',
      );
  String get odCancelKeepBtn => _t('Keep request', 'अनुरोध रखें', 'मागणी ठेवा');
  String get odCancelConfirmBtn => _t('Yes, cancel', 'हाँ, रद्द करें', 'होय, रद्द करा');

  String get odBtnAcceptOffer => _t('Accept offer', 'प्रस्ताव स्वीकारें', 'प्रस्ताव स्वीकारा');
  String get odBtnDeclineOffer => _t('Decline offer', 'प्रस्ताव अस्वीकारें', 'प्रस्ताव नाकारा');

  String get odBtnIHavePaid => _t('I have paid', 'मैंने भुगतान कर दिया है', 'मी पेमेंट केले आहे');
  String get odPaidSheetTitle =>
      _t('Report UPI payment', 'UPI भुगतान की सूचना दें', 'UPI पेमेंट कळवा');
  String get odPaidSheetSubtitle => _t(
        'Enter the payment reference (6 to 30 characters) from your UPI app.',
        'अपने UPI ऐप से भुगतान संदर्भ (6 से 30 अक्षर या अंक) लिखें।',
        'तुमच्या UPI अ‍ॅपमधील पेमेंट संदर्भ (6 ते 30 अक्षरे किंवा अंक) लिहा.',
      );
  String get odPaidRefHint =>
      _t('6 to 30 characters', '6 से 30 अक्षर या अंक', '6 ते 30 अक्षरे किंवा अंक');
  String get odPaidRefError => _t(
        'Enter a reference between 6 and 30 characters.',
        '6 से 30 अक्षरों के बीच का संदर्भ लिखें।',
        '6 ते 30 अक्षरांचा संदर्भ लिहा.',
      );
  String get odPaidSubmitBtn => _t('Submit reference', 'संदर्भ भेजें', 'संदर्भ पाठवा');

  // ---- Seller action labels & sheets -----------------------------------------------------------
  String get odBtnApprove => _t('Approve', 'स्वीकार करें', 'मंजूर करा');
  String get odBtnReject => _t('Reject', 'अस्वीकार करें', 'नाकारा');
  String get odRejectSheetTitle =>
      _t('Reject request', 'अनुरोध अस्वीकार करें', 'मागणी नाकारा');
  String get odRejectReasonHint => _t(
        'Explain why this request cannot be fulfilled',
        'बताएँ कि यह अनुरोध क्यों पूरा नहीं किया जा सकता',
        'ही मागणी का पूर्ण करता येत नाही ते सांगा',
      );
  String get odRejectReasonError =>
      _t('Please enter a reason.', 'कृपया कारण लिखें।', 'कृपया कारण लिहा.');
  String get odRejectSubmitBtn =>
      _t('Confirm reject', 'अस्वीकृति पक्की करें', 'नाकारणे निश्चित करा');

  String get odBtnCounter =>
      _t('Send another offer', 'दूसरा प्रस्ताव भेजें', 'दुसरा प्रस्ताव पाठवा');
  String get odCounterSheetTitle =>
      _t('Send another offer', 'दूसरा प्रस्ताव भेजें', 'दुसरा प्रस्ताव पाठवा');
  String odCounterQtyLabel(String unit) =>
      _t('Quantity ($unit)', 'मात्रा ($unit)', 'प्रमाण ($unit)');
  String odCounterPriceLabel(String unit) =>
      _t('Price per $unit (₹)', 'प्रति $unit कीमत (₹)', 'प्रति $unit किंमत (₹)');
  String get odCounterNoteLabel =>
      _t('Note (optional)', 'टिप्पणी (वैकल्पिक)', 'टीप (पर्यायी)');
  String odCounterRulesHint(int minQty, int maxQty, String unit, String mrp) => _t(
        'Allowed: $minQty–$maxQty $unit · Max MRP: $mrp',
        'मान्य: $minQty–$maxQty $unit · अधिकतम एमआरपी: $mrp',
        'मान्य: $minQty–$maxQty $unit · कमाल एमआरपी: $mrp',
      );
  String odCounterQtyError(int minQty, int maxQty, String unit) => _t(
        'Quantity must be between $minQty and $maxQty $unit.',
        'मात्रा $minQty और $maxQty $unit के बीच होनी चाहिए।',
        'प्रमाण $minQty आणि $maxQty $unit दरम्यान असावे.',
      );
  String odCounterPriceError(String mrp) => _t(
        'Price must be at least ₹1 and at most MRP ($mrp).',
        'कीमत कम से कम ₹1 और अधिकतम एमआरपी ($mrp) तक होनी चाहिए।',
        'किंमत किमान ₹1 आणि कमाल एमआरपी ($mrp) पर्यंत असावी.',
      );
  String get odCounterSubmitBtn => _t('Send offer', 'प्रस्ताव भेजें', 'प्रस्ताव पाठवा');

  String get odBtnConfirmPayment => _t(
        'Confirm payment received',
        'भुगतान प्राप्ति की पुष्टि करें',
        'पेमेंट मिळाल्याची पुष्टी करा',
      );
  String get odBtnMarkCompleted =>
      _t('Mark completed', 'पूरा चिह्नित करें', 'पूर्ण म्हणून चिन्हांकित करा');

  // ---- Localization helpers for dates, village names, and sample text --------------------------
  String odFormatDate(DateTime date) {
    const monthsEn = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const monthsHi = [
      'जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
      'जुलाई', 'अगस्त', 'सितंबर', 'अक्तूबर', 'नवंबर', 'दिसंबर',
    ];
    const monthsMr = [
      'जानेवारी', 'फेब्रुवारी', 'मार्च', 'एप्रिल', 'मे', 'जून',
      'जुलै', 'ऑगस्ट', 'सप्टेंबर', 'ऑक्टोबर', 'नोव्हेंबर', 'डिसेंबर',
    ];
    final mIndex = (date.month - 1).clamp(0, 11);
    final month = _t(monthsEn[mIndex], monthsHi[mIndex], monthsMr[mIndex]);
    return '${date.day} $month ${date.year}';
  }

  String odVillageName(String? villageId) {
    if (villageId == null || villageId.isEmpty) return '';
    for (final v in pilotVillages) {
      if (v.id == villageId) {
        return v.label(language);
      }
    }
    return villageId;
  }

  String odLocalizePartyName(String rawName) {
    if (language == AppLanguage.en) return rawName;
    final gramSabhaMatch = RegExp(r'^Sample Gram Sabha\s*(\d*)$').firstMatch(rawName);
    if (gramSabhaMatch != null) {
      final numPart = gramSabhaMatch.group(1) ?? '';
      final suffix = numPart.isEmpty ? '' : ' $numPart';
      return _t(rawName, 'ग्राम सभा$suffix', 'ग्रामसभा$suffix');
    }
    final cfrMatch = RegExp(r'^Sample CFR holder\s*(\d*)$', caseSensitive: false).firstMatch(rawName);
    if (cfrMatch != null) {
      final numPart = cfrMatch.group(1) ?? '';
      final suffix = numPart.isEmpty ? '' : ' $numPart';
      return _t(rawName, 'सीएफआर धारक$suffix', 'सीएफआर धारक$suffix');
    }
    final sellerMatch = RegExp(r'^Sample Seller\s*(.*)$', caseSensitive: false).firstMatch(rawName);
    if (sellerMatch != null) {
      final rest = (sellerMatch.group(1) ?? '').trim();
      final suffix = rest.isEmpty ? '' : ' $rest';
      return _t(rawName, 'विक्रेता$suffix', 'विक्रेता$suffix');
    }
    final buyerMatch = RegExp(r'^Sample Buyer\s*(\d*)$', caseSensitive: false).firstMatch(rawName);
    if (buyerMatch != null) {
      final numPart = buyerMatch.group(1) ?? '';
      final suffix = numPart.isEmpty ? '' : ' $numPart';
      return _t(rawName, 'खरीदार$suffix', 'खरेदीदार$suffix');
    }
    return rawName;
  }

  String odLocalizeNote(String rawNote) {
    if (rawNote.isEmpty || language == AppLanguage.en) return rawNote;
    switch (rawNote) {
      case 'Sample request for wholesale market supply':
        return _t(
          rawNote,
          'थोक बाज़ार आपूर्ति के लिए अनुरोध',
          'घाऊक बाजार पुरवठ्यासाठी मागणी',
        );
      case 'Sample pickup request from village collection center':
        return _t(
          rawNote,
          'गाँव संग्रह केंद्र से स्वयं उठाने का अनुरोध',
          'गाव संकलन केंद्रातून स्वतः घेऊन जाण्यासाठी मागणी',
        );
      case 'Sample seasonal fruit order':
        return _t(
          rawNote,
          'मौसमी फलों का ऑर्डर',
          'हंगामी फळांची ऑर्डर',
        );
      case 'Current harvest stock is 20 kg at ₹90 per kg':
        return _t(
          rawNote,
          'वर्तमान फसल स्टॉक ₹90 प्रति किग्रा पर 20 किग्रा उपलब्ध है',
          'सध्याचा हंगामी साठा ₹90 प्रति किलो दराने 20 किलो उपलब्ध आहे',
        );
      case 'Harvest batch already sold to local mandi':
        return _t(
          rawNote,
          'फसल का बैच पहले ही स्थानीय मंडी में बिक चुका है',
          'हंगामी साठा स्थानिक मंडईत आधीच विकला गेला आहे',
        );
      default:
        // If a note looks like a numeric/UPI reference or non-English text, return as is;
        // if it has English words in Hindi/Marathi mode, provide a safe localized label.
        if (RegExp(r'^[0-9]+$').hasMatch(rawNote)) return rawNote;
        if (RegExp(r'[A-Za-z]').hasMatch(rawNote)) {
          return _t(rawNote, 'विवरण', 'तपशील');
        }
        return rawNote;
    }
  }
}

