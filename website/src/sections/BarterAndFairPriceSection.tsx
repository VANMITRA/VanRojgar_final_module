import React, { useState } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { evaluateBarterBalance } from '../utils/marketplace';
import {
  Scale,
  Sparkles,
  HelpCircle,
  ArrowLeftRight,
  TrendingUp,
  Info,
  CheckCircle2,
  AlertTriangle,
} from 'lucide-react';

export const BarterAndFairPriceSection: React.FC = () => {
  const { language } = useMarketplace();
  const t = translations[language];

  // Sliders for Party A (Offering)
  const [offeredResource, setOfferedResource] = useState('Wild Forest Raw Honey');
  const [offeredQty, setOfferedQty] = useState(10);
  const [offeredUnitVal, setOfferedUnitVal] = useState(550); // ₹550/kg

  // Sliders for Party B (Requesting in return)
  const [requestedResource, setRequestedResource] = useState('Organic Ashwagandha Roots');
  const [requestedQty, setRequestedQty] = useState(11);
  const [requestedUnitVal, setRequestedUnitVal] = useState(480); // ₹480/kg

  // Simulated "Not enough data yet" state toggle
  const [isDataSparse, setIsDataSparse] = useState(false);

  const totalOfferedValue = offeredQty * offeredUnitVal;
  const totalRequestedValue = requestedQty * requestedUnitVal;

  const evaluation = evaluateBarterBalance(totalOfferedValue, totalRequestedValue);

  const verdictLabel =
    evaluation.verdict === 'balanced'
      ? t.barterSection.balancedVerdict
      : evaluation.verdict === 'favorable_to_receiver'
      ? t.barterSection.favoursReceiverVerdict
      : t.barterSection.favoursSenderVerdict;

  return (
    <section id="barter" className="py-20 bg-white dark:bg-[#10261B] text-[#13202B] dark:text-[#F4F7F5] transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Heading */}
        <div className="text-center max-w-3xl mx-auto mb-14 space-y-4">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1A4331]/10 dark:bg-[#2D765C]/30 text-[#1A4331] dark:text-[#5FAE3B] text-xs font-bold">
            <Scale className="w-3.5 h-3.5" />
            <span>{t.barterSection.badge}</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold font-['Manrope'] tracking-tight">
            {t.barterSection.title}
          </h2>
          <p className="text-sm sm:text-base text-[#66737C] dark:text-[#AAB8B2]">
            {t.barterSection.desc}
          </p>
        </div>

        {/* Interactive Balance Meter Tool Card */}
        <div className="p-6 sm:p-8 rounded-3xl bg-[#F4F7F5] dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xl">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 pb-6 border-b border-gray-200 dark:border-[#2B5A46]">
            <div>
              <h3 className="text-xl font-bold text-[#1A4331] dark:text-white flex items-center gap-2">
                <span>{t.barterSection.simulatorTitle}</span>
                <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-[#FF8D20]/20 text-[#FF8D20]">
                  {t.barterSection.liveTestBadge}
                </span>
              </h3>
              <p className="text-xs text-[#66737C] dark:text-[#AAB8B2] mt-0.5">
                {t.barterSection.simulatorDesc}
              </p>
            </div>

            {/* "Not enough data" simulation switch */}
            <div className="flex items-center gap-2 bg-white dark:bg-[#10261B] px-3 py-1.5 rounded-xl border border-gray-200 dark:border-[#2B5A46]">
              <span className="text-xs font-semibold text-[#13202B] dark:text-white">
                {t.barterSection.simToggleLabel}
              </span>
              <button
                type="button"
                onClick={() => setIsDataSparse(!isDataSparse)}
                aria-label="Toggle sparse data simulation"
                className={`relative inline-flex h-5 w-9 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
                  isDataSparse ? 'bg-[#FF8D20]' : 'bg-gray-300 dark:bg-gray-600'
                }`}
              >
                <span
                  className={`pointer-events-none inline-block h-4 w-4 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                    isDataSparse ? 'translate-x-4' : 'translate-x-0'
                  }`}
                />
              </button>
            </div>
          </div>

          {/* New Resource / Not Enough Data State Alert */}
          {isDataSparse ? (
            <div className="my-6 p-4 rounded-2xl bg-amber-50 dark:bg-amber-950/40 border border-amber-200 dark:border-amber-800 flex items-start gap-3 text-xs text-amber-900 dark:text-amber-200">
              <Info className="w-5 h-5 text-amber-600 dark:text-amber-400 shrink-0 mt-0.5" />
              <div>
                <strong className="font-bold">{t.barterSection.sparseDataTitle}</strong>
                <p className="mt-1 leading-relaxed">
                  {t.barterSection.sparseDataDesc}
                </p>
              </div>
            </div>
          ) : (
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center my-6">
              
              {/* Party A (Offering) Column */}
              <div className="lg:col-span-5 p-5 rounded-2xl bg-white dark:bg-[#10261B] border border-gray-200 dark:border-[#2B5A46] space-y-4">
                <div className="flex items-center justify-between pb-2 border-b border-gray-100 dark:border-[#2B5A46]">
                  <span className="text-xs font-bold text-[#1A4331] dark:text-[#5FAE3B]">
                    {t.barterSection.partyATitle}
                  </span>
                  <span className="text-xs font-semibold px-2 py-0.5 rounded bg-emerald-100 dark:bg-emerald-950/50 text-[#1A4331] dark:text-emerald-300">
                    {t.barterSection.partyASub}
                  </span>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-[#66737C] dark:text-[#AAB8B2] mb-1">
                    {t.barterSection.commodityLabel}
                  </label>
                  <select
                    value={offeredResource}
                    onChange={(e) => {
                      setOfferedResource(e.target.value);
                      if (e.target.value.includes('Honey')) setOfferedUnitVal(550);
                      else if (e.target.value.includes('Bamboo')) setOfferedUnitVal(220);
                      else setOfferedUnitVal(380);
                    }}
                    className="w-full p-2 text-xs font-bold rounded-xl bg-gray-50 dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] text-[#13202B] dark:text-white"
                  >
                    <option value="Wild Forest Raw Honey">
                      {language === 'hi' ? 'जंगली शुद्ध शहद (₹५५०/किग्रा)' : language === 'mr' ? 'जंगली शुद्ध मध (₹५५०/किलो)' : 'Wild Forest Raw Honey (₹550/kg)'}
                    </option>
                    <option value="Tribal Bamboo Storage Baskets">
                      {language === 'hi' ? 'जनजातीय बांस टोकरी (₹२२०/नग)' : language === 'mr' ? 'बांबूच्या हस्तकला टोपल्या (₹२२०/नग)' : 'Tribal Bamboo Baskets (₹220/pc)'}
                    </option>
                    <option value="Natural Shellac / Lac">
                      {language === 'hi' ? 'प्राकृतिक लाख (₹३८०/किग्रा)' : language === 'mr' ? 'नैसर्गिक लाख (₹३८०/किलो)' : 'Natural Shellac / Lac (₹380/kg)'}
                    </option>
                  </select>
                </div>

                <div>
                  <div className="flex justify-between text-xs font-bold mb-1">
                    <span>{t.barterSection.qtyOfferedLabel}</span>
                    <span className="text-[#FF8D20]">{offeredQty} units</span>
                  </div>
                  <input
                    type="range"
                    min="1"
                    max="50"
                    value={offeredQty}
                    onChange={(e) => setOfferedQty(Number(e.target.value))}
                    className="w-full accent-[#FF8D20]"
                  />
                </div>

                <div className="p-3 bg-gray-50 dark:bg-[#173425] rounded-xl flex items-center justify-between text-xs">
                  <span className="text-[#66737C] dark:text-[#AAB8B2]">{t.barterSection.totalBenchmarkVal}</span>
                  <span className="font-extrabold text-[#1A4331] dark:text-[#5FAE3B] text-sm">
                    ₹{totalOfferedValue.toLocaleString()}
                  </span>
                </div>
              </div>

              {/* Central Swap Icon & Ratio Indicator */}
              <div className="lg:col-span-2 flex flex-col items-center justify-center text-center space-y-2">
                <div className="w-12 h-12 rounded-full bg-[#1A4331] dark:bg-[#2D765C] text-white flex items-center justify-center shadow-lg">
                  <ArrowLeftRight className="w-6 h-6 text-[#FF8D20]" />
                </div>
                <div className="text-xs font-bold text-[#13202B] dark:text-white">
                  {t.barterSection.exchangeRatioLabel}
                </div>
                <div className="text-base font-extrabold text-[#FF8D20]">
                  {evaluation.ratio.toFixed(2)}x
                </div>
              </div>

              {/* Party B (Requested) Column */}
              <div className="lg:col-span-5 p-5 rounded-2xl bg-white dark:bg-[#10261B] border border-gray-200 dark:border-[#2B5A46] space-y-4">
                <div className="flex items-center justify-between pb-2 border-b border-gray-100 dark:border-[#2B5A46]">
                  <span className="text-xs font-bold text-[#FF8D20]">
                    {t.barterSection.partyBTitle}
                  </span>
                  <span className="text-xs font-semibold px-2 py-0.5 rounded bg-orange-100 dark:bg-orange-950/50 text-[#FF8D20]">
                    {t.barterSection.partyBSub}
                  </span>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-[#66737C] dark:text-[#AAB8B2] mb-1">
                    {t.barterSection.commodityLabel}
                  </label>
                  <select
                    value={requestedResource}
                    onChange={(e) => {
                      setRequestedResource(e.target.value);
                      if (e.target.value.includes('Ashwagandha')) setRequestedUnitVal(480);
                      else if (e.target.value.includes('Water')) setRequestedUnitVal(650);
                      else setRequestedUnitVal(95);
                    }}
                    className="w-full p-2 text-xs font-bold rounded-xl bg-gray-50 dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] text-[#13202B] dark:text-white"
                  >
                    <option value="Organic Ashwagandha Roots">
                      {language === 'hi' ? 'जैविक अश्वगंधा जड़ें (₹४८०/किग्रा)' : language === 'mr' ? 'सेंद्रिय अश्वगंधा मुळ्या (₹४८०/किलो)' : 'Organic Ashwagandha Roots (₹480/kg)'}
                    </option>
                    <option value="Perennial Spring Water Tankers">
                      {language === 'hi' ? 'बारहमासी पहाड़ी स्वच्छ जल (₹६५०/टैंकर)' : language === 'mr' ? 'बारमाही झऱ्याचे शुद्ध पाणी (₹६५०/टँकर)' : 'Perennial Spring Water (₹650/tanker)'}
                    </option>
                    <option value="Sun-Dried Mahua Flowers">
                      {language === 'hi' ? 'धूप में सूखे महुआ फूल (₹९५/किग्रा)' : language === 'mr' ? 'सुकलेली मोहाची फुले (₹९५/किलो)' : 'Sun-Dried Mahua Flowers (₹95/kg)'}
                    </option>
                  </select>
                </div>

                <div>
                  <div className="flex justify-between text-xs font-bold mb-1">
                    <span>{t.barterSection.qtyRequestedLabel}</span>
                    <span className="text-[#FF8D20]">{requestedQty} units</span>
                  </div>
                  <input
                    type="range"
                    min="1"
                    max="50"
                    value={requestedQty}
                    onChange={(e) => setRequestedQty(Number(e.target.value))}
                    className="w-full accent-[#FF8D20]"
                  />
                </div>

                <div className="p-3 bg-gray-50 dark:bg-[#173425] rounded-xl flex items-center justify-between text-xs">
                  <span className="text-[#66737C] dark:text-[#AAB8B2]">{t.barterSection.totalBenchmarkVal}</span>
                  <span className="font-extrabold text-[#1A4331] dark:text-[#5FAE3B] text-sm">
                    ₹{totalRequestedValue.toLocaleString()}
                  </span>
                </div>
              </div>

            </div>
          )}

          {/* Balance Verdict Display */}
          {!isDataSparse && (
            <div className="p-4 rounded-2xl bg-white dark:bg-[#10261B] border border-gray-200 dark:border-[#2B5A46] space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Scale className="w-5 h-5 text-[#FF8D20]" />
                  <span className="text-sm font-bold text-[#13202B] dark:text-white">
                    {t.barterSection.equivalenceStatus}
                  </span>
                </div>

                <span
                  className={`text-xs font-extrabold px-3 py-1 rounded-full ${
                    evaluation.verdict === 'balanced'
                      ? 'bg-[#5FAE3B]/20 text-[#5FAE3B]'
                      : evaluation.verdict === 'favorable_to_receiver'
                      ? 'bg-blue-500/20 text-blue-400'
                      : 'bg-amber-500/20 text-amber-500'
                  }`}
                >
                  {verdictLabel}
                </span>
              </div>

              {/* Visual Bar Meter */}
              <div className="relative h-3 w-full bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                <div
                  className="h-full bg-gradient-to-r from-[#2D765C] via-[#FF8D20] to-[#2D765C] transition-all duration-300"
                  style={{ width: `${Math.min(100, Math.max(10, (evaluation.ratio / 2) * 100))}%` }}
                />
              </div>

              <div className="flex items-center justify-between text-xs text-[#66737C] dark:text-[#AAB8B2]">
                <span>{language === 'hi' ? 'पक्ष क: ₹' : language === 'mr' ? 'गाव अ: ₹' : 'Party A: ₹'}{totalOfferedValue.toLocaleString()}</span>
                <span className="italic">
                  {language === 'hi'
                    ? evaluation.verdict === 'balanced'
                      ? 'दोनों पक्षों के लिए संतुलित विनिमय मूल्य'
                      : evaluation.verdict === 'favorable_to_receiver'
                      ? 'प्रतिपक्ष को अधिक मूल्य प्राप्त हो रहा है'
                      : 'प्रस्तावित माल का मूल्य कम है'
                    : evaluation.advice}
                </span>
                <span>{language === 'hi' ? 'पक्ष ख: ₹' : language === 'mr' ? 'गाव ब: ₹' : 'Party B: ₹'}{totalRequestedValue.toLocaleString()}</span>
              </div>
            </div>
          )}

          {/* Principle Footnote */}
          <div className="mt-4 pt-4 border-t border-gray-200 dark:border-[#2B5A46] flex items-start gap-2 text-xs text-[#66737C] dark:text-[#AAB8B2]">
            <Info className="w-4 h-4 text-[#2D765C] dark:text-[#5FAE3B] shrink-0 mt-0.5" />
            <p>
              <strong>{t.barterSection.footnoteTitle}</strong> {t.barterSection.footnoteDesc}
            </p>
          </div>

        </div>

      </div>
    </section>
  );
};
