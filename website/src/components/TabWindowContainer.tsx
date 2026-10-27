import React from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { TabId } from '../types';
import { ChevronLeft, ChevronRight, Home, ShieldCheck } from 'lucide-react';

interface TabWindowContainerProps {
  children: React.ReactNode;
}

const TAB_ORDER: TabId[] = [
  'overview',
  'ecosystem',
  'how_it_works',
  'portals',
  'marketplace',
  'barter',
  'delivery',
  'impact',
];

export const TabWindowContainer: React.FC<TabWindowContainerProps> = ({ children }) => {
  const { language, activeTab, setActiveTab } = useMarketplace();
  const t = translations[language];

  const currentIndex = TAB_ORDER.indexOf(activeTab);
  const prevTabId = currentIndex > 0 ? TAB_ORDER[currentIndex - 1] : null;
  const nextTabId = currentIndex < TAB_ORDER.length - 1 ? TAB_ORDER[currentIndex + 1] : null;

  const getTabLabel = (id: TabId): string => {
    switch (id) {
      case 'overview':
        return t.nav.overview;
      case 'ecosystem':
        return t.nav.ecosystem;
      case 'how_it_works':
        return t.nav.howItWorks;
      case 'portals':
        return t.nav.portals;
      case 'marketplace':
        return t.nav.marketplace;
      case 'barter':
        return t.nav.barter;
      case 'delivery':
        return t.nav.delivery;
      case 'impact':
        return t.nav.impact;
    }
  };

  return (
    <div
      role="tabpanel"
      id={`tab-panel-${activeTab}`}
      aria-labelledby={`tab-btn-${activeTab}`}
      className="flex-grow flex flex-col focus:outline-none animate-fadeIn"
    >
      {/* Active Tab Content Window */}
      <div className="flex-grow">{children}</div>

      {/* Tab Switcher Bottom Navigator */}
      <nav
        aria-label="Section Navigation"
        className="bg-white dark:bg-[#0A1810] border-t border-gray-200/80 dark:border-[#2D765C]/25 py-6 px-4 sm:px-6 lg:px-8 transition-colors"
      >
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
          {/* Previous tab button */}
          <div className="w-full sm:w-auto flex items-center justify-start">
            {prevTabId ? (
              <button
                type="button"
                onClick={() => {
                  setActiveTab(prevTabId);
                  window.scrollTo({ top: 0, behavior: 'smooth' });
                }}
                className="group flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#F4F7F5] dark:bg-[#143424] border border-gray-200/80 dark:border-[#2B5A46]/30 hover:border-[#FF8D20] text-xs sm:text-sm font-semibold text-[#13202B] dark:text-[#F4F7F5] shadow-xs hover:shadow-md transition-all cursor-pointer"
              >
                <ChevronLeft className="w-4 h-4 text-[#FF8D20] group-hover:-translate-x-0.5 transition-transform" />
                <div className="text-left">
                  <span className="block text-[10px] text-[#66737C] dark:text-[#AAB8B2] font-medium uppercase tracking-wider">
                    {t.nav.previousTab}
                  </span>
                  <span>{getTabLabel(prevTabId)}</span>
                </div>
              </button>
            ) : (
              <div className="flex items-center gap-2 text-xs text-[#66737C] dark:text-[#AAB8B2]">
                <ShieldCheck className="w-4 h-4 text-[#5FAE3B]" />
                <span>{t.tagline}</span>
              </div>
            )}
          </div>

          {/* Quick jump to overview */}
          <div className="flex items-center gap-3">
            {activeTab !== 'overview' && (
              <button
                type="button"
                onClick={() => {
                  setActiveTab('overview');
                  window.scrollTo({ top: 0, behavior: 'smooth' });
                }}
                className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-semibold text-[#13202B] dark:text-[#F4F7F5] bg-black/5 dark:bg-white/5 hover:bg-black/10 dark:hover:bg-white/10 transition-colors cursor-pointer"
              >
                <Home className="w-3.5 h-3.5 text-[#2D765C] dark:text-[#5FAE3B]" />
                <span>{t.nav.backToSite}</span>
              </button>
            )}
          </div>

          {/* Next tab button */}
          <div className="w-full sm:w-auto flex items-center justify-end">
            {nextTabId ? (
              <button
                type="button"
                onClick={() => {
                  setActiveTab(nextTabId);
                  window.scrollTo({ top: 0, behavior: 'smooth' });
                }}
                className="group flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#F4F7F5] dark:bg-[#143424] border border-gray-200/80 dark:border-[#2B5A46]/30 hover:border-[#FF8D20] text-xs sm:text-sm font-semibold text-[#13202B] dark:text-[#F4F7F5] shadow-xs hover:shadow-md transition-all cursor-pointer"
              >
                <div className="text-right">
                  <span className="block text-[10px] text-[#66737C] dark:text-[#AAB8B2] font-medium uppercase tracking-wider">
                    {t.nav.nextTab}
                  </span>
                  <span>{getTabLabel(nextTabId)}</span>
                </div>
                <ChevronRight className="w-4 h-4 text-[#FF8D20] group-hover:translate-x-0.5 transition-transform" />
              </button>
            ) : (
              <button
                type="button"
                onClick={() => {
                  setActiveTab('overview');
                  window.scrollTo({ top: 0, behavior: 'smooth' });
                }}
                className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#FF8D20] hover:bg-[#D96B00] text-white text-xs sm:text-sm font-semibold shadow-xs transition-all cursor-pointer"
              >
                <Home className="w-4 h-4" />
                <span>{t.nav.backToSite}</span>
              </button>
            )}
          </div>
        </div>
      </nav>
    </div>
  );
};
