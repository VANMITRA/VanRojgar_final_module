import '../api/v2_api_client.dart';
import 'app_strings.dart';

/// Messages for when the server cannot be reached or refuses something.
/// English, Hindi and Marathi. The Hindi and Marathi texts are machine drafts (not yet read by a native speaker).
extension LiveStrings on AppStrings {
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

  String get lvNetworkError => _t(
        'Cannot reach the server. Check your internet and try again.',
        'सर्वर तक नहीं पहुँच पाए। इंटरनेट जाँचें और फिर कोशिश करें।',
        'सर्व्हरशी संपर्क होत नाही. इंटरनेट तपासा आणि पुन्हा प्रयत्न करा.',
      );
  String get lvSignInFailed => _t(
        'Mobile number or PIN is wrong.',
        'मोबाइल नंबर या पिन गलत है।',
        'मोबाईल नंबर किंवा पिन चुकीचा आहे.',
      );
  String get lvSignUpFailed => _t(
        'Could not create the account. This number may already be registered.',
        'खाता नहीं बन सका। यह नंबर पहले से दर्ज हो सकता है।',
        'खाते तयार होऊ शकले नाही. हा नंबर आधीच नोंदवलेला असू शकतो.',
      );
  String get lvSendFailed => _t(
        'Your request could not be sent. Please try again.',
        'आपका अनुरोध नहीं भेजा जा सका। कृपया फिर कोशिश करें।',
        'तुमची मागणी पाठवता आली नाही. कृपया पुन्हा प्रयत्न करा.',
      );
  String get lvSomeNotSent => _t(
        'Some products could not be requested and are still in your cart.',
        'कुछ उत्पादों का अनुरोध नहीं हो सका और वे कार्ट में ही हैं।',
        'काही उत्पादनांची मागणी करता आली नाही आणि ती कार्टमध्येच आहेत.',
      );
  String get lvActionFailed => _t(
        'That did not go through. Please try again.',
        'यह नहीं हो पाया। कृपया फिर कोशिश करें।',
        'हे होऊ शकले नाही. कृपया पुन्हा प्रयत्न करा.',
      );

  /// A short message for any error from the server.
  String lvErrorText(Object error, {String? fallback}) {
    if (error is V2NetworkException) return lvNetworkError;
    return fallback ?? lvActionFailed;
  }
}
