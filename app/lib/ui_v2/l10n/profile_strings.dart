import 'app_strings.dart';

/// Structured item for a single row on the Credits page.
class ProfileCreditItem {
  final String what;
  final String source;
  final String terms;

  const ProfileCreditItem({
    required this.what,
    required this.source,
    required this.terms,
  });
}

/// A titled group of credit cards on the Credits page.
class ProfileCreditGroup {
  final String heading;
  final List<ProfileCreditItem> items;

  const ProfileCreditGroup({
    required this.heading,
    required this.items,
  });
}

/// A titled section on the Privacy or About page.
class ProfileTextSection {
  final String heading;
  final String body;

  const ProfileTextSection({
    required this.heading,
    required this.body,
  });
}

/// Strings for Phase 9: Profile, Settings, My activity, More, About, Credits, and Privacy.
///
/// NOTE: The Hindi and Marathi translations in this file are machine-written drafts
/// and have not yet been reviewed by a native speaker.
/// Every getter and method name starts with `pf` to avoid collisions across branches.
extension ProfileStrings on AppStrings {
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

  // ---- Draft notice shown on long translated pages in Hindi and Marathi -------------------------
  String get pfDraftNotice => _t(
        '',
        'नोट: यह हिन्दी अनुवाद एक मशीनी मसौदा है और अभी किसी मातृभाषी द्वारा जाँचा नहीं गया है।',
        'टीप: हा मराठी अनुवाद मशीनी मसुदा आहे आणि अद्याप मातृभाषकाकडून तपासलेला नाही.',
      );

  // ---- Account card & Sign-out confirmation -----------------------------------------------------
  String get pfAccountSectionTitle => _t('Account', 'खाता', 'खाते');

  String get pfSignOutConfirmTitle => _t(
        'Sign out?',
        'साइन आउट करें?',
        'साइन आउट करायचे?',
      );

  String get pfSignOutConfirmBody => _t(
        'Are you sure you want to sign out of your account on this device?',
        'क्या आप इस डिवाइस पर अपने खाते से साइन आउट करना चाहते हैं?',
        'तुम्हाला या उपकरणावरून तुमच्या खात्यातून साइन आउट करायचे आहे का?',
      );

  String get pfCancel => _t('Cancel', 'रद्द करें', 'रद्द करा');

  // ---- Settings section -------------------------------------------------------------------------
  String get pfSettingsSectionTitle => _t('Settings', 'सेटिंग्स', 'सेटिंग्ज');

  String get pfAppearanceLabel => _t('Appearance', 'रंगरूप', 'देखावा');

  // ---- My activity section ----------------------------------------------------------------------
  String get pfMyActivityTitle => _t('My activity', 'मेरी गतिविधि', 'माझी कृती');

  String get pfMyOrders => _t('My orders', 'मेरे ऑर्डर', 'माझ्या ऑर्डर्स');

  String get pfSellOnVanMitra => _t(
        'Sell on VanMitra',
        'वनमित्र पर बेचें',
        'वनमित्रवर विका',
      );

  // ---- More section -----------------------------------------------------------------------------
  String get pfMoreSectionTitle => _t('More', 'अधिक', 'अधिक');

  String get pfAboutTitle => _t(
        'About VanMitra',
        'वनमित्र के बारे में',
        'वनमित्र बद्दल',
      );

  String get pfCreditsTitle => _t('Credits', 'श्रेय', 'श्रेय');

  String get pfPrivacyTitle => _t('Privacy', 'गोपनीयता', 'गोपनीयता');

  String get pfMoreLivelihoodTitle => _t(
        'Livelihood report',
        'आजीविका रिपोर्ट',
        'उपजीविका अहवाल',
      );

  String get pfMoreMessagesTitle => _t(
        'Messages',
        'संदेश और सूचनाएँ',
        'सूचना व संदेश',
      );

  String get pfMoreBarterTitle => _t(
        'Barter offers',
        'वस्तु-विनिमय प्रस्ताव',
        'वस्तुविनिमय प्रस्ताव',
      );

  String get pfMoreDeliveryTitle => _t(
        'Delivery partners',
        'डिलीवरी पार्टनर',
        'डिलिव्हरी पार्टनर',
      );

  // ---- Footer -----------------------------------------------------------------------------------
  String get pfDemoVersion => _t('Demo version', 'डेमो संस्करण', 'डेमो आवृत्ती');

  // ---- Older feature pages (/more/:key) ---------------------------------------------------------
  String get pfOpensInFullApp => _t(
        'Opens in the full app',
        'पूर्ण ऐप में खुलता है',
        'पूर्ण ॲपमध्ये उघडते',
      );

  String get pfUnknownMoreTitle => _t(
        'Page not found',
        'पृष्ठ नहीं मिला',
        'पृष्ठ सापडले नाही',
      );

  String get pfUnknownMoreBody => _t(
        'This section is not part of the demo.',
        'यह अनुभाग इस डेमो का हिस्सा नहीं है।',
        'हा विभाग या डेमोचा भाग नाही.',
      );

  String pfMorePageTitle(String key) {
    switch (key) {
      case 'messages':
        return pfMoreMessagesTitle;
      case 'barter':
        return pfMoreBarterTitle;
      case 'delivery':
        return pfMoreDeliveryTitle;
      case 'livelihood':
        return pfMoreLivelihoodTitle;
      default:
        return pfUnknownMoreTitle;
    }
  }

  List<String> pfMorePageSentences(String key) {
    switch (key) {
      case 'messages':
        return [
          _t(
            'Messages shows updates and notifications about your buyer requests, orders, and trade activity.',
            'संदेश अनुभाग आपके खरीदार अनुरोधों, ऑर्डर और व्यापारिक गतिविधियों से जुड़ी ताज़ा सूचनाएँ दिखाता है।',
            'संदेश विभाग तुमच्या खरेदी मागण्या, ऑर्डर्स आणि व्यवहारांच्या ताज्या सूचना दाखवतो.',
          ),
          _t(
            'Opening the messages list marks unread notifications as read for your account.',
            'संदेश सूची खोलने पर आपके खाते की अपठित सूचनाएँ पढ़ी गई के रूप में चिह्नित हो जाती हैं।',
            'संदेश यादी उघडल्यावर तुमच्या खात्यातील न वाचलेल्या सूचना वाचल्या म्हणून नोंदवल्या जातात.',
          ),
        ];
      case 'barter':
        return [
          _t(
            'Barter lets members offer one forest product in exchange for another listing in the marketplace.',
            'वस्तु-विनिमय के माध्यम से सदस्य बाज़ार की किसी सूची के बदले अपना दूसरा वनोपज देने का प्रस्ताव रख सकते हैं।',
            'वस्तुविनिमयाद्वारे सदस्य बाजारपेठेतील एका उत्पादनाच्या बदल्यात आपले दुसरे वनोपज देण्याचा प्रस्ताव ठेवू शकतात.',
          ),
          _t(
            'You can review incoming and sent barter offers, and accept, decline, or send a counter offer.',
            'आप आने वाले और भेजे गए प्रस्ताव देख सकते हैं तथा उन्हें स्वीकार, अस्वीकार या प्रति-प्रस्ताव कर सकते हैं।',
            'तुम्ही आलेले आणि पाठवलेले प्रस्ताव पाहू शकता आणि ते स्वीकारू, नाकारू किंवा प्रति-प्रस्ताव पाठवू शकता.',
          ),
        ];
      case 'delivery':
        return [
          _t(
            'Community members with a vehicle can apply to become delivery partners for the Deola, Dindori, and Trimbakeshwar blocks.',
            'वाहन रखने वाले समुदाय के सदस्य देवला, दिंडोरी और त्र्यंबकेश्वर विकासखंडों के लिए डिलीवरी पार्टनर बनने हेतु आवेदन कर सकते हैं।',
            'वाहन असलेले सदस्य देवळा, दिंडोरी आणि त्र्यंबकेश्वर तालुक्यांसाठी डिलिव्हरी पार्टनर होण्यासाठी अर्ज करू शकतात.',
          ),
          _t(
            'Approved partners can see open delivery jobs between villages and buyers and update pickup and delivery status.',
            'स्वीकृत पार्टनर गाँवों और खरीदारों के बीच उपलब्ध डिलीवरी कार्य देख सकते हैं और माल उठाने व पहुँचाने की स्थिति अपडेट कर सकते हैं।',
            'मंजूर पार्टनर गावे आणि खरेदीदारांमधील उपलब्ध डिलिव्हरी कामे पाहू शकतात आणि माल उचलण्याची व पोहोचवण्याची स्थिती अपडेट करू शकतात.',
          ),
        ];
      case 'livelihood':
        return [
          _t(
            'CFR holders can enter details about their land, water, animals, and tools to get a draft livelihood report and map.',
            'सीएफआर धारक अपनी भूमि, पानी, पशुओं और औज़ारों का विवरण भरकर मसौदा आजीविका रिपोर्ट और मानचित्र प्राप्त कर सकते हैं।',
            'सीएफआर धारक आपली जमीन, पाणी, जनावरे आणि अवजारे यांची माहिती भरून मसुदा उपजीविका अहवाल आणि नकाशा पाहू शकतात.',
          ),
          _t(
            'The report shows ranked work ideas, nearby map resources, typical monthly rain and temperature, and official government scheme information.',
            'रिपोर्ट में क्रमबद्ध कार्य विचार, आस-पास के मानचित्र संसाधन, सामान्य मासिक वर्षा व तापमान और सरकारी योजनाओं की जानकारी दिखती है।',
            'या अहवालात क्रमवारीतील कामाच्या कल्पना, जवळील नकाशा संसाधने, सरासरी मासिक पाऊस व तापमान आणि शासकीय योजनांची माहिती दिसते.',
          ),
        ];
      default:
        return [pfUnknownMoreBody];
    }
  }

  // ---- About VanMitra (/about) ------------------------------------------------------------------
  List<String> get pfAboutSentences => [
        _t(
          'VanMitra is an Android app for Community Forest Rights (CFR) villages in Nashik district across the Deola, Dindori, and Trimbakeshwar blocks.',
          'वनमित्र नासिक जिले के देवला, दिंडोरी और त्र्यंबकेश्वर विकासखंडों के सामुदायिक वन अधिकार (सीएफआर) गाँवों के लिए एक एंड्रॉइड ऐप है।',
          'वनमित्र हे नाशिक जिल्ह्यातील देवळा, दिंडोरी आणि त्र्यंबकेश्वर तालुक्यांमधील सामूहिक वनहक्क (सीएफआर) गावांसाठीचे अँड्रॉइड ॲप आहे.',
        ),
        _t(
          'Gram Sabhas and CFR holders list forest produce such as bamboo, fruits, herbs, flowers, and nuts.',
          'ग्राम सभाएँ और सीएफआर धारक बाँस, फल, जड़ी-बूटियाँ, फूल और मेवे जैसे वनोपज सूचीबद्ध करते हैं।',
          'ग्रामसभा आणि सीएफआर धारक बांबू, फळे, औषधी वनस्पती, फुले आणि सुकामेवा यांसारखे वनोपज नोंदवतात.',
        ),
        _t(
          'Wholesalers and business buyers browse the catalog and send purchase requests directly to Gram Sabhas and CFR holders.',
          'थोक व्यापारी और व्यावसायिक खरीदार कैटलॉग देखते हैं और सीधे ग्राम सभाओं व सीएफआर धारकों को खरीद अनुरोध भेजते हैं।',
          'घाऊक व्यापारी आणि व्यावसायिक खरेदीदार कॅटलॉग पाहतात आणि थेट ग्रामसभा व सीएफआर धारकांना खरेदीच्या मागण्या पाठवतात.',
        ),
        _t(
          'For CFR holders, the app also provides a draft livelihood report with a map of nearby resources, typical monthly rain and temperature, and official government scheme information.',
          'सीएफआर धारकों के लिए ऐप में आस-पास के संसाधनों के मानचित्र, सामान्य मासिक वर्षा व तापमान और सरकारी योजनाओं की जानकारी के साथ मसौदा आजीविका रिपोर्ट भी है।',
          'सीएफआर धारकांसाठी या ॲपमध्ये जवळील संसाधनांचा नकाशा, सरासरी मासिक पाऊस व तापमान आणि शासकीय योजनांच्या माहितीसह मसुदा उपजीविका अहवाल देखील आहे.',
        ),
        _t(
          'The app works in three languages—English, Hindi, and Marathi—and all products, prices, and sellers in this demo are sample data.',
          'यह ऐप तीन भाषाओं—अंग्रेज़ी, हिन्दी और मराठी—में काम करता है और इस डेमो के सभी उत्पाद, कीमतें और विक्रेता नमूना डेटा हैं।',
          'हे ॲप इंग्रजी, हिन्दी आणि मराठी या तीन भाषांमध्ये चालते आणि या डेमोमधील सर्व उत्पादने, किमती आणि विक्रेते नमुना डेटा आहेत.',
        ),
      ];

  // ---- Credits (/credits) -----------------------------------------------------------------------
  String get pfCreditsSourceLabel => _t('Source', 'स्रोत', 'स्रोत');
  String get pfCreditsTermsLabel => _t('Notes & terms', 'शर्तें और विवरण', 'अटी आणि तपशील');

  List<ProfileCreditGroup> get pfCreditGroups => [
        ProfileCreditGroup(
          heading: _t('Project & modules', 'परियोजना और मॉड्यूल', 'प्रकल्प आणि विभाग'),
          items: [
            ProfileCreditItem(
              what: _t(
                'Livelihood report and map',
                'आजीविका रिपोर्ट और मानचित्र',
                'उपजीविका अहवाल आणि नकाशा',
              ),
              source: _t(
                'Soham (Module 4 of the VanMitra family)',
                'सोहम (वनमित्र परिवार का मॉड्यूल 4)',
                'सोहम (वनमित्र परिवाराचा विभाग 4)',
              ),
              terms: _t(
                'Reused with the project team agreement.',
                'परियोजना टीम की सहमति से उपयोग किया गया।',
                'प्रकल्प संघाच्या सहमतीने वापरण्यात आले.',
              ),
            ),
            ProfileCreditItem(
              what: _t(
                'Marketplace (trade, barter, delivery)',
                'बाज़ार (व्यापार, वस्तु-विनिमय, डिलीवरी)',
                'बाजारपेठ (व्यापार, वस्तुविनिमय, डिलिव्हरी)',
              ),
              source: _t('Ayush More', 'आयुष मोरे', 'आयुष मोरे'),
              terms: _t(
                'Accounts, listings, buyer requests, orders, barter, and delivery.',
                'खाते, सूचियाँ, खरीदार अनुरोध, ऑर्डर, वस्तु-विनिमय और डिलीवरी।',
                'खाती, उत्पादने, खरेदी मागण्या, ऑर्डर्स, वस्तुविनिमय आणि डिलिव्हरी.',
              ),
            ),
            ProfileCreditItem(
              what: _t(
                'Design system and Gram Sabha foundation',
                'डिज़ाइन प्रणाली और ग्राम सभा कार्य',
                'डिझाइन प्रणाली आणि ग्रामसभा कार्य',
              ),
              source: _t('The VanMitra team', 'वनमित्र टीम', 'वनमित्र संघ'),
              terms: _t(
                'Shared design tokens, village workflows, and community structure.',
                'साझा डिज़ाइन टोकन, ग्राम कार्यप्रणाली और सामुदायिक संरचना।',
                'सामायिक डिझाइन टोकन्स, गाव कार्यपद्धती आणि सामूहिक रचना.',
              ),
            ),
          ],
        ),
        ProfileCreditGroup(
          heading: _t('Pictures', 'चित्र', 'चित्रे'),
          items: [
            ProfileCreditItem(
              what: _t(
                'App header, footer, and full-screen background pictures',
                'ऐप हेडर, फ़ुटर और पूर्ण-स्क्रीन पृष्ठभूमि चित्र',
                'ॲप हेडर, फुटर आणि पूर्ण-स्क्रीन पार्श्वभूमी चित्रे',
              ),
              source: _t(
                'AI-generated illustrations (ChatGPT), prompted by the project team',
                'परियोजना टीम द्वारा तैयार किए गए कृत्रिम बुद्धिमत्ता चित्रण',
                'प्रकल्प संघाने तयार केलेली कृत्रिम बुद्धिमत्ता चित्रे',
              ),
              terms: _t(
                'Illustration only; no real place, person, or brand is shown.',
                'केवल चित्रण; कोई वास्तविक स्थान, व्यक्ति या ब्रांड नहीं दिखाया गया है।',
                'केवळ चित्रण; कोणतेही खरे ठिकाण, व्यक्ती किंवा ब्रँड दाखवलेला नाही.',
              ),
            ),
            ProfileCreditItem(
              what: _t(
                'Product pictures (43 catalog items) and sample catalog data',
                'उत्पाद चित्र (43 कैटलॉग वस्तुएँ) और नमूना कैटलॉग डेटा',
                'उत्पादन चित्रे (43 कॅटलॉग वस्तू) आणि नमुना कॅटलॉग डेटा',
              ),
              source: _t(
                'AI-generated resource pictures made for the project; product names from the resource manifest',
                'परियोजना के लिए बनाए गए कृत्रिम बुद्धिमत्ता संसाधन चित्र; संसाधन सूची से उत्पाद नाम',
                'प्रकल्पासाठी तयार केलेली कृत्रिम बुद्धिमत्ता संसाधन चित्रे; संसाधन यादीतील उत्पादन नावे',
              ),
              terms: _t(
                'AI-generated, not photographs of real products. Several items are marked to be checked against real photos. Prices, sellers, stock, and dates in the sample catalog are made up and shown as Sample. Bibba and Gunj Vel are not for eating.',
                'ये वास्तविक उत्पादों की तस्वीरें नहीं बल्कि कृत्रिम चित्रण हैं। कई चित्रों को वास्तविक तस्वीरों से जाँचा जाना बाकी है। नमूना कैटलॉग में कीमतें, विक्रेता, स्टॉक और तिथियाँ काल्पनिक हैं और नमूना के रूप में दिखाई जाती हैं। बिब्बा और गुंज वेल खाने के लिए नहीं हैं।',
                'ही खऱ्या उत्पादनांची छायाचित्रे नसून कृत्रिम चित्रे आहेत. काही चित्रे खऱ्या छायाचित्रांशी पडताळणे बाकी आहे. नमुना कॅटलॉगमधील किमती, विक्रेते, साठा आणि तारखा काल्पनिक असून नमुना म्हणून दाखवल्या आहेत. बिब्बा आणि गुंज वेल खाण्यासाठी नाहीत.',
              ),
            ),
            ProfileCreditItem(
              what: _t(
                'Landing slide pictures (6 intro artwork panels)',
                'प्रारंभिक स्लाइड चित्र (6 परिचय चित्र पैनल)',
                'प्रारंभिक स्लाइड चित्रे (6 परिचय चित्र पॅनेल)',
              ),
              source: _t(
                'AI-generated images (ChatGPT), prompted by the project team',
                'परियोजना टीम द्वारा तैयार किए गए कृत्रिम बुद्धिमत्ता चित्र',
                'प्रकल्प संघाने तयार केलेली कृत्रिम बुद्धिमत्ता चित्रे',
              ),
              terms: _t(
                'AI-generated illustrations that show no real village, person, or product. The dried-fruit picture still needs a check by the NGO for the correct fruits.',
                'कृत्रिम चित्रण जो किसी वास्तविक गाँव, व्यक्ति या उत्पाद को नहीं दिखाते। सूखे फलों के चित्र की सही फलों के लिए संस्था द्वारा जाँच बाकी है।',
                'कृत्रिम चित्रे जी कोणतेही खरे गाव, व्यक्ती किंवा उत्पादन दाखवत नाहीत. वाळलेल्या फळांच्या चित्राची संस्थेकडून तपासणी बाकी आहे.',
              ),
            ),
          ],
        ),
        ProfileCreditGroup(
          heading: _t('Data and map credits', 'डेटा और मानचित्र श्रेय', 'डेटा आणि नकाशा श्रेय'),
          items: [
            ProfileCreditItem(
              what: _t(
                'The 14 villages and their forest restoration figures (CFR area, saplings, ponds, water storage, boulder structures, labour days, meetings, species)',
                '14 गाँव और उनके वन पुनर्संरक्षण आँकड़े (सीएफआर क्षेत्र, पौधे, तालाब, जल संचयन, पत्थर संरचनाएँ, श्रम दिवस, बैठकें, प्रजातियाँ)',
                '14 गावे आणि त्यांची वन संवर्धन आकडेवारी (सीएफआर क्षेत्र, रोपे, तळी, पाणी साठा, दगडी बांध, रोजगार दिवस, बैठका, प्रजाती)',
              ),
              source: _t(
                'Raah Foundation quarterly update on ecological restoration in the CFR areas of Nashik district (1 October 2026)',
                'राह फाउंडेशन, नासिक जिले के सीएफआर क्षेत्रों में पारिस्थितिक पुनर्संरक्षण पर त्रैमासिक रिपोर्ट (1 अक्टूबर 2026)',
                'राह फाउंडेशन, नाशिक जिल्ह्यातील सीएफआर क्षेत्रांमधील पर्यावरण संवर्धनाचा त्रैमासिक अहवाल (1 ऑक्टोबर 2026)',
              ),
              terms: _t(
                'Supplied by the project owner; figures as printed in the report.',
                'परियोजना स्वामी द्वारा प्रदत्त; रिपोर्ट में छपे अनुसार आँकड़े।',
                'प्रकल्प मालकाने पुरवलेली माहिती; अहवालात छापल्यानुसार आकडेवारी.',
              ),
            ),
            ProfileCreditItem(
              what: _t(
                'Map tiles and optional resource dataset',
                'मानचित्र टाइल्स और वैकल्पिक संसाधन डेटासेट',
                'नकाशा टाइल्स आणि पर्यायी संसाधन डेटासेट',
              ),
              source: _t(
                'OpenStreetMap contributors',
                'ओपनस्ट्रीटमैप योगदानकर्ता',
                'ओपनस्ट्रीटमॅप योगदानकर्ते',
              ),
              terms: _t(
                'Open Database Licence (ODbL). Tiles are for light use; replace the tile server before any large launch.',
                'ओपन डेटाबेस लाइसेंस। टाइल्स हल्के उपयोग के लिए हैं; बड़े लॉन्च से पहले टाइल सर्वर बदलें।',
                'ओपन डेटाबेस परवाना. टाइल्स मर्यादित वापरासाठी आहेत; मोठ्या प्रक्षेपणापूर्वी टाइल सर्व्हर बदला.',
              ),
            ),
            ProfileCreditItem(
              what: _t(
                'Typical monthly rain and temperature',
                'सामान्य मासिक वर्षा और तापमान',
                'सरासरी मासिक पाऊस आणि तापमान',
              ),
              source: _t(
                'Open-Meteo historical weather',
                'ओपन-मेटियो ऐतिहासिक मौसम डेटा',
                'ओपन-मेटियो ऐतिहासिक हवामान डेटा',
              ),
              terms: _t(
                'Creative Commons Attribution 4.0 (CC BY 4.0). Typical values from past years, not a forecast.',
                'क्रिएटिव कॉमन्स एट्रिब्यूशन 4.0। पिछले वर्षों के सामान्य मान, कोई पूर्वानुमान नहीं।',
                'क्रिएटिव्ह कॉमन्स श्रेय 4.0. मागील वर्षांचे सरासरी मान, हा हवामान अंदाज नाही.',
              ),
            ),
            ProfileCreditItem(
              what: _t(
                'Government scheme information',
                'सरकारी योजनाओं की जानकारी',
                'शासकीय योजनांची माहिती',
              ),
              source: _t(
                'Official government websites named in each scheme row',
                'प्रत्येक योजना पंक्ति में नामित आधिकारिक सरकारी वेबसाइटें',
                'प्रत्येक योजनेच्या ओळीत नमूद केलेल्या अधिकृत सरकारी वेबसाइट्स',
              ),
              terms: _t(
                'Information references only; no money amounts and no applications in the app.',
                'केवल जानकारी संदर्भ; ऐप में कोई राशि या आवेदन नहीं।',
                'केवळ माहिती संदर्भ; ॲपमध्ये कोणतीही रक्कम किंवा अर्ज नाही.',
              ),
            ),
            ProfileCreditItem(
              what: _t(
                'Idea library and Hindi / Marathi translations',
                'विचार पुस्तकालय और हिन्दी / मराठी अनुवाद',
                'कल्पना संग्रह आणि हिन्दी / मराठी अनुवाद',
              ),
              source: _t(
                'Drafts prepared by the project team',
                'परियोजना टीम द्वारा तैयार किए गए मसौदे',
                'प्रकल्प संघाने तयार केलेले मसुदे',
              ),
              terms: _t(
                'The idea library has not been reviewed by an expert. Marathi and Hindi texts are machine-written drafts not yet read by a native speaker.',
                'विचार पुस्तकालय की किसी विशेषज्ञ द्वारा समीक्षा नहीं की गई है। मराठी और हिन्दी पाठ मशीनी मसौदे हैं जिन्हें अभी मातृभाषी ने नहीं पढ़ा है।',
                'कल्पना संग्रहाचे तज्ज्ञांकडून परीक्षण झालेले नाही. मराठी आणि हिन्दी मजकूर मशीनी मसुदे असून अद्याप मातृभाषकाकडून वाचलेले नाहीत.',
              ),
            ),
          ],
        ),
      ];

  // ---- Privacy (/privacy) -----------------------------------------------------------------------
  List<ProfileTextSection> get pfPrivacySections => [
        ProfileTextSection(
          heading: _t('What we keep', 'हम क्या रखते हैं', 'आम्ही काय ठेवतो'),
          body: _t(
            'We keep your name, phone number, village, role, and language. Your 6-digit PIN is stored only as a one-way hash (bcrypt), never as the PIN itself.',
            'हम आपका नाम, फ़ोन नंबर, गाँव, भूमिका और भाषा रखते हैं। आपका 6 अंकों का पिन केवल एक-तरफ़ा हैश के रूप में सुरक्षित रहता है, कभी भी सीधे पिन के रूप में नहीं।',
            'आम्ही तुमचे नाव, फोन नंबर, गाव, भूमिका आणि भाषा जतन करतो. तुमचा 6 अंकी पिन केवळ एकेरी हॅश स्वरूपात ठेवला जातो, कधीही थेट पिन म्हणून नाही.',
          ),
        ),
        ProfileTextSection(
          heading: _t('CFR holders', 'सीएफआर धारक', 'सीएफआर धारक'),
          body: _t(
            'The details given for the livelihood report (land size, water, animals, tools, plot position) are kept on the livelihood server and shown only to that person.',
            'आजीविका रिपोर्ट के लिए दिया गया विवरण (भूमि का आकार, पानी, पशु, औज़ार, भूखंड की स्थिति) आजीविका सर्वर पर रखा जाता है और केवल उसी व्यक्ति को दिखाया जाता है।',
            'उपजीविका अहवालासाठी दिलेली माहिती (जमिनीचा आकार, पाणी, जनावरे, अवजारे, जागेचे स्थान) उपजीविका सर्व्हरवर ठेवली जाते आणि केवळ त्याच व्यक्तीला दाखवली जाते.',
          ),
        ),
        ProfileTextSection(
          heading: _t('Listings are public', 'सूचियाँ सार्वजनिक हैं', 'उत्पादन याद्या सार्वजनिक आहेत'),
          body: _t(
            'Marketplace listings are public. Their position is rounded to about 1 km, and a phone number is never shown on a listing.',
            'बाज़ार की सूचियाँ सार्वजनिक हैं। उनका स्थान लगभग 1 किलोमीटर तक पूर्णांकित किया जाता है और किसी भी सूची पर फ़ोन नंबर कभी नहीं दिखाया जाता।',
            'बाजारपेठेतील उत्पादन याद्या सार्वजनिक आहेत. त्यांचे स्थान सुमारे 1 किलोमीटरपर्यंत पूर्णांकित केले जाते आणि यादीवर फोन नंबर कधीही दाखवला जात नाही.',
          ),
        ),
        ProfileTextSection(
          heading: _t('Phone location', 'फ़ोन का स्थान', 'फोनचे स्थान'),
          body: _t(
            'Phone location is used only if the person allows it, to place their plot. They can type a position instead.',
            'फ़ोन के स्थान का उपयोग केवल तभी किया जाता है जब व्यक्ति अपना भूखंड चिह्नित करने के लिए इसकी अनुमति देता है। इसके बजाय वे स्थान टाइप भी कर सकते हैं।',
            'फोनचे स्थान केवळ व्यक्तीने स्वतःची जागा दर्शवण्यासाठी परवानगी दिल्यासच वापरले जाते. त्याऐवजी ते स्थान टाइप करू शकतात.',
          ),
        ),
        ProfileTextSection(
          heading: _t('Third parties', 'तृतीय पक्ष', 'तिसरे पक्ष'),
          body: _t(
            'There is no advertising and no analytics in the app. Map pictures come from OpenStreetMap, which can see the network address when tiles load. Typical weather comes from Open-Meteo, fetched by our server for the village position only.',
            'ऐप में कोई विज्ञापन और कोई एनालिटिक्स नहीं है। मानचित्र चित्र ओपनस्ट्रीटमैप से आते हैं, जो टाइल्स लोड होने पर नेटवर्क पता देख सकता है। सामान्य मौसम ओपन-मेटियो से केवल गाँव के स्थान के लिए हमारे सर्वर द्वारा लाया जाता है।',
            'या ॲपमध्ये कोणतीही जाहिरात किंवा विश्लेषण सेवा नाही. नकाशा चित्रे ओपनस्ट्रीटमॅपकडून येतात, ज्याला टाइल्स लोड होताना नेटवर्क पत्ता दिसू शकतो. सरासरी हवामान केवळ गावाच्या स्थानासाठी आमच्या सर्व्हरद्वारे ओपन-मेटियोकडून घेतले जाते.',
          ),
        ),
        ProfileTextSection(
          heading: _t('Deletion and open items', 'खाता हटाना और खुली मदें', 'खाते हटवणे आणि खुल्या बाबी'),
          body: _t(
            'To have an account and report deleted, contact the VanMitra team (there is no self-service delete yet). Before launch, the team will confirm a named contact for deletion requests and confirm that no other SDK collects data in the APK build.',
            'खाता और रिपोर्ट हटवाने के लिए वनमित्र टीम से संपर्क करें (अभी स्वयं खाता हटाने की सुविधा नहीं है)। लॉन्च से पहले टीम खाता हटाने के अनुरोधों के लिए एक नामित संपर्क की पुष्टि करेगी।',
            'खाते आणि अहवाल हटवण्यासाठी वनमित्र संघाशी संपर्क साधा (अद्याप स्वतः खाते हटवण्याची सोय नाही). प्रक्षेपणापूर्वी संघ खाते हटवण्याच्या विनंत्यांसाठी एका नामित संपर्काची पुष्टी करेल.',
          ),
        ),
      ];
}
