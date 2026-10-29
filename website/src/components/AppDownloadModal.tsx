import React from 'react';
import { Download, Info, ShieldCheck, X } from 'lucide-react';
import { useMarketplace } from '../context/MarketplaceContext';
import { appFlow } from '../i18n/appFlow';
import { APK_URL } from '../config';
import { CopyCodeButton } from './CopyCodeButton';

/**
 * "Buy in the app": the website takes no payment. It sends the person to the APK, shows the four steps and
 * the item code to paste into the app's search.
 */
export const AppDownloadModal: React.FC = () => {
  const { downloadListing, setDownloadListing, language } = useMarketplace();
  const text = appFlow[language].download;
  const flow = appFlow[language];

  if (!downloadListing) return null;
  const isSample = downloadListing.source === 'sample';

  return (
    <div className="fixed inset-0 z-[60] overflow-y-auto bg-black/60 backdrop-blur-sm flex items-center justify-center p-3 sm:p-4">
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="download-title"
        className="relative bg-white dark:bg-[#173425] rounded-3xl max-w-lg w-full border border-gray-200 dark:border-[#2B5A46] shadow-2xl overflow-hidden my-6"
      >
        <div className="relative bg-gradient-to-r from-[#1A4331] to-[#2D765C] p-5 text-white">
          <button
            type="button"
            onClick={() => setDownloadListing(null)}
            aria-label={text.close}
            className="absolute top-4 right-4 p-2 rounded-full bg-black/20 hover:bg-black/40 text-white transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
          <div className="flex items-center gap-3 pr-10">
            <img
              src="/logo-192.png"
              alt="VanMitra"
              width={40}
              height={40}
              className="w-8 h-8 sm:w-10 sm:h-10 rounded-full object-cover shrink-0"
            />
            <h2 id="download-title" className="text-xl font-bold font-['Manrope']">
              {text.title}
            </h2>
          </div>
          <p className="text-xs text-white/80 mt-1">{text.subtitle}</p>
        </div>

        <div className="p-5 space-y-4">
          <div className="p-3 rounded-2xl bg-gray-50 dark:bg-[#10261B] border border-gray-200 dark:border-[#2B5A46]">
            <div className="text-[11px] font-bold text-[#66737C] dark:text-[#AAB8B2] uppercase tracking-wider">
              {text.codeHeading}
            </div>
            <div className="mt-1 text-sm font-semibold text-[#13202B] dark:text-white truncate">{downloadListing.title}</div>
            <div className="mt-2 flex items-center justify-between gap-3">
              <code
                data-testid="download-item-code"
                className="text-xl font-extrabold tracking-widest text-[#1A4331] dark:text-[#5FAE3B]"
              >
                {downloadListing.itemCode}
              </code>
              <CopyCodeButton code={downloadListing.itemCode} />
            </div>
            {isSample && (
              <p className="mt-2 flex items-start gap-1.5 text-[11px] text-amber-800 dark:text-amber-200">
                <Info className="w-3.5 h-3.5 shrink-0 mt-0.5" />
                <span>
                  <strong>{flow.sampleBadge}.</strong> {text.sampleNote}
                </span>
              </p>
            )}
          </div>

          <ol className="space-y-2.5">
            {text.steps.map((step, i) => (
              <li key={i} className="flex items-start gap-3 text-sm text-[#13202B] dark:text-[#F4F7F5]">
                <span className="w-6 h-6 shrink-0 rounded-full bg-[#FF8D20] text-white text-xs font-extrabold flex items-center justify-center">
                  {i + 1}
                </span>
                <span className="pt-0.5">{step}</span>
              </li>
            ))}
          </ol>

          <a
            href={APK_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center justify-center gap-2 w-full bg-[#FF8D20] hover:bg-[#D96B00] text-white px-6 py-3 rounded-2xl text-sm font-bold shadow-lg shadow-orange-950/20 transition-all active:scale-95"
          >
            <Download className="w-4 h-4" />
            <span>{text.downloadBtn}</span>
          </a>

          <p className="flex items-start gap-1.5 text-[11px] text-[#66737C] dark:text-[#AAB8B2]">
            <ShieldCheck className="w-3.5 h-3.5 shrink-0 mt-0.5 text-[#5FAE3B]" />
            <span>{text.paymentNote}</span>
          </p>
        </div>
      </div>
    </div>
  );
};
