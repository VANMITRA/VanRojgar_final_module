import React, { useState } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { calculateGroupSellingSplit } from '../utils/marketplace';
import {
  Layers,
  Users,
  ArrowRight,
  Coins,
} from 'lucide-react';

export const GroupSellingSection: React.FC = () => {
  const { language } = useMarketplace();
  const t = translations[language];

  const [soldQty, setSoldQty] = useState(60);
  const pricePerUnit = 65; // ₹65/kg for pooled Organic Wild Amla

  const contributors = [
    {
      id: 'p1',
      name: language === 'hi' ? 'ग्राम सभा जव्हार' : language === 'mr' ? 'ग्रामसभा जव्हार' : 'Gram Sabha Jawhar',
      quantity: 40,
    },
    {
      id: 'p2',
      name: language === 'hi' ? 'ग्राम सभा मोखाडा' : language === 'mr' ? 'ग्रामसभा मोखाडा' : 'Gram Sabha Mokhada',
      quantity: 35,
    },
    {
      id: 'p3',
      name: language === 'hi' ? 'ग्राम सभा विक्रमगड' : language === 'mr' ? 'ग्रामसभा विक्रमगड' : 'Gram Sabha Vikramgad',
      quantity: 25,
    },
  ];

  const totalPoolCapacity = contributors.reduce((acc, c) => acc + c.quantity, 0); // 100 kg
  const splits = calculateGroupSellingSplit(contributors, soldQty, pricePerUnit);
  const totalBuyerCost = soldQty * pricePerUnit;

  return (
    <section className="py-20 bg-[#F4F7F5] dark:bg-[#0C1B14] text-[#13202B] dark:text-[#F4F7F5] transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Heading */}
        <div className="text-center max-w-3xl mx-auto mb-14 space-y-4">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1A4331]/10 dark:bg-[#2D765C]/30 text-[#1A4331] dark:text-[#5FAE3B] text-xs font-bold">
            <Layers className="w-3.5 h-3.5" />
            <span>{t.groupSellingSection.badge}</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold font-['Manrope'] tracking-tight">
            {t.groupSellingSection.title}
          </h2>
          <p className="text-sm sm:text-base text-[#66737C] dark:text-[#AAB8B2]">
            {t.groupSellingSection.desc}
          </p>
        </div>

        {/* Visual Pooling & Distribution Interactive Card */}
        <div className="p-6 sm:p-8 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xl">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
            
            {/* Left: Contributing Villages */}
            <div className="lg:col-span-5 space-y-4">
              <div className="flex items-center justify-between pb-2 border-b border-gray-100 dark:border-[#2B5A46]">
                <h3 className="text-sm font-bold text-[#1A4331] dark:text-white flex items-center gap-2">
                  <Users className="w-4 h-4 text-[#5FAE3B]" />
                  <span>{t.groupSellingSection.contributingTitle}</span>
                </h3>
                <span className="text-xs font-bold text-[#5FAE3B]">
                  {t.groupSellingSection.totalPoolLabel} {totalPoolCapacity} kg
                </span>
              </div>

              <div className="space-y-3">
                {contributors.map((contrib) => (
                  <div
                    key={contrib.id}
                    className="p-3.5 rounded-2xl bg-[#F4F7F5] dark:bg-[#10261B] border border-gray-200 dark:border-[#2B5A46] flex items-center justify-between"
                  >
                    <div>
                      <div className="text-xs font-bold text-[#13202B] dark:text-white">
                        {contrib.name}
                      </div>
                      <div className="text-[11px] text-[#66737C] dark:text-[#AAB8B2]">
                        {t.groupSellingSection.contributedPrefix} <strong className="text-[#13202B] dark:text-white">{contrib.quantity} kg</strong> ({contrib.quantity}%)
                      </div>
                    </div>

                    <div className="w-16 bg-gray-200 dark:bg-gray-700 h-2 rounded-full overflow-hidden">
                      <div
                        className="bg-[#2D765C] h-full"
                        style={{ width: `${contrib.quantity}%` }}
                      />
                    </div>
                  </div>
                ))}
              </div>

              <div className="p-3 rounded-2xl bg-emerald-50 dark:bg-emerald-950/30 text-xs text-[#1A4331] dark:text-emerald-300">
                {t.groupSellingSection.equalRuleNote}
              </div>
            </div>

            {/* Middle: Funnel / Arrow */}
            <div className="lg:col-span-2 flex flex-col items-center justify-center text-center space-y-2 py-4 lg:py-0">
              <div className="w-10 h-10 rounded-full bg-[#FF8D20] text-white flex items-center justify-center shadow-md">
                <ArrowRight className="w-5 h-5" />
              </div>
              <span className="text-[11px] font-bold text-[#FF8D20] uppercase tracking-wider">
                {t.groupSellingSection.pooledFunnelLabel}
              </span>
            </div>

            {/* Right: Buyer View & Automated Payout Split */}
            <div className="lg:col-span-5 p-5 rounded-2xl bg-[#F4F7F5] dark:bg-[#10261B] border border-gray-200 dark:border-[#2B5A46] space-y-4">
              <div>
                <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-blue-100 dark:bg-blue-950/60 text-blue-800 dark:text-blue-300">
                  {t.groupSellingSection.bulkBuyerPurchaseLabel}
                </span>
                <h4 className="text-base font-bold text-[#13202B] dark:text-white mt-1">
                  {language === 'hi' ? 'जैविक जंगली आंवला (₹६५/किग्रा)' : language === 'mr' ? 'सेंद्रिय रान आवळा (₹६५/किलो)' : `Organic Wild Amla (₹${pricePerUnit}/kg)`}
                </h4>
              </div>

              {/* Slider for buyer order amount */}
              <div>
                <div className="flex justify-between text-xs font-bold mb-1">
                  <span>{t.groupSellingSection.simBuyerOrder}</span>
                  <span className="text-[#FF8D20]">{soldQty} kg</span>
                </div>
                <input
                  type="range"
                  min="10"
                  max={totalPoolCapacity}
                  step="5"
                  value={soldQty}
                  onChange={(e) => setSoldQty(Number(e.target.value))}
                  className="w-full accent-[#FF8D20]"
                />
                <div className="flex justify-between text-[10px] text-[#66737C] dark:text-[#AAB8B2] mt-0.5">
                  <span>{t.groupSellingSection.minLabel}</span>
                  <span>{t.groupSellingSection.maxLabel}</span>
                </div>
              </div>

              <div className="p-3 bg-white dark:bg-[#173425] rounded-xl flex items-center justify-between text-xs">
                <span className="text-[#66737C] dark:text-[#AAB8B2]">{t.groupSellingSection.totalOrderVal}</span>
                <span className="text-base font-extrabold text-[#1A4331] dark:text-[#5FAE3B]">
                  ₹{totalBuyerCost.toLocaleString()}
                </span>
              </div>

              {/* Automated Payout Splits per Producer */}
              <div className="space-y-2 pt-1">
                <div className="text-[11px] font-bold text-[#13202B] dark:text-white flex items-center gap-1">
                  <Coins className="w-3.5 h-3.5 text-[#FF8D20]" />
                  <span>{t.groupSellingSection.villagePayoutTitle}</span>
                </div>

                {splits.map((s) => (
                  <div
                    key={s.id}
                    className="p-2 rounded-xl bg-white dark:bg-[#173425] border border-gray-100 dark:border-[#2B5A46] flex items-center justify-between text-xs"
                  >
                    <span className="font-semibold text-[#13202B] dark:text-white truncate">
                      {s.name}
                    </span>
                    <span className="font-extrabold text-[#5FAE3B] shrink-0">
                      ₹{s.earnings.toLocaleString()}
                      <span className="text-[10px] font-normal text-[#66737C] dark:text-[#AAB8B2]"> ({s.sharePct}%)</span>
                    </span>
                  </div>
                ))}
              </div>
            </div>

          </div>
        </div>

      </div>
    </section>
  );
};
