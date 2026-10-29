export type Lang='en'|'hi'|'mr';
export const LANGS:{id:Lang,label:string}[]=[{id:'en',label:'English'},{id:'hi',label:'हिन्दी'},{id:'mr',label:'मराठी'}];

/* Only the shared chrome (navbar, login footer, legal page) is translated so far. Missing keys fall back to English. */
const D:Record<string,Record<Lang,string>>={
  'Home':{en:'Home',hi:'होम',mr:'मुख्यपृष्ठ'},
  'Resources':{en:'Resources',hi:'संसाधन',mr:'संसाधने'},
  'Gram Sabhas':{en:'Gram Sabhas',hi:'ग्राम सभाएँ',mr:'ग्रामसभा'},
  'Barter':{en:'Barter',hi:'वस्तु विनिमय',mr:'वस्तुविनिमय'},
  'Deliver with us':{en:'Deliver with us',hi:'हमारे साथ डिलीवरी करें',mr:'आमच्यासोबत डिलिव्हरी करा'},
  'Our impact':{en:'Our impact',hi:'हमारा प्रभाव',mr:'आमचा प्रभाव'},
  'Search bamboo, Moh, awla...':{en:'Search bamboo, Moh, awla...',hi:'बाँस, मोह, आंवला खोजें...',mr:'बांबू, मोह, आवळा शोधा...'},
  'Login':{en:'Login',hi:'लॉगिन',mr:'लॉगिन'},
  'Account':{en:'Account',hi:'खाता',mr:'खाते'},
  'My profile':{en:'My profile',hi:'मेरी प्रोफ़ाइल',mr:'माझी प्रोफाइल'},
  'Wishlist':{en:'Wishlist',hi:'पसंदीदा सूची',mr:'आवडती यादी'},
  'My requests':{en:'My requests',hi:'मेरे अनुरोध',mr:'माझ्या विनंत्या'},
  'Log out':{en:'Log out',hi:'लॉग आउट',mr:'लॉग आउट'},
  'Language':{en:'Language',hi:'भाषा',mr:'भाषा'},
  'Switch theme':{en:'Switch theme',hi:'थीम बदलें',mr:'थीम बदला'},
  'Need help? Contact the VanRozgar team':{en:'Need help? Contact the VanRozgar team',hi:'मदद चाहिए? वनरोज़गार टीम से संपर्क करें',mr:'मदत हवी? वनरोजगार टीमशी संपर्क साधा'},
  'Terms and privacy':{en:'Terms and privacy',hi:'नियम और गोपनीयता',mr:'अटी आणि गोपनीयता'},
  'Privacy and terms':{en:'Privacy and terms',hi:'गोपनीयता और नियम',mr:'गोपनीयता आणि अटी'},
  'I agree to the':{en:'I agree to the',hi:'मैं सहमत हूँ',mr:'मी सहमत आहे'},
  'Back':{en:'Back',hi:'वापस',mr:'मागे'},
  'Terms of use':{en:'Terms of use',hi:'उपयोग की शर्तें',mr:'वापराच्या अटी'},
  'Privacy policy':{en:'Privacy policy',hi:'गोपनीयता नीति',mr:'गोपनीयता धोरण'},
};
export const tr=(l:Lang,s:string)=>D[s]?.[l]||s;

export const LEGAL:Record<Lang,{terms:string[],privacy:string[]}>={
  en:{
    terms:['VanRozgar connects buyers with Gram Sabhas and CFR villagers who collect and sell forest produce.','Give true details when you sign up. Gram Sabha and villager accounts are checked before they go live.','Prices are set fairly with the Gram Sabha. Do not misuse the platform, place false requests, or sell restricted items.','Delivery and payment steps follow what is shown on each request. We may pause an account that breaks these terms.','VanRozgar does not support any harm to wildlife or nature, or any deforestation. Do not list or request produce gathered by cutting trees that is not necessary, by uprooting plants, or by harming animals or their habitat. Collect only what is ripe and fallen, and leave the forest healthy. Accounts that break this rule can be removed.'],
    privacy:['We collect your name, phone number, address and the documents you upload only to run your account and orders.','Your phone number is checked with a one-time code. We do not sell your data.','Details are shared only with the Gram Sabha, buyer or delivery partner involved in your order.','You can ask the VanRozgar team to correct or delete your data at any time.','VanRozgar does not support harm to wildlife or nature, or any unnecessary cutting of trees or deforestation. We do not accept or share listings, photos or locations that promote such harm, and we may report or remove them to protect the forest and the people who care for it.'],
  },
  hi:{
    terms:['वनरोज़गार खरीदारों को ग्राम सभाओं और वन उपज इकट्ठा कर बेचने वाले CFR ग्रामीणों से जोड़ता है।','साइन अप करते समय सही जानकारी दें। ग्राम सभा और ग्रामीण खातों की जाँच के बाद ही उन्हें चालू किया जाता है।','कीमतें ग्राम सभा के साथ उचित रूप से तय होती हैं। प्लेटफ़ॉर्म का दुरुपयोग, झूठे अनुरोध या प्रतिबंधित वस्तुओं की बिक्री न करें।','डिलीवरी और भुगतान के चरण हर अनुरोध में दिखाए अनुसार होते हैं। नियम तोड़ने पर खाता रोका जा सकता है।','वनरोज़गार वन्यजीवों या प्रकृति को किसी भी नुकसान, या किसी भी वनों की कटाई का समर्थन नहीं करता। ऐसी उपज सूचीबद्ध या अनुरोधित न करें जो अनावश्यक रूप से पेड़ काटकर, पौधे उखाड़कर, या जानवरों व उनके आवास को नुकसान पहुँचाकर इकट्ठा की गई हो। केवल पकी और गिरी हुई उपज ही लें और जंगल को स्वस्थ छोड़ें। यह नियम तोड़ने वाले खाते हटाए जा सकते हैं।'],
    privacy:['हम आपका नाम, फ़ोन नंबर, पता और अपलोड किए दस्तावेज़ केवल आपका खाता और ऑर्डर चलाने के लिए लेते हैं।','आपका फ़ोन नंबर एक बार वाले कोड से जाँचा जाता है। हम आपका डेटा नहीं बेचते।','जानकारी केवल आपके ऑर्डर से जुड़ी ग्राम सभा, खरीदार या डिलीवरी पार्टनर के साथ साझा होती है।','आप कभी भी वनरोज़गार टीम से अपना डेटा सुधारने या हटाने को कह सकते हैं।','वनरोज़गार वन्यजीवों या प्रकृति को नुकसान, या अनावश्यक पेड़ कटाई और वनों की कटाई का समर्थन नहीं करता। हम ऐसे नुकसान को बढ़ावा देने वाली सूचियाँ, तस्वीरें या स्थान स्वीकार या साझा नहीं करते, और जंगल व उसकी देखभाल करने वाले लोगों की रक्षा के लिए उन्हें रिपोर्ट या हटा सकते हैं।'],
  },
  mr:{
    terms:['वनरोजगार खरेदीदारांना ग्रामसभा आणि वनउपज गोळा करून विकणाऱ्या CFR ग्रामस्थांशी जोडते.','साइन अप करताना खरी माहिती द्या. ग्रामसभा आणि ग्रामस्थ खाती तपासल्यानंतरच सुरू होतात.','किमती ग्रामसभेसोबत योग्य रीतीने ठरतात. प्लॅटफॉर्मचा गैरवापर, खोट्या विनंत्या किंवा प्रतिबंधित वस्तूंची विक्री करू नका.','डिलिव्हरी आणि पेमेंटचे टप्पे प्रत्येक विनंतीत दाखवल्याप्रमाणे असतात. अटी मोडल्यास खाते थांबवले जाऊ शकते.','वनरोजगार वन्यजीव किंवा निसर्गाला कोणतीही हानी, किंवा कोणत्याही जंगलतोडीचे समर्थन करत नाही. अनावश्यकपणे झाडे तोडून, झाडे उपटून किंवा प्राणी व त्यांच्या अधिवासाला हानी पोहोचवून गोळा केलेली उपज नोंदवू किंवा मागू नका. फक्त पिकलेले आणि गळलेले घ्या आणि जंगल निरोगी ठेवा. हा नियम मोडणारी खाती काढली जाऊ शकतात.'],
    privacy:['आम्ही तुमचे नाव, फोन नंबर, पत्ता आणि अपलोड केलेली कागदपत्रे फक्त तुमचे खाते व ऑर्डर चालवण्यासाठी घेतो.','तुमचा फोन नंबर एकदाच वापरायच्या कोडने तपासला जातो. आम्ही तुमचा डेटा विकत नाही.','माहिती फक्त तुमच्या ऑर्डरशी संबंधित ग्रामसभा, खरेदीदार किंवा डिलिव्हरी भागीदाराला दिली जाते.','तुम्ही कधीही वनरोजगार टीमला तुमचा डेटा दुरुस्त किंवा हटवण्यास सांगू शकता.','वनरोजगार वन्यजीव किंवा निसर्गाला हानी, किंवा अनावश्यक वृक्षतोड आणि जंगलतोडीचे समर्थन करत नाही. अशा हानीला प्रोत्साहन देणाऱ्या नोंदी, फोटो किंवा ठिकाणे आम्ही स्वीकारत किंवा शेअर करत नाही आणि जंगलाचे व त्याची काळजी घेणाऱ्या लोकांचे रक्षण करण्यासाठी ती कळवू किंवा काढू शकतो.'],
  },
};
