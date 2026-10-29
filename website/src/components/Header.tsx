import React, { useState, useEffect, useRef } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { Language, TabId } from '../types';
import {
  Sun,
  Moon,
  Globe,
  Menu,
  X,
  ShieldCheck,
  ChevronDown,
  Check,
  LayoutGrid,
  LayoutDashboard,
  TreePine,
  Sparkles,
  Users,
  ShoppingBag,
  Scale,
  Truck,
  BarChart3,
} from 'lucide-react';

interface SectionItem {
  id: TabId;
  label: (t: typeof translations['en']) => string;
  badge: {
    en: string;
    hi: string;
    mr: string;
  };
  icon: React.ComponentType<{ className?: string }>;
}

const ALL_SECTIONS: SectionItem[] = [
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

const LANGUAGES: { id: Language; label: string; nativeName: string; short: string }[] = [
  { id: 'en', label: 'English', nativeName: 'English', short: 'EN' },
  { id: 'hi', label: 'Hindi', nativeName: 'हिन्दी', short: 'हिन्दी' },
  { id: 'mr', label: 'Marathi', nativeName: 'मराठी', short: 'मराठी' },
];

export const Header: React.FC = () => {
  const { isDark, toggleTheme, language, setLanguage, activeTab, setActiveTab } = useMarketplace();
  const t = translations[language];

  const [isScrolled, setIsScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [sectionsDropdownOpen, setSectionsDropdownOpen] = useState(false);
  const [mobileSectionsDropdownOpen, setMobileSectionsDropdownOpen] = useState(false);
  const [langOpen, setLangOpen] = useState(false);

  const sectionsRef = useRef<HTMLDivElement>(null);
  const sectionsBtnRef = useRef<HTMLButtonElement>(null);
  const sectionsItemsRef = useRef<(HTMLButtonElement | null)[]>([]);

  const mobileSectionsRef = useRef<HTMLDivElement>(null);

  const langRef = useRef<HTMLDivElement>(null);
  const langBtnRef = useRef<HTMLButtonElement>(null);
  const langItemsRef = useRef<(HTMLButtonElement | null)[]>([]);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 15);
    };
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Close dropdowns on outside click
  useEffect(() => {
    const handleOutsideClick = (e: MouseEvent) => {
      const target = e.target as Node;
      if (sectionsRef.current && !sectionsRef.current.contains(target)) {
        setSectionsDropdownOpen(false);
      }
      if (mobileSectionsRef.current && !mobileSectionsRef.current.contains(target)) {
        setMobileSectionsDropdownOpen(false);
      }
      if (langRef.current && !langRef.current.contains(target)) {
        setLangOpen(false);
      }
    };
    document.addEventListener('mousedown', handleOutsideClick);
    return () => document.removeEventListener('mousedown', handleOutsideClick);
  }, []);

  // Close menus on Escape key
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        if (sectionsDropdownOpen) {
          setSectionsDropdownOpen(false);
          sectionsBtnRef.current?.focus();
        }
        if (mobileSectionsDropdownOpen) {
          setMobileSectionsDropdownOpen(false);
        }
        if (langOpen) {
          setLangOpen(false);
          langBtnRef.current?.focus();
        }
        if (mobileMenuOpen) {
          setMobileMenuOpen(false);
        }
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [sectionsDropdownOpen, mobileSectionsDropdownOpen, langOpen, mobileMenuOpen]);

  const currentLangObj = LANGUAGES.find((l) => l.id === language) ?? LANGUAGES[0];
  const activeSectionObj = ALL_SECTIONS.find((s) => s.id === activeTab) ?? ALL_SECTIONS[0];

  const handleSelectSection = (tabId: TabId) => {
    setActiveTab(tabId);
    setSectionsDropdownOpen(false);
    setMobileSectionsDropdownOpen(false);
    setMobileMenuOpen(false);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Keyboard navigation for Sections dropdown
  const handleSectionsTriggerKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown' || e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      setSectionsDropdownOpen(true);
      const currIdx = ALL_SECTIONS.findIndex((s) => s.id === activeTab);
      setTimeout(() => sectionsItemsRef.current[currIdx >= 0 ? currIdx : 0]?.focus(), 15);
    }
  };

  const handleSectionsItemKeyDown = (e: React.KeyboardEvent, index: number) => {
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      const nextIdx = (index + 1) % ALL_SECTIONS.length;
      sectionsItemsRef.current[nextIdx]?.focus();
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      const prevIdx = (index - 1 + ALL_SECTIONS.length) % ALL_SECTIONS.length;
      sectionsItemsRef.current[prevIdx]?.focus();
    } else if (e.key === 'Home') {
      e.preventDefault();
      sectionsItemsRef.current[0]?.focus();
    } else if (e.key === 'End') {
      e.preventDefault();
      sectionsItemsRef.current[ALL_SECTIONS.length - 1]?.focus();
    } else if (e.key === 'Tab') {
      setSectionsDropdownOpen(false);
    }
  };

  // Keyboard navigation for Language dropdown
  const handleLangTriggerKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown' || e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      setLangOpen(true);
      const currIdx = LANGUAGES.findIndex((l) => l.id === language);
      setTimeout(() => langItemsRef.current[currIdx >= 0 ? currIdx : 0]?.focus(), 15);
    }
  };

  const handleLangItemKeyDown = (e: React.KeyboardEvent, index: number) => {
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      const nextIdx = (index + 1) % LANGUAGES.length;
      langItemsRef.current[nextIdx]?.focus();
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      const prevIdx = (index - 1 + LANGUAGES.length) % LANGUAGES.length;
      langItemsRef.current[prevIdx]?.focus();
    } else if (e.key === 'Home') {
      e.preventDefault();
      langItemsRef.current[0]?.focus();
    } else if (e.key === 'End') {
      e.preventDefault();
      langItemsRef.current[LANGUAGES.length - 1]?.focus();
    } else if (e.key === 'Tab') {
      setLangOpen(false);
    }
  };

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-200 ${
        isScrolled
          ? 'bg-[#1A4331]/98 dark:bg-[#0C1B14]/98 backdrop-blur-md shadow-md border-b border-[#2D765C]/40'
          : 'bg-[#1A4331] dark:bg-[#0C1B14] border-b border-[#2D765C]/30'
      }`}
      style={{ height: 'var(--header-h)' }}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-full flex items-center justify-between">
        
        {/* Brand Logo & Wordmark - Branded Forest Green header per theme doc */}
        <button
          onClick={() => handleSelectSection('overview')}
          className="flex items-center gap-2.5 sm:gap-3 group focus:outline-none focus:ring-2 focus:ring-[#FF8D20] rounded-xl p-1 text-left cursor-pointer transition-colors"
          aria-label="VanMitra Home"
        >
          <img
            src="/logo-192.png"
            alt="VanMitra Tribal Mandala Logo"
            width={40}
            height={40}
            className="w-8 h-8 sm:w-10 sm:h-10 rounded-full object-cover shrink-0 group-hover:scale-105 transition-transform"
          />
          <div>
            <div className="flex items-center gap-1.5 sm:gap-2">
              <span className="text-lg sm:text-xl font-bold tracking-tight text-white font-['Manrope']">
                {language === 'hi' ? 'वनमित्र' : language === 'mr' ? 'वनमित्र' : 'VanMitra'}
              </span>
              <span className="hidden sm:inline-block px-1.5 py-0.5 text-[9px] sm:text-[10px] font-bold bg-[#2D765C] text-emerald-100 rounded-md tracking-wider border border-emerald-400/20">
                {language === 'hi' ? 'सीएफआर बाज़ार' : language === 'mr' ? 'सीएफआर बाजार' : 'CFR MARKETPLACE'}
              </span>
            </div>
            <p className="text-[10px] sm:text-[11px] text-[#AAB8B2] hidden sm:flex items-center gap-1 font-medium">
              <span>
                {language === 'hi'
                  ? 'वनमित्र-AI का भाग'
                  : language === 'mr'
                  ? 'वनमित्र-AI चा भाग'
                  : 'A module of VanMitra-AI'}
              </span>
              <ShieldCheck className="w-3 h-3 text-[#5FAE3B]" />
            </p>
          </div>
        </button>

        {/* Top Right Controls: Language Selector, SECTIONS DROPDOWN (next to Theme Toggle), Theme Toggle */}
        <div className="flex items-center gap-1.5 sm:gap-2 xl:gap-2.5">
          
          {/* 1. Language Dropdown */}
          <div className="relative" ref={langRef}>
            <button
              ref={langBtnRef}
              id="lang-trigger"
              type="button"
              aria-haspopup="listbox"
              aria-expanded={langOpen}
              aria-label={`Select language. Current: ${currentLangObj.label}`}
              onClick={() => {
                setLangOpen((prev) => !prev);
                setSectionsDropdownOpen(false);
              }}
              onKeyDown={handleLangTriggerKeyDown}
              className="flex items-center gap-1.5 px-2.5 py-1.5 text-xs font-bold rounded-xl border transition-all cursor-pointer bg-white/10 hover:bg-white/15 text-white border-white/20 focus:outline-none focus:ring-2 focus:ring-[#FF8D20]"
            >
              <Globe className="w-3.5 h-3.5 text-[#FF8D20] shrink-0" />
              <span className="whitespace-nowrap">{currentLangObj.short}</span>
              <ChevronDown className={`w-3.5 h-3.5 transition-transform duration-200 ${langOpen ? 'rotate-180' : ''}`} />
            </button>

            {/* Language Options Listbox */}
            {langOpen && (
              <div
                role="listbox"
                aria-labelledby="lang-trigger"
                className="absolute right-0 mt-2 w-44 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-2xl p-1.5 z-50 transition-all"
              >
                {LANGUAGES.map((opt, idx) => {
                  const isSelected = language === opt.id;
                  return (
                    <button
                      key={opt.id}
                      ref={(el) => {
                        langItemsRef.current[idx] = el;
                      }}
                      role="option"
                      aria-selected={isSelected}
                      onClick={() => {
                        setLanguage(opt.id);
                        setLangOpen(false);
                      }}
                      onKeyDown={(e) => handleLangItemKeyDown(e, idx)}
                      className={`w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs sm:text-sm font-medium transition-colors text-left cursor-pointer focus:outline-none focus:ring-2 focus:ring-[#FF8D20] ${
                        isSelected
                          ? 'bg-[#FF8D20]/15 text-[#D96B00] dark:text-[#FF8D20] font-bold'
                          : 'text-[#13202B] dark:text-white hover:bg-black/5 dark:hover:bg-white/5'
                      }`}
                    >
                      <span className="whitespace-nowrap">{opt.nativeName}</span>
                      {isSelected ? (
                        <Check className="w-4 h-4 text-[#FF8D20]" />
                      ) : (
                        <span className="text-[10px] text-[#66737C] dark:text-[#889B93] uppercase font-bold">{opt.short}</span>
                      )}
                    </button>
                  );
                })}
              </div>
            )}
          </div>

          {/* 2. SECTIONS DROPDOWN BUTTON - PLACED DIRECTLY NEXT TO THE THEME TOGGLE BUTTON */}
          <div className="relative" ref={sectionsRef}>
            <button
              ref={sectionsBtnRef}
              id="sections-dropdown-trigger"
              type="button"
              aria-haspopup="menu"
              aria-expanded={sectionsDropdownOpen}
              aria-label={`Jump to Section. Current section: ${activeSectionObj.label(t)}`}
              onClick={() => {
                setSectionsDropdownOpen((prev) => !prev);
                setLangOpen(false);
              }}
              onKeyDown={handleSectionsTriggerKeyDown}
              className={`flex items-center gap-2 px-3 py-1.5 text-xs font-bold rounded-xl border transition-all cursor-pointer focus:outline-none focus:ring-2 focus:ring-[#FF8D20] ${
                sectionsDropdownOpen
                  ? 'bg-white text-[#1A4331] border-white shadow-md'
                  : 'bg-white/15 hover:bg-white/25 text-white border-white/25'
              }`}
            >
              <LayoutGrid className="w-4 h-4 text-[#FF8D20] shrink-0" />
              <span className="whitespace-nowrap font-bold hidden sm:inline">{activeSectionObj.label(t)}</span>
              <span className="hidden sm:inline-block px-1.5 py-0.5 text-[9px] font-bold bg-[#FF8D20] text-white rounded-md uppercase tracking-wider">
                {activeSectionObj.badge[language]}
              </span>
              <ChevronDown className={`w-3.5 h-3.5 transition-transform duration-200 ${sectionsDropdownOpen ? 'rotate-180' : ''}`} />
            </button>

            {/* Sections Dropdown Menu with all 8 buttons */}
            {sectionsDropdownOpen && (
              <div
                role="menu"
                aria-labelledby="sections-dropdown-trigger"
                className="absolute right-0 mt-2 w-72 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-2xl p-2 z-50 transition-all max-h-[80vh] overflow-y-auto"
              >
                <div className="px-3 py-2 border-b border-gray-100 dark:border-[#2B5A46]/60 mb-1 flex items-center justify-between">
                  <span className="text-[11px] font-bold uppercase tracking-wider text-[#1A4331] dark:text-[#5FAE3B] flex items-center gap-1.5">
                    <LayoutGrid className="w-3.5 h-3.5 text-[#FF8D20]" />
                    <span>{language === 'hi' ? 'सभी अनुभाग (८)' : language === 'mr' ? 'सर्व विभाग (८)' : 'All Sections (8)'}</span>
                  </span>
                  <span className="text-[10px] font-medium text-[#66737C] dark:text-[#AAB8B2]">
                    {language === 'hi' ? 'सीधा जाएँ' : language === 'mr' ? 'थेट जा' : 'Jump to'}
                  </span>
                </div>

                <div className="space-y-1">
                  {ALL_SECTIONS.map((sec, idx) => {
                    const Icon = sec.icon;
                    const isActive = activeTab === sec.id;
                    const label = sec.label(t);
                    const badgeText = sec.badge[language];

                    return (
                      <button
                        key={sec.id}
                        ref={(el) => {
                          sectionsItemsRef.current[idx] = el;
                        }}
                        role="menuitem"
                        aria-current={isActive ? 'page' : undefined}
                        onClick={() => handleSelectSection(sec.id)}
                        onKeyDown={(e) => handleSectionsItemKeyDown(e, idx)}
                        className={`w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all text-left cursor-pointer focus:outline-none focus:ring-2 focus:ring-[#FF8D20] ${
                          isActive
                            ? 'bg-[#FF8D20]/15 text-[#D96B00] dark:text-[#FF8D20] font-bold border border-[#FF8D20]/30 shadow-xs'
                            : 'text-[#13202B] dark:text-white hover:bg-black/5 dark:hover:bg-white/5 border border-transparent'
                        }`}
                      >
                        <div className="flex items-center gap-2.5 min-w-0">
                          <div className={`p-1.5 rounded-lg shrink-0 ${isActive ? 'bg-[#FF8D20] text-white' : 'bg-black/5 dark:bg-white/10 text-[#2D765C] dark:text-[#5FAE3B]'}`}>
                            <Icon className="w-4 h-4" />
                          </div>
                          <span className="truncate">{label}</span>
                        </div>

                        <div className="flex items-center gap-2 shrink-0 ml-2">
                          <span className={`text-[10px] px-1.5 py-0.5 rounded-md font-semibold ${
                            isActive
                              ? 'bg-[#FF8D20] text-white'
                              : 'bg-black/5 dark:bg-white/10 text-[#66737C] dark:text-[#889B93]'
                          }`}>
                            {badgeText}
                          </span>
                          {isActive && (
                            <Check className="w-4 h-4 text-[#FF8D20]" />
                          )}
                        </div>
                      </button>
                    );
                  })}
                </div>
              </div>
            )}
          </div>

          {/* 3. Theme Toggle Button */}
          <button
            type="button"
            onClick={toggleTheme}
            aria-label={isDark ? t.nav.switchToLightMode : t.nav.switchToDarkMode}
            title={isDark ? t.nav.switchToLightMode : t.nav.switchToDarkMode}
            className="p-2 rounded-xl border transition-colors cursor-pointer bg-white/10 hover:bg-white/15 text-white border-white/20 focus:outline-none focus:ring-2 focus:ring-[#FF8D20]"
          >
            {isDark ? <Sun className="w-4 h-4 text-[#FF8D20]" /> : <Moon className="w-4 h-4 text-amber-300" />}
          </button>
        </div>
      </div>
    </header>
  );
};
