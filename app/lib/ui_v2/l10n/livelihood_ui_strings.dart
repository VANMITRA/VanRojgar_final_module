import 'package:flutter/widgets.dart';
import '../../../features/livelihood/livelihood_strings.dart';
import 'app_strings.dart';

/// Strings for the Livelihood module in the new design system.
/// Wraps and extends the domain translations with pure Marathi and Hindi text.
class LivelihoodUiStrings {
  final AppLanguage language;
  final LivelihoodStrings raw;

  const LivelihoodUiStrings(this.language, this.raw);

  static LivelihoodUiStrings of(BuildContext context, AppLanguage language) {
    return LivelihoodUiStrings(language, LivelihoodStrings(language.name));
  }

  String _t(String en, String hi, String mr) {
    switch (language) {
      case AppLanguage.hi:
        return hi;
      case AppLanguage.mr:
        return mr;
      case AppLanguage.en:
        return en;
    }
  }

  String get lhTitle => _t('My livelihood', 'मेरी आजीविका', 'माझी उपजीविका');
  String get lhGuestBody => _t(
        'Sign in or create an account to view your livelihood report.',
        'आजीविका रिपोर्ट देखने के लिए साइन इन करें या खाता बनाएँ।',
        'उपजीविका अहवाल पाहण्यासाठी साइन इन करा किंवा खाते तयार करा.',
      );
  String get lhNotCfrTitle => _t('Livelihood report', 'आजीविका रिपोर्ट', 'उपजीविका अहवाल');
  String get lhNotCfrBody => _t(
        'Livelihood reports are available for CFR holders.',
        'आजीविका रिपोर्ट केवल सीएफआर धारकों के लिए उपलब्ध हैं।',
        'उपजीविका अहवाल केवळ सीएफआर धारकांसाठी उपलब्ध आहेत.',
      );

  String get lhNoDetailsYet => _t(
        'You have not added details yet. Add them to get ideas that fit your land.',
        'आपने अभी विवरण नहीं जोड़े हैं। अपनी जमीन के अनुकूल विचार पाने के लिए विवरण जोड़ें।',
        'तुम्ही अजून तपशील जोडलेले नाहीत. तुमच्या जमिनीला साजेसे पर्याय मिळवण्यासाठी तपशील जोडा.',
      );
  String get lhDetailsSaved => _t(
        'Your details are saved on this phone.',
        'आपके विवरण इस फोन पर सुरक्षित हैं।',
        'तुमचे तपशील या फोनवर सुरक्षित आहेत.',
      );
  String get lhSyncPending => _t(
        'Saved on phone. Will update when connected.',
        'फोन पर सुरक्षित। कनेक्शन मिलने पर अपडेट होगा।',
        'फोनवर सेव्ह केले. इंटरनेट उपलब्ध झाल्यावर अपडेट होईल.',
      );

  String get lhCreateReport => _t('Create my livelihood report', 'मेरा आजीविका रिपोर्ट बनाएँ', 'माझा उपजीविका अहवाल तयार करा');
  String get lhSavePdf => _t('Save report as PDF', 'रिपोर्ट पीडीएफ के रूप में सहेजें', 'अहवाल पीडीएफ म्हणून जतन करा');
  String get lhViewReport => _t('View my report', 'मेरा रिपोर्ट देखें', 'माझा अहवाल पहा');
  String get lhUpdateDetails => _t('Update my details', 'मेरे विवरण बदलें', 'माझे तपशील बदला');

  String get lhHubSection => _t('Explore more', 'अधिक जानकारी', 'अधिक माहिती');
  String get lhHubSchemes => _t('Government schemes', 'सरकारी योजनाएँ', 'शासकीय योजना');
  String get lhHubSchemesSub => _t(
        'Official government support programs and subsidies',
        'आधिकारिक सहायता कार्यक्रम और अनुदान',
        'अधिकृत साहाय्य योजना आणि अनुदान',
      );
  String get lhHubResources => _t('Nearby resources', 'नजदीकी संसाधन', 'परिसरातील संसाधने');
  String get lhHubResourcesSub => _t(
        'Water bodies, markets and processing centres',
        'जलस्रोत, बाजार और प्रसंस्करण केंद्र',
        'पाण्याचे स्रोत, बाजार आणि प्रक्रिया केंद्रे',
      );
  String get lhHubMap => _t('Interactive map', 'नक्शा', 'नकाशा');
  String get lhHubMapSub => _t(
        'Your plot, local boundary and mapped points',
        'आपकी जमीन, स्थानीय सीमा और चिन्हित बिंदु',
        'तुमची जमीन, स्थानिक मर्यादा आणि नोंदवलेली ठिकाणे',
      );
  String get lhHubPolicy => _t('Wildlife policy', 'वन्यजीव नीति', 'वन्यजीव धोरण');
  String get lhHubPolicySub => _t(
        'Safe practices that protect forest and animals',
        'जंगल और पशुओं की रक्षा करने वाले नियम',
        'जंगल आणि वन्यजीवांचे रक्षण करणारे नियम',
      );

  String get lhDeleteAnswers => _t('Delete my answers', 'मेरे विवरण हटाएँ', 'माझे तपशील हटवा');
  String get lhDeleteConfirmTitle => _t('Delete your answers?', 'अपने विवरण हटाएँ?', 'तुमचे तपशील हटवायचे?');
  String get lhDeleteConfirmBody => _t(
        'This removes your answers from this phone.',
        'इससे आपके विवरण इस फोन से हटा दिए जाएँगे।',
        'यामुळे तुमचे तपशील या फोनवरून काढून टाकले जातील.',
      );

  String get lhReportLoadError => _t(
        'Could not load the livelihood report.',
        'आजीविका रिपोर्ट लोड नहीं हो सकी।',
        'उपजीविका अहवाल लोड करता आला नाही.',
      );
  String get lhRetry => _t('Retry', 'पुनः प्रयास करें', 'पुन्हा प्रयत्न करा');
  String get lhDeleteConfirmOk => _t('Delete', 'हटाएँ', 'हटवा');
  String get lhCancel => _t('Cancel', 'रद्द करें', 'रद्द करा');

  String get lhWildlifeSafe => _t('Safe for wildlife', 'वन्यजीवों के लिए सुरक्षित', 'वन्यजीवांसाठी सुरक्षित');
  String get lhWildlifeCaution => _t('Wildlife caution', 'वन्यजीव सावधानी', 'वन्यजीव दक्षता');
  String get lhWildlifeHigh => _t('Wildlife warning', 'वन्यजीव चेतावनी', 'वन्यजीव जोखीम');

  String get lhGramSabhaOnly => _t(
        'Community forest: use only through the Gram Sabha',
        'सामुदायिक वन: उपयोग केवल ग्रामसभा के माध्यम से',
        'सामूहिक वन: वापर केवळ ग्रामसभेद्वारेच',
      );
  String get lhIdeasDraftBadge => _t('Draft ideas', 'प्रारूप विचार', 'प्रारूप पर्याय');
  String get lhToVerify => _t('Check locally', 'स्थानीय स्तर पर जाँचें', 'स्थानिक पातळीवर तपासा');
  String get lhOpenSchemeLink => _t('Official portal', 'आधिकारिक पोर्टल', 'अधिकृत संकेतस्थळ');
  String get lhMissingNotAvailable => _t('Not available', 'उपलब्ध नहीं', 'उपलब्ध नाही');
  String get lhReportFor => _t('Report for', 'रिपोर्ट:', 'अहवाल:');
  String get lhPlotCentre => _t('Plot centre', 'जमीन केंद्र', 'प्लॉट मध्य');
  String get lhVillageCentre => _t('Village centre', 'गाँव केंद्र', 'गाव मध्य');

  String get lhStepLand => _t('Land & soil', 'जमीन और मिट्टी', 'जमीन आणि माती');
  String get lhStepAnimals => _t('Livestock', 'पशुधन', 'पशुधन');
  String get lhStepAssets => _t('Tools & equipment', 'उपकरण और साधन', 'साधने आणि उपकरणे');
  String get lhStepWork => _t('Experience & income', 'अनुभव और आय', 'अनुभव आणि उत्पन्न');
  String get lhStepLocation => _t('Plot location', 'जमीन की स्थिति', 'जमिनीचे स्थान');

  String get lhNextStep => _t('Next', 'आगे बढ़ें', 'पुढे चला');
  String get lhPrevStep => _t('Back', 'पीछे', 'मागे');
  String get lhCreateReportBtn => _t('Create report', 'रिपोर्ट बनाएँ', 'अहवाल तयार करा');
  String get lhAreaLabel => _t('Area', 'क्षेत्रफल', 'क्षेत्रफळ');
  String get lhAcre => _t('Acre', 'एकड़', 'एकर');
  String get lhGuntha => _t('Guntha', 'गुंठा', 'गुंठा');
  String get lhHectare => _t('Hectare', 'हेक्टेयर', 'हेक्टर');
}
