import React, { useState } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import {
  FilePlus2,
  Search,
  Scale,
  CheckCircle,
  Truck,
  Award,
  ArrowRight,
  ShieldAlert,
  ChevronRight,
} from 'lucide-react';

export const HowItWorksSection: React.FC = () => {
  const { language } = useMarketplace();
  const t = translations[language];
  const [activeStep, setActiveStep] = useState(0);

  const stepIcons = [
    <FilePlus2 key="0" className="w-5 h-5 text-[#5FAE3B]" />,
    <Search key="1" className="w-5 h-5 text-blue-500" />,
    <Scale key="2" className="w-5 h-5 text-[#FF8D20]" />,
    <CheckCircle key="3" className="w-5 h-5 text-emerald-500" />,
    <Truck key="4" className="w-5 h-5 text-amber-500" />,
    <Award key="5" className="w-5 h-5 text-purple-500" />,
  ];

  const steps = t.howItWorksSection.steps;

  return (
    <section id="how-it-works" className="py-20 bg-[#F4F7F5] dark:bg-[#10261B] text-[#13202B] dark:text-[#F4F7F5] transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Heading */}
        <div className="text-center max-w-3xl mx-auto mb-16 space-y-4">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1A4331]/10 dark:bg-[#2D765C]/30 text-[#1A4331] dark:text-[#5FAE3B] text-xs font-bold">
            <CheckCircle className="w-3.5 h-3.5" />
            <span>{t.howItWorksSection.badge}</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold font-['Manrope'] tracking-tight">
            {t.howItWorksSection.title}
          </h2>
          <p className="text-sm sm:text-base text-[#66737C] dark:text-[#AAB8B2]">
            {t.howItWorksSection.desc}
          </p>
        </div>

        {/* Stepper Tabs Row */}
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-2 mb-10">
          {steps.map((s, idx) => (
            <button
              key={s.step}
              onClick={() => setActiveStep(idx)}
              className={`p-3 rounded-2xl text-left border transition-all cursor-pointer ${
                activeStep === idx
                  ? 'bg-[#1A4331] text-white dark:bg-[#173425] border-[#FF8D20] shadow-lg ring-2 ring-[#FF8D20]/30'
                  : 'bg-white dark:bg-[#0C1B14] border-gray-200/80 dark:border-[#2B5A46] text-[#13202B] dark:text-[#AAB8B2] hover:bg-gray-50'
              }`}
            >
              <div className="flex items-center justify-between mb-1.5">
                <span className={`text-xs font-black ${activeStep === idx ? 'text-[#FF8D20]' : 'text-[#2D765C] dark:text-[#5FAE3B]'}`}>
                  {s.step}
                </span>
                <div className="p-1 rounded-lg bg-black/5 dark:bg-white/10">{stepIcons[idx % stepIcons.length]}</div>
              </div>
              <div className="text-xs font-bold line-clamp-1">
                {s.title}
              </div>
              <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2] truncate mt-0.5">
                {s.actor}
              </div>
            </button>
          ))}
        </div>

        {/* Active Step Feature Display */}
        <div className="p-6 sm:p-8 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200/80 dark:border-[#2B5A46] shadow-xl">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
            
            <div className="lg:col-span-7 space-y-4 text-left">
              <div className="flex items-center gap-2">
                <span className="text-xs font-extrabold px-3 py-1 rounded-full bg-[#FF8D20] text-white">
                  {t.howItWorksSection.stepPrefix} {steps[activeStep].step}
                </span>
                <span className="text-xs font-bold text-[#2D765C] dark:text-[#5FAE3B]">
                  {steps[activeStep].actor}
                </span>
              </div>

              <h3 className="text-2xl sm:text-3xl font-extrabold text-[#1A4331] dark:text-white font-['Manrope']">
                {steps[activeStep].title}
              </h3>

              <p className="text-sm sm:text-base text-[#13202B] dark:text-[#F4F7F5]/90 leading-relaxed font-medium">
                {steps[activeStep].summary}
              </p>

              <div className="space-y-2.5 pt-2">
                {steps[activeStep].details.map((detail, dIdx) => (
                  <div key={dIdx} className="flex items-start gap-2.5 text-xs text-[#66737C] dark:text-[#AAB8B2]">
                    <ChevronRight className="w-4 h-4 text-[#FF8D20] shrink-0 mt-0.5" />
                    <span>{detail}</span>
                  </div>
                ))}
              </div>

              <div className="flex items-center gap-3 pt-4">
                <button
                  onClick={() => setActiveStep((prev) => (prev > 0 ? prev - 1 : steps.length - 1))}
                  className="px-4 py-2 rounded-xl text-xs font-semibold bg-white dark:bg-[#10261B] border border-gray-200 dark:border-[#2B5A46] text-[#13202B] dark:text-white cursor-pointer"
                >
                  {t.howItWorksSection.prevBtn}
                </button>
                <button
                  onClick={() => setActiveStep((prev) => (prev < steps.length - 1 ? prev + 1 : 0))}
                  className="flex items-center gap-1.5 px-5 py-2 rounded-xl text-xs font-bold bg-[#FF8D20] text-white shadow-md hover:bg-[#D96B00] cursor-pointer"
                >
                  <span>{t.howItWorksSection.nextBtn}</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>

            {/* Visual Step Card Mock */}
            <div className="lg:col-span-5 p-6 rounded-2xl bg-white dark:bg-[#10261B] border border-gray-200 dark:border-[#2B5A46] shadow-md space-y-4">
              <div className="flex items-center justify-between pb-3 border-b border-gray-100 dark:border-[#2B5A46]">
                <div className="flex items-center gap-2">
                  <span className="w-3 h-3 rounded-full bg-emerald-500 animate-pulse" />
                  <span className="text-xs font-bold text-[#13202B] dark:text-white">{t.howItWorksSection.liveStatusTitle}</span>
                </div>
                <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-orange-100 dark:bg-orange-950/60 text-[#FF8D20]">
                  {steps[activeStep].previewBadge}
                </span>
              </div>

              {activeStep === 0 && (
                <div className="space-y-3 text-xs">
                  <div className="p-3 bg-gray-50 dark:bg-[#173425] rounded-xl space-y-1">
                    <div className="font-bold text-[#13202B] dark:text-white">
                      {language === 'hi' ? 'संसाधन: शुद्ध जंगली शहद' : language === 'mr' ? 'उत्पादन: शुद्ध जंगली मध' : 'Resource: Wild Forest Honey'}
                    </div>
                    <div className="text-[#66737C] dark:text-[#AAB8B2]">
                      {language === 'hi' ? 'मूल इनपुट दर: ₹५५०/किग्रा' : language === 'mr' ? 'मूळ दर: ₹५५०/किलो' : 'Base input price: ₹550/kg'}
                    </div>
                    <div className="text-[11px] text-[#5FAE3B] font-semibold">
                      {language === 'hi' ? 'सुझाया गया निष्पक्ष मूल्य: ₹४८० – ₹६२०/किग्रा' : language === 'mr' ? 'सुचवलेला योग्य बाजारभाव: ₹४८० – ₹६२०/किलो' : 'Suggested Fair Guide: ₹480 – ₹620/kg'}
                    </div>
                  </div>
                  <div className="p-3 bg-emerald-50 dark:bg-emerald-950/30 rounded-xl text-[#1A4331] dark:text-emerald-300">
                    {language === 'hi'
                      ? 'जव्हार सीएफआर वन समिति द्वारा सतत निष्कर्षण प्रमाणित।'
                      : language === 'mr'
                      ? 'जव्हार सीएफआर वन समितीद्वारे शाश्वत संकलन प्रमाणित.'
                      : 'Sustainable extraction verified by Jawhar CFR Forest Committee.'}
                  </div>
                </div>
              )}

              {activeStep === 1 && (
                <div className="space-y-3 text-xs">
                  <div className="flex justify-between items-center p-3 bg-gray-50 dark:bg-[#173425] rounded-xl">
                    <span>{language === 'hi' ? 'सूची: जैविक अश्वगंधा' : language === 'mr' ? 'उत्पादन: सेंद्रिय अश्वगंधा' : 'Listing: Organic Ashwagandha'}</span>
                    <span className="font-bold text-[#FF8D20]">
                      {language === 'hi' ? '९.८ किमी दूरी' : language === 'mr' ? '९.८ किमी अंतर' : '9.8 km away'}
                    </span>
                  </div>
                  <div className="p-3 bg-blue-50 dark:bg-blue-950/30 rounded-xl text-blue-700 dark:text-blue-300">
                    {language === 'hi'
                      ? 'निकटतम दूरी फ़िल्टर लागू: कम परिवहन लागत और कम कार्बन उत्सर्जन।'
                      : language === 'mr'
                      ? 'जवळचे अंतर फिल्टर लागू: कमी वाहतूक खर्च व कमी उत्सर्जन.'
                      : 'Sort filter applied: Nearest first. Saves transport cost and delivery emissions.'}
                  </div>
                </div>
              )}

              {activeStep === 2 && (
                <div className="space-y-3 text-xs">
                  <div className="p-3 bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-900 rounded-xl text-amber-800 dark:text-amber-200">
                    <div className="font-bold flex items-center gap-1">
                      <ShieldAlert className="w-3.5 h-3.5" />
                      {language === 'hi' ? 'थोक ऑर्डर सीमा पार (३० किग्रा)' : language === 'mr' ? 'मोठी खरेदी मर्यादा (३० किलो)' : 'Bulk Order Threshold Reached (30 kg)'}
                    </div>
                    <div className="text-[11px] mt-1">
                      {language === 'hi'
                        ? 'कारण: "सर्दियों के लिए हर्बल सीरप बैच निर्माण हेतु कच्चा माल।"'
                        : language === 'mr'
                        ? 'कारण: "हिवाळी काढा निर्मितीसाठी कच्चा माल."'
                        : 'Reason: "Batch formulation for winter herbal syrup."'}
                    </div>
                  </div>
                </div>
              )}

              {activeStep === 3 && (
                <div className="space-y-2 text-xs">
                  <div className="p-3 bg-emerald-50 dark:bg-emerald-950/40 rounded-xl font-bold text-[#5FAE3B] flex items-center justify-between">
                    <span>{language === 'hi' ? 'ग्राम सभा द्वारा अनुरोध स्वीकृत' : language === 'mr' ? 'ग्रामसभेकडून मागणी मंजूर' : 'Request Approved by Gram Sabha'}</span>
                    <CheckCircle className="w-4 h-4" />
                  </div>
                  <div className="text-[11px] text-[#66737C] dark:text-[#AAB8B2]">
                    {language === 'hi'
                      ? 'ऑर्डर उत्पन्न: ORD-801. ग्राम डिपो में ३० किग्रा आरक्षित।'
                      : language === 'mr'
                      ? 'ऑर्डर तयार: ORD-801. ग्राम भांडारात ३० किलो माल आरक्षित.'
                      : 'Order generated: ORD-801. 30 kg reserved in village storage depot.'}
                  </div>
                </div>
              )}

              {activeStep === 4 && (
                <div className="space-y-3 text-xs">
                  <div className="p-3 bg-gray-50 dark:bg-[#173425] rounded-xl flex items-center justify-between">
                    <div>
                      <div className="font-bold text-[#13202B] dark:text-white">
                        {language === 'hi' ? 'चालक: सुरेश भोर' : language === 'mr' ? 'चालक: सुरेश भोर' : 'Driver: Suresh Bhor'}
                      </div>
                      <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                        {language === 'hi' ? 'वाहन: महिंद्रा बोलेरो पिकअप' : language === 'mr' ? 'वाहन: महिंद्रा बोलेरो पिकअप' : 'Vehicle: Mahindra Bolero Pickup'}
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-xs font-bold text-[#FF8D20]">₹370</div>
                      <div className="text-[9px] text-[#5FAE3B]">
                        {language === 'hi' ? 'उपलब्ध कार्य स्वीकृत' : language === 'mr' ? 'काम स्वीकारले' : 'Available Job Accepted'}
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {activeStep === 5 && (
                <div className="space-y-3 text-xs">
                  <div className="p-3 bg-purple-50 dark:bg-purple-950/30 rounded-xl space-y-1">
                    <div className="font-bold text-purple-700 dark:text-purple-300">
                      {language === 'hi' ? 'उपज प्राप्ति की पुष्टि व रेटिंग ★★★★★' : language === 'mr' ? 'माल मिळाल्याची खात्री व रेटिंग ★★★★★' : 'Produce Confirmed & Rated ★★★★★'}
                    </div>
                    <div className="text-[11px] text-[#66737C] dark:text-[#AAB8B2]">
                      {language === 'hi'
                        ? '₹१६,५०० ग्राम सभा कोष में · ₹३७० चालक सुरेश को जमा।'
                        : language === 'mr'
                        ? '₹१६,५०० ग्रामसभा खात्यात · ₹३७० चालक सुरेशला जमा.'
                        : '₹16,500 credited to Gram Sabha · ₹370 credited to Driver Suresh.'}
                    </div>
                  </div>
                </div>
              )}

            </div>

          </div>
        </div>

      </div>
    </section>
  );
};
