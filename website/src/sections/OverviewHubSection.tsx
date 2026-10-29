import React from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { TabId } from '../types';
import {
  TreePine,
  Sparkles,
  Users,
  ShoppingBag,
  Scale,
  Truck,
  BarChart3,
  ArrowRight,
  ShieldCheck,
  Coins,
  CheckCircle2,
  ExternalLink,
} from 'lucide-react';

interface ModuleCardConfig {
  tabId: TabId;
  titleKey: 'ecosystem' | 'howItWorks' | 'portals' | 'marketplace' | 'barter' | 'delivery' | 'impact';
  icon: React.ComponentType<{ className?: string }>;
  tag: {
    en: string;
    hi: string;
    mr: string;
  };
  highlight: {
    en: string;
    hi: string;
    mr: string;
  };
  description: {
    en: string;
    hi: string;
    mr: string;
  };
}

const MODULE_CARDS: ModuleCardConfig[] = [
  {
    tabId: 'ecosystem',
    titleKey: 'ecosystem',
    icon: TreePine,
    tag: { en: '5 FRA Pillars', hi: '५ वन अधिकार स्तंभ', mr: '५ वन हक्क स्तंभ' },
    highlight: { en: 'VanMitra Architecture', hi: 'वनमित्र-AI वास्तुकला', mr: 'वनमित्र-AI रचना' },
    description: {
      en: 'How legal forest rights mapped in VanMitra-AI connect directly into VanMitra for sustainable rural trade.',
      hi: 'वनमित्र-AI में मान्यता प्राप्त वन अधिकार कैसे सीधे वनमित्र के बाज़ार से जुड़कर आय उत्पन्न करते हैं।',
      mr: 'वनमित्र-AI मध्ये मिळालेले वन हक्क कसे थेट वनमित्र बाजारपेठेशी जोडून उत्पन्न मिळवून देतात.',
    },
  },
  {
    tabId: 'how_it_works',
    titleKey: 'howItWorks',
    icon: Sparkles,
    tag: { en: '6-Stage Lifecycle', hi: '६-चरणीय जीवनचक्र', mr: '६-टप्प्यांची कार्यपद्धती' },
    highlight: { en: 'End-to-End Workflow', hi: 'पूर्ण कार्यप्रणाली', mr: 'संपूर्ण कार्यपद्धती' },
    description: {
      en: 'From Gram Sabha listing to buyer request, barter evaluation, vehicle dispatch, and verified ratings.',
      hi: 'ग्राम सभा सूचीकरण से लेकर खरीदार अनुरोध, विनिमय मूल्यांकन, वाहन रवानगी और सत्यापित रेटिंग तक।',
      mr: 'ग्राम सभा नोंदणीपासून खरेदी विनंती, विनिमय मूल्यमापन, वाहन रवानगी आणि पडताळणी रेटिंगपर्यंत.',
    },
  },
  {
    tabId: 'portals',
    titleKey: 'portals',
    icon: Users,
    tag: { en: '3 Role Views', hi: '३ मुख्य भूमिका', mr: '३ भूमिकांचे दृश्य' },
    highlight: { en: 'Role-Based Access', hi: 'भूमिका-आधारित प्रवेश', mr: 'भूमिका-आधारित प्रवेश' },
    description: {
      en: 'Detailed comparison matrix and interactive workflows for Gram Sabhas, Villagers, and Enterprise Buyers.',
      hi: 'ग्राम सभा, ग्रामीण भूस्वामी और संस्थागत खरीदारों के लिए विस्तृत तुलना तालिका और कार्यप्रवाह।',
      mr: 'ग्राम सभा, स्थानिक ग्रामस्थ आणि संस्थात्मक खरेदीदारांसाठी सविस्तर तुलना आणि वैशिष्ट्ये.',
    },
  },
  {
    tabId: 'marketplace',
    titleKey: 'marketplace',
    icon: ShoppingBag,
    tag: { en: 'Live Catalog', hi: 'सजीव सूची', mr: 'थेट बाजार' },
    highlight: { en: 'Produce & Jadibuti', hi: 'जड़ी-बूटी व वनोपज', mr: 'जडीबुटी व वनोपज' },
    description: {
      en: 'Search and filter wild honey, ashwagandha, bamboo crafts, and lac by distance, price, and provenance.',
      hi: 'जंगली शहद, अश्वगंधा, बांस शिल्प और लाख को दूरी, उचित मूल्य और वन प्रमाणीकरण द्वारा खोजें।',
      mr: 'रानटी मध, अश्वगंधा, बांबू कलाकृती आणि लाख अंतर, योग्य दर आणि वन प्रमाणीकरणासह शोधा.',
    },
  },
  {
    tabId: 'barter',
    titleKey: 'barter',
    icon: Scale,
    tag: { en: 'Fair Pricing', hi: 'उचित मूल्य व विनिमय', mr: 'योग्य दर व विनिमय' },
    highlight: { en: 'Equity Meter & Pooling', hi: 'संतुलन मीटर व समूह विक्रय', mr: 'संतुलन मीटर व समूह विक्री' },
    description: {
      en: 'Autonomous pricing guidance, interactive barter balance meter, and pooled harvest aggregation simulator.',
      hi: 'स्वायत्त मूल्य मार्गदर्शन, वस्तु विनिमय संतुलन मीटर और सामूहिक वनोपज एकत्रीकरण सिमुलेटर।',
      mr: 'स्वायत्त दर मार्गदर्शन, वस्तु विनिमय समतोल मीटर आणि सामूहिक वनोपज एकत्रीकरण सिम्युलेटर.',
    },
  },
  {
    tabId: 'delivery',
    titleKey: 'delivery',
    icon: Truck,
    tag: { en: 'Rural Transport', hi: 'ग्रामीण परिवहन', mr: 'स्थानिक वाहतूक' },
    highlight: { en: 'Paid Delivery Gigs', hi: 'सशुल्क वाहन रोज़गार', mr: 'सशुल्क वाहतूक रोजगार' },
    description: {
      en: 'Registered pickup truck, tempo, and bike owners claim local haul orders and earn guaranteed per-trip income.',
      hi: 'पंजीकृत पिकअप, ऑटो और बाइक मालिक स्थानीय ढुलाई कार्य स्वीकार कर प्रति-यात्रा सुरक्षित आय कमाते हैं।',
      mr: 'नोंदणीकृत पिकअप, ऑटो आणि बाईक चालक स्थानिक वाहतूक कामे स्वीकारून खात्रीशीर उत्पन्न मिळवतात.',
    },
  },
  {
    tabId: 'impact',
    titleKey: 'impact',
    icon: BarChart3,
    tag: { en: 'Proven Impact', hi: 'प्रमाणित परिणाम', mr: 'नोंदवलेला प्रभाव' },
    highlight: { en: 'Provenance & Decisions', hi: 'विश्वसनीयता व निर्णय', mr: 'विश्वासार्हता व निर्णय' },
    description: {
      en: 'Community fund metrics, FRA trust tags, sustainable harvest quotas, and open product architecture roadmap.',
      hi: 'सामुदायिक कोष आंकड़े, एफआरए विश्वास टैग, सतत दोहन सीमाएं और ओपन प्रोडक्ट निर्णय रोडमैप।',
      mr: 'सामुदायिक निधी आकडेवारी, एफआरए विश्वास टॅग, शाश्वत संकलन मर्यादा आणि पुढील रोडमॅप.',
    },
  },
];

export const OverviewHubSection: React.FC = () => {
  const { language, setActiveTab } = useMarketplace();
  const t = translations[language];

  return (
    <section className="py-16 sm:py-20 bg-[#F4F7F5] dark:bg-[#10261B] text-[#13202B] dark:text-[#F4F7F5] transition-colors border-t border-[#2D765C]/20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Heading */}
        <div className="text-center max-w-3xl mx-auto mb-12 sm:mb-16 space-y-4">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#1A4331]/10 dark:bg-[#2D765C]/30 text-[#1A4331] dark:text-[#5FAE3B] text-xs font-bold">
            <ShieldCheck className="w-4 h-4 text-[#FF8D20]" />
            <span>
              {language === 'hi'
                ? 'अलग-अलग विंडो टैब में अनुभाग देखें'
                : language === 'mr'
                ? 'स्वतंत्र विंडो टॅबमध्ये विभाग पहा'
                : 'Dedicated Window Tab Sections'}
            </span>
          </div>

          <h2 className="text-3xl sm:text-4xl font-extrabold font-['Manrope'] tracking-tight">
            {language === 'hi'
              ? 'वनमित्र के सभी ७ प्रमुख अनुभाग'
              : language === 'mr'
              ? 'वनमित्रचे सर्व ७ मुख्य विभाग'
              : 'Explore All 7 Dedicated Sections'}
          </h2>

          <p className="text-sm sm:text-base text-[#66737C] dark:text-[#AAB8B2] leading-relaxed">
            {language === 'hi'
              ? 'प्रत्येक विषय अपनी स्वतंत्र विंडो टैब में संरचित है ताकि आप बिना किसी रुकावट के लक्षित जानकारी देख सकें।'
              : language === 'mr'
              ? 'प्रत्येक विषय त्याच्या स्वतंत्र विंडो टॅबमध्ये मांडला आहे जेणेकरून आपण संबंधित माहिती सहजपणे पाहू शकाल.'
              : 'Each core feature operates inside its own dedicated window tab section. Click any module below or use the top right sections dropdown to switch instantly.'}
          </p>
        </div>

        {/* 7 Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {MODULE_CARDS.map((card, idx) => {
            const Icon = card.icon;
            const tabTitle = t.nav[card.titleKey];
            const tag = card.tag[language];
            const highlight = card.highlight[language];
            const desc = card.description[language];

            return (
              <div
                key={card.tabId}
                className={`relative flex flex-col justify-between p-6 sm:p-7 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200/80 dark:border-[#2B5A46] shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 group ${
                  idx === 6 ? 'md:col-span-2 lg:col-span-1' : ''
                }`}
              >
                {/* Top Row: Icon + Tag */}
                <div className="flex items-center justify-between gap-3 mb-4">
                  <div className="w-12 h-12 rounded-2xl bg-[#F4F7F5] dark:bg-[#10261B] border border-[#2D765C]/20 flex items-center justify-center text-[#FF8D20] shadow-xs group-hover:scale-110 transition-transform">
                    <Icon className="w-6 h-6 text-[#FF8D20]" />
                  </div>
                  <span className="text-[11px] font-bold px-2.5 py-1 rounded-full bg-[#1A4331]/10 dark:bg-[#2D765C]/40 text-[#1A4331] dark:text-[#5FAE3B]">
                    {tag}
                  </span>
                </div>

                {/* Content */}
                <div className="space-y-2 mb-6 flex-grow">
                  <div className="text-xs font-semibold text-[#FF8D20] uppercase tracking-wider">
                    {highlight}
                  </div>
                  <h3 className="text-xl font-bold font-['Manrope'] text-[#13202B] dark:text-white group-hover:text-[#FF8D20] transition-colors">
                    {tabTitle}
                  </h3>
                  <p className="text-xs sm:text-sm text-[#66737C] dark:text-[#AAB8B2] leading-relaxed">
                    {desc}
                  </p>
                </div>

                {/* Action CTA */}
                <button
                  type="button"
                  onClick={() => {
                    setActiveTab(card.tabId);
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                  }}
                  className="w-full inline-flex items-center justify-between px-4 py-2.5 rounded-xl bg-[#F4F7F5] dark:bg-[#10261B] hover:bg-[#FF8D20] dark:hover:bg-[#FF8D20] text-[#13202B] dark:text-[#F4F7F5] hover:text-white dark:hover:text-white border border-gray-200/80 dark:border-[#2B5A46]/30 text-xs sm:text-sm font-bold shadow-xs hover:shadow-md transition-all cursor-pointer group/btn"
                >
                  <span>
                    {language === 'hi'
                      ? `${tabTitle} टैब खोलें`
                      : language === 'mr'
                      ? `${tabTitle} टॅब उघडा`
                      : `Open ${tabTitle} Tab`}
                  </span>
                  <ArrowRight className="w-4 h-4 text-[#FF8D20] group-hover/btn:text-white group-hover/btn:translate-x-1 transition-all" />
                </button>
              </div>
            );
          })}
        </div>

        {/* Global Architecture Summary Callout */}
        <div
          className="mt-12 p-6 sm:p-8 rounded-3xl bg-gradient-to-r from-[#1A4331] to-[#10261B] text-white border border-[#2D765C]/40 shadow-xl flex flex-col md:flex-row items-center justify-between gap-6"
        >
          <div className="space-y-2 text-left">
            <div className="inline-flex items-center gap-2 text-xs font-bold text-[#FF8D20] tracking-wide uppercase">
              <CheckCircle2 className="w-4 h-4" />
              <span>{t.ecosystemSynergy}</span>
            </div>
            <h4 className="text-lg sm:text-xl font-bold font-['Manrope']">
              {language === 'hi'
                ? 'पारदर्शी वन संपदा और ग्रामीण परिवहन मंच'
                : language === 'mr'
                ? 'पारदर्शक वन संपत्ती आणि स्थानिक वाहतूक मंच'
                : 'Empowering Forest Stewards, Tribal Gatherers & Local Drivers'}
            </h4>
            <p className="text-xs sm:text-sm text-[#AAB8B2] max-w-2xl leading-relaxed">
              {t.footer.summary}
            </p>
          </div>

          <button
            type="button"
            onClick={() => setActiveTab('marketplace')}
            className="shrink-0 flex items-center gap-2 bg-[#FF8D20] hover:bg-[#D96B00] active:scale-95 text-white px-6 py-3 rounded-2xl text-xs sm:text-sm font-bold shadow-lg shadow-orange-950/20 transition-all cursor-pointer"
          >
            <ShoppingBag className="w-4 h-4" />
            <span>{t.nav.exploreSection}: {t.nav.marketplace}</span>
          </button>
        </div>

      </div>
    </section>
  );
};
