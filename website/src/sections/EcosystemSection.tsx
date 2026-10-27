import React from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import {
  LayoutDashboard,
  FileText,
  Users,
  Map,
  UserCheck,
  ArrowRight,
  Sparkles,
  TreePine,
  Coins,
  CheckCircle2,
} from 'lucide-react';

export const EcosystemSection: React.FC = () => {
  const { language } = useMarketplace();
  const t = translations[language];

  const parentIcons = [
    <LayoutDashboard key="dash" className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />,
    <FileText key="file" className="w-5 h-5 text-[#FF8D20]" />,
    <Users key="users" className="w-5 h-5 text-blue-600 dark:text-blue-400" />,
    <Map key="map" className="w-5 h-5 text-teal-600 dark:text-teal-400" />,
    <UserCheck key="user" className="w-5 h-5 text-purple-600 dark:text-purple-400" />,
  ];

  return (
    <section id="ecosystem" className="py-20 bg-[#F4F7F5] dark:bg-[#10261B] text-[#13202B] dark:text-[#F4F7F5] transition-colors relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Heading */}
        <div className="text-center max-w-3xl mx-auto mb-16 space-y-4">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#1A4331]/10 dark:bg-[#2D765C]/30 text-[#1A4331] dark:text-[#5FAE3B] text-xs font-bold">
            <TreePine className="w-3.5 h-3.5" />
            <span>{t.ecosystemSection.badge}</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold font-['Manrope'] tracking-tight">
            {t.ecosystemSection.title}
          </h2>
          <p className="text-sm sm:text-base text-[#66737C] dark:text-[#AAB8B2] leading-relaxed">
            {t.ecosystemSection.desc}
          </p>
        </div>

        {/* Dual Pillar Architecture Diagram */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
          
          {/* Pillar 1: VanMitra-AI Governance Platform */}
          <div className="lg:col-span-5 p-6 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200/80 dark:border-[#2B5A46] shadow-xl space-y-4">
            <div className="flex items-center justify-between pb-3 border-b border-gray-100 dark:border-[#2B5A46]">
              <div>
                <span className="text-[11px] font-bold text-[#2D765C] dark:text-[#5FAE3B] tracking-wider uppercase">
                  {language === 'hi' ? 'मूल मंच' : language === 'mr' ? 'मूळ मंच' : 'Parent Platform'}
                </span>
                <h3 className="text-xl font-bold text-[#1A4331] dark:text-white flex items-center gap-2">
                  <span>{t.ecosystemSection.parentTitle}</span>
                </h3>
              </div>
              <span className="px-2.5 py-1 text-[11px] font-bold rounded-full bg-emerald-100 dark:bg-emerald-900/50 text-[#1A4331] dark:text-emerald-300">
                {t.ecosystemSection.parentBadge}
              </span>
            </div>

            <p className="text-xs text-[#66737C] dark:text-[#AAB8B2]">
              {t.ecosystemSection.parentDesc}
            </p>

            <div className="space-y-2.5">
              {t.ecosystemSection.parentModules.map((m, idx) => (
                <div
                  key={m.title}
                  className="p-3 rounded-xl bg-[#F4F7F5] dark:bg-[#10261B] border border-gray-200/70 dark:border-[#2B5A46] flex items-center justify-between transition-all hover:translate-x-1"
                >
                  <div className="flex items-center gap-3">
                    <div className="p-2 rounded-lg bg-gray-50 dark:bg-[#173425]">
                      {parentIcons[idx % parentIcons.length]}
                    </div>
                    <div>
                      <h4 className="text-xs font-bold text-[#13202B] dark:text-white">
                        {m.title}
                      </h4>
                      <p className="text-[11px] text-[#66737C] dark:text-[#AAB8B2] line-clamp-1">
                        {m.desc}
                      </p>
                    </div>
                  </div>
                  <span className="text-[10px] font-semibold text-[#5FAE3B] px-2 py-0.5 rounded bg-emerald-50 dark:bg-emerald-950/40 shrink-0">
                    {m.status}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* Flow Bridge (Arrow connector) */}
          <div className="lg:col-span-2 flex flex-col items-center justify-center text-center space-y-3 py-4 lg:py-0">
            <div className="hidden lg:flex flex-col items-center gap-2">
              <span className="text-[11px] font-extrabold text-[#FF8D20] px-2.5 py-1 rounded-full bg-orange-100 dark:bg-orange-950/50 border border-[#FF8D20]/40">
                {t.ecosystemSection.bridgeBadge}
              </span>
              <div className="w-16 h-1 bg-gradient-to-r from-[#2D765C] via-[#FF8D20] to-[#2D765C] rounded-full animate-pulse" />
              <div className="w-10 h-10 rounded-full bg-[#FF8D20] text-white flex items-center justify-center shadow-md">
                <ArrowRight className="w-5 h-5" />
              </div>
            </div>
            <div className="text-xs font-bold text-[#66737C] dark:text-[#AAB8B2] max-w-[180px]">
              {t.ecosystemSection.bridgeDesc}
            </div>
          </div>

          {/* Pillar 2: VanRozgar Marketplace Module */}
          <div className="lg:col-span-5 p-6 rounded-3xl bg-gradient-to-br from-[#1A4331] to-[#143424] text-white shadow-2xl border border-[#2D765C] space-y-4">
            <div className="flex items-center justify-between pb-3 border-b border-[#2D765C]/50">
              <div>
                <span className="text-[11px] font-bold text-[#FF8D20] tracking-wider uppercase">
                  {language === 'hi' ? 'परिसंस्था मॉड्यूल' : language === 'mr' ? 'परिसंस्था विभाग' : 'Ecosystem Module'}
                </span>
                <h3 className="text-xl font-bold text-white flex items-center gap-2">
                  <span>{t.ecosystemSection.moduleTitle}</span>
                </h3>
              </div>
              <span className="px-2.5 py-1 text-[11px] font-bold rounded-full bg-[#FF8D20] text-white">
                {t.ecosystemSection.moduleBadge}
              </span>
            </div>

            <p className="text-xs text-[#F4F7F5]/80">
              {t.ecosystemSection.moduleDesc}
            </p>

            <div className="space-y-3 pt-1">
              {t.ecosystemSection.pillars.map((pillar, idx) => (
                <div key={idx} className="p-3.5 rounded-xl bg-black/20 border border-white/10 space-y-1">
                  <div className="flex items-center gap-2 text-xs font-bold text-[#FF8D20]">
                    {idx === 0 ? <Coins className="w-4 h-4" /> : idx === 1 ? <CheckCircle2 className="w-4 h-4 text-[#5FAE3B]" /> : <Sparkles className="w-4 h-4 text-amber-300" />}
                    <span>{pillar.title}</span>
                  </div>
                  <p className="text-[11px] text-[#AAB8B2] leading-relaxed">
                    {pillar.desc}
                  </p>
                </div>
              ))}
            </div>
          </div>

        </div>
      </div>
    </section>
  );
};
