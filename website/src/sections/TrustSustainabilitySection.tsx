import React from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import {
  ShieldCheck,
  Leaf,
  FileCheck,
  AlertTriangle,
  Scale,
  TreePine,
  CheckCircle2,
} from 'lucide-react';

export const TrustSustainabilitySection: React.FC = () => {
  const { language } = useMarketplace();
  const t = translations[language];

  return (
    <section className="py-20 bg-[#F4F7F5] dark:bg-[#10261B] text-[#13202B] dark:text-[#F4F7F5] transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Heading */}
        <div className="text-center max-w-3xl mx-auto mb-14 space-y-4">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1A4331]/10 dark:bg-[#2D765C]/30 text-[#1A4331] dark:text-[#5FAE3B] text-xs font-bold">
            <ShieldCheck className="w-3.5 h-3.5" />
            <span>{t.trustSection.badge}</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold font-['Manrope'] tracking-tight">
            {t.trustSection.title}
          </h2>
          <p className="text-sm sm:text-base text-[#66737C] dark:text-[#AAB8B2]">
            {t.trustSection.desc}
          </p>
        </div>

        {/* 2-Column Architecture: Provenance Tag vs Large-Order Reason Rule */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          
          {/* Card 1: Anatomical Breakdown of the Trust Tag */}
          <div className="p-6 sm:p-8 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200/80 dark:border-[#2B5A46] shadow-xl space-y-5">
            <div className="flex items-center justify-between pb-3 border-b border-gray-100 dark:border-[#2B5A46]">
              <div className="flex items-center gap-2">
                <div className="p-2 rounded-xl bg-emerald-500/20 text-[#5FAE3B]">
                  <Leaf className="w-5 h-5" />
                </div>
                <h3 className="text-lg font-bold text-[#1A4331] dark:text-white font-['Manrope']">
                  {t.trustSection.tagTitle}
                </h3>
              </div>
              <span className="text-[11px] font-bold px-2.5 py-0.5 rounded-full bg-emerald-100 dark:bg-emerald-950/60 text-[#1A4331] dark:text-[#5FAE3B]">
                {t.trustSection.tagBadge}
              </span>
            </div>

            <p className="text-xs text-[#66737C] dark:text-[#AAB8B2] leading-relaxed">
              {t.trustSection.tagIntro}
            </p>

            <div className="space-y-3">
              {t.trustSection.tagPillars.map((pillar, idx) => (
                <div key={idx} className="p-3.5 rounded-2xl bg-[#F4F7F5] dark:bg-[#10261B] border border-gray-200/80 dark:border-[#2B5A46] flex items-start gap-3">
                  <CheckCircle2 className="w-4 h-4 text-[#5FAE3B] shrink-0 mt-0.5" />
                  <div className="text-xs">
                    <strong className="text-[#13202B] dark:text-white">{pillar.title}</strong>
                    <p className="text-[#66737C] dark:text-[#AAB8B2] mt-0.5">
                      {pillar.desc}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Card 2: The Large-Order Sustainability Rule */}
          <div className="p-6 sm:p-8 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200/80 dark:border-[#2B5A46] shadow-xl space-y-5">
            <div className="flex items-center justify-between pb-3 border-b border-gray-100 dark:border-[#2B5A46]">
              <div className="flex items-center gap-2">
                <div className="p-2 rounded-xl bg-amber-500/20 text-[#FF8D20]">
                  <AlertTriangle className="w-5 h-5" />
                </div>
                <h3 className="text-lg font-bold text-[#1A4331] dark:text-white font-['Manrope']">
                  {t.trustSection.largeOrderTitle}
                </h3>
              </div>
              <span className="text-[11px] font-bold px-2.5 py-0.5 rounded-full bg-amber-100 dark:bg-amber-950/60 text-[#D96B00] dark:text-[#FF8D20]">
                {t.trustSection.largeOrderBadge}
              </span>
            </div>

            <p className="text-xs text-[#66737C] dark:text-[#AAB8B2] leading-relaxed">
              {t.trustSection.largeOrderIntro}
            </p>

            <div className="space-y-3">
              {t.trustSection.largeOrderRules.map((rule, idx) => (
                <div key={idx} className="p-3.5 rounded-2xl bg-[#F4F7F5] dark:bg-[#10261B] border border-gray-200/80 dark:border-[#2B5A46] flex items-start gap-3">
                  {idx === 0 ? <TreePine className="w-4 h-4 text-[#FF8D20] shrink-0 mt-0.5" /> : idx === 1 ? <Scale className="w-4 h-4 text-[#FF8D20] shrink-0 mt-0.5" /> : <FileCheck className="w-4 h-4 text-[#FF8D20] shrink-0 mt-0.5" />}
                  <div className="text-xs">
                    <strong className="text-[#13202B] dark:text-white">{rule.title}</strong>
                    <p className="text-[#66737C] dark:text-[#AAB8B2] mt-0.5">
                      {rule.desc}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>

        </div>

      </div>
    </section>
  );
};
