import React from 'react';

interface ResourceIconProps {
  type: string;
  className?: string;
}

export const ResourceIcon: React.FC<ResourceIconProps> = ({ type, className = 'w-6 h-6' }) => {
  switch (type) {
    case 'honey':
      return (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={className}>
          <path d="M12 2l3 3.5v3l-3 3.5-3-3.5v-3L12 2z" fill="#FF8D20" fillOpacity="0.2" stroke="#FF8D20" />
          <path d="M18 8l3 3.5v3l-3 3.5-3-3.5v-3L18 8z" fill="#FF8D20" fillOpacity="0.2" stroke="#FF8D20" />
          <path d="M6 8l3 3.5v3L6 18l-3-3.5v-3L6 8z" fill="#FF8D20" fillOpacity="0.2" stroke="#FF8D20" />
          <path d="M12 12l3 3.5v3l-3 3.5-3-3.5v-3L12 12z" fill="#FF8D20" fillOpacity="0.3" stroke="#FF8D20" />
        </svg>
      );
    case 'herbs':
      return (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={className}>
          <path d="M12 2a8 8 0 0 0-8 8c0 4.4 3.6 8 8 8 1 0 2-.2 3-.5" stroke="#2D765C" />
          <path d="M12 2c3.3 2 5.5 5.5 5.5 9.5 0 2.5-.9 4.8-2.5 6.5" stroke="#5FAE3B" />
          <path d="M12 2v20" stroke="#1A4331" />
          <path d="M12 14c-2.5-1-4-3-4-5" stroke="#2D765C" />
          <path d="M12 9c2.5-1 4-3 4-5" stroke="#5FAE3B" />
        </svg>
      );
    case 'bamboo':
      return (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={className}>
          <rect x="7" y="2" width="4" height="20" rx="1" stroke="#2D765C" fill="#2D765C" fillOpacity="0.1" />
          <rect x="13" y="2" width="4" height="20" rx="1" stroke="#5FAE3B" fill="#5FAE3B" fillOpacity="0.1" />
          <line x1="7" y1="8" x2="11" y2="8" stroke="#1A4331" />
          <line x1="7" y1="14" x2="11" y2="14" stroke="#1A4331" />
          <line x1="13" y1="9" x2="17" y2="9" stroke="#1A4331" />
          <line x1="13" y1="15" x2="17" y2="15" stroke="#1A4331" />
          <path d="M11 6c2-1 4-1 6-3" stroke="#5FAE3B" />
          <path d="M7 12c-2-1-4-1-6-3" stroke="#2D765C" />
        </svg>
      );
    case 'water':
      return (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={className}>
          <path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z" stroke="#2F5FB3" fill="#2F5FB3" fillOpacity="0.2" />
          <path d="M12 12a3 3 0 0 0 3 3" stroke="#2F5FB3" />
        </svg>
      );
    case 'lac':
    case 'gum':
      return (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={className}>
          <circle cx="12" cy="12" r="8" stroke="#D96B00" fill="#FF8D20" fillOpacity="0.2" />
          <path d="M12 6v4l3 3" stroke="#D96B00" />
          <circle cx="8" cy="15" r="2" fill="#D96B00" />
        </svg>
      );
    case 'seeds':
    default:
      return (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={className}>
          <path d="M12 2C7.5 2 4 6 4 11c0 5 4 11 8 11s8-6 8-11c0-5-3.5-9-8-9z" stroke="#2D765C" fill="#5FAE3B" fillOpacity="0.15" />
          <path d="M12 2v20" stroke="#2D765C" />
          <path d="M8 8c2 1 4 1 4 4" stroke="#2D765C" />
          <path d="M16 14c-2 1-4 1-4 4" stroke="#5FAE3B" />
        </svg>
      );
  }
};
