import 'package:flutter/widgets.dart';

/// Centralized multilingual input hints and labels for text fields across EN, MR, and HI.
class AppInputHints {
  AppInputHints._();

  static String _loc(BuildContext context) {
    try {
      return Localizations.localeOf(context).languageCode;
    } catch (_) {
      return 'mr';
    }
  }

  // --- Auth / Registration ---

  static String phone(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'अपना 10-अंकों का मोबाइल नंबर दर्ज करें';
      case 'mr':
        return 'तुमचा १०-अंकी मोबाईल नंबर टाका';
      default:
        return 'Enter your 10-digit mobile number';
    }
  }

  static String phoneLabel(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'मोबाइल नंबर (Mobile Number)';
      case 'mr':
        return 'मोबाईल क्रमांक (Mobile Number)';
      default:
        return 'Mobile Number';
    }
  }

  static String password(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'अपना 6-अंकों का पिन या पासवर्ड दर्ज करें';
      case 'mr':
        return 'तुमचा ६-अंकी पिन किंवा पासवर्ड टाका';
      default:
        return 'Enter your 6-digit PIN / password';
    }
  }

  static String passwordLabel(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'पासवर्ड / पिन (Password)';
      case 'mr':
        return 'पासवर्ड / पिन (Password)';
      default:
        return 'Password / PIN';
    }
  }

  static String fullName(BuildContext context, {bool isGs = false}) {
    if (isGs) {
      switch (_loc(context)) {
        case 'hi':
          return 'उदा. ग्रामसभा देवगाव';
        case 'mr':
          return 'उदा. ग्रामसभा देवगाव';
        default:
          return 'e.g. Gram Sabha Devgaon';
      }
    }
    switch (_loc(context)) {
      case 'hi':
        return 'उदा. गणेश वाघ';
      case 'mr':
        return 'उदा. गणेश वाघ';
      default:
        return 'e.g. Ganesh Wagh';
    }
  }

  static String selectTaluka(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'तालुका चुनें (Select Taluka)';
      case 'mr':
        return 'तालुका निवडा (Select Taluka)';
      default:
        return 'Select Taluka';
    }
  }

  static String selectVillage(BuildContext context, bool hasTaluka) {
    if (!hasTaluka) {
      switch (_loc(context)) {
        case 'hi':
          return 'पहले तालुका चुनें (Select Taluka first)';
        case 'mr':
          return 'प्रथम तालुका निवडा (Select Taluka first)';
        default:
          return 'Select Taluka first';
      }
    }
    switch (_loc(context)) {
      case 'hi':
        return 'गाँव चुनें (Select Village)';
      case 'mr':
        return 'गाव निवडा (Select Village)';
      default:
        return 'Select Village';
    }
  }

  static String typeVillage(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'गाँव का नाम टाइप करें (Type Village Name)';
      case 'mr':
        return 'गावाचे नाव टाईप करा (Type Village Name)';
      default:
        return 'Type Village Name';
    }
  }

  static String representative(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'उदा. सचिव या मुख्य प्रतिनिधि का नाम';
      case 'mr':
        return 'उदा. सचिव किंवा मुख्य प्रतिनिधी नाव';
      default:
        return 'e.g. Secretary or Chief Representative Name';
    }
  }

  static String organization(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'उदा. सह्याद्री आयुर्वेद';
      case 'mr':
        return 'उदा. सह्याद्री आयुर्वेद';
      default:
        return 'e.g. Sahyadri Ayurveda';
    }
  }

  static String city(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'उदा. नासिक / पुणे';
      case 'mr':
        return 'उदा. नाशिक / पुणे';
      default:
        return 'e.g. Nashik / Pune';
    }
  }

  // --- Search / Marketplace ---

  static String searchForest(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'शहद, बांस, जड़ी-बूटी खोजें या आइटम कोड (VR-...) डालें';
      case 'mr':
        return 'मध, बांबू, औषधी शोधा किंवा वस्तू कोड (VR-...) टाका';
      default:
        return 'Search honey, bamboo... or paste an item code (VR-...)';
    }
  }

  static String searchMyListings(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'अपने वन उत्पाद खोजें (Search my listings)...';
      case 'mr':
        return 'माझी उत्पादने शोधा (Search my listings)...';
      default:
        return 'Search my listings...';
    }
  }

  static String buyerSearch(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'प्रमाणित वनोत्पाद, शहद, जड़ी-बूटियाँ खोजें...';
      case 'mr':
        return 'प्रमाणित वनोपज, मध, औषधी वनस्पती शोधा...';
      default:
        return 'Search authenticated bulk MFP, herbs, honey...';
    }
  }

  // --- Add / Edit Listing ---

  static String listingTitleMr(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'स्थानीय/देवनागरी नाम (उदा. शुद्ध जंगली शहद)';
      case 'mr':
        return 'स्थानिक/मराठी नाव (उदा. शुद्ध रान मध)';
      default:
        return 'Local/Devanagari name (e.g. Pure Wild Honey)';
    }
  }

  static String listingTitleEn(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'अंग्रेजी नाम (उदा. Pure Wild Forest Honey)';
      case 'mr':
        return 'इंग्रजी नाव (उदा. Pure Wild Forest Honey)';
      default:
        return 'English name (e.g. Pure Wild Forest Honey)';
    }
  }

  static String listingDescription(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'संग्रह स्थान, गुणवत्ता एवं विशेष विवरण';
      case 'mr':
        return 'गोळा करण्याचे ठिकाण, गुणवत्ता व विशेष माहिती';
      default:
        return 'Harvest location, quality and special details';
    }
  }

  static String quantityHint(BuildContext context) {
    return _loc(context) == 'en' ? '50' : '५०';
  }

  static String priceHint(BuildContext context) {
    return _loc(context) == 'en' ? '150' : '१५०';
  }

  static String barterWants(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'उदा. बांस की टोकरियां या जैविक बीज';
      case 'mr':
        return 'उदा. बांबू टोपल्या किंवा सेंद्रिय बियाणे';
      default:
        return 'e.g. Bamboo baskets or organic seeds';
    }
  }

  static String sourceForest(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'उदा. सीएफआर नासिक कंपार्टमेंट 42';
      case 'mr':
        return 'उदा. CFR नाशिक कंपार्टमेंट ४२';
      default:
        return 'e.g. CFR Nashik Compartment 42';
    }
  }

  // --- Trade / Requests / Orders ---

  static String rejectReason(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'उदा. स्थानीय सामुदायिक उपयोग हेतु स्टॉक आरक्षित है';
      case 'mr':
        return 'उदा. स्थानिक वापरासाठी साठा राखीव आहे / Stock reserved for local use';
      default:
        return 'e.g. Stock reserved for local community use';
    }
  }

  static String requestPurpose(BuildContext context) {
    switch (_loc(context)) {
      case 'hi':
        return 'उदा. स्थानीय आयुर्वेदिक औषधि निर्माण हेतु';
      case 'mr':
        return 'उदा. स्थानिक आयुर्वेदिक औषध निर्मितीसाठी';
      default:
        return 'e.g. For local Ayurvedic medicine preparation';
    }
  }

  // --- Delivery ---

  static String deliveryVehicle(BuildContext context) {
    return 'MH 15 AB 1234';
  }

  static String deliveryPayload(BuildContext context) {
    return _loc(context) == 'en' ? '50' : '५०';
  }

  static String deliveryLicense(BuildContext context) {
    return 'MH15 20210001234';
  }
}
