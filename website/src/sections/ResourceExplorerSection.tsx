import React, { useState, useMemo } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { ResourceCategory, ListingMode } from '../types';
import { ResourceIcon } from '../components/ResourceIcon';
import { CopyCodeButton } from '../components/CopyCodeButton';
import { appFlow } from '../i18n/appFlow';
import { normaliseItemCode } from '../utils/itemCode';
import {
  Search,
  SlidersHorizontal,
  MapPin,
  Star,
  ShieldCheck,
  Scale,
  Sparkles,
  ShoppingBag,
  ArrowUpDown,
  Leaf,
  FilterX,
} from 'lucide-react';

export const ResourceExplorerSection: React.FC = () => {
  const { listings, dataSource, setSelectedListing, language } = useMarketplace();
  const t = translations[language];
  const flow = appFlow[language];

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [sortBy, setSortBy] = useState<'nearest' | 'price_asc' | 'rating_desc'>('nearest');
  const [filterMode, setFilterMode] = useState<string>('all');

  const categories: { key: string; label: string }[] = [
    { key: 'all', label: t.categories.all },
    { key: 'medicinal', label: t.categories.medicinal },
    { key: 'forest_produce', label: t.categories.forest_produce },
    { key: 'handicrafts', label: t.categories.handicrafts },
    { key: 'water_land', label: t.categories.water_land },
    { key: 'others', label: t.categories.others },
  ];

  const filteredListings = useMemo(() => {
    return listings
      .filter((item) => {
        // Search filter
        const typedCode = normaliseItemCode(searchQuery);
        const matchesQuery =
          (typedCode !== null && item.itemCode === typedCode) ||
          item.itemCode.toLowerCase().includes(searchQuery.trim().toLowerCase()) ||
          item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
          item.gramSabhaName.toLowerCase().includes(searchQuery.toLowerCase()) ||
          item.village.toLowerCase().includes(searchQuery.toLowerCase()) ||
          item.description.toLowerCase().includes(searchQuery.toLowerCase());

        // Category filter
        const matchesCategory = selectedCategory === 'all' || item.category === selectedCategory;

        // Mode filter
        const matchesMode =
          filterMode === 'all' ||
          (filterMode === 'buy' && (item.mode === 'sell' || item.mode === 'both')) ||
          (filterMode === 'barter' && (item.mode === 'barter' || item.mode === 'both'));

        return matchesQuery && matchesCategory && matchesMode;
      })
      .sort((a, b) => {
        if (sortBy === 'nearest') return a.distanceKm - b.distanceKm;
        if (sortBy === 'price_asc') return a.pricePerUnit - b.pricePerUnit;
        if (sortBy === 'rating_desc') return b.rating - a.rating;
        return 0;
      });
  }, [listings, searchQuery, selectedCategory, sortBy, filterMode]);

  return (
    <section id="marketplace" className="py-20 bg-[#F4F7F5] dark:bg-[#0C1B14] text-[#13202B] dark:text-[#F4F7F5] transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 mb-8">
          <div>
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#2D765C]/20 text-[#1A4331] dark:text-[#5FAE3B] text-xs font-bold mb-2">
              <ShoppingBag className="w-3.5 h-3.5" />
              <span>{t.explorerSection.badge}</span>
            </div>
            <h2 className="text-3xl sm:text-4xl font-extrabold font-['Manrope'] tracking-tight">
              {t.explorerSection.title}
            </h2>
            <p className="text-xs sm:text-sm text-[#66737C] dark:text-[#AAB8B2] mt-1 max-w-xl">
              {t.explorerSection.desc}
            </p>
          </div>

          <div className="flex items-center gap-2 self-start md:self-auto">
            <span className="text-xs text-[#66737C] dark:text-[#AAB8B2] font-medium flex items-center gap-1">
              <ArrowUpDown className="w-3.5 h-3.5" />
              {t.explorerSection.sortBy}
            </span>
            <select
              value={sortBy}
              aria-label="Sort listings"
              onChange={(e) => setSortBy(e.target.value as any)}
              className="text-xs font-semibold px-3 py-2 rounded-xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] text-[#13202B] dark:text-white outline-none focus:ring-2 focus:ring-[#FF8D20]"
            >
              <option value="nearest">{t.explorerSection.sortNearest}</option>
              <option value="price_asc">{t.explorerSection.sortPriceAsc}</option>
              <option value="rating_desc">{t.explorerSection.sortRatingDesc}</option>
            </select>
          </div>
        </div>

        {/* Where the listings come from: live from the marketplace, or labelled sample data */}
        <div
          role="status"
          className={`mb-5 flex items-start gap-2 px-4 py-3 rounded-2xl text-xs font-semibold border ${
            dataSource === 'live'
              ? 'bg-emerald-50 dark:bg-emerald-950/40 border-emerald-300 dark:border-emerald-800 text-emerald-900 dark:text-emerald-200'
              : 'bg-amber-50 dark:bg-amber-950/40 border-amber-300 dark:border-amber-800 text-amber-900 dark:text-amber-200'
          }`}
        >
          <span className="px-2 py-0.5 rounded-full bg-black/10 dark:bg-white/10 text-[10px] font-extrabold tracking-wider shrink-0">
            {dataSource === 'live' ? flow.liveBadge : flow.sampleBadge}
          </span>
          <span>{dataSource === 'live' ? flow.liveBanner : flow.sampleBanner}</span>
        </div>

        {/* Search Bar & Mode Filter Row */}
        <div className="grid grid-cols-1 md:grid-cols-12 gap-3 mb-6">
          <div className="md:col-span-8 relative">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[#66737C] dark:text-[#AAB8B2]" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder={t.common.searchPlaceholder}
              className="w-full pl-10 pr-4 py-3 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] text-xs sm:text-sm text-[#13202B] dark:text-white placeholder:text-[#66737C] dark:placeholder:text-[#AAB8B2] outline-none focus:ring-2 focus:ring-[#FF8D20] shadow-sm"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="absolute right-3.5 top-1/2 -translate-y-1/2 text-xs text-[#66737C] hover:text-[#13202B] dark:hover:text-white"
              >
                {t.explorerSection.clear}
              </button>
            )}
          </div>

          <div className="md:col-span-4 flex items-center gap-2">
            <span className="text-xs text-[#66737C] dark:text-[#AAB8B2] font-semibold shrink-0">
              {t.explorerSection.modeLabel}
            </span>
            <div className="grid grid-cols-3 gap-1 w-full bg-white dark:bg-[#173425] p-1 rounded-2xl border border-gray-200 dark:border-[#2B5A46]">
              <button
                type="button"
                onClick={() => setFilterMode('all')}
                className={`py-1.5 text-xs font-bold rounded-xl transition-colors ${
                  filterMode === 'all'
                    ? 'bg-[#1A4331] text-white dark:bg-[#FF8D20]'
                    : 'text-[#66737C] dark:text-[#AAB8B2] hover:text-[#13202B]'
                }`}
              >
                {t.explorerSection.modeAll}
              </button>
              <button
                type="button"
                onClick={() => setFilterMode('buy')}
                className={`py-1.5 text-xs font-bold rounded-xl transition-colors ${
                  filterMode === 'buy'
                    ? 'bg-[#1A4331] text-white dark:bg-[#FF8D20]'
                    : 'text-[#66737C] dark:text-[#AAB8B2] hover:text-[#13202B]'
                }`}
              >
                {t.explorerSection.modeBuy}
              </button>
              <button
                type="button"
                onClick={() => setFilterMode('barter')}
                className={`py-1.5 text-xs font-bold rounded-xl transition-colors ${
                  filterMode === 'barter'
                    ? 'bg-[#1A4331] text-white dark:bg-[#FF8D20]'
                    : 'text-[#66737C] dark:text-[#AAB8B2] hover:text-[#13202B]'
                }`}
              >
                {t.explorerSection.modeBarter}
              </button>
            </div>
          </div>
        </div>

        {/* Category Filter Chips */}
        <div className="flex items-center gap-2 overflow-x-auto pb-4 mb-6 no-scrollbar">
          {categories.map((cat) => (
            <button
              key={cat.key}
              onClick={() => setSelectedCategory(cat.key)}
              className={`px-4 py-2 rounded-xl text-xs font-bold whitespace-nowrap transition-all shrink-0 ${
                selectedCategory === cat.key
                  ? 'bg-[#1A4331] text-white dark:bg-[#FF8D20] shadow-md shadow-[#1A4331]/20 dark:shadow-orange-950/30'
                  : 'bg-white dark:bg-[#173425] text-[#66737C] dark:text-[#AAB8B2] hover:text-[#13202B] dark:hover:text-white border border-gray-200 dark:border-[#2B5A46]'
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* Listing Cards Grid */}
        {filteredListings.length > 0 ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredListings.map((listing) => (
              <div
                key={listing.id}
                onClick={() => setSelectedListing(listing)}
                className="group relative bg-white dark:bg-[#173425] rounded-3xl p-5 border border-gray-200 dark:border-[#2B5A46] shadow-md hover:shadow-xl hover:border-[#FF8D20]/50 transition-all cursor-pointer flex flex-col justify-between"
              >
                <div>
                  {/* Top Row: Category, Icon, Mode */}
                  <div className="flex items-start justify-between gap-2 mb-3">
                    <div className="w-12 h-12 rounded-2xl bg-[#1A4331]/10 dark:bg-black/30 p-2 flex items-center justify-center shrink-0 group-hover:scale-105 transition-transform">
                      <ResourceIcon type={listing.iconType} className="w-7 h-7" />
                    </div>

                    <div className="flex items-center gap-1.5 flex-wrap justify-end">
                      {listing.isGroupListing && (
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-50 dark:bg-emerald-950/60 text-[#1A4331] dark:text-[#5FAE3B] border border-emerald-300 dark:border-emerald-700">
                          {t.explorerSection.groupPooled}
                        </span>
                      )}
                      <span
                        className={`text-[10px] font-extrabold px-2 py-0.5 rounded-full uppercase tracking-wider ${
                          listing.mode === 'both'
                            ? 'bg-amber-100 dark:bg-amber-950/60 text-amber-800 dark:text-[#FF8D20]'
                            : listing.mode === 'barter'
                            ? 'bg-blue-100 dark:bg-blue-950/60 text-blue-800 dark:text-blue-300'
                            : 'bg-emerald-100 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300'
                        }`}
                      >
                        {listing.mode === 'both' ? t.modes.both : listing.mode === 'barter' ? t.modes.barter : t.modes.sell}
                      </span>
                    </div>
                  </div>

                  {/* Title & Description */}
                  <h3 className="text-base font-bold text-[#13202B] dark:text-white group-hover:text-[#FF8D20] transition-colors line-clamp-1">
                    {listing.title}
                  </h3>

                  <p className="text-xs text-[#66737C] dark:text-[#AAB8B2] mt-1 line-clamp-2 leading-relaxed">
                    {listing.description}
                  </p>

                  {/* Provenance & Distance Tag */}
                  <div className="mt-3.5 pt-3 border-t border-gray-100 dark:border-[#2B5A46]/60 flex items-center justify-between text-xs">
                    <div className="flex items-center gap-1 font-semibold text-[#1A4331] dark:text-[#5FAE3B] truncate">
                      <ShieldCheck className="w-3.5 h-3.5 shrink-0 text-[#5FAE3B]" />
                      <span className="truncate">{listing.gramSabhaName}</span>
                    </div>

                    <div className="flex items-center gap-1 text-[11px] font-medium text-[#66737C] dark:text-[#AAB8B2] shrink-0">
                      <MapPin className="w-3.5 h-3.5 text-[#FF8D20]" />
                      <span>{listing.source === 'sample' ? `${listing.distanceKm} km ${t.common.distance}` : listing.village}</span>
                    </div>
                  </div>

                  {/* Item code: paste it into the app's search */}
                  <div className="mt-2.5 flex items-center justify-between gap-2 text-[11px]">
                    <span className="flex items-center gap-1.5 text-[#66737C] dark:text-[#AAB8B2]">
                      {flow.itemCode}
                      <code className="font-extrabold tracking-wider text-[#13202B] dark:text-white">{listing.itemCode}</code>
                      {listing.source === 'sample' && (
                        <span className="px-1.5 py-0.5 rounded-full bg-amber-100 dark:bg-amber-950/60 text-amber-800 dark:text-amber-300 text-[9px] font-extrabold">
                          {flow.sampleBadge}
                        </span>
                      )}
                    </span>
                    <CopyCodeButton code={listing.itemCode} />
                  </div>

                  {/* Fair Price Guide Box (a guide for sample data only; a live listing has just its asking price) */}
                  {listing.source === 'sample' && (
                  <div className="mt-2.5 p-2 rounded-xl bg-gray-50 dark:bg-[#10261B] text-[11px] flex items-center justify-between text-[#66737C] dark:text-[#AAB8B2]">
                    <span className="flex items-center gap-1">
                      <Scale className="w-3 h-3 text-[#FF8D20]" />
                      {t.explorerSection.fairRange}
                    </span>
                    <span className="font-semibold text-[#13202B] dark:text-white">
                      ₹{listing.fairPriceRange[0]} – ₹{listing.fairPriceRange[1]} /{listing.unit}
                    </span>
                  </div>
                  )}
                </div>

                {/* Bottom Row: Price & Rating */}
                <div className="mt-4 pt-3 border-t border-gray-100 dark:border-[#2B5A46]/60 flex items-center justify-between">
                  <div>
                    <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">{t.explorerSection.offeredAt}</div>
                    <div className="text-lg font-extrabold text-[#1A4331] dark:text-[#5FAE3B]">
                      ₹{listing.pricePerUnit}
                      <span className="text-xs font-normal text-[#66737C] dark:text-[#AAB8B2]"> /{listing.unit}</span>
                    </div>
                  </div>

                  {listing.reviewCount > 0 && (
                  <div className="flex items-center gap-1 bg-amber-50 dark:bg-amber-950/40 px-2.5 py-1 rounded-xl text-xs font-bold text-amber-800 dark:text-[#FF8D20]">
                    <Star className="w-3.5 h-3.5 fill-[#FF8D20] text-[#FF8D20]" />
                    <span>{listing.rating}</span>
                    <span className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">({listing.reviewCount})</span>
                  </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        ) : (
          /* Empty State */
          <div className="text-center py-16 px-4 bg-white dark:bg-[#173425] rounded-3xl border border-gray-200 dark:border-[#2B5A46] max-w-lg mx-auto space-y-3">
            <FilterX className="w-10 h-10 text-[#66737C] mx-auto" />
            <h3 className="text-base font-bold text-[#13202B] dark:text-white">
              {t.explorerSection.noResultsTitle}
            </h3>
            <p className="text-xs text-[#66737C] dark:text-[#AAB8B2]">
              {t.explorerSection.noResultsDesc}
            </p>
            <button
              onClick={() => {
                setSearchQuery('');
                setSelectedCategory('all');
                setFilterMode('all');
              }}
              className="mt-2 text-xs font-bold text-[#FF8D20] hover:underline"
            >
              {t.explorerSection.resetFilters}
            </button>
          </div>
        )}

      </div>
    </section>
  );
};
