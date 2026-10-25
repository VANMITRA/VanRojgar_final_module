import React, { useState } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import {
  TrendingUp,
  Award,
  Users,
  Truck,
  Coins,
  Info,
} from 'lucide-react';

export const ImpactSection: React.FC = () => {
  const { language } = useMarketplace();
  const t = translations[language];

  const [selectedDistrict, setSelectedDistrict] = useState<'all' | 'palghar' | 'gadchiroli' | 'amravati'>('all');

  const districtData = {
    all: {
      earnings: language === 'hi' ? '₹१८,४५,२००' : language === 'mr' ? '₹१८,४५,२००' : '₹18,45,200',
      jobs: language === 'hi' ? '१,४२०' : language === 'mr' ? '१,४२०' : '1,420',
      families: language === 'hi' ? '८९०' : language === 'mr' ? '८९०' : '890',
      forestAcres: '14,200',
      monthlyGrowth: [
        { month: language === 'hi' ? 'जून' : language === 'mr' ? 'जून' : 'Jun', amount: 180 },
        { month: language === 'hi' ? 'जुलाई' : language === 'mr' ? 'जुलै' : 'Jul', amount: 240 },
        { month: language === 'hi' ? 'अगस्त' : language === 'mr' ? 'ऑगस्ट' : 'Aug', amount: 310 },
        { month: language === 'hi' ? 'सितंबर' : language === 'mr' ? 'सप्टेंबर' : 'Sep', amount: 480 },
        { month: language === 'hi' ? 'अक्टूबर' : language === 'mr' ? 'ऑक्टोबर' : 'Oct', amount: 635 },
      ],
      topProduce: [
        { name: language === 'hi' ? 'जंगली शुद्ध शहद' : language === 'mr' ? 'शुद्ध रान मध' : 'Wild Forest Raw Honey', share: 38 },
        { name: language === 'hi' ? 'जैविक अश्वगंधा व जड़ी-बूटी' : language === 'mr' ? 'सेंद्रिय अश्वगंधा व वनस्पती' : 'Organic Ashwagandha & Herbs', share: 29 },
        { name: language === 'hi' ? 'बांस व बेंत हस्तशिल्प' : language === 'mr' ? 'बांबू व वेत हस्तकला' : 'Tribal Bamboo & Cane Crafts', share: 21 },
        { name: language === 'hi' ? 'लाख व प्राकृतिक गोंद' : language === 'mr' ? 'लाख व नैसर्गिक डिंक' : 'Lac & Forest Gums', share: 12 },
      ],
    },
    palghar: {
      earnings: language === 'hi' ? '₹११,२०,५००' : language === 'mr' ? '₹११,२०,५००' : '₹11,20,500',
      jobs: language === 'hi' ? '८६०' : language === 'mr' ? '८६०' : '860',
      families: language === 'hi' ? '५४०' : language === 'mr' ? '५४०' : '540',
      forestAcres: '8,400',
      monthlyGrowth: [
        { month: language === 'hi' ? 'जून' : language === 'mr' ? 'जून' : 'Jun', amount: 110 },
        { month: language === 'hi' ? 'जुलाई' : language === 'mr' ? 'जुलै' : 'Jul', amount: 150 },
        { month: language === 'hi' ? 'अगस्त' : language === 'mr' ? 'ऑगस्ट' : 'Aug', amount: 200 },
        { month: language === 'hi' ? 'सितंबर' : language === 'mr' ? 'सप्टेंबर' : 'Sep', amount: 290 },
        { month: language === 'hi' ? 'अक्टूबर' : language === 'mr' ? 'ऑक्टोबर' : 'Oct', amount: 370 },
      ],
      topProduce: [
        { name: language === 'hi' ? 'जंगली शहद (जव्हार)' : language === 'mr' ? 'रान मध (जव्हार)' : 'Wild Forest Honey (Jawhar)', share: 44 },
        { name: language === 'hi' ? 'अश्वगंधा (मोखाडा)' : language === 'mr' ? 'अश्वगंधा (मोखाडा)' : 'Ashwagandha (Mokhada)', share: 32 },
        { name: language === 'hi' ? 'बांस उत्पाद (विक्रमगड)' : language === 'mr' ? 'बांबू उत्पादने (विक्रमगड)' : 'Bamboo Crafts (Vikramgad)', share: 24 },
      ],
    },
    gadchiroli: {
      earnings: language === 'hi' ? '₹४,८०,३००' : language === 'mr' ? '₹४,८०,३००' : '₹4,80,300',
      jobs: language === 'hi' ? '३८०' : language === 'mr' ? '३८०' : '380',
      families: language === 'hi' ? '२४०' : language === 'mr' ? '२४०' : '240',
      forestAcres: '4,100',
      monthlyGrowth: [
        { month: language === 'hi' ? 'जून' : language === 'mr' ? 'जून' : 'Jun', amount: 50 },
        { month: language === 'hi' ? 'जुलाई' : language === 'mr' ? 'जुलै' : 'Jul', amount: 65 },
        { month: language === 'hi' ? 'अगस्त' : language === 'mr' ? 'ऑगस्ट' : 'Aug', amount: 80 },
        { month: language === 'hi' ? 'सितंबर' : language === 'mr' ? 'सप्टेंबर' : 'Sep', amount: 130 },
        { month: language === 'hi' ? 'अक्टूबर' : language === 'mr' ? 'ऑक्टोबर' : 'Oct', amount: 155 },
      ],
      topProduce: [
        { name: language === 'hi' ? 'प्राकृतिक लाख' : language === 'mr' ? 'नैसर्गिक लाख' : 'Natural Shellac & Lac', share: 55 },
        { name: language === 'hi' ? 'तेंदू पत्ता व जड़ी-बूटी' : language === 'mr' ? 'तेंदू पाने व औषधी' : 'Tendu Leaves & Herbs', share: 45 },
      ],
    },
    amravati: {
      earnings: language === 'hi' ? '₹२,४४,४००' : language === 'mr' ? '₹२,४४,४००' : '₹2,44,400',
      jobs: language === 'hi' ? '१८०' : language === 'mr' ? '१८०' : '180',
      families: language === 'hi' ? '११०' : language === 'mr' ? '११०' : '110',
      forestAcres: '1,700',
      monthlyGrowth: [
        { month: language === 'hi' ? 'जून' : language === 'mr' ? 'जून' : 'Jun', amount: 20 },
        { month: language === 'hi' ? 'जुलाई' : language === 'mr' ? 'जुलै' : 'Jul', amount: 25 },
        { month: language === 'hi' ? 'अगस्त' : language === 'mr' ? 'ऑगस्ट' : 'Aug', amount: 30 },
        { month: language === 'hi' ? 'सितंबर' : language === 'mr' ? 'सप्टेंबर' : 'Sep', amount: 60 },
        { month: language === 'hi' ? 'अक्टूबर' : language === 'mr' ? 'ऑक्टोबर' : 'Oct', amount: 110 },
      ],
      topProduce: [
        { name: language === 'hi' ? 'धूप में सूखे महुआ फूल' : language === 'mr' ? 'सुकलेली मोहाची फुले' : 'Sun-Dried Mahua Flowers', share: 70 },
        { name: language === 'hi' ? 'जंगली बीज' : language === 'mr' ? 'जंगली बिया' : 'Wild Forest Seeds', share: 30 },
      ],
    },
  };

  const activeData = districtData[selectedDistrict];

  return (
    <section id="impact" className="py-20 bg-[#F4F7F5] dark:bg-[#0C1B14] text-[#13202B] dark:text-[#F4F7F5] transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Heading */}
        <div className="text-center max-w-3xl mx-auto mb-12 space-y-4">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-100 dark:bg-emerald-950/60 text-[#1A4331] dark:text-[#5FAE3B] text-xs font-bold">
            <Award className="w-3.5 h-3.5" />
            <span>{t.impactSection.badge}</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold font-['Manrope'] tracking-tight">
            {t.impactSection.title}
          </h2>
          <div className="inline-block px-3 py-1 rounded-full bg-amber-100 dark:bg-amber-950/60 border border-amber-300 dark:border-amber-800 text-amber-900 dark:text-amber-200 text-xs font-bold">
            {t.impactSection.demoDataWarning}
          </div>
          <p className="text-xs sm:text-sm text-[#66737C] dark:text-[#AAB8B2]">
            {t.impactSection.desc}
          </p>
        </div>

        {/* District Filter Selector */}
        <div className="flex items-center justify-center gap-2 mb-8 overflow-x-auto pb-2">
          {(['all', 'palghar', 'gadchiroli', 'amravati'] as const).map((dist) => (
            <button
              key={dist}
              onClick={() => setSelectedDistrict(dist)}
              className={`px-4 py-1.5 rounded-xl text-xs font-bold capitalize transition-all cursor-pointer ${
                selectedDistrict === dist
                  ? 'bg-[#1A4331] text-white dark:bg-[#FF8D20] shadow-md'
                  : 'bg-white dark:bg-[#173425] text-[#66737C] dark:text-[#AAB8B2] border border-gray-200 dark:border-[#2B5A46]'
              }`}
            >
              {dist === 'all'
                ? t.impactSection.filterAll
                : `${dist.charAt(0).toUpperCase() + dist.slice(1)} ${t.impactSection.filterDistrictSuffix}`}
            </button>
          ))}
        </div>

        {/* Big 3 Metrics Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
          <div className="p-6 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-md flex items-center gap-4">
            <div className="w-14 h-14 rounded-2xl bg-emerald-500/15 text-[#5FAE3B] flex items-center justify-center shrink-0">
              <Coins className="w-7 h-7" />
            </div>
            <div>
              <div className="text-xs font-bold text-[#66737C] dark:text-[#AAB8B2] uppercase tracking-wider">
                {t.impactSection.earningsCardTitle}
              </div>
              <div className="text-2xl sm:text-3xl font-extrabold text-[#1A4331] dark:text-white mt-1">
                {activeData.earnings}
              </div>
              <div className="text-[11px] text-[#5FAE3B] font-semibold mt-0.5">
                {t.impactSection.earningsCardSub}
              </div>
            </div>
          </div>

          <div className="p-6 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-md flex items-center gap-4">
            <div className="w-14 h-14 rounded-2xl bg-amber-500/15 text-[#FF8D20] flex items-center justify-center shrink-0">
              <Truck className="w-7 h-7" />
            </div>
            <div>
              <div className="text-xs font-bold text-[#66737C] dark:text-[#AAB8B2] uppercase tracking-wider">
                {t.impactSection.jobsCardTitle}
              </div>
              <div className="text-2xl sm:text-3xl font-extrabold text-[#1A4331] dark:text-white mt-1">
                {activeData.jobs}
              </div>
              <div className="text-[11px] text-[#FF8D20] font-semibold mt-0.5">
                {t.impactSection.jobsCardSub}
              </div>
            </div>
          </div>

          <div className="p-6 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-md flex items-center gap-4">
            <div className="w-14 h-14 rounded-2xl bg-blue-500/15 text-blue-500 flex items-center justify-center shrink-0">
              <Users className="w-7 h-7" />
            </div>
            <div>
              <div className="text-xs font-bold text-[#66737C] dark:text-[#AAB8B2] uppercase tracking-wider">
                {t.impactSection.familiesCardTitle}
              </div>
              <div className="text-2xl sm:text-3xl font-extrabold text-[#1A4331] dark:text-white mt-1">
                {activeData.families}+
              </div>
              <div className="text-[11px] text-blue-500 font-semibold mt-0.5">
                {t.impactSection.familiesCardSub} ({activeData.forestAcres} ha)
              </div>
            </div>
          </div>
        </div>

        {/* Charts: Monthly Growth + Category Volume Split */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          
          {/* Monthly Livelihood Disbursal Growth Chart */}
          <div className="lg:col-span-7 p-6 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-md space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-sm font-bold text-[#13202B] dark:text-white">
                  {t.impactSection.trendTitle}
                </h3>
                <span className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                  {t.impactSection.trendSub}
                </span>
              </div>
              <span className="text-xs font-extrabold text-[#5FAE3B] flex items-center gap-1">
                <TrendingUp className="w-4 h-4" />
                {t.impactSection.trendBadge}
              </span>
            </div>

            {/* Custom SVG Bar Chart */}
            <div className="h-44 flex items-end justify-between gap-3 pt-6 px-4">
              {activeData.monthlyGrowth.map((bar, bIdx) => (
                <div key={bIdx} className="flex-1 flex flex-col items-center gap-2">
                  <div className="text-[10px] font-bold text-[#66737C] dark:text-[#AAB8B2]">
                    ₹{bar.amount}k
                  </div>
                  <div
                    className="w-full rounded-t-xl bg-gradient-to-t from-[#1A4331] to-[#5FAE3B] dark:from-[#2D765C] dark:to-[#FF8D20] transition-all duration-500"
                    style={{ height: `${(bar.amount / 700) * 120}px` }}
                  />
                  <div className="text-xs font-semibold text-[#13202B] dark:text-white">
                    {bar.month}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Category Distribution Breakdown */}
          <div className="lg:col-span-5 p-6 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-md space-y-4">
            <div>
              <h3 className="text-sm font-bold text-[#13202B] dark:text-white">
                {t.impactSection.volumeTitle}
              </h3>
              <span className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                {t.impactSection.volumeSub}
              </span>
            </div>

            <div className="space-y-3 pt-2">
              {activeData.topProduce.map((p, idx) => (
                <div key={idx} className="space-y-1">
                  <div className="flex justify-between text-xs font-medium text-[#13202B] dark:text-white">
                    <span>{p.name}</span>
                    <span className="font-bold text-[#FF8D20]">{p.share}%</span>
                  </div>
                  <div className="h-2 w-full bg-gray-100 dark:bg-gray-800 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-[#2D765C] dark:bg-[#5FAE3B]"
                      style={{ width: `${p.share}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>

            <div className="p-3 bg-gray-50 dark:bg-[#10261B] rounded-xl text-[11px] text-[#66737C] dark:text-[#AAB8B2] flex items-start gap-2">
              <Info className="w-3.5 h-3.5 text-[#5FAE3B] shrink-0 mt-0.5" />
              <span>
                {t.impactSection.commissionNotice}
              </span>
            </div>
          </div>

        </div>

      </div>
    </section>
  );
};
