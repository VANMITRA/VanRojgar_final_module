import React from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { ArrowUpRight, ChevronDown, Sparkles, MapPin, Star, ShieldCheck, TreePine, Truck, Layers } from 'lucide-react';
import { ResourceIcon } from '../components/ResourceIcon';

export const HeroSection: React.FC = () => {
  const { language, setIsDemoOpen, setSelectedListing, listings, setActiveTab } = useMarketplace();
  const t = translations[language];

  const floatingListings = listings.slice(0, 3);

  const handleLaunchDemo = () => {
    window.location.hash = '#/demo';
    setIsDemoOpen(true);
  };

  return (
    <section className="relative min-h-[85vh] flex items-center pt-10 sm:pt-14 pb-16 overflow-hidden bg-gradient-to-b from-[#1A4331] via-[#10261B] to-[#0C1B14] text-white">
      {/* Topographic Lines Background Pattern */}
      <div className="absolute inset-0 opacity-15 pointer-events-none topo-pattern" />

      {/* Decorative Forest Silhouettes & Rolling Hill SVG Layers */}
      <div className="absolute bottom-0 left-0 right-0 h-64 sm:h-80 pointer-events-none opacity-40 overflow-hidden">
        {/* Layer 3 - Distant Mountains */}
        <svg
          viewBox="0 0 1440 320"
          className="absolute bottom-0 w-full h-full preserve-3d"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M0 240L80 220C160 200 320 160 480 168C640 176 800 232 960 228C1120 224 1280 160 1360 128L1440 96V320H1360C1280 320 1120 320 960 320C800 320 640 320 480 320C320 320 160 320 80 320H0V240Z"
            fill="#0A1810"
            fillOpacity="0.8"
          />
          {/* Layer 2 - Forest Canopy Hills */}
          <path
            d="M0 270L60 260C120 250 240 230 360 220C480 210 600 210 720 225C840 240 960 270 1080 265C1200 260 1320 220 1380 200L1440 180V320H1380C1320 320 1200 320 1080 320C960 320 840 320 720 320C600 320 480 320 360 320C240 320 120 320 60 320H0V270Z"
            fill="#143424"
            fillOpacity="0.9"
          />
          {/* Layer 1 - Foreground Village Foothill */}
          <path
            d="M0 295C180 275 360 285 540 295C720 305 900 280 1080 285C1260 290 1350 300 1440 310V320H0V295Z"
            fill="#1D4A37"
          />
        </svg>
      </div>

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 z-10 w-full py-8">
        <div
          style={{ paddingLeft: '0px', marginLeft: '-70px', marginBottom: '0px', marginRight: '-70px' }}
          className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center"
        >
          
          {/* Left Hero Column */}
          <div className="lg:col-span-7 space-y-6 text-left">
            {/* Tag / Badge */}
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#2D765C]/30 border border-[#2B5A46] text-[#AAB8B2] text-xs font-semibold backdrop-blur-md">
              <span className="w-2 h-2 rounded-full bg-[#FF8D20] animate-pulse" />
              <span>{t.hero.badge}</span>
              <span className="text-[#FF8D20]">{t.hero.cfrCommerce}</span>
            </div>

            {/* Headline */}
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight text-white font-['Manrope'] leading-[1.12]">
              <span>
                {t.hero.headlineBefore} <br />
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#FF8D20] via-amber-300 to-emerald-400">
                  {t.hero.headlineHighlight}
                </span>
                {t.hero.headlineAfter && ` ${t.hero.headlineAfter}`}
              </span>
            </h1>

            {/* Supporting Copy */}
            <p className="text-base sm:text-lg text-[#F4F7F5]/85 max-w-2xl font-normal leading-relaxed">
              <strong className="text-white">{t.ecosystemSynergy}</strong> {t.hero.description}
            </p>

            {/* Three Core Concept Chips */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-2.5 pt-2">
              <div className="flex items-center gap-2 p-2.5 rounded-xl bg-white/5 border border-white/10 backdrop-blur-sm">
                <div className="w-7 h-7 rounded-lg bg-emerald-500/20 text-[#5FAE3B] flex items-center justify-center shrink-0">
                  <TreePine className="w-4 h-4" />
                </div>
                <div className="text-xs font-bold text-white leading-tight">
                  {t.concepts.communityCommerce}
                </div>
              </div>

              <div className="flex items-center gap-2 p-2.5 rounded-xl bg-white/5 border border-white/10 backdrop-blur-sm">
                <div className="w-7 h-7 rounded-lg bg-amber-500/20 text-[#FF8D20] flex items-center justify-center shrink-0">
                  <ShieldCheck className="w-4 h-4" />
                </div>
                <div className="text-xs font-bold text-white leading-tight">
                  {t.concepts.sustainableLivelihoods}
                </div>
              </div>

              <div className="flex items-center gap-2 p-2.5 rounded-xl bg-white/5 border border-white/10 backdrop-blur-sm">
                <div className="w-7 h-7 rounded-lg bg-blue-500/20 text-blue-400 flex items-center justify-center shrink-0">
                  <Truck className="w-4 h-4" />
                </div>
                <div className="text-xs font-bold text-white leading-tight">
                  {t.concepts.employmentGeneration}
                </div>
              </div>
            </div>

            {/* CTAs */}
            <div className="flex flex-wrap items-center gap-4 pt-4">
              <button
                onClick={handleLaunchDemo}
                className="flex items-center gap-2.5 bg-[#FF8D20] hover:bg-[#D96B00] active:scale-95 text-white px-7 py-3.5 rounded-2xl text-sm sm:text-base font-bold shadow-xl shadow-orange-950/30 transition-all focus:outline-none focus:ring-2 focus:ring-[#FF8D20]"
              >
                <span>{t.hero.tryDemo}</span>
                <ArrowUpRight className="w-5 h-5" />
              </button>

              <button
                type="button"
                onClick={() => setActiveTab('how_it_works')}
                className="flex items-center gap-2 bg-[#2D765C]/40 hover:bg-[#2D765C]/70 text-[#F4F7F5] px-6 py-3.5 rounded-2xl text-sm font-semibold border border-[#2B5A46] transition-all cursor-pointer"
              >
                <span>{t.hero.howItWorks}</span>
                <ChevronDown className="w-4 h-4" />
              </button>
            </div>

            {/* Live Stats Preview Bar */}
            <div className="flex items-center gap-6 pt-3 text-xs text-[#AAB8B2]">
              <div>
                <span className="font-extrabold text-white text-base">12+</span> {t.hero.statsActiveGs}
              </div>
              <div className="w-1 h-1 rounded-full bg-[#AAB8B2]" />
              <div>
                <span className="font-extrabold text-[#5FAE3B] text-base">₹18.4L+</span> {t.hero.statsRuralEarnings}
              </div>
              <div className="w-1 h-1 rounded-full bg-[#AAB8B2]" />
              <div>
                <span className="font-extrabold text-[#FF8D20] text-base">1,420+</span> {t.hero.statsDeliveries}
              </div>
            </div>
          </div>

          {/* Right Column: Village-to-Buyer Network Visual & Floating Cards */}
          <div className="lg:col-span-5 relative">
            {/* Visual Network Canvas Container */}
            <div className="relative w-full aspect-square max-w-md mx-auto rounded-3xl bg-gradient-to-tr from-[#173425]/90 to-[#0C1B14]/80 p-6 border border-[#2B5A46] shadow-2xl overflow-hidden">
              
              {/* Animated Network Map Lines SVG */}
              <svg className="absolute inset-0 w-full h-full pointer-events-none opacity-40" viewBox="0 0 400 400">
                <defs>
                  <linearGradient id="lineGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#5FAE3B" stopOpacity="0.8" />
                    <stop offset="50%" stopColor="#FF8D20" stopOpacity="0.9" />
                    <stop offset="100%" stopColor="#2F5FB3" stopOpacity="0.8" />
                  </linearGradient>
                </defs>

                <path d="M 80,120 Q 200,60 320,130" stroke="url(#lineGrad)" strokeWidth="2" strokeDasharray="4 4" fill="none" />
                <path d="M 80,120 Q 150,260 220,320" stroke="url(#lineGrad)" strokeWidth="2" strokeDasharray="4 4" fill="none" />
                <path d="M 320,130 Q 260,240 220,320" stroke="url(#lineGrad)" strokeWidth="2" strokeDasharray="4 4" fill="none" />
                <path d="M 200,200 L 80,120" stroke="#FF8D20" strokeWidth="1.5" strokeOpacity="0.6" fill="none" />
                <path d="M 200,200 L 320,130" stroke="#FF8D20" strokeWidth="1.5" strokeOpacity="0.6" fill="none" />
                <path d="M 200,200 L 220,320" stroke="#FF8D20" strokeWidth="1.5" strokeOpacity="0.6" fill="none" />

                <circle cx="150" cy="85" r="4" fill="#FF8D20">
                  <animate attributeName="opacity" values="0.3;1;0.3" dur="2s" repeatCount="indefinite" />
                </circle>
                <circle cx="270" cy="220" r="4" fill="#5FAE3B">
                  <animate attributeName="opacity" values="0.3;1;0.3" dur="2.5s" repeatCount="indefinite" />
                </circle>
                <circle cx="140" cy="240" r="3" fill="#FF8D20">
                  <animate attributeName="opacity" values="0.2;1;0.2" dur="1.8s" repeatCount="indefinite" />
                </circle>
              </svg>

              {/* Village Nodes on Map */}
              <div className="absolute top-10 left-8 p-2 rounded-xl bg-[#1A4331] border border-[#5FAE3B]/50 shadow-md flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-[#5FAE3B] animate-ping" />
                <div className="text-[10px]">
                  <div className="font-bold text-white">
                    {language === 'hi' ? 'जव्हार सीएफआर वन' : language === 'mr' ? 'जव्हार सीएफआर वन' : 'Jawhar CFR Forest'}
                  </div>
                  <div className="text-[#AAB8B2]">
                    {language === 'hi' ? 'शहद व जड़ी-बूटी' : language === 'mr' ? 'मध व जडीबुटी' : 'Honey & Herbs'}
                  </div>
                </div>
              </div>

              <div className="absolute top-12 right-6 p-2 rounded-xl bg-[#1A4331] border border-[#5FAE3B]/50 shadow-md flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-[#5FAE3B]" />
                <div className="text-[10px]">
                  <div className="font-bold text-white">
                    {language === 'hi' ? 'मोखाडा सीएफआर' : language === 'mr' ? 'मोखाडा सीएफआर' : 'Mokhada CFR'}
                  </div>
                  <div className="text-[#AAB8B2]">
                    {language === 'hi' ? 'अश्वगंधा व तेल' : language === 'mr' ? 'अश्वगंधा व तेल' : 'Ashwagandha & Oil'}
                  </div>
                </div>
              </div>

              <div className="absolute bottom-10 right-14 p-2 rounded-xl bg-[#10261B] border border-[#FF8D20]/60 shadow-md flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-[#FF8D20]" />
                <div className="text-[10px]">
                  <div className="font-bold text-white">
                    {language === 'hi' ? 'संस्थागत खरीदार हब' : language === 'mr' ? 'संस्थात्मक खरेदी केंद्र' : 'Ethical Buyers Hub'}
                  </div>
                  <div className="text-[#AAB8B2]">
                    {language === 'hi' ? 'थोक प्रसंस्करण' : language === 'mr' ? 'घाऊक प्रक्रिया' : 'Bulk Processing'}
                  </div>
                </div>
              </div>

              {/* Delivery Driver in Motion node in center */}
              <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 p-2.5 rounded-2xl bg-[#0C1B14] border-2 border-[#FF8D20] shadow-xl flex items-center gap-2">
                <div className="w-6 h-6 rounded-lg bg-[#FF8D20] text-white flex items-center justify-center">
                  <Truck className="w-3.5 h-3.5" />
                </div>
                <div className="text-[10px] text-left">
                  <div className="font-bold text-[#FF8D20]">{t.hero.driverEnRoute}</div>
                  <div className="text-[#AAB8B2]">{t.hero.routeMeta}</div>
                </div>
              </div>

              {/* Stacked Interactive Floating Listing Cards */}
              <div className="absolute -bottom-4 left-4 right-4 space-y-2 pointer-events-auto">
                {floatingListings.map((item) => (
                  <button
                    key={item.id}
                    onClick={() => setSelectedListing(item)}
                    className="w-full text-left p-3 rounded-2xl bg-white/95 dark:bg-[#173425]/95 border border-white/20 dark:border-[#2B5A46] shadow-xl hover:translate-y-[-2px] transition-all flex items-center justify-between backdrop-blur-md cursor-pointer"
                  >
                    <div className="flex items-center gap-2.5">
                      <div className="w-8 h-8 rounded-xl bg-[#1A4331]/10 dark:bg-black/20 p-1 flex items-center justify-center shrink-0">
                        <ResourceIcon type={item.iconType} className="w-5 h-5" />
                      </div>
                      <div className="text-left">
                        <div className="text-xs font-bold text-[#13202B] dark:text-white line-clamp-1">
                          {item.title}
                        </div>
                        <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2] flex items-center gap-1">
                          <span>{item.gramSabhaName}</span>
                          <span>•</span>
                          <span className="text-[#5FAE3B] font-semibold">{item.distanceKm} km {t.common.distance}</span>
                        </div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-xs font-extrabold text-[#1A4331] dark:text-[#5FAE3B]">
                        ₹{item.pricePerUnit}
                        <span className="text-[9px] font-normal text-[#66737C] dark:text-[#AAB8B2]">/{item.unit}</span>
                      </div>
                      <span className="text-[9px] px-1.5 py-0.5 rounded bg-[#FF8D20]/10 text-[#FF8D20] font-bold">
                        {item.mode === 'both' ? t.modes.both : item.mode === 'barter' ? t.modes.barter : t.modes.sell}
                      </span>
                    </div>
                  </button>
                ))}
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
};
