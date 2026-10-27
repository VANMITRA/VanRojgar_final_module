import React, { useState, useMemo } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { ResourceIcon } from '../components/ResourceIcon';
import { Listing } from '../types';
import {
  Sparkles,
  MapPin,
  Star,
  ShieldCheck,
  ArrowRight,
  FilterX,
  LayoutGrid,
  Sprout,
  TreePine,
  ShoppingBag,
  Droplets,
  Boxes,
} from 'lucide-react';

interface CategoryFilterItem {
  key: string;
  icon: React.ComponentType<{ className?: string }>;
  getLabel: (lang: string) => string;
}

const CATEGORIES: CategoryFilterItem[] = [
  {
    key: 'all',
    icon: LayoutGrid,
    getLabel: (lang) => {
      if (lang === 'hi') return 'सभी उत्पाद';
      if (lang === 'mr') return 'सर्व उत्पादने';
      return 'All Products';
    },
  },
  {
    key: 'medicinal',
    icon: Sprout,
    getLabel: (lang) => {
      if (lang === 'hi') return 'जड़ी-बूटी';
      if (lang === 'mr') return 'औषधी वनस्पती';
      return 'Medicinal Plants';
    },
  },
  {
    key: 'forest_produce',
    icon: TreePine,
    getLabel: (lang) => {
      if (lang === 'hi') return 'वनोपज';
      if (lang === 'mr') return 'वनोपज';
      return 'Forest Produce';
    },
  },
  {
    key: 'handicrafts',
    icon: ShoppingBag,
    getLabel: (lang) => {
      if (lang === 'hi') return 'हस्तशिल्प';
      if (lang === 'mr') return 'हस्तकला';
      return 'Handicrafts';
    },
  },
  {
    key: 'water_land',
    icon: Droplets,
    getLabel: (lang) => {
      if (lang === 'hi') return 'जल व भूमि';
      if (lang === 'mr') return 'जल व जमीन';
      return 'Water & Land';
    },
  },
  {
    key: 'others',
    icon: Boxes,
    getLabel: (lang) => {
      if (lang === 'hi') return 'अन्य संसाधन';
      if (lang === 'mr') return 'इतर संसाधने';
      return 'Other Resources';
    },
  },
];

export const FeaturedProductsSection: React.FC = () => {
  const { listings, setSelectedListing, setActiveTab, language } = useMarketplace();
  const t = translations[language];

  const [selectedCategory, setSelectedCategory] = useState<string>('all');

  // Compute live counts per category from current active listings
  const counts = useMemo(() => {
    const countsMap: Record<string, number> = {
      all: 0,
      medicinal: 0,
      forest_produce: 0,
      handicrafts: 0,
      water_land: 0,
      others: 0,
    };
    listings.forEach((item) => {
      if (item.status === 'active') {
        countsMap.all++;
        if (countsMap[item.category] !== undefined) {
          countsMap[item.category]++;
        }
      }
    });
    return countsMap;
  }, [listings]);

  // Filter listings based on selected category and active status
  const filteredListings = useMemo(() => {
    return listings.filter((item) => {
      if (item.status !== 'active') return false;
      if (selectedCategory === 'all') return true;
      return item.category === selectedCategory;
    });
  }, [listings, selectedCategory]);

  const handleCardClick = (listing: Listing) => {
    setSelectedListing(listing);
  };

  const handleCardKeyDown = (e: React.KeyboardEvent, listing: Listing) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      setSelectedListing(listing);
    }
  };

  return (
    <section
      id="featured-products"
      aria-labelledby="featured-products-heading"
      className="py-14 sm:py-18 bg-[#F4F7F5] dark:bg-[#0C1B14] text-[#13202B] dark:text-[#F4F7F5] transition-colors border-t border-[#2D765C]/20"
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Heading Area */}
        <div className="text-center max-w-3xl mx-auto mb-8 sm:mb-10 space-y-3">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1A4331]/10 dark:bg-[#2D765C]/30 text-[#1A4331] dark:text-[#5FAE3B] text-xs font-bold">
            <Sparkles className="w-3.5 h-3.5 text-[#FF8D20]" />
            <span>{t.featuredProducts.badge}</span>
          </div>
          
          <h2
            id="featured-products-heading"
            className="text-3xl sm:text-4xl font-extrabold text-[#1A4331] dark:text-white font-['Manrope'] tracking-tight"
          >
            {t.featuredProducts.title}
          </h2>

          <p className="text-xs sm:text-sm text-[#66737C] dark:text-[#AAB8B2] leading-relaxed max-w-2xl mx-auto">
            {t.featuredProducts.desc}
          </p>
        </div>

        {/* Circular Category Filters Row */}
        <div
          role="toolbar"
          aria-label="Category filters"
          className="mb-10 sm:mb-12 overflow-x-auto no-scrollbar py-2 px-1"
        >
          <div className="flex items-start justify-start sm:justify-center gap-4 sm:gap-6 min-w-max mx-0 px-0">
            {CATEGORIES.map((cat) => {
              const isSelected = selectedCategory === cat.key;
              const count = counts[cat.key] ?? 0;
              const label = cat.getLabel(language);
              const IconComponent = cat.icon;

              return (
                <button
                  key={cat.key}
                  type="button"
                  role="button"
                  aria-pressed={isSelected}
                  onClick={() => setSelectedCategory(cat.key)}
                  className="group flex flex-col items-center gap-2.5 cursor-pointer focus:outline-none transition-transform hover:-translate-y-0.5"
                >
                  {/* Round Circle Icon Container */}
                  <div
                    className={`relative w-18 h-18 sm:w-20 sm:h-20 rounded-full flex items-center justify-center transition-all duration-200 ${
                      isSelected
                        ? 'bg-[#1A4331] text-white dark:bg-[#FF8D20] dark:text-white shadow-lg shadow-[#1A4331]/30 dark:shadow-[#FF8D20]/30 ring-4 ring-[#1A4331]/20 dark:ring-[#FF8D20]/30 scale-105'
                        : 'bg-[#2D765C]/10 dark:bg-[#173425] text-[#2D765C] dark:text-[#AAB8B2] border border-[#2D765C]/25 dark:border-[#2B5A46] group-hover:bg-[#2D765C]/15 dark:group-hover:bg-[#1f4532] group-hover:text-[#1A4331] dark:group-hover:text-white group-hover:border-[#2D765C]/50'
                    }`}
                  >
                    <IconComponent className="w-8 h-8 sm:w-9 sm:h-9 transition-transform group-hover:scale-110" />

                    {/* Small count pill badge on circle */}
                    <span
                      className={`absolute -top-1 -right-1 text-[10px] font-bold px-1.5 py-0.2 rounded-full border ${
                        isSelected
                          ? 'bg-[#FF8D20] text-white border-white dark:bg-white dark:text-[#10261B] dark:border-[#FF8D20]'
                          : 'bg-white dark:bg-[#0C1B14] text-[#13202B] dark:text-[#F4F7F5] border-gray-200 dark:border-[#2B5A46]'
                      }`}
                    >
                      {count}
                    </span>
                  </div>

                  {/* Label Underneath */}
                  <div className="flex flex-col items-center text-center max-w-[92px] sm:max-w-[104px]">
                    <span
                      className={`text-xs sm:text-xs font-bold leading-snug line-clamp-2 transition-colors ${
                        isSelected
                          ? 'text-[#1A4331] dark:text-[#FF8D20]'
                          : 'text-[#46535E] dark:text-[#AAB8B2] group-hover:text-[#13202B] dark:group-hover:text-white'
                      }`}
                    >
                      {label}
                    </span>
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Accessible live status announcement */}
        <div aria-live="polite" className="sr-only">
          {t.featuredProducts.showingCount
            .replace('{count}', String(filteredListings.length))
            .replace('{total}', String(listings.length))}
        </div>

        {/* Product Cards: 4-column × 3-row desktop grid showing all listings */}
        {filteredListings.length > 0 ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 -mx-[170px]">
            {filteredListings.map((listing) => {
              const accessibleName = `${listing.title}, ₹${listing.pricePerUnit} per ${listing.unit}, ${listing.gramSabhaName}`;

              return (
                <div
                  key={listing.id}
                  role="button"
                  tabIndex={0}
                  aria-label={accessibleName}
                  onClick={() => handleCardClick(listing)}
                  onKeyDown={(e) => handleCardKeyDown(e, listing)}
                  className="group relative bg-white dark:bg-[#173425] rounded-3xl border border-[#2D765C]/20 dark:border-[#2B5A46] shadow-xs hover:shadow-xl hover:border-[#FF8D20]/60 transition-all duration-200 cursor-pointer flex flex-col overflow-hidden focus:outline-none focus:ring-2 focus:ring-[#2D765C] dark:focus:ring-[#FF8D20] hover:-translate-y-1"
                >
                  {/* Top Visual Panel (fixed height, stylized background with ResourceIcon) */}
                  <div className="relative w-full h-44 sm:h-48 bg-gradient-to-b from-[#F4F7F5] to-[#E2EBE5] dark:from-[#12281D] dark:to-[#0C1B14] p-4 flex items-center justify-center border-b border-[#2D765C]/10 dark:border-[#2B5A46]/40 overflow-hidden">
                    {/* Centered Large Icon */}
                    <div className="w-16 h-16 sm:w-20 sm:h-20 rounded-2xl bg-white/70 dark:bg-black/40 backdrop-blur-xs p-3 flex items-center justify-center shadow-xs group-hover:scale-110 transition-transform duration-300">
                      <ResourceIcon type={listing.iconType} className="w-10 h-10 sm:w-12 sm:h-12" />
                    </div>

                    {/* Top Badges Row */}
                    <div className="absolute top-2.5 left-2.5 right-2.5 flex items-center justify-between gap-1.5 pointer-events-none">
                      {listing.isVerified ? (
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-white/95 dark:bg-[#173425]/95 text-[#2D765C] dark:text-[#5FAE3B] border border-[#5FAE3B]/30 flex items-center gap-1 shadow-xs">
                          <ShieldCheck className="w-3 h-3 text-[#5FAE3B]" />
                          <span>{t.featuredProducts.verified}</span>
                        </span>
                      ) : <span />}

                      <div className="flex items-center gap-1">
                        {listing.isGroupListing && (
                          <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-50/95 dark:bg-emerald-950/90 text-[#1A4331] dark:text-[#5FAE3B] border border-emerald-300 dark:border-emerald-700 shadow-xs">
                            {t.featuredProducts.groupPooled}
                          </span>
                        )}

                        <span
                          className={`text-[10px] font-extrabold px-2 py-0.5 rounded-full uppercase tracking-wider shadow-xs ${
                            listing.mode === 'both'
                              ? 'bg-amber-100/95 dark:bg-amber-950/90 text-amber-900 dark:text-[#FF8D20] border border-amber-300 dark:border-amber-700/60'
                              : listing.mode === 'barter'
                              ? 'bg-blue-100/95 dark:bg-blue-950/90 text-blue-900 dark:text-blue-300 border border-blue-300 dark:border-blue-700/60'
                              : 'bg-emerald-100/95 dark:bg-emerald-950/90 text-emerald-900 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-700/60'
                          }`}
                        >
                          {listing.mode === 'both' ? t.modes.both : listing.mode === 'barter' ? t.modes.barter : t.modes.sell}
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Card Content Body */}
                  <div className="p-4 sm:p-5 flex flex-col flex-1 justify-between gap-3">
                    <div>
                      {/* Title & Description */}
                      <h3 className="text-sm sm:text-base font-bold text-[#13202B] dark:text-white group-hover:text-[#FF8D20] transition-colors line-clamp-2 leading-snug">
                        {listing.title}
                      </h3>

                      <p className="text-xs text-[#66737C] dark:text-[#AAB8B2] mt-1.5 line-clamp-2 leading-relaxed">
                        {listing.description}
                      </p>

                      {/* Provenance & Distance */}
                      <div className="mt-3 pt-2.5 border-t border-gray-100 dark:border-[#2B5A46]/60 flex items-center justify-between text-xs gap-2">
                        <div className="flex items-center gap-1 font-semibold text-[#1A4331] dark:text-[#5FAE3B] truncate min-w-0">
                          <ShieldCheck className="w-3.5 h-3.5 shrink-0 text-[#5FAE3B]" />
                          <span className="truncate">{listing.gramSabhaName}</span>
                        </div>

                        <div className="flex items-center gap-1 text-[11px] font-medium text-[#66737C] dark:text-[#AAB8B2] shrink-0">
                          <MapPin className="w-3 h-3 text-[#FF8D20]" />
                          <span>{listing.distanceKm} km</span>
                        </div>
                      </div>

                      {/* Available Stock Tag */}
                      <div className="mt-1.5 text-[11px] text-[#66737C] dark:text-[#AAB8B2] flex items-center justify-between">
                        <span>{t.featuredProducts.availableStock}</span>
                        <span className="font-semibold text-[#13202B] dark:text-[#F4F7F5]">
                          {listing.quantity} {listing.unit}
                        </span>
                      </div>
                    </div>

                    {/* Bottom: Price, Rating, and View Details Button */}
                    <div className="pt-2.5 border-t border-gray-100 dark:border-[#2B5A46]/60">
                      <div className="flex items-center justify-between">
                        <div>
                          <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2] font-medium">
                            {t.explorerSection.offeredAt}
                          </div>
                          <div className="text-base sm:text-lg font-extrabold text-[#1A4331] dark:text-[#5FAE3B]">
                            ₹{listing.pricePerUnit}
                            <span className="text-xs font-normal text-[#66737C] dark:text-[#AAB8B2]"> /{listing.unit}</span>
                          </div>
                        </div>

                        <div className="flex items-center gap-1 bg-amber-50 dark:bg-amber-950/40 px-2 py-1 rounded-xl text-xs font-bold text-amber-800 dark:text-[#FF8D20]">
                          <Star className="w-3.5 h-3.5 fill-[#FF8D20] text-[#FF8D20]" />
                          <span>{listing.rating}</span>
                          <span className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">({listing.reviewCount})</span>
                        </div>
                      </div>

                      {/* View Details Action Button */}
                      <div className="mt-3 w-full inline-flex items-center justify-center gap-1.5 py-2 px-3 rounded-xl bg-[#1A4331]/5 dark:bg-[#2D765C]/25 text-[#1A4331] dark:text-[#5FAE3B] group-hover:bg-[#FF8D20] group-hover:text-white font-bold text-xs transition-all shadow-2xs">
                        <span>{t.featuredProducts.viewDetails}</span>
                        <ArrowRight className="w-3.5 h-3.5 transition-transform group-hover:translate-x-1" />
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        ) : (
          /* Empty State */
          <div className="text-center py-14 px-4 bg-white dark:bg-[#173425] rounded-3xl border border-[#2D765C]/20 dark:border-[#2B5A46] max-w-md mx-auto space-y-3 shadow-xs">
            <FilterX className="w-10 h-10 text-[#66737C] dark:text-[#AAB8B2] mx-auto" />
            <h3 className="text-base font-bold text-[#13202B] dark:text-white">
              {t.featuredProducts.emptyTitle}
            </h3>
            <p className="text-xs text-[#66737C] dark:text-[#AAB8B2] leading-relaxed">
              {t.featuredProducts.emptyDesc}
            </p>
            <button
              type="button"
              onClick={() => setSelectedCategory('all')}
              className="mt-2 inline-flex items-center gap-1.5 text-xs font-bold text-[#FF8D20] hover:underline cursor-pointer"
            >
              <span>{t.featuredProducts.resetFilter}</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </div>
        )}

        {/* Single Explore Marketplace Button at bottom */}
        <div className="mt-12 sm:mt-14 flex justify-center">
          <button
            type="button"
            onClick={() => setActiveTab('marketplace')}
            className="inline-flex items-center gap-2 bg-[#FF8D20] hover:bg-[#D96B00] text-white px-8 py-3.5 rounded-2xl text-sm font-bold shadow-md shadow-orange-950/20 transition-all cursor-pointer hover:scale-[1.02] active:scale-95"
          >
            <span>{t.featuredProducts.exploreMarketplace}</span>
            <ArrowRight className="w-4 h-4" />
          </button>
        </div>

      </div>
    </section>
  );
};
