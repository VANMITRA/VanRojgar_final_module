import React, { useState, useEffect } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { Language, TabId } from '../types';
import { Sun, Moon, Globe, Menu, X, ArrowUpRight, ShieldCheck } from 'lucide-react';

export const Header: React.FC = () => {
  const { isDark, toggleTheme, language, setLanguage, setIsDemoOpen, activeTab, setActiveTab } = useMarketplace();
  const t = translations[language];

  const [isScrolled, setIsScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const navTabs: { id: TabId; label: string; href: string }[] = [
    { id: 'overview', label: t.nav.overview, href: '#overview' },
    { id: 'ecosystem', label: t.nav.ecosystem, href: '#ecosystem' },
    { id: 'how_it_works', label: t.nav.howItWorks, href: '#how-it-works' },
    { id: 'portals', label: t.nav.portals, href: '#portals' },
    { id: 'marketplace', label: t.nav.marketplace, href: '#marketplace' },
    { id: 'barter', label: t.nav.barter, href: '#barter' },
    { id: 'delivery', label: t.nav.delivery, href: '#delivery' },
    { id: 'impact', label: t.nav.impact, href: '#impact' },
  ];

  const handleLaunchDemo = () => {
    window.location.hash = '#/demo';
    setIsDemoOpen(true);
    setMobileMenuOpen(false);
  };

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        isScrolled
          ? 'bg-[#1A4331]/95 dark:bg-[#0C1B14]/95 backdrop-blur-md shadow-md py-3 border-b border-[#2D765C]/30'
          : 'bg-[#1A4331] dark:bg-[#0C1B14] py-4 border-b border-[#2D765C]/20'
      }`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between">
          {/* Brand Logo & Wordmark */}
          <button
            onClick={() => setActiveTab('overview')}
            style={{ marginLeft: '-70px' }}
            className="flex items-center gap-3 group focus:outline-none focus:ring-2 focus:ring-[#FF8D20] rounded-lg p-1 text-left cursor-pointer"
          >
            <div className="relative w-10 h-10 rounded-full overflow-hidden border-2 border-[#FF8D20] shadow-sm bg-white shrink-0 group-hover:scale-105 transition-transform">
              <img
                src="/assets/aistudio/IMG-20261006-WA0009_1_.jpg_91f800c1.jpeg"
                alt="VanRozgar Tribal Mandala Logo"
                className="w-full h-full object-cover"
              />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-xl font-bold tracking-tight text-white font-['Manrope']">
                  {language === 'hi' ? 'वनरोज़गार' : language === 'mr' ? 'वनरोजगार' : 'VanRozgar'}
                </span>
                <span className="hidden sm:inline-block px-1.5 py-0.5 text-[10px] font-semibold bg-[#2D765C] text-emerald-100 rounded-md tracking-wider">
                  {language === 'hi' ? 'सीएफआर बाज़ार' : language === 'mr' ? 'सीएफआर बाजार' : 'CFR MARKETPLACE'}
                </span>
              </div>
              <p className="text-[11px] text-[#AAB8B2] flex items-center gap-1 font-medium">
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

          {/* Desktop Navigation Tabs */}
          <nav className="hidden lg:flex items-center gap-1 xl:gap-1.5" role="tablist" aria-label="Main Section Tabs">
            {navTabs.map((tab) => {
              const isActive = activeTab === tab.id;
              return (
                <button
                  key={tab.id}
                  role="tab"
                  aria-selected={isActive}
                  onClick={(e) => {
                    e.preventDefault();
                    setActiveTab(tab.id);
                  }}
                  className={`text-xs font-semibold px-2.5 py-1.5 rounded-lg transition-all flex items-center gap-1 cursor-pointer ${
                    isActive
                      ? 'bg-[#FF8D20] text-white shadow-sm font-bold scale-[1.02]'
                      : 'text-[#F4F7F5]/85 hover:text-white hover:bg-white/10'
                  }`}
                >
                  <span>{tab.label}</span>
                </button>
              );
            })}
          </nav>

          {/* Header Controls (Language Toggle, Theme, Launch CTA) */}
          <div className="hidden sm:flex items-center gap-3">
            {/* Quick Segmented Language Toggle (English <-> Hindi <-> Marathi) */}
            <div
              className="flex items-center bg-[#173425]/90 border border-[#2B5A46] rounded-xl p-0.5 shadow-xs"
              role="group"
              aria-label="Language selection toggle"
            >
              <button
                type="button"
                onClick={() => setLanguage('en')}
                aria-pressed={language === 'en'}
                className={`px-2.5 py-1 text-xs font-bold rounded-lg transition-all ${
                  language === 'en'
                    ? 'bg-[#FF8D20] text-white shadow-sm'
                    : 'text-[#F4F7F5]/80 hover:text-white hover:bg-white/10'
                }`}
                title="Switch to English"
              >
                EN
              </button>
              <button
                type="button"
                onClick={() => setLanguage('hi')}
                aria-pressed={language === 'hi'}
                className={`px-2.5 py-1 text-xs font-bold rounded-lg transition-all ${
                  language === 'hi'
                    ? 'bg-[#FF8D20] text-white shadow-sm'
                    : 'text-[#F4F7F5]/80 hover:text-white hover:bg-white/10'
                }`}
                title="हिन्दी में बदलें"
              >
                हिन्दी
              </button>
              <button
                type="button"
                onClick={() => setLanguage('mr')}
                aria-pressed={language === 'mr'}
                className={`px-2 py-1 text-[11px] font-semibold rounded-lg transition-all ${
                  language === 'mr'
                    ? 'bg-[#FF8D20] text-white shadow-sm'
                    : 'text-[#F4F7F5]/70 hover:text-white hover:bg-white/10'
                }`}
                title="मराठी मध्ये बदला"
              >
                मराठी
              </button>
            </div>

            {/* Theme Toggle */}
            <button
              onClick={toggleTheme}
              aria-label={isDark ? 'Switch to light mode' : 'Switch to dark mode'}
              className="p-2 rounded-lg bg-[#2D765C]/40 hover:bg-[#2D765C]/70 text-[#F4F7F5] border border-[#2B5A46] transition-colors"
            >
              {isDark ? <Sun className="w-4 h-4 text-[#FF8D20]" /> : <Moon className="w-4 h-4 text-[#F4F7F5]" />}
            </button>

            {/* Primary Action Button */}
            <button
              onClick={handleLaunchDemo}
              style={{ marginRight: '-70px' }}
              className="flex items-center gap-2 bg-[#FF8D20] hover:bg-[#D96B00] active:scale-95 text-white px-4 py-2 rounded-xl text-xs sm:text-sm font-bold shadow-lg shadow-orange-950/20 transition-all focus:outline-none focus:ring-2 focus:ring-[#FF8D20]"
            >
              <span>{t.nav.tryDemo}</span>
              <ArrowUpRight className="w-4 h-4" />
            </button>
          </div>

          {/* Mobile hamburger menu toggle */}
          <div className="flex items-center gap-2 lg:hidden">
            {/* Quick language toggle on mobile bar */}
            <button
              onClick={() => setLanguage(language === 'hi' ? 'en' : 'hi')}
              aria-label="Toggle language English Hindi"
              className="px-2 py-1 rounded-lg bg-[#2D765C]/40 text-[#F4F7F5] border border-[#2B5A46] text-xs font-bold flex items-center gap-1"
            >
              <Globe className="w-3 h-3 text-[#FF8D20]" />
              <span>{language === 'hi' ? 'EN' : 'हिन्दी'}</span>
            </button>
            <button
              onClick={toggleTheme}
              aria-label="Toggle theme"
              className="p-2 rounded-lg bg-[#2D765C]/40 text-[#F4F7F5]"
            >
              {isDark ? <Sun className="w-4 h-4 text-[#FF8D20]" /> : <Moon className="w-4 h-4" />}
            </button>
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              aria-label="Open mobile menu"
              className="p-2 rounded-lg bg-[#2D765C]/40 text-[#F4F7F5]"
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>

        {/* Mobile Navigation Drawer */}
        {mobileMenuOpen && (
          <div className="lg:hidden mt-3 pt-3 border-t border-[#2D765C]/40 pb-4 space-y-3">
            <nav className="flex flex-col space-y-1" role="tablist" aria-label="Mobile Navigation Tabs">
              {navTabs.map((tab) => {
                const isActive = activeTab === tab.id;
                return (
                  <button
                    key={tab.id}
                    role="tab"
                    aria-selected={isActive}
                    onClick={() => {
                      setActiveTab(tab.id);
                      setMobileMenuOpen(false);
                    }}
                    className={`w-full text-left px-3 py-2 rounded-lg text-sm font-semibold transition-colors flex items-center justify-between cursor-pointer ${
                      isActive
                        ? 'bg-[#FF8D20] text-white font-bold shadow-sm'
                        : 'text-white/90 hover:bg-white/10'
                    }`}
                  >
                    <span>{tab.label}</span>
                    {isActive && <span className="w-2 h-2 rounded-full bg-white animate-pulse" />}
                  </button>
                );
              })}
            </nav>

            {/* Language Selection Segmented Bar for Mobile */}
            <div className="pt-2 px-3">
              <span className="block text-xs text-[#AAB8B2] mb-1.5 font-medium">
                {language === 'hi' ? 'भाषा चुनें:' : language === 'mr' ? 'भाषा निवडा:' : 'Select Language:'}
              </span>
              <div className="grid grid-cols-3 gap-1 bg-[#173425] p-1 rounded-xl border border-[#2B5A46]">
                <button
                  type="button"
                  onClick={() => setLanguage('en')}
                  className={`py-1.5 text-xs rounded-lg font-bold transition-colors ${
                    language === 'en' ? 'bg-[#FF8D20] text-white shadow-sm' : 'text-white/80 hover:bg-white/10'
                  }`}
                >
                  English (EN)
                </button>
                <button
                  type="button"
                  onClick={() => setLanguage('hi')}
                  className={`py-1.5 text-xs rounded-lg font-bold transition-colors ${
                    language === 'hi' ? 'bg-[#FF8D20] text-white shadow-sm' : 'text-white/80 hover:bg-white/10'
                  }`}
                >
                  हिन्दी (HI)
                </button>
                <button
                  type="button"
                  onClick={() => setLanguage('mr')}
                  className={`py-1.5 text-xs rounded-lg font-bold transition-colors ${
                    language === 'mr' ? 'bg-[#FF8D20] text-white shadow-sm' : 'text-white/80 hover:bg-white/10'
                  }`}
                >
                  मराठी (MR)
                </button>
              </div>
            </div>

            <div className="pt-2 px-3">
              <button
                onClick={handleLaunchDemo}
                className="w-full flex items-center justify-center gap-2 bg-[#FF8D20] hover:bg-[#D96B00] text-white py-2.5 rounded-xl text-sm font-bold shadow-md"
              >
                <span>{t.nav.tryDemo}</span>
                <ArrowUpRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </header>
  );
};
