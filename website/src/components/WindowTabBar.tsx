import React, { useRef, useEffect } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { TabId } from '../types';
import {
  LayoutDashboard,
  TreePine,
  Sparkles,
  Users,
  ShoppingBag,
  Scale,
  Truck,
  BarChart3,
  ChevronRight,
  ChevronLeft,
} from 'lucide-react';

interface TabItemConfig {
  id: TabId;
  label: (t: typeof translations['en']) => string;
  badge: {
    en: string;
    hi: string;
    mr: string;
  };
  icon: React.ComponentType<{ className?: string }>;
}

const TAB_CONFIGS: TabItemConfig[] = [
  {
    id: 'overview',
    label: (t) => t.nav.overview,
    badge: { en: 'Portal', hi: 'मुख्य', mr: 'मुख्य' },
    icon: LayoutDashboard,
  },
  {
    id: 'ecosystem',
    label: (t) => t.nav.ecosystem,
    badge: { en: '5 Modules', hi: '५ घटक', mr: '५ विभाग' },
    icon: TreePine,
  },
  {
    id: 'how_it_works',
    label: (t) => t.nav.howItWorks,
    badge: { en: '6 Stages', hi: '६ चरण', mr: '६ टप्पे' },
    icon: Sparkles,
  },
  {
    id: 'portals',
    label: (t) => t.nav.portals,
    badge: { en: '3 Roles', hi: '३ भूमिका', mr: '३ भूमिका' },
    icon: Users,
  },
  {
    id: 'marketplace',
    label: (t) => t.nav.marketplace,
    badge: { en: 'Catalog', hi: 'बाज़ार', mr: 'बाजार' },
    icon: ShoppingBag,
  },
  {
    id: 'barter',
    label: (t) => t.nav.barter,
    badge: { en: 'Fair Meter', hi: 'उचित मीटर', mr: 'दर मीटर' },
    icon: Scale,
  },
  {
    id: 'delivery',
    label: (t) => t.nav.delivery,
    badge: { en: 'Transport', hi: 'वाहन रोज़गार', mr: 'वाहतूक रोजगार' },
    icon: Truck,
  },
  {
    id: 'impact',
    label: (t) => t.nav.impact,
    badge: { en: 'Metrics', hi: 'आंकड़े', mr: 'माहिती' },
    icon: BarChart3,
  },
];

export const WindowTabBar: React.FC = () => {
  const { language, activeTab, setActiveTab } = useMarketplace();
  const t = translations[language];
  const scrollRef = useRef<HTMLDivElement>(null);

  // Auto-scroll the active tab into view when activeTab changes
  useEffect(() => {
    if (scrollRef.current) {
      const activeEl = scrollRef.current.querySelector<HTMLButtonElement>(`[data-tab-id="${activeTab}"]`);
      if (activeEl) {
        activeEl.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
      }
    }
  }, [activeTab]);

  const scrollTabs = (direction: 'left' | 'right') => {
    if (scrollRef.current) {
      const offset = direction === 'left' ? -220 : 220;
      scrollRef.current.scrollBy({ left: offset, behavior: 'smooth' });
    }
  };

  return (
    <div className="sticky top-[68px] sm:top-[72px] z-40 bg-white/95 dark:bg-[#0C1B14]/95 backdrop-blur-md border-b border-[#2D765C]/30 shadow-xs transition-colors">
      <div className="max-w-7xl mx-auto px-2 sm:px-4 lg:px-8">
        <div className="relative flex items-center">
          {/* Left Arrow on desktop/tablet if needed */}
          <button
            type="button"
            onClick={() => scrollTabs('left')}
            aria-label="Scroll tabs left"
            className="hidden sm:flex p-1.5 rounded-lg text-[#66737C] dark:text-[#AAB8B2] hover:text-[#13202B] dark:hover:text-white hover:bg-black/5 dark:hover:bg-white/5 transition-colors shrink-0"
          >
            <ChevronLeft className="w-4 h-4" />
          </button>

          {/* Horizontally scrollable tab strip */}
          <div
            ref={scrollRef}
            role="tablist"
            aria-label="Sections Window Tabs"
            className="flex-grow flex items-center gap-1.5 sm:gap-2 py-2.5 overflow-x-auto no-scrollbar scroll-smooth"
          >
            {TAB_CONFIGS.map((tab) => {
              const Icon = tab.icon;
              const isActive = activeTab === tab.id;
              const label = tab.label(t);
              const badgeText = tab.badge[language];

              return (
                <button
                  key={tab.id}
                  data-tab-id={tab.id}
                  role="tab"
                  aria-selected={isActive}
                  id={`tab-btn-${tab.id}`}
                  aria-controls={`tab-panel-${tab.id}`}
                  onClick={() => setActiveTab(tab.id)}
                  className={`group shrink-0 inline-flex items-center gap-2 px-3 py-2 sm:px-3.5 sm:py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all cursor-pointer select-none ${
                    isActive
                      ? 'bg-[#FF8D20] text-white shadow-md shadow-orange-950/20 font-bold scale-[1.02]'
                      : 'bg-black/5 dark:bg-white/5 text-[#46535E] dark:text-[#AAB8B2] hover:text-[#13202B] dark:hover:text-white hover:bg-black/10 dark:hover:bg-white/10'
                  }`}
                >
                  <Icon
                    className={`w-4 h-4 shrink-0 transition-transform ${
                      isActive ? 'text-white scale-110' : 'text-[#2D765C] dark:text-[#5FAE3B] group-hover:scale-110'
                    }`}
                  />
                  <span>{label}</span>
                  <span
                    className={`text-[10px] px-1.5 py-0.5 rounded-md font-medium tracking-wide ${
                      isActive
                        ? 'bg-white/25 text-white'
                        : 'bg-black/5 dark:bg-white/10 text-[#66737C] dark:text-[#889B93]'
                    }`}
                  >
                    {badgeText}
                  </span>
                </button>
              );
            })}
          </div>

          {/* Right Arrow on desktop/tablet */}
          <button
            type="button"
            onClick={() => scrollTabs('right')}
            aria-label="Scroll tabs right"
            className="hidden sm:flex p-1.5 rounded-lg text-[#66737C] dark:text-[#AAB8B2] hover:text-[#13202B] dark:hover:text-white hover:bg-black/5 dark:hover:bg-white/5 transition-colors shrink-0"
          >
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
};
