import React from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { CheckCircle2, AlertTriangle, Info, XCircle, X } from 'lucide-react';

export const ToastContainer: React.FC = () => {
  const { toasts, dismissToast } = useMarketplace();

  if (toasts.length === 0) return null;

  return (
    <div className="fixed bottom-5 right-5 z-50 flex flex-col gap-2 max-w-sm w-full pointer-events-none px-4 sm:px-0">
      {toasts.map((toast) => {
        let icon = <Info className="w-5 h-5 text-[#2F5FB3] shrink-0" />;
        let borderClass = 'border-[#2F5FB3]/40';

        if (toast.type === 'success') {
          icon = <CheckCircle2 className="w-5 h-5 text-[#5FAE3B] shrink-0" />;
          borderClass = 'border-[#5FAE3B]/50';
        } else if (toast.type === 'warning') {
          icon = <AlertTriangle className="w-5 h-5 text-[#F0B323] shrink-0" />;
          borderClass = 'border-[#F0B323]/50';
        } else if (toast.type === 'error') {
          icon = <XCircle className="w-5 h-5 text-[#D7262E] shrink-0" />;
          borderClass = 'border-[#D7262E]/50';
        }

        return (
          <div
            key={toast.id}
            role="status"
            className={`pointer-events-auto flex items-start gap-3 p-3.5 rounded-xl bg-white dark:bg-[#173425] border ${borderClass} shadow-xl text-left transition-all`}
          >
            {icon}
            <div className="flex-1 min-w-0">
              <h4 className="text-xs font-bold text-[#13202B] dark:text-[#F4F7F5] truncate">
                {toast.title}
              </h4>
              <p className="text-[11px] text-[#66737C] dark:text-[#AAB8B2] mt-0.5 leading-snug">
                {toast.message}
              </p>
            </div>
            <button
              onClick={() => dismissToast(toast.id)}
              aria-label="Dismiss notification"
              className="text-[#66737C] hover:text-[#13202B] dark:hover:text-[#F4F7F5] p-1 -mr-1"
            >
              <X className="w-3.5 h-3.5" />
            </button>
          </div>
        );
      })}
    </div>
  );
};
