import React, { useState } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { PortalType } from '../types';
import {
  Users,
  Home,
  Check,
  X,
  Smartphone,
  Layers,
  ArrowRight,
  ShieldCheck,
  Truck,
  Scale,
} from 'lucide-react';

export const PortalsComparisonSection: React.FC = () => {
  const { language, setIsDemoOpen, setActivePortal } = useMarketplace();
  const t = translations[language];

  const [selectedPortalIdx, setSelectedPortalIdx] = useState<number>(0);
  const portalTypes: PortalType[] = ['gram_sabha', 'villager', 'buyer'];

  const specs = t.portalsSection.portalSpecs;
  const currentSpec = specs[selectedPortalIdx];
  const activePortalType = portalTypes[selectedPortalIdx];

  const handleTestPortalInDemo = (portal: PortalType) => {
    setActivePortal(portal);
    window.location.hash = '#/demo';
    setIsDemoOpen(true);
  };

  return (
    <section id="portals" className="py-20 bg-[#F4F7F5] dark:bg-[#0C1B14] text-[#13202B] dark:text-[#F4F7F5] transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Heading */}
        <div className="text-center max-w-3xl mx-auto mb-14 space-y-4">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1A4331]/10 dark:bg-[#2D765C]/30 text-[#1A4331] dark:text-[#5FAE3B] text-xs font-bold">
            <Users className="w-3.5 h-3.5" />
            <span>{t.portalsSection.badge}</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold font-['Manrope'] tracking-tight">
            {t.portalsSection.title}
          </h2>
          <p className="text-sm sm:text-base text-[#66737C] dark:text-[#AAB8B2]">
            {t.portalsSection.desc} <span className="font-semibold text-[#FF8D20]">{t.portalsSection.deliveryClarification}</span>
          </p>
        </div>

        {/* 3 Portal Selection Tabs */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
          {specs.map((spec, idx) => (
            <button
              key={idx}
              onClick={() => setSelectedPortalIdx(idx)}
              className={`p-5 rounded-3xl text-left border transition-all cursor-pointer ${
                selectedPortalIdx === idx
                  ? 'bg-white dark:bg-[#173425] border-[#FF8D20] shadow-xl ring-2 ring-[#FF8D20]/20 scale-[1.02]'
                  : 'bg-white/60 dark:bg-[#10261B] border-gray-200 dark:border-[#2B5A46] hover:bg-white dark:hover:bg-[#173425]/60'
              }`}
            >
              <div className="flex items-center justify-between mb-2">
                <span className="text-xs font-bold px-2.5 py-0.5 rounded-full bg-[#1A4331]/10 dark:bg-[#2D765C]/30 text-[#1A4331] dark:text-[#5FAE3B]">
                  {spec.badge}
                </span>
                <span className={`w-2.5 h-2.5 rounded-full ${selectedPortalIdx === idx ? 'bg-[#FF8D20]' : 'bg-gray-300 dark:bg-gray-700'}`} />
              </div>
              <h3 className="text-lg font-bold text-[#13202B] dark:text-white font-['Manrope']">
                {spec.title}
              </h3>
              <p className="text-xs text-[#66737C] dark:text-[#AAB8B2] mt-1 line-clamp-2">
                {spec.description}
              </p>
            </button>
          ))}
        </div>

        {/* Active Portal Deep Dive Card */}
        <div className="p-6 sm:p-8 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xl mb-12">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
            
            <div className="lg:col-span-7 space-y-4 text-left">
              <div className="flex items-center gap-2">
                <span className="text-xs font-bold px-3 py-1 rounded-full bg-[#FF8D20] text-white">
                  {t.portalsSection.activeSpecBadge}
                </span>
                <span className="text-xs text-[#66737C] dark:text-[#AAB8B2]">
                  {currentSpec.subtitle}
                </span>
              </div>

              <h3 className="text-2xl sm:text-3xl font-extrabold text-[#1A4331] dark:text-white font-['Manrope']">
                {currentSpec.title}
              </h3>

              <p className="text-sm text-[#13202B] dark:text-[#F4F7F5]/90 leading-relaxed">
                {currentSpec.description}
              </p>

              {/* Bottom Navigation Tabs display */}
              <div className="p-3.5 rounded-2xl bg-[#F4F7F5] dark:bg-[#10261B] border border-gray-200 dark:border-[#2B5A46]">
                <div className="text-[11px] font-bold text-[#66737C] dark:text-[#AAB8B2] uppercase tracking-wider mb-2 flex items-center gap-1.5">
                  <Smartphone className="w-3.5 h-3.5 text-[#FF8D20]" />
                  <span>{t.portalsSection.bottomTabsLabel}</span>
                </div>
                <div className="flex flex-wrap gap-2">
                  {currentSpec.bottomTabs.map((tab, idx) => (
                    <span
                      key={idx}
                      className="px-3 py-1 rounded-xl text-xs font-bold bg-white dark:bg-[#173425] text-[#1A4331] dark:text-[#5FAE3B] border border-gray-200 dark:border-[#2B5A46] shadow-xs"
                    >
                      {tab}
                    </span>
                  ))}
                </div>
              </div>

              {/* Key Features List */}
              <div className="space-y-2 pt-2">
                <div className="text-xs font-bold text-[#13202B] dark:text-white">
                  {t.portalsSection.coreCapsLabel}
                </div>
                {currentSpec.keyFeatures.map((feat, fIdx) => (
                  <div key={fIdx} className="flex items-start gap-2 text-xs text-[#66737C] dark:text-[#AAB8B2]">
                    <Check className="w-4 h-4 text-[#5FAE3B] shrink-0 mt-0.5" />
                    <span>{feat}</span>
                  </div>
                ))}
                {currentSpec.notAllowed.map((not, nIdx) => (
                  <div key={nIdx} className="flex items-start gap-2 text-xs text-[#D7262E] dark:text-red-400">
                    <X className="w-4 h-4 text-[#D7262E] shrink-0 mt-0.5" />
                    <span>{not}</span>
                  </div>
                ))}
              </div>

              <div className="pt-4">
                <button
                  onClick={() => handleTestPortalInDemo(activePortalType)}
                  className="flex items-center gap-2 bg-[#FF8D20] hover:bg-[#D96B00] text-white px-6 py-2.5 rounded-xl text-xs sm:text-sm font-bold shadow-md transition-all active:scale-95 cursor-pointer"
                >
                  <span>{t.portalsSection.launchInDemo} ({currentSpec.title})</span>
                  <ArrowRight className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* Visual Phone Frame Mini Preview */}
            <div className="lg:col-span-5 flex justify-center">
              <div className="w-64 rounded-3xl bg-[#0C1B14] p-3 shadow-2xl border-4 border-[#2B5A46] text-white space-y-3">
                {/* Simulated Phone Top Bar */}
                <div className="flex items-center justify-between text-[10px] text-white/70 px-2 pt-1">
                  <span>9:41</span>
                  <span className="font-bold">VanRozgar</span>
                  <span>5G 98%</span>
                </div>

                {/* Simulated Portal Top Header */}
                <div className="p-2.5 rounded-xl bg-[#1A4331] text-xs flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div className="w-6 h-6 rounded-full bg-[#FF8D20] text-white font-bold flex items-center justify-center text-[10px]">
                      {selectedPortalIdx === 0 ? 'GS' : selectedPortalIdx === 1 ? 'VI' : 'BY'}
                    </div>
                    <div>
                      <div className="font-bold leading-tight">{currentSpec.title}</div>
                      <div className="text-[9px] text-[#AAB8B2]">
                        {language === 'hi' ? 'जव्हार सीएफआर क्लस्टर' : language === 'mr' ? 'जव्हार सीएफआर विभाग' : 'Jawhar CFR Cluster'}
                      </div>
                    </div>
                  </div>
                  <ShieldCheck className="w-4 h-4 text-[#5FAE3B]" />
                </div>

                {/* Content snippet */}
                <div className="p-2.5 rounded-xl bg-[#173425] text-[11px] space-y-1.5">
                  <div className="text-[#FF8D20] font-bold">
                    {selectedPortalIdx === 0
                      ? language === 'hi' ? '₹४२,८०० ग्राम आय' : language === 'mr' ? '₹४२,८०० ग्राम उत्पन्न' : '₹42,800 Village Earnings'
                      : selectedPortalIdx === 1
                      ? language === 'hi' ? 'वाहन है? ₹१२/किमी कमाएं' : language === 'mr' ? 'वाहन आहे? ₹१२/किमी कमवा' : 'Have a Vehicle? Earn ₹12/km'
                      : language === 'hi' ? 'थोक प्रसंस्करण सूचियां पहले' : language === 'mr' ? 'घाऊक साठा आधी' : 'Bulk Processing Listings First'}
                  </div>
                  <div className="text-[9px] text-[#AAB8B2] line-clamp-2">
                    {selectedPortalIdx === 0
                      ? language === 'hi' ? '२ ऑर्डर चालक को सुपुर्दगी हेतु प्रतीक्षारत' : language === 'mr' ? '२ ऑर्डर्स चालकाकडे देण्यास तयार' : '2 orders awaiting handover to driver'
                      : selectedPortalIdx === 1
                      ? language === 'hi' ? 'ग्राम परिषदों के बीच संसाधन पहुंचाएं' : language === 'mr' ? 'गावागावांत माल पोहोचवा' : 'Deliver resources between forest councils'
                      : language === 'hi' ? 'सह्याद्री पर्वतमाला से प्रमाणित आंवला व जड़ी-बूटी' : language === 'mr' ? 'सह्याद्रीतून अस्सल आवळा व औषधी' : 'Verified bulk amla & herbs from Sahyadri ridges'}
                  </div>
                </div>

                {/* Simulated Bottom Nav with Orange Active Pill */}
                <div className="pt-2 border-t border-white/10 flex items-center justify-around text-[9px] text-white/70">
                  <div className="flex flex-col items-center text-[#FF8D20] font-bold">
                    <Home className="w-3.5 h-3.5" />
                    <span>{language === 'hi' ? 'गृह' : language === 'mr' ? 'मुख्य' : 'Home'}</span>
                  </div>
                  <div className="flex flex-col items-center">
                    <Layers className="w-3.5 h-3.5" />
                    <span>{selectedPortalIdx === 0 ? (language === 'hi' ? 'सूचियां' : language === 'mr' ? 'उत्पादने' : 'Listings') : (language === 'hi' ? 'खोजें' : language === 'mr' ? 'शोधा' : 'Search')}</span>
                  </div>
                  <div className="flex flex-col items-center">
                    <Scale className="w-3.5 h-3.5" />
                    <span>{language === 'hi' ? 'अनुरोध' : language === 'mr' ? 'विनंत्या' : 'Requests'}</span>
                  </div>
                  <div className="flex flex-col items-center">
                    <Truck className="w-3.5 h-3.5" />
                    <span>{language === 'hi' ? 'ऑर्डर्स' : language === 'mr' ? 'ऑर्डर्स' : 'Orders'}</span>
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>

        {/* Comparison Matrix Table */}
        <div className="rounded-3xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-lg overflow-hidden">
          <div className="p-5 border-b border-gray-200 dark:border-[#2B5A46]">
            <h4 className="text-base font-bold text-[#13202B] dark:text-white font-['Manrope']">
              {t.portalsSection.matrixTitle}
            </h4>
            <p className="text-xs text-[#66737C] dark:text-[#AAB8B2]">
              {t.portalsSection.matrixDesc}
            </p>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="bg-gray-50 dark:bg-[#10261B] text-[#66737C] dark:text-[#AAB8B2] border-b border-gray-200 dark:border-[#2B5A46]">
                  <th className="py-3 px-4 font-bold">{t.portalsSection.colFeature}</th>
                  <th className="py-3 px-4 font-bold text-[#1A4331] dark:text-[#5FAE3B]">{t.portalsSection.colGramSabha}</th>
                  <th className="py-3 px-4 font-bold text-[#FF8D20]">{t.portalsSection.colVillager}</th>
                  <th className="py-3 px-4 font-bold text-blue-600 dark:text-blue-400">{t.portalsSection.colBuyer}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 dark:divide-[#2B5A46]">
                {t.portalsSection.comparisonRows.map((row, rIdx) => (
                  <tr key={rIdx} className="hover:bg-gray-50/50 dark:hover:bg-white/5">
                    <td className="py-3 px-4 font-semibold text-[#13202B] dark:text-white">
                      {row.feature}
                    </td>
                    <td className="py-3 px-4 text-[#13202B] dark:text-white">
                      {typeof row.gs === 'boolean' ? (
                        row.gs ? <Check className="w-4 h-4 text-[#5FAE3B]" /> : <X className="w-4 h-4 text-gray-300 dark:text-gray-600" />
                      ) : (
                        row.gs
                      )}
                    </td>
                    <td className="py-3 px-4 text-[#13202B] dark:text-white">
                      {typeof row.vil === 'boolean' ? (
                        row.vil ? <Check className="w-4 h-4 text-[#5FAE3B]" /> : <X className="w-4 h-4 text-gray-300 dark:text-gray-600" />
                      ) : (
                        row.vil
                      )}
                    </td>
                    <td className="py-3 px-4 text-[#13202B] dark:text-white">
                      {typeof row.buy === 'boolean' ? (
                        row.buy ? <Check className="w-4 h-4 text-[#5FAE3B]" /> : <X className="w-4 h-4 text-gray-300 dark:text-gray-600" />
                      ) : (
                        row.buy
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

      </div>
    </section>
  );
};
