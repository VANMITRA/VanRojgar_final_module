import React, { useState } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { appFlow } from '../i18n/appFlow';
import { CopyCodeButton } from './CopyCodeButton';
import { ResourceIcon } from './ResourceIcon';
import { evaluateBarterBalance, checkIsLargeOrder, calculateDeliveryPay } from '../utils/marketplace';
import {
  X,
  ShieldCheck,
  MapPin,
  Star,
  Scale,
  ShoppingBag,
  ArrowRight,
  AlertCircle,
  Truck,
  Leaf,
  Info,
} from 'lucide-react';

export const ListingDetailModal: React.FC = () => {
  const { selectedListing, setSelectedListing, setDownloadListing, submitRequest, language, activePortal } = useMarketplace();
  const t = translations[language];
  const flow = appFlow[language];

  const [activeTab, setActiveTab] = useState<'buy' | 'barter'>('buy');
  const [quantity, setQuantity] = useState<number>(5);
  const [reason, setReason] = useState<string>('');
  const [offeredResource, setOfferedResource] = useState<string>('Pure Forest Honey');
  const [offeredQuantity, setOfferedQuantity] = useState<number>(4);
  const [offeredUnitVal, setOfferedUnitVal] = useState<number>(500);
  const [deliveryType, setDeliveryType] = useState<'delivery' | 'pickup'>('delivery');
  const [submitting, setSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  if (!selectedListing) return null;

  const isLarge = checkIsLargeOrder(quantity);
  const canBarter = (selectedListing.mode === 'barter' || selectedListing.mode === 'both') && activePortal !== 'buyer';
  const estimatedResourceTotal = quantity * selectedListing.pricePerUnit;
  const estimatedDeliveryPay = deliveryType === 'delivery' ? calculateDeliveryPay(selectedListing.distanceKm, quantity) : 0;
  const grandTotal = estimatedResourceTotal + estimatedDeliveryPay;

  // Barter calculation
  const totalOfferedValue = offeredQuantity * offeredUnitVal;
  const barterEvaluation = evaluateBarterBalance(totalOfferedValue, estimatedResourceTotal);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage(null);

    if (quantity <= 0) {
      setErrorMessage(language === 'hi' ? 'कृपया शून्य से अधिक मात्रा निर्दिष्ट करें।' : 'Please specify a quantity greater than zero.');
      return;
    }

    if (quantity > selectedListing.quantity) {
      setErrorMessage(
        language === 'hi'
          ? `अनुरोध मात्रा उपलब्ध स्टॉक (${selectedListing.quantity} ${selectedListing.unit}) से अधिक है।`
          : `Requested quantity exceeds available stock (${selectedListing.quantity} ${selectedListing.unit}).`
      );
      return;
    }

    if (isLarge && !reason.trim()) {
      setErrorMessage(
        language === 'hi'
          ? 'सतत वन संकलन सुनिश्चित करने हेतु थोक मांग (≥२५ इकाई) के लिए कारण बताना अनिवार्य है।'
          : 'A reason is strictly mandatory for bulk requests (≥25 units) to safeguard village sustainable harvesting.'
      );
      return;
    }

    // Buying happens in the app (payment, orders). The website only hands over the item code and the download.
    if (activeTab === 'buy') {
      setDownloadListing(selectedListing);
      setSelectedListing(null);
      return;
    }

    setSubmitting(true);

    const result = submitRequest({
      listingId: selectedListing.id,
      quantity,
      isBarter: activeTab === 'barter',
      offeredResource: activeTab === 'barter' ? offeredResource : undefined,
      offeredQuantity: activeTab === 'barter' ? offeredQuantity : undefined,
      reason: isLarge ? reason : undefined,
    });

    setSubmitting(false);

    if (result.success) {
      setSelectedListing(null);
    } else if (result.error) {
      setErrorMessage(result.error);
    }
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto bg-black/60 backdrop-blur-sm flex items-center justify-center p-3 sm:p-4">
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="modal-title"
        className="relative bg-white dark:bg-[#173425] rounded-3xl max-w-2xl w-full border border-gray-200 dark:border-[#2B5A46] shadow-2xl overflow-hidden my-6 transition-all"
      >
        {/* Modal Header */}
        <div className="relative bg-gradient-to-r from-[#1A4331] to-[#2D765C] p-5 sm:p-6 text-white">
          <button
            onClick={() => setSelectedListing(null)}
            aria-label="Close modal"
            className="absolute top-4 right-4 p-2 rounded-full bg-black/20 hover:bg-black/40 text-white transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>

          <div className="flex items-start gap-4">
            <div className="w-14 h-14 rounded-2xl bg-white/10 border border-white/20 p-2.5 flex items-center justify-center shrink-0">
              <ResourceIcon type={selectedListing.iconType} className="w-9 h-9" />
            </div>
            <div>
              <div className="flex flex-wrap items-center gap-2 mb-1">
                <span className="text-[11px] font-bold px-2 py-0.5 rounded-full bg-[#FF8D20] text-white">
                  {selectedListing.mode === 'both' ? t.modes.both : selectedListing.mode === 'barter' ? t.modes.barter : t.modes.sell}
                </span>
                {selectedListing.isGroupListing && (
                  <span className="text-[11px] font-bold px-2 py-0.5 rounded-full bg-emerald-400/20 text-emerald-200 border border-emerald-400/30">
                    {t.explorerSection.groupPooled}
                  </span>
                )}
                <span className="text-[11px] text-white/80 font-medium">
                  {language === 'hi' ? 'मौसम:' : language === 'mr' ? 'हंगाम:' : 'Season:'} {selectedListing.harvestSeason}
                </span>
              </div>
              <h2 id="modal-title" className="text-xl sm:text-2xl font-bold font-['Manrope']">
                {selectedListing.title}
              </h2>
              <div className="flex flex-wrap items-center gap-2 mt-1.5 text-xs text-white/90">
                <span className="opacity-80">{flow.itemCode}</span>
                <code className="font-extrabold tracking-wider bg-black/25 px-2 py-0.5 rounded-md">{selectedListing.itemCode}</code>
                <CopyCodeButton code={selectedListing.itemCode} className="!bg-white/10 !text-white !border-white/20 hover:!bg-white/20" />
                {selectedListing.source === 'sample' && (
                  <span className="px-2 py-0.5 rounded-full bg-amber-400/25 border border-amber-300/40 text-amber-100 text-[10px] font-extrabold">
                    {flow.sampleBadge}
                  </span>
                )}
              </div>
              <div className="flex items-center gap-2 mt-1 text-xs text-white/90">
                <span className="font-semibold">{selectedListing.gramSabhaName}</span>
                <span>•</span>
                <span className="flex items-center gap-1">
                  <MapPin className="w-3.5 h-3.5 text-[#FF8D20]" />
                  {selectedListing.village}, {selectedListing.district}{selectedListing.source === 'sample' ? ` (${selectedListing.distanceKm} km ${t.common.distance})` : ''}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Modal Body */}
        <div className="p-5 sm:p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          {/* Trust and Provenance Card */}
          <div className="bg-[#F4F7F5] dark:bg-[#10261B] p-4 rounded-2xl border border-gray-200 dark:border-[#2B5A46] space-y-2.5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-1.5 text-xs font-bold text-[#1A4331] dark:text-[#5FAE3B]">
                <ShieldCheck className="w-4 h-4 text-[#5FAE3B]" />
                <span>{t.listingModal.verifiedBadge}</span>
              </div>
              <div className="flex items-center gap-1 text-xs font-bold text-[#FF8D20]">
                <Star className="w-3.5 h-3.5 fill-[#FF8D20]" />
                <span>{selectedListing.rating} ({selectedListing.reviewCount} {t.listingModal.verifiedReviews})</span>
              </div>
            </div>

            <div className="text-xs text-[#66737C] dark:text-[#AAB8B2] space-y-1">
              <p>
                <strong className="text-[#13202B] dark:text-[#F4F7F5]">{t.listingModal.sourceAreaLabel} </strong>
                {selectedListing.sourceArea}
              </p>
              <p>
                <strong className="text-[#13202B] dark:text-[#F4F7F5]">{t.listingModal.harvestMethodLabel} </strong>
                {selectedListing.collectionMethod}
              </p>
            </div>

            <div className="flex items-center gap-1.5 pt-1 text-[11px] text-[#5FAE3B] font-semibold">
              <Leaf className="w-3.5 h-3.5" />
              <span>{t.listingModal.sustainablePledge}</span>
            </div>
          </div>

          {/* Pricing & Fair Value Guidance */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div className="p-3.5 rounded-xl bg-gray-50 dark:bg-[#10261B]/60 border border-gray-200 dark:border-[#2B5A46]">
              <div className="text-xs text-[#66737C] dark:text-[#AAB8B2]">{t.listingModal.listedPriceLabel}</div>
              <div className="text-xl font-extrabold text-[#1A4331] dark:text-[#5FAE3B]">
                ₹{selectedListing.pricePerUnit}
                <span className="text-xs font-normal text-[#66737C] dark:text-[#AAB8B2]"> / {selectedListing.unit}</span>
              </div>
              <div className="text-[11px] text-[#66737C] dark:text-[#AAB8B2] mt-0.5">
                {t.common.quantity}: <strong className="text-[#13202B] dark:text-white">{selectedListing.quantity} {selectedListing.unit}</strong> {t.listingModal.inStoreStock}
              </div>
            </div>

            <div className="p-3.5 rounded-xl bg-orange-50/70 dark:bg-[#173425] border border-orange-200/60 dark:border-orange-500/30">
              <div className="flex items-center gap-1 text-xs font-bold text-[#FF8D20]">
                <Scale className="w-3.5 h-3.5" />
                <span>{t.listingModal.fairPriceGuideTitle}</span>
              </div>
              <div className="text-base font-bold text-[#13202B] dark:text-[#F4F7F5] mt-1">
                ₹{selectedListing.fairPriceRange[0]} – ₹{selectedListing.fairPriceRange[1]}
                <span className="text-xs font-normal text-[#66737C] dark:text-[#AAB8B2]"> / {selectedListing.unit}</span>
              </div>
              <p className="text-[10px] text-[#66737C] dark:text-[#AAB8B2] mt-0.5 leading-tight">
                {t.listingModal.fairPriceNotice}
              </p>
            </div>
          </div>

          {/* Action Tabs: Buy vs Barter */}
          <div>
            <div className="flex border-b border-gray-200 dark:border-[#2B5A46] mb-4">
              <button
                type="button"
                onClick={() => setActiveTab('buy')}
                className={`flex-1 py-2.5 text-xs font-bold flex items-center justify-center gap-2 border-b-2 transition-colors cursor-pointer ${
                  activeTab === 'buy'
                    ? 'border-[#FF8D20] text-[#FF8D20]'
                    : 'border-transparent text-[#66737C] dark:text-[#AAB8B2] hover:text-[#13202B] dark:hover:text-white'
                }`}
              >
                <ShoppingBag className="w-4 h-4" />
                <span>{t.listingModal.requestPurchaseTab}</span>
              </button>

              {canBarter ? (
                <button
                  type="button"
                  onClick={() => setActiveTab('barter')}
                  className={`flex-1 py-2.5 text-xs font-bold flex items-center justify-center gap-2 border-b-2 transition-colors cursor-pointer ${
                    activeTab === 'barter'
                      ? 'border-[#FF8D20] text-[#FF8D20]'
                      : 'border-transparent text-[#66737C] dark:text-[#AAB8B2] hover:text-[#13202B] dark:hover:text-white'
                  }`}
                >
                  <Scale className="w-4 h-4" />
                  <span>{t.listingModal.offerBarterTab}</span>
                </button>
              ) : (
                activePortal === 'buyer' && (
                  <div className="flex-1 py-2.5 text-xs text-center text-[#66737C] dark:text-[#AAB8B2] opacity-60">
                    {t.listingModal.barterDisabledNotice}
                  </div>
                )
              )}
            </div>

            {/* Error banner */}
            {errorMessage && (
              <div className="mb-4 p-3 rounded-xl bg-red-50 dark:bg-red-950/40 border border-red-200 dark:border-red-900 text-xs text-red-700 dark:text-red-300 flex items-start gap-2">
                <AlertCircle className="w-4 h-4 shrink-0 mt-0.5 text-red-500" />
                <span>{errorMessage}</span>
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-4">
              {/* Common Quantity Field */}
              <div>
                <label className="block text-xs font-bold text-[#13202B] dark:text-[#F4F7F5] mb-1">
                  {t.listingModal.quantityDesiredLabel} ({selectedListing.unit})
                </label>
                <div className="flex items-center gap-3">
                  <input
                    type="range"
                    min="1"
                    max={selectedListing.quantity}
                    value={quantity}
                    onChange={(e) => setQuantity(Number(e.target.value))}
                    className="flex-1 accent-[#FF8D20]"
                  />
                  <div className="w-20">
                    <input
                      type="number"
                      min="1"
                      max={selectedListing.quantity}
                      value={quantity}
                      onChange={(e) => setQuantity(Number(e.target.value))}
                      className="w-full text-center font-bold px-2 py-1.5 rounded-lg border border-gray-300 dark:border-[#2B5A46] bg-white dark:bg-[#10261B] text-sm text-[#13202B] dark:text-white"
                    />
                  </div>
                </div>
              </div>

              {/* Large Order Reason Rule (Required when quantity >= 25) */}
              {isLarge && (
                <div className="p-3.5 rounded-xl bg-amber-50 dark:bg-amber-950/30 border border-amber-300 dark:border-amber-700/50 space-y-2">
                  <div className="flex items-start gap-2 text-xs font-bold text-amber-800 dark:text-amber-300">
                    <Info className="w-4 h-4 shrink-0 text-amber-600 dark:text-amber-400 mt-0.5" />
                    <div>
                      <span>{t.listingModal.sustainabilityTitle} (≥25 {selectedListing.unit})</span>
                      <p className="font-normal text-[11px] text-amber-700 dark:text-amber-400/90 mt-0.5 leading-relaxed">
                        {t.listingModal.sustainabilityNotice}
                      </p>
                    </div>
                  </div>
                  <div>
                    <label htmlFor="large-order-reason" className="block text-[11px] font-bold text-amber-900 dark:text-amber-200 mb-1">
                      {t.listingModal.reasonInputLabel} <span className="text-red-500">*</span>
                    </label>
                    <textarea
                      id="large-order-reason"
                      rows={2}
                      value={reason}
                      onChange={(e) => setReason(e.target.value)}
                      placeholder={t.listingModal.reasonPlaceholder}
                      className="w-full text-xs p-2 rounded-lg border border-amber-300 dark:border-amber-700 bg-white dark:bg-[#10261B] text-[#13202B] dark:text-white placeholder:text-gray-400 focus:ring-2 focus:ring-[#FF8D20] outline-none"
                      required
                    />
                  </div>
                </div>
              )}

              {/* Buy Tab specific fields */}
              {activeTab === 'buy' && (
                <div className="space-y-3">
                  <div>
                    <label className="block text-xs font-bold text-[#13202B] dark:text-[#F4F7F5] mb-1">
                      {t.listingModal.fulfillmentModeLabel}
                    </label>
                    <div className="grid grid-cols-2 gap-3 text-xs">
                      <button
                        type="button"
                        onClick={() => setDeliveryType('delivery')}
                        className={`p-2.5 rounded-xl border text-left flex items-center gap-2 transition-all cursor-pointer ${
                          deliveryType === 'delivery'
                            ? 'border-[#FF8D20] bg-orange-50 dark:bg-[#173425] text-[#FF8D20] font-bold'
                            : 'border-gray-200 dark:border-[#2B5A46] text-[#66737C] dark:text-[#AAB8B2]'
                        }`}
                      >
                        <Truck className="w-4 h-4" />
                        <div>
                          <div>{t.listingModal.deliveryOptionTitle}</div>
                          <div className="text-[10px] font-normal text-[#66737C] dark:text-[#AAB8B2]">
                            {t.listingModal.deliveryOptionSub} (~₹{calculateDeliveryPay(selectedListing.distanceKm, quantity)})
                          </div>
                        </div>
                      </button>

                      <button
                        type="button"
                        onClick={() => setDeliveryType('pickup')}
                        className={`p-2.5 rounded-xl border text-left flex items-center gap-2 transition-all cursor-pointer ${
                          deliveryType === 'pickup'
                            ? 'border-[#FF8D20] bg-orange-50 dark:bg-[#173425] text-[#FF8D20] font-bold'
                            : 'border-gray-200 dark:border-[#2B5A46] text-[#66737C] dark:text-[#AAB8B2]'
                        }`}
                      >
                        <MapPin className="w-4 h-4" />
                        <div>
                          <div>{t.listingModal.pickupOptionTitle}</div>
                          <div className="text-[10px] font-normal text-[#66737C] dark:text-[#AAB8B2]">
                            {t.listingModal.pickupOptionSub}
                          </div>
                        </div>
                      </button>
                    </div>
                  </div>

                  <div className="p-3 bg-gray-50 dark:bg-[#10261B] rounded-xl border border-gray-200 dark:border-[#2B5A46] flex items-center justify-between text-xs">
                    <div>
                      <div className="text-[#66737C] dark:text-[#AAB8B2]">{t.listingModal.estimatedAmountLabel}</div>
                      <div className="font-semibold text-[#13202B] dark:text-white">
                        {quantity} {selectedListing.unit} × ₹{selectedListing.pricePerUnit} = ₹{estimatedResourceTotal}
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                        {t.listingModal.paymentDecisionNotice}
                      </div>
                      <div className="text-sm font-bold text-[#1A4331] dark:text-[#5FAE3B]">
                        {t.listingModal.grandTotalLabel} ₹{grandTotal}
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Barter Tab: Balance Meter Demonstration */}
              {activeTab === 'barter' && (
                <div className="space-y-4 p-4 rounded-2xl bg-emerald-50/50 dark:bg-[#10261B]/80 border border-emerald-200 dark:border-[#2B5A46]">
                  <div className="text-xs">
                    <span className="font-bold text-[#1A4331] dark:text-[#5FAE3B]">{t.listingModal.barterWantsLabel} </span>
                    <span className="text-[#66737C] dark:text-[#AAB8B2]">{selectedListing.barterWants || (language === 'hi' ? 'सामान्य वन संपदा' : 'General forest commodities')}</span>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
                    <div>
                      <label className="block font-bold text-[#13202B] dark:text-[#F4F7F5] mb-1">
                        {t.listingModal.exchangeResourceLabel}
                      </label>
                      <input
                        type="text"
                        value={offeredResource}
                        onChange={(e) => setOfferedResource(e.target.value)}
                        placeholder="e.g. Pure Wild Honey"
                        className="w-full p-2 rounded-lg border border-gray-300 dark:border-[#2B5A46] bg-white dark:bg-[#173425] text-[#13202B] dark:text-white"
                      />
                    </div>
                    <div>
                      <label className="block font-bold text-[#13202B] dark:text-[#F4F7F5] mb-1">
                        {t.listingModal.exchangeQtyLabel}
                      </label>
                      <input
                        type="number"
                        min="1"
                        value={offeredQuantity}
                        onChange={(e) => setOfferedQuantity(Number(e.target.value))}
                        className="w-full p-2 rounded-lg border border-gray-300 dark:border-[#2B5A46] bg-white dark:bg-[#173425] text-[#13202B] dark:text-white"
                      />
                    </div>
                  </div>

                  {/* Interactive Barter Balance Meter */}
                  <div className="p-3.5 rounded-xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] space-y-2">
                    <div className="flex items-center justify-between text-xs">
                      <span className="font-bold flex items-center gap-1 text-[#1A4331] dark:text-[#F4F7F5]">
                        <Scale className="w-3.5 h-3.5 text-[#FF8D20]" />
                        {t.listingModal.equityMeterTitle}
                      </span>
                      <span
                        className={`px-2 py-0.5 rounded-full font-bold text-[10px] ${
                          barterEvaluation.verdict === 'balanced'
                            ? 'bg-[#5FAE3B]/20 text-[#5FAE3B]'
                            : barterEvaluation.verdict === 'favorable_to_receiver'
                            ? 'bg-blue-500/20 text-blue-400'
                            : 'bg-amber-500/20 text-amber-500'
                        }`}
                      >
                        {barterEvaluation.verdict === 'balanced'
                          ? t.barterSection.balancedVerdict
                          : barterEvaluation.verdict === 'favorable_to_receiver'
                          ? t.barterSection.favoursReceiverVerdict
                          : t.barterSection.favoursSenderVerdict}
                      </span>
                    </div>

                    <div className="h-2 w-full bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden flex">
                      <div
                        className="bg-[#2D765C] h-full transition-all duration-300"
                        style={{ width: `${Math.min(100, Math.max(10, (barterEvaluation.ratio / 2) * 100))}%` }}
                      />
                    </div>

                    <div className="flex items-center justify-between text-[11px] text-[#66737C] dark:text-[#AAB8B2]">
                      <span>{t.listingModal.offeredValLabel} ~₹{totalOfferedValue}</span>
                      <span>{t.listingModal.targetValLabel} ~₹{estimatedResourceTotal}</span>
                    </div>

                    <p className="text-[11px] text-[#66737C] dark:text-[#AAB8B2] italic">
                      {language === 'hi'
                        ? barterEvaluation.verdict === 'balanced'
                          ? 'दोनों पक्षों के लिए संतुलित विनिमय मूल्य'
                          : barterEvaluation.verdict === 'favorable_to_receiver'
                          ? 'प्रतिपक्ष को अधिक मूल्य प्राप्त हो रहा है'
                          : 'प्रस्तावित माल का मूल्य कम है'
                        : barterEvaluation.advice}
                    </p>
                  </div>
                </div>
              )}

              {/* Submit Button */}
              <div className="flex items-center justify-end gap-3 pt-3">
                <button
                  type="button"
                  onClick={() => setSelectedListing(null)}
                  className="px-4 py-2.5 rounded-xl text-xs font-semibold text-[#66737C] hover:text-[#13202B] dark:hover:text-white transition-colors cursor-pointer"
                >
                  {t.listingModal.cancelBtn}
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="flex items-center gap-2 bg-[#FF8D20] hover:bg-[#D96B00] text-white px-6 py-2.5 rounded-xl text-xs sm:text-sm font-bold shadow-lg shadow-orange-950/20 transition-all active:scale-95 disabled:opacity-50 cursor-pointer"
                >
                  <span>{activeTab === 'buy' ? flow.buyInApp : t.listingModal.submitBarterBtn}</span>
                  <ArrowRight className="w-4 h-4" />
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};
