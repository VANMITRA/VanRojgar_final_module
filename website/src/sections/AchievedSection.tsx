import React from 'react';
import { Award, Check } from 'lucide-react';
import { useMarketplace } from '../context/MarketplaceContext';
import { appFlow } from '../i18n/appFlow';

/**
 * What has been achieved, in real figures: the 14 Community Forest Resource villages of the Raah Foundation
 * report (1 Oct 2026), and what the app offers. Nothing here is sample data.
 */
export const AchievedSection: React.FC = () => {
  const { language } = useMarketplace();
  const text = appFlow[language].achieved;

  return (
    <section id="achieved" className="py-16 bg-white dark:bg-[#10261B] text-[#13202B] dark:text-[#F4F7F5] transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-10 space-y-3">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-100 dark:bg-emerald-950/60 text-[#1A4331] dark:text-[#5FAE3B] text-xs font-bold">
            <Award className="w-3.5 h-3.5" />
            <span>{text.badge}</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold font-['Manrope'] tracking-tight">{text.title}</h2>
          <p className="text-xs sm:text-sm text-[#66737C] dark:text-[#AAB8B2]">{text.desc}</p>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
          {text.figures.map((f) => (
            <div
              key={f.label}
              className="p-5 rounded-3xl bg-[#F4F7F5] dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] text-center"
            >
              <div className="text-3xl font-extrabold font-['Manrope'] text-[#1A4331] dark:text-[#5FAE3B]">{f.value}</div>
              <div className="mt-1 text-xs text-[#66737C] dark:text-[#AAB8B2]">{f.label}</div>
            </div>
          ))}
        </div>
        <p className="mt-3 text-center text-[11px] text-[#66737C] dark:text-[#AAB8B2]">{text.source}</p>

        <div className="mt-10 max-w-3xl mx-auto p-6 rounded-3xl bg-[#1A4331] text-white">
          <h3 className="text-lg font-bold font-['Manrope'] mb-3">{text.inAppTitle}</h3>
          <ul className="space-y-2">
            {text.inApp.map((line) => (
              <li key={line} className="flex items-start gap-2 text-sm text-white/90">
                <Check className="w-4 h-4 mt-0.5 shrink-0 text-[#5FAE3B]" />
                <span>{line}</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
};
