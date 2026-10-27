import React from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import {
  CreditCard,
  Truck,
  Layers,
  Globe,
  WifiOff,
  FolderTree,
  AlertCircle,
} from 'lucide-react';

export const OpenDecisionsSection: React.FC = () => {
  const { language } = useMarketplace();
  const t = translations[language];

  const icons = [
    <CreditCard key="card" className="w-5 h-5 text-[#FF8D20]" />,
    <Truck key="truck" className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />,
    <Layers key="layers" className="w-5 h-5 text-blue-600 dark:text-blue-400" />,
    <Globe key="globe" className="w-5 h-5 text-teal-600 dark:text-teal-400" />,
    <WifiOff key="wifi" className="w-5 h-5 text-purple-600 dark:text-purple-400" />,
    <FolderTree key="folder" className="w-5 h-5 text-amber-600 dark:text-amber-400" />,
  ];

  return (
    <section className="py-20 bg-[#F4F7F5] dark:bg-[#0C1B14] text-[#13202B] dark:text-[#F4F7F5] transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Heading */}
        <div className="text-center max-w-3xl mx-auto mb-14 space-y-4">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-100 dark:bg-amber-950/60 text-amber-900 dark:text-amber-300 text-xs font-bold">
            <AlertCircle className="w-3.5 h-3.5" />
            <span>{t.openDecisionsSection.badge}</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold font-['Manrope'] tracking-tight">
            {t.openDecisionsSection.title}
          </h2>
          <p className="text-sm sm:text-base text-[#66737C] dark:text-[#AAB8B2]">
            {t.openDecisionsSection.desc}
          </p>
        </div>

        {/* 6 Decisions Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {t.openDecisionsSection.decisions.map((item, idx) => (
            <div
              key={item.id}
              className="p-6 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-md flex flex-col justify-between space-y-4"
            >
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <div className="p-2 rounded-xl bg-[#F4F7F5] dark:bg-[#10261B] border border-gray-200/70 dark:border-[#2B5A46]/40">
                    {icons[idx % icons.length]}
                  </div>
                  <span className="text-xs font-bold px-2 py-0.5 rounded-md bg-[#F4F7F5] dark:bg-[#10261B] text-[#1A4331] dark:text-[#5FAE3B]">
                    {item.id}
                  </span>
                </div>

                <h3 className="text-base font-bold text-[#13202B] dark:text-white font-['Manrope']">
                  {item.title}
                </h3>

                <p className="text-xs font-medium text-[#1A4331] dark:text-white leading-relaxed">
                  {item.question}
                </p>

                <p className="text-[11px] text-[#66737C] dark:text-[#AAB8B2] leading-relaxed">
                  {item.impact}
                </p>
              </div>

              <div className="p-2.5 rounded-xl bg-[#F4F7F5] dark:bg-[#10261B] border border-gray-200 dark:border-[#2B5A46]/60 text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                <strong className="text-[#FF8D20]">{t.openDecisionsSection.statusLabel} </strong>
                {item.demoPlaceholder}
              </div>
            </div>
          ))}
        </div>

      </div>
    </section>
  );
};
