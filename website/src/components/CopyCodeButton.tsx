import React, { useState } from 'react';
import { Check, Copy } from 'lucide-react';
import { useMarketplace } from '../context/MarketplaceContext';
import { appFlow } from '../i18n/appFlow';

/** Copies an item code to the clipboard; falls back to selecting nothing when the browser blocks it. */
export async function copyText(text: string): Promise<boolean> {
  try {
    await navigator.clipboard.writeText(text);
    return true;
  } catch {
    try {
      const area = document.createElement('textarea');
      area.value = text;
      area.setAttribute('readonly', '');
      area.style.position = 'fixed';
      area.style.opacity = '0';
      document.body.appendChild(area);
      area.select();
      const ok = document.execCommand('copy');
      document.body.removeChild(area);
      return ok;
    } catch {
      return false;
    }
  }
}

export const CopyCodeButton: React.FC<{ code: string; className?: string }> = ({ code, className = '' }) => {
  const { language } = useMarketplace();
  const text = appFlow[language];
  const [copied, setCopied] = useState(false);

  const onClick = async (e: React.MouseEvent) => {
    e.stopPropagation(); // the card behind it opens the listing
    if (await copyText(code)) {
      setCopied(true);
      setTimeout(() => setCopied(false), 1800);
    }
  };

  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={`${text.copy} ${code}`}
      className={`inline-flex items-center gap-1 px-2 py-1 rounded-lg border border-gray-200 dark:border-[#2B5A46] text-[11px] font-bold text-[#1A4331] dark:text-[#5FAE3B] hover:bg-emerald-50 dark:hover:bg-[#10261B] cursor-pointer transition-colors ${className}`}
    >
      {copied ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />}
      <span>{copied ? text.copied : text.copy}</span>
    </button>
  );
};
