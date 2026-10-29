import React from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { ShieldCheck, Lock } from 'lucide-react';

interface FooterProps {
  onReplayIntro?: () => void;
}

export const Footer: React.FC<FooterProps> = ({ onReplayIntro }) => {
  const { language, setActiveTab } = useMarketplace();
  const t = translations[language];

  return (
    <footer className="bg-[#1A4331] dark:bg-[#0C1B14] text-white pt-16 pb-12 border-t border-[#2D765C]/40 transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        <div
          className="grid grid-cols-1 md:grid-cols-12 gap-8 pb-12 border-b border-[#2D765C]/30"
        >
          
          {/* Brand & Ecosystem Summary */}
          <div className="md:col-span-5 space-y-4">
            <div className="flex items-center gap-3">
              <button
                type="button"
                onClick={() => setActiveTab('overview')}
                className="shrink-0 hover:scale-105 transition-transform text-left cursor-pointer"
              >
                <img
                  src="/logo-192.png"
                  alt="VanMitra Tribal Mandala Logo"
                  width={40}
                  height={40}
                  className="w-8 h-8 sm:w-10 sm:h-10 rounded-full object-cover"
                />
              </button>
              <div>
                <button
                  type="button"
                  onClick={() => setActiveTab('overview')}
                  className="text-xl font-bold tracking-tight text-white font-['Manrope'] hover:text-[#FF8D20] transition-colors cursor-pointer text-left block"
                >
                  {language === 'hi' ? 'वनमित्र' : language === 'mr' ? 'वनमित्र' : 'VanMitra'}
                </button>
                <p className="text-xs text-[#AAB8B2]">{t.footer.subtitle}</p>
              </div>
            </div>

            <p className="text-xs text-[#AAB8B2] max-w-sm leading-relaxed">
              {t.footer.summary}
            </p>

            <div className="flex items-center gap-2 text-xs text-[#5FAE3B] font-semibold">
              <ShieldCheck className="w-4 h-4" />
              <span>{t.footer.compliance}</span>
            </div>
          </div>

          {/* Quick Ecosystem Links */}
          <div className="md:col-span-3 space-y-3">
            <h4 className="text-xs font-bold text-white uppercase tracking-wider">
              {t.footer.ecosystemTitle}
            </h4>
            <ul className="space-y-2 text-xs text-[#AAB8B2]">
              <li>
                <button
                  type="button"
                  onClick={() => setActiveTab('overview')}
                  className="hover:text-[#FF8D20] transition-colors cursor-pointer text-left"
                >
                  {t.nav.overview}
                </button>
              </li>
              <li>
                <button
                  type="button"
                  onClick={() => setActiveTab('ecosystem')}
                  className="hover:text-[#FF8D20] transition-colors cursor-pointer text-left"
                >
                  {t.nav.ecosystem}
                </button>
              </li>
              <li>
                <button
                  type="button"
                  onClick={() => setActiveTab('how_it_works')}
                  className="hover:text-[#FF8D20] transition-colors cursor-pointer text-left"
                >
                  {t.nav.howItWorks}
                </button>
              </li>
              <li>
                <button
                  type="button"
                  onClick={() => setActiveTab('portals')}
                  className="hover:text-[#FF8D20] transition-colors cursor-pointer text-left"
                >
                  {t.nav.portals}
                </button>
              </li>
              <li>
                <button
                  type="button"
                  onClick={() => setActiveTab('marketplace')}
                  className="hover:text-[#FF8D20] transition-colors cursor-pointer text-left"
                >
                  {t.nav.marketplace}
                </button>
              </li>
              <li>
                <button
                  type="button"
                  onClick={() => setActiveTab('barter')}
                  className="hover:text-[#FF8D20] transition-colors cursor-pointer text-left"
                >
                  {t.nav.barter}
                </button>
              </li>
              <li>
                <button
                  type="button"
                  onClick={() => setActiveTab('delivery')}
                  className="hover:text-[#FF8D20] transition-colors cursor-pointer text-left"
                >
                  {t.nav.delivery}
                </button>
              </li>
              <li>
                <button
                  type="button"
                  onClick={() => setActiveTab('impact')}
                  className="hover:text-[#FF8D20] transition-colors cursor-pointer text-left"
                >
                  {t.nav.impact}
                </button>
              </li>
            </ul>
          </div>

          {/* Governance Notice & Back-Office Disclaimer */}
          <div className="md:col-span-4 space-y-3">
            <h4 className="text-xs font-bold text-white uppercase tracking-wider flex items-center gap-1.5">
              <Lock className="w-3.5 h-3.5 text-[#FF8D20]" />
              <span>{t.footer.backOfficeTitle}</span>
            </h4>
            <div className="p-3.5 rounded-2xl bg-black/30 border border-white/10 text-xs text-[#AAB8B2] leading-relaxed">
              <p>
                {t.footer.backOfficeText}
              </p>
            </div>
          </div>

        </div>

        {/* Bottom Bar */}
        <div className="pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-[#AAB8B2]">
          <div>
            {t.footer.allRightsReserved}
          </div>

          <div className="flex items-center gap-4 sm:gap-6 flex-wrap">
            {onReplayIntro && (
              <>
                <button
                  type="button"
                  onClick={onReplayIntro}
                  className="text-xs text-[#AAB8B2] hover:text-[#FF8D20] transition-colors underline-offset-4 hover:underline cursor-pointer"
                >
                  {t.footer.replayIntro}
                </button>
                <span>•</span>
              </>
            )}
            <span>{t.footer.fraLaw}</span>
            <span>•</span>
            <span>{t.footer.privacyPolicy}</span>
            <span>•</span>
            <span className="text-[#FF8D20] font-semibold">{t.tagline}</span>
          </div>
        </div>

      </div>
    </footer>
  );
};
