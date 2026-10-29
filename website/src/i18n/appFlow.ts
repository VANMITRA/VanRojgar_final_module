import { Language } from '../types';

/**
 * Text for the item code, the "Buy in the app" page and the "what has been achieved" figures.
 * Marathi and Hindi are drafts for a native speaker to read before the site goes to villagers.
 */
export interface AppFlowText {
  itemCode: string;
  copy: string;
  copied: string;
  sampleBadge: string;
  liveBadge: string;
  sampleBanner: string;
  liveBanner: string;
  buyInApp: string;
  download: {
    title: string;
    subtitle: string;
    steps: [string, string, string, string];
    downloadBtn: string;
    codeHeading: string;
    paymentNote: string;
    sampleNote: string;
    close: string;
  };
  achieved: {
    badge: string;
    title: string;
    desc: string;
    source: string;
    figures: { value: string; label: string }[];
    inAppTitle: string;
    inApp: string[];
  };
  heroStats: { value: string; label: string }[];
}

export const appFlow: Record<Language, AppFlowText> = {
  en: {
    itemCode: 'Item code',
    copy: 'Copy',
    copied: 'Copied',
    sampleBadge: 'PREVIEW',
    liveBadge: 'LIVE',
    sampleBanner:
      'These are preview listings. Their codes will not be found in the app. Real items appear here once Gram Sabhas list them.',
    liveBanner: 'These listings are live from the VanRozgar marketplace. Copy an item code and paste it into the app search.',
    buyInApp: 'Buy in the app',
    download: {
      title: 'Buy this in the VanRozgar app',
      subtitle: 'Orders and payment happen in the Android app, not on this website.',
      steps: [
        'Download and install the VanRozgar app (Android).',
        'Sign up or log in with your phone number and a 6-digit PIN.',
        'Open Search and paste the item code below.',
        'Place your request. Pay by UPI or cash on delivery.',
      ],
      downloadBtn: 'Download the app (APK)',
      codeHeading: 'Your item code',
      paymentNote: 'Payment is made inside the app, by UPI or cash on delivery. This website never takes payment.',
      sampleNote: 'This is a preview item: its code is not in the app. Real items have codes that the app finds.',
      close: 'Close',
    },
    achieved: {
      badge: 'What has been achieved',
      title: 'The ground work is real',
      desc: 'Figures from the Raah Foundation report on the 14 Community Forest Resource villages this project starts with.',
      source: 'Source: Raah Foundation report, 1 October 2026',
      figures: [
        { value: '14', label: 'CFR villages (Deola, Dindori, Trimbakeshwar)' },
        { value: '2,019 ha', label: 'Community forest area covered' },
        { value: '217,708', label: 'Saplings planted and nurtured' },
        { value: '11', label: 'Forest ponds' },
        { value: '794', label: 'Boulder structures for water' },
        { value: '12,710', label: 'Labour days created' },
      ],
      inAppTitle: 'What is in the app',
      inApp: [
        'Marketplace: Gram Sabhas list forest produce, buyers send requests, each item has a code',
        'Barter between villages, with a fairness check',
        'Delivery partners from the villages',
        'Livelihood report for CFR holders: ideas, nearby resources, schemes, map and PDF',
        'English, Marathi and Hindi',
      ],
    },
    heroStats: [
      { value: '14', label: 'CFR villages in the report' },
      { value: '217,708', label: 'Saplings planted' },
      { value: '2,019 ha', label: 'Forest area covered' },
    ],
  },
  hi: {
    itemCode: 'आइटम कोड',
    copy: 'कॉपी',
    copied: 'कॉपी हुआ',
    sampleBadge: 'पूर्वावलोकन',
    liveBadge: 'लाइव',
    sampleBanner:
      'ये पूर्वावलोकन सूचियाँ हैं। इनके कोड ऐप में नहीं मिलेंगे। ग्राम सभाओं के सूचीबद्ध करते ही असली वस्तुएँ यहाँ दिखेंगी।',
    liveBanner: 'ये सूचियाँ वनरोजगार बाज़ार से लाइव हैं। आइटम कोड कॉपी करें और ऐप की खोज में डालें।',
    buyInApp: 'ऐप में खरीदें',
    download: {
      title: 'इसे वनरोजगार ऐप में खरीदें',
      subtitle: 'ऑर्डर और भुगतान इस वेबसाइट पर नहीं, एंड्रॉइड ऐप में होते हैं।',
      steps: [
        'वनरोजगार ऐप (एंड्रॉइड) डाउनलोड और इंस्टॉल करें।',
        'अपने फ़ोन नंबर और 6 अंकों के पिन से साइन अप या लॉग इन करें।',
        'खोज खोलें और नीचे दिया आइटम कोड डालें।',
        'अनुरोध भेजें। यूपीआई या डिलीवरी पर नकद से भुगतान करें।',
      ],
      downloadBtn: 'ऐप डाउनलोड करें (APK)',
      codeHeading: 'आपका आइटम कोड',
      paymentNote: 'भुगतान ऐप के अंदर यूपीआई या डिलीवरी पर नकद से होता है। यह वेबसाइट कभी भुगतान नहीं लेती।',
      sampleNote: 'यह पूर्वावलोकन वस्तु है: इसका कोड ऐप में नहीं है। असली वस्तुओं के कोड ऐप में मिलते हैं।',
      close: 'बंद करें',
    },
    achieved: {
      badge: 'अब तक की उपलब्धि',
      title: 'ज़मीनी काम असली है',
      desc: 'राह फाउंडेशन की रिपोर्ट के आँकड़े, उन 14 सामुदायिक वन संसाधन गाँवों के बारे में जहाँ से यह परियोजना शुरू होती है।',
      source: 'स्रोत: राह फाउंडेशन रिपोर्ट, 1 अक्टूबर 2026',
      figures: [
        { value: '14', label: 'सीएफआर गाँव (देवळा, दिंडोरी, त्र्यंबकेश्वर)' },
        { value: '2,019 हे.', label: 'सामुदायिक वन क्षेत्र' },
        { value: '217,708', label: 'लगाए और पाले गए पौधे' },
        { value: '11', label: 'वन तालाब' },
        { value: '794', label: 'जल के लिए पत्थर की संरचनाएँ' },
        { value: '12,710', label: 'सृजित श्रम दिवस' },
      ],
      inAppTitle: 'ऐप में क्या है',
      inApp: [
        'बाज़ार: ग्राम सभाएँ वनोपज सूचीबद्ध करती हैं, खरीदार अनुरोध भेजते हैं, हर वस्तु का कोड है',
        'गाँवों के बीच वस्तु-विनिमय, निष्पक्षता जाँच के साथ',
        'गाँवों के डिलीवरी पार्टनर',
        'सीएफआर धारकों के लिए आजीविका रिपोर्ट: विचार, पास के संसाधन, योजनाएँ, नक्शा और पीडीएफ',
        'अंग्रेज़ी, मराठी और हिंदी',
      ],
    },
    heroStats: [
      { value: '14', label: 'रिपोर्ट के सीएफआर गाँव' },
      { value: '217,708', label: 'लगाए गए पौधे' },
      { value: '2,019 हे.', label: 'वन क्षेत्र' },
    ],
  },
  mr: {
    itemCode: 'वस्तू कोड',
    copy: 'कॉपी',
    copied: 'कॉपी झाले',
    sampleBadge: 'पूर्वावलोकन',
    liveBadge: 'लाइव्ह',
    sampleBanner:
      'ही पूर्वावलोकन यादी आहे. या कोडचा अॅपमध्ये शोध लागणार नाही. ग्रामसभांनी यादी केल्यावर खऱ्या वस्तू येथे दिसतील.',
    liveBanner: 'ही यादी वनरोजगार बाजारातून थेट आहे. वस्तू कोड कॉपी करून अॅपच्या शोधात टाका.',
    buyInApp: 'अॅपमध्ये खरेदी करा',
    download: {
      title: 'हे वनरोजगार अॅपमध्ये खरेदी करा',
      subtitle: 'ऑर्डर आणि पैसे या वेबसाइटवर नाही, अँड्रॉइड अॅपमध्ये होतात.',
      steps: [
        'वनरोजगार अॅप (अँड्रॉइड) डाउनलोड करून इन्स्टॉल करा.',
        'तुमचा फोन नंबर आणि 6 अंकी पिन वापरून साइन अप किंवा लॉग इन करा.',
        'शोध उघडा आणि खालील वस्तू कोड टाका.',
        'मागणी पाठवा. यूपीआय किंवा डिलिव्हरीवर रोख रक्कम देऊन पैसे भरा.',
      ],
      downloadBtn: 'अॅप डाउनलोड करा (APK)',
      codeHeading: 'तुमचा वस्तू कोड',
      paymentNote: 'पैसे अॅपमध्येच यूपीआय किंवा डिलिव्हरीवर रोख देऊन भरले जातात. ही वेबसाइट कधीही पैसे घेत नाही.',
      sampleNote: 'ही पूर्वावलोकन वस्तू आहे: तिचा कोड अॅपमध्ये नाही. खऱ्या वस्तूंचे कोड अॅपमध्ये सापडतात.',
      close: 'बंद करा',
    },
    achieved: {
      badge: 'आतापर्यंत काय साधले',
      title: 'जमिनीवरील काम खरे आहे',
      desc: 'राह फाउंडेशनच्या अहवालातील आकडे, ज्या 14 सामूहिक वन संसाधन गावांपासून हा प्रकल्प सुरू होतो त्यांच्याबद्दल.',
      source: 'स्रोत: राह फाउंडेशन अहवाल, 1 ऑक्टोबर 2026',
      figures: [
        { value: '14', label: 'सीएफआर गावे (देवळा, दिंडोरी, त्र्यंबकेश्वर)' },
        { value: '2,019 हे.', label: 'सामूहिक वन क्षेत्र' },
        { value: '217,708', label: 'लावलेली व जोपासलेली रोपे' },
        { value: '11', label: 'वन तलाव' },
        { value: '794', label: 'पाण्यासाठी दगडी बांध' },
        { value: '12,710', label: 'निर्माण झालेले श्रमदिवस' },
      ],
      inAppTitle: 'अॅपमध्ये काय आहे',
      inApp: [
        'बाजार: ग्रामसभा वनोपज यादीत टाकतात, खरेदीदार मागणी पाठवतात, प्रत्येक वस्तूला कोड आहे',
        'गावांमधील वस्तुविनिमय, निष्पक्षता तपासणीसह',
        'गावांमधील डिलिव्हरी भागीदार',
        'सीएफआर धारकांसाठी उपजीविका अहवाल: कल्पना, जवळची संसाधने, योजना, नकाशा आणि पीडीएफ',
        'इंग्रजी, मराठी आणि हिंदी',
      ],
    },
    heroStats: [
      { value: '14', label: 'अहवालातील सीएफआर गावे' },
      { value: '217,708', label: 'लावलेली रोपे' },
      { value: '2,019 हे.', label: 'वन क्षेत्र' },
    ],
  },
};
