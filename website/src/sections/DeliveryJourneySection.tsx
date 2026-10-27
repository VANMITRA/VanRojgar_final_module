import React, { useState } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import {
  Truck,
  ShieldCheck,
  CheckCircle,
  Star,
} from 'lucide-react';

export const DeliveryJourneySection: React.FC = () => {
  const { deliveryPartner, deliveryJobs, language } = useMarketplace();
  const t = translations[language];

  return (
    <section id="delivery" className="py-20 bg-[#F4F7F5] dark:bg-[#10261B] text-[#13202B] dark:text-[#F4F7F5] transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Section Heading */}
        <div className="text-center max-w-3xl mx-auto mb-14 space-y-4">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#FF8D20]/15 text-[#D96B00] dark:text-[#FF8D20] text-xs font-bold">
            <Truck className="w-3.5 h-3.5" />
            <span>{t.deliverySection.badge}</span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-extrabold font-['Manrope'] tracking-tight">
            {t.deliverySection.title}
          </h2>
          <p className="text-sm sm:text-base text-[#66737C] dark:text-[#AAB8B2]">
            {t.deliverySection.desc}
          </p>
        </div>

        {/* 4-Step Horizontal Journey */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-12">
          {t.deliverySection.journeySteps.map((s, idx) => (
            <div
              key={s.step}
              className="p-5 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200/80 dark:border-[#2B5A46] shadow-md relative flex flex-col justify-between"
            >
              <div>
                <div className="flex items-center justify-between mb-3">
                  <span className="w-8 h-8 rounded-xl bg-[#1A4331] text-white dark:bg-[#FF8D20] text-xs font-black flex items-center justify-center">
                    {s.step}
                  </span>
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 dark:bg-emerald-950/60 text-[#1A4331] dark:text-[#5FAE3B]">
                    {s.actor}
                  </span>
                </div>
                <h3 className="text-base font-bold text-[#13202B] dark:text-white font-['Manrope']">
                  {s.title}
                </h3>
                <p className="text-xs text-[#66737C] dark:text-[#AAB8B2] mt-2 leading-relaxed">
                  {s.desc}
                </p>
              </div>

              {idx < 3 && (
                <div className="hidden lg:block absolute -right-2.5 top-1/2 -translate-y-1/2 z-10 w-5 h-5 rounded-full bg-[#FF8D20] text-white text-[10px] flex items-center justify-center">
                  →
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Live Delivery Dispatch & "My Deliveries" Interface Mock */}
        <div className="p-6 sm:p-8 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200/80 dark:border-[#2B5A46] shadow-xl mb-12">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
            
            <div className="lg:col-span-6 space-y-4 text-left">
              <div className="inline-flex items-center gap-1.5 text-xs font-bold text-[#5FAE3B]">
                <CheckCircle className="w-4 h-4" />
                <span>{t.deliverySection.unlockedBadge}</span>
              </div>

              <h3 className="text-2xl sm:text-3xl font-extrabold text-[#1A4331] dark:text-white font-['Manrope']">
                {t.deliverySection.dashTitle}
              </h3>

              <p className="text-sm text-[#66737C] dark:text-[#AAB8B2] leading-relaxed">
                {t.deliverySection.dashDesc}
              </p>

              <div className="grid grid-cols-2 gap-3 pt-2">
                <div className="p-3.5 rounded-2xl bg-[#F4F7F5] dark:bg-[#10261B] border border-gray-200/80 dark:border-[#2B5A46]">
                  <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">{t.deliverySection.totalEarningsLabel}</div>
                  <div className="text-xl font-extrabold text-[#5FAE3B] mt-0.5">
                    ₹{deliveryPartner.totalEarnings.toLocaleString()}
                  </div>
                  <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">{deliveryPartner.completedJobs} {t.deliverySection.completedHaulsLabel}</div>
                </div>

                <div className="p-3.5 rounded-2xl bg-[#F4F7F5] dark:bg-[#10261B] border border-gray-200/80 dark:border-[#2B5A46]">
                  <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">{t.deliverySection.partnerRatingLabel}</div>
                  <div className="text-xl font-extrabold text-[#FF8D20] mt-0.5 flex items-center gap-1">
                    <Star className="w-4 h-4 fill-[#FF8D20]" />
                    <span>{deliveryPartner.rating}</span>
                  </div>
                  <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">{t.deliverySection.ratedByLabel}</div>
                </div>
              </div>

              {/* Driver Availability Toggle Simulation */}
              <div className="p-3.5 rounded-2xl bg-[#F4F7F5] dark:bg-[#10261B] border border-gray-200/80 dark:border-[#2B5A46] flex items-center justify-between">
                <div>
                  <div className="text-xs font-bold text-[#13202B] dark:text-white">
                    {t.deliverySection.availabilityTitle}
                  </div>
                  <div className="text-[11px] text-[#66737C] dark:text-[#AAB8B2]">
                    {t.deliverySection.availabilitySub}
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <span className={`text-xs font-bold ${deliveryPartner.isAvailable ? 'text-[#5FAE3B]' : 'text-gray-400'}`}>
                    {deliveryPartner.isAvailable ? t.deliverySection.activeText : t.deliverySection.offlineText}
                  </span>
                  <div className="w-10 h-6 bg-[#5FAE3B] rounded-full p-1 flex items-center justify-end">
                    <div className="w-4 h-4 rounded-full bg-white shadow-sm" />
                  </div>
                </div>
              </div>
            </div>

            {/* Live Haul Feed Preview */}
            <div className="lg:col-span-6 space-y-3">
              <div className="flex items-center justify-between px-1">
                <span className="text-xs font-bold text-[#13202B] dark:text-white uppercase tracking-wider">
                  {t.deliverySection.availableJobsTitle}
                </span>
                <span className="text-xs font-semibold text-[#FF8D20]">
                  {deliveryJobs.filter((j) => j.status === 'available').length} {t.deliverySection.jobsOpenNearby}
                </span>
              </div>

              {deliveryJobs.map((job) => (
                <div
                  key={job.id}
                  className="p-4 rounded-2xl bg-[#F4F7F5] dark:bg-[#10261B] border border-gray-200/80 dark:border-[#2B5A46] shadow-sm flex items-center justify-between gap-3"
                >
                  <div className="space-y-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-bold text-[#13202B] dark:text-white truncate">
                        {job.resourceTitle}
                      </span>
                      <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-emerald-100 dark:bg-emerald-950/60 text-[#1A4331] dark:text-[#5FAE3B] shrink-0">
                        {job.weightKg} kg
                      </span>
                    </div>

                    <div className="text-[11px] text-[#66737C] dark:text-[#AAB8B2]">
                      {t.deliverySection.pickupLabel} <strong className="text-[#13202B] dark:text-white">{job.pickupVillage}</strong> → {t.deliverySection.dropLabel} <strong className="text-[#13202B] dark:text-white">{job.dropVillage}</strong>
                    </div>

                    <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                      {t.deliverySection.routeLabel} {job.distanceKm} km
                    </div>
                  </div>

                  <div className="text-right shrink-0">
                    <div className="text-base font-extrabold text-[#5FAE3B]">
                      ₹{job.estimatedPay}
                    </div>
                    <span className="text-[10px] px-2 py-0.5 rounded-md bg-[#FF8D20]/15 text-[#FF8D20] font-bold">
                      {job.status === 'available' ? t.deliverySection.openJobBadge : job.status.replace('_', ' ')}
                    </span>
                  </div>
                </div>
              ))}
            </div>

          </div>
        </div>

        {/* Fairness Rules Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {t.deliverySection.fairnessRules.map((rule, idx) => (
            <div
              key={idx}
              className="p-5 rounded-2xl bg-[#F4F7F5] dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] space-y-2"
            >
              <div className="flex items-center gap-2 text-xs font-bold text-[#1A4331] dark:text-[#5FAE3B]">
                <ShieldCheck className="w-4 h-4 text-[#5FAE3B]" />
                <span>{rule.title}</span>
              </div>
              <p className="text-xs text-[#66737C] dark:text-[#AAB8B2] leading-relaxed">
                {rule.desc}
              </p>
            </div>
          ))}
        </div>

      </div>
    </section>
  );
};
