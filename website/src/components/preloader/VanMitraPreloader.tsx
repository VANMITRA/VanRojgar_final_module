import React, { useState, useEffect, useCallback, useRef } from 'react';

interface VanMitraPreloaderProps {
  onComplete?: () => void;
  isReplay?: boolean;
}

export const VanMitraPreloader: React.FC<VanMitraPreloaderProps> = ({ onComplete, isReplay = false }) => {
  const [phase, setPhase] = useState<'enter' | 'reveal' | 'orbit' | 'wordmark' | 'exit' | 'done'>('enter');
  const [isSkipping, setIsSkipping] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const mountTimeRef = useRef<number>(Date.now());

  // Check prefers-reduced-motion
  const isReducedMotion = useRef(
    typeof window !== 'undefined' &&
    window.matchMedia &&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches
  ).current;

  // Handle skip action immediately
  const handleSkip = useCallback(() => {
    // Guard against accidental click propagation from the replay trigger button
    if (Date.now() - mountTimeRef.current < 300) return;
    if (isSkipping || phase === 'exit' || phase === 'done') return;
    setIsSkipping(true);
    setPhase('exit');

    try {
      sessionStorage.setItem('vanmitra_intro_played', 'true');
    } catch {}

    const exitTimer = setTimeout(() => {
      setPhase('done');
      if (onComplete) onComplete();
    }, 350);

    return () => clearTimeout(exitTimer);
  }, [isSkipping, phase, onComplete]);

  // Lock body scroll while mounted
  useEffect(() => {
    const originalOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';

    return () => {
      document.body.style.overflow = originalOverflow;
    };
  }, []);

  // Keyboard shortcut listener (Enter, Space, Escape to skip)
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (['Enter', ' ', 'Escape'].includes(e.key)) {
        e.preventDefault();
        handleSkip();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleSkip]);

  // Animation timeline progression
  useEffect(() => {
    if (isReducedMotion) {
      // Reduced motion timeline: simple 0.6s fade-in, 0.8s hold, 0.4s fade-out
      const t1 = setTimeout(() => setPhase('wordmark'), 300);
      const t2 = setTimeout(() => setPhase('exit'), 1400);
      const t3 = setTimeout(() => {
        setPhase('done');
        try {
          sessionStorage.setItem('vanmitra_intro_played', 'true');
        } catch {}
        if (onComplete) onComplete();
      }, 1800);

      return () => {
        clearTimeout(t1);
        clearTimeout(t2);
        clearTimeout(t3);
      };
    }

    // Standard cinematic timeline (~4.2s total)
    // 0.0s - 0.4s: Initial background bloom & firefly drift (phase = 'enter')
    // 0.4s - 1.5s: Circular mask expansion of the mandala emblem
    const tReveal = setTimeout(() => {
      setPhase('reveal');
    }, 400);

    // 0.8s - 2.6s: Concentric orbit rings draw around medallion + traveling gold node
    const tOrbit = setTimeout(() => {
      setPhase('orbit');
    }, 850);

    // 2.6s - 3.6s: Wordmark wipe & subtext reveal
    const tWordmark = setTimeout(() => {
      setPhase('wordmark');
    }, 2600);

    // 3.6s - 4.2s: Smooth dissolve exit & scale-up
    const tExit = setTimeout(() => {
      setPhase('exit');
    }, 3650);

    // 4.2s: Unmount and clean up completely
    const tDone = setTimeout(() => {
      setPhase('done');
      try {
        sessionStorage.setItem('vanmitra_intro_played', 'true');
      } catch {}
      if (onComplete) onComplete();
    }, 4200);

    return () => {
      clearTimeout(tReveal);
      clearTimeout(tOrbit);
      clearTimeout(tWordmark);
      clearTimeout(tExit);
      clearTimeout(tDone);
    };
  }, [isReducedMotion, onComplete]);

  // Unmount when completed
  if (phase === 'done') {
    return null;
  }

  // 16 curated drifting particle coordinates (gold & emerald embers)
  const particles = [
    { x: -140, y: -160, size: 3.5, color: '#C99A2E', delay: 0, dur: 3.2 },
    { x: 130, y: -180, size: 4, color: '#2D765C', delay: 0.1, dur: 3.5 },
    { x: -190, y: -40, size: 3, color: '#5FAE3B', delay: 0.2, dur: 3.0 },
    { x: 200, y: -60, size: 3.5, color: '#C99A2E', delay: 0.15, dur: 3.4 },
    { x: -160, y: 120, size: 4, color: '#C99A2E', delay: 0.05, dur: 3.1 },
    { x: 170, y: 140, size: 3, color: '#2D765C', delay: 0.25, dur: 3.6 },
    { x: -70, y: -220, size: 2.5, color: '#5FAE3B', delay: 0.3, dur: 2.9 },
    { x: 80, y: -210, size: 3, color: '#C99A2E', delay: 0.18, dur: 3.3 },
    { x: -210, y: 40, size: 3.5, color: '#2D765C', delay: 0.12, dur: 3.7 },
    { x: 220, y: 60, size: 3, color: '#C99A2E', delay: 0.22, dur: 3.2 },
    { x: -110, y: 190, size: 3, color: '#5FAE3B', delay: 0.28, dur: 3.0 },
    { x: 100, y: 200, size: 4, color: '#C99A2E', delay: 0.08, dur: 3.4 },
    { x: -40, y: -140, size: 2.5, color: '#C99A2E', delay: 0.14, dur: 3.2 },
    { x: 50, y: -150, size: 3, color: '#2D765C', delay: 0.26, dur: 3.1 },
    { x: -130, y: -90, size: 3.5, color: '#5FAE3B', delay: 0.19, dur: 3.5 },
    { x: 140, y: -80, size: 3, color: '#C99A2E', delay: 0.07, dur: 3.3 },
  ];

  return (
    <div
      ref={containerRef}
      role="status"
      aria-label="Loading VanMitra"
      onClick={handleSkip}
      className={`fixed inset-0 z-[9999] flex flex-col items-center justify-center select-none overflow-hidden cursor-pointer transition-opacity duration-500 ease-out ${
        phase === 'exit' ? 'opacity-0 pointer-events-none' : 'opacity-100'
      }`}
      style={{
        backgroundColor: '#0C1B14',
      }}
    >
      <style>{`
        @keyframes vm-pulse-glow {
          0%, 100% { transform: scale(1); opacity: 0.4; }
          50% { transform: scale(1.15); opacity: 0.7; }
        }

        @keyframes vm-orbit-rotate {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }

        @keyframes vm-orbit-reverse {
          from { transform: rotate(360deg); }
          to { transform: rotate(0deg); }
        }

        @keyframes vm-light-sweep {
          0% { transform: translateX(-150%) rotate(25deg); opacity: 0; }
          40% { opacity: 0.6; }
          100% { transform: translateX(250%) rotate(25deg); opacity: 0; }
        }

        @keyframes vm-drift-particle {
          0% {
            opacity: 0;
            transform: translate(var(--px), var(--py)) scale(0.6);
          }
          30% {
            opacity: 0.9;
          }
          80% {
            opacity: 0.8;
          }
          100% {
            opacity: 0;
            transform: translate(calc(var(--px) * 0.2), calc(var(--py) * 0.2)) scale(1);
          }
        }

        @keyframes vm-wipe-reveal {
          0% {
            clip-path: inset(0 100% 0 0);
            opacity: 0;
            transform: translateY(6px);
          }
          100% {
            clip-path: inset(0 0% 0 0);
            opacity: 1;
            transform: translateY(0);
          }
        }
      `}</style>

      {/* Atmospheric Background with soft radial light bloom in lower-left */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background: `
            radial-gradient(circle at 25% 75%, rgba(45, 118, 92, 0.25) 0%, transparent 55%),
            radial-gradient(circle at 75% 25%, rgba(201, 154, 46, 0.12) 0%, transparent 45%),
            radial-gradient(circle at 50% 50%, rgba(26, 67, 49, 0.45) 0%, #0C1B14 70%)
          `,
        }}
      />

      {/* Soft central bloom behind the emblem */}
      <div
        className="absolute rounded-full pointer-events-none transition-opacity duration-1000"
        style={{
          width: 'clamp(300px, 75vw, 600px)',
          height: 'clamp(300px, 75vw, 600px)',
          background: 'radial-gradient(circle, rgba(45, 118, 92, 0.35) 0%, rgba(201, 154, 46, 0.12) 40%, transparent 70%)',
          animation: isReducedMotion ? 'none' : 'vm-pulse-glow 5s ease-in-out infinite',
        }}
      />

      {/* Drifting Embers / Fireflies (capped at 16 points, strictly non-invasive) */}
      {!isReducedMotion && phase !== 'exit' && (
        <div className="absolute inset-0 pointer-events-none flex items-center justify-center">
          {particles.map((p, idx) => (
            <div
              key={idx}
              className="absolute rounded-full"
              style={{
                width: `${p.size}px`,
                height: `${p.size}px`,
                backgroundColor: p.color,
                boxShadow: `0 0 8px ${p.color}`,
                '--px': `${p.x}px`,
                '--py': `${p.y}px`,
                animation: `vm-drift-particle ${p.dur}s ease-in-out ${p.delay}s infinite`,
              } as React.CSSProperties}
            />
          ))}
        </div>
      )}

      {/* Main Focal Unit (Medallion + Orbit Rings) */}
      <div className="relative flex flex-col items-center justify-center z-10 px-4">
        
        {/* Emblem & SVG Orbit Rings Wrapper */}
        <div
          className="relative flex items-center justify-center transition-transform duration-700 ease-out"
          style={{
            width: 'clamp(240px, min(62vw, 62vh), 440px)',
            height: 'clamp(240px, min(62vw, 62vh), 440px)',
            transform: phase === 'exit' ? 'scale(1.03)' : 'scale(1)',
          }}
        >
          {/* SVG Orbit Rings (replacing generic globe rings) */}
          {!isReducedMotion && (
            <svg
              className="absolute inset-[-14%] w-[128%] h-[128%] pointer-events-none overflow-visible"
              viewBox="0 0 500 500"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <defs>
                <linearGradient id="orbitGold" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" stopColor="#C99A2E" stopOpacity="0.65" />
                  <stop offset="50%" stopColor="#C99A2E" stopOpacity="0.2" />
                  <stop offset="100%" stopColor="#C99A2E" stopOpacity="0.75" />
                </linearGradient>
                <linearGradient id="orbitEmerald" x1="100%" y1="0%" x2="0%" y2="100%">
                  <stop offset="0%" stopColor="#2D765C" stopOpacity="0.5" />
                  <stop offset="60%" stopColor="#5FAE3B" stopOpacity="0.2" />
                  <stop offset="100%" stopColor="#2D765C" stopOpacity="0.6" />
                </linearGradient>
              </defs>

              {/* Inner Orbit Ring (Gold) - Drawn smoothly with stroke-dashoffset */}
              <circle
                cx="250"
                cy="250"
                r="220"
                stroke="url(#orbitGold)"
                strokeWidth="1.2"
                strokeDasharray="1382"
                strokeDashoffset={
                  phase === 'enter' ? 1382 : phase === 'reveal' ? 700 : 0
                }
                style={{
                  transition: 'stroke-dashoffset 1.8s cubic-bezier(0.25, 1, 0.5, 1), opacity 0.8s ease',
                  opacity: phase === 'enter' ? 0 : 0.85,
                }}
              />

              {/* Outer Orbit Ring (Emerald) */}
              <circle
                cx="250"
                cy="250"
                r="238"
                stroke="url(#orbitEmerald)"
                strokeWidth="1"
                strokeDasharray="1495"
                strokeDashoffset={
                  phase === 'enter' ? 1495 : phase === 'reveal' ? 900 : 0
                }
                style={{
                  transition: 'stroke-dashoffset 2.2s cubic-bezier(0.25, 1, 0.5, 1), opacity 0.8s ease',
                  opacity: phase === 'enter' ? 0 : 0.6,
                }}
              />

              {/* Orbiting Gold Node (Traveling along the inner ring - strictly only gold) */}
              {phase !== 'enter' && (
                <g
                  style={{
                    transformOrigin: '250px 250px',
                    animation: 'vm-orbit-rotate 9s linear infinite',
                  }}
                >
                  <circle
                    cx="470"
                    cy="250"
                    r="3.5"
                    fill="#C99A2E"
                    style={{
                      filter: 'drop-shadow(0 0 6px rgba(201, 154, 46, 0.9))',
                    }}
                  />
                  {/* Subtle faint trail behind traveling node */}
                  <circle
                    cx="468"
                    cy="242"
                    r="2"
                    fill="#C99A2E"
                    opacity="0.5"
                  />
                </g>
              )}
            </svg>
          )}

          {/* The Circular Ivory Medallion Frame */}
          <div
            className="relative w-full h-full rounded-full transition-all duration-1000 ease-out flex items-center justify-center"
            style={{
              clipPath:
                isReducedMotion || phase !== 'enter'
                  ? 'circle(49.2% at 50% 50%)'
                  : 'circle(0% at 50% 50%)',
              opacity: phase === 'enter' ? 0 : 1,
              transform:
                phase === 'enter'
                  ? 'scale(0.92)'
                  : phase === 'exit'
                  ? 'scale(1.03)'
                  : 'scale(1)',
              boxShadow:
                '0 0 45px rgba(45, 118, 92, 0.35), 0 0 25px rgba(201, 154, 46, 0.25), inset 0 0 0 1px rgba(201, 154, 46, 0.4)',
              backgroundColor: '#FFFFFF',
            }}
          >
            {/* The Untouched Real VanMitra Tribal Logo */}
            <img
              src="/brand/vanmitra-logo-original.jpg"
              alt="VanMitra Logo Emblem"
              decoding="async"
              className="w-full h-full object-contain pointer-events-none"
              style={{
                imageRendering: 'auto',
              }}
            />

            {/* Warm Diagonal Light Sweep (single elegant pass across logo artwork) */}
            {!isReducedMotion && (phase === 'reveal' || phase === 'orbit' || phase === 'wordmark') && (
              <div
                className="absolute inset-0 pointer-events-none rounded-full overflow-hidden"
              >
                <div
                  className="w-[60%] h-[200%] absolute top-[-50%] left-0"
                  style={{
                    background: 'linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.32), transparent)',
                    animation: 'vm-light-sweep 2.4s cubic-bezier(0.4, 0, 0.2, 1) 0.6s 1 forwards',
                  }}
                />
              </div>
            )}
          </div>
        </div>

        {/* Wordmark Reveal (Masked wipe left-to-right) */}
        <div
          className="mt-6 text-center transition-all duration-700 ease-out"
          style={{
            opacity: phase === 'wordmark' || phase === 'exit' ? 1 : 0,
            animation:
              (phase === 'wordmark' || phase === 'exit') && !isReducedMotion
                ? 'vm-wipe-reveal 0.85s cubic-bezier(0.16, 1, 0.3, 1) forwards'
                : 'none',
          }}
        >
          {/* Main Brand Title */}
          <h1
            className="text-2xl sm:text-3xl md:text-4xl font-extrabold tracking-[0.16em] text-white uppercase font-['Manrope']"
            style={{
              textShadow: '0 2px 10px rgba(0,0,0,0.6), 0 0 20px rgba(45,118,92,0.4)',
            }}
          >
            VanMitra
          </h1>

          {/* Subtitle Ecosystem Line */}
          <p className="mt-1.5 text-xs sm:text-sm font-semibold text-[#AAB8B2] tracking-wider font-['Manrope']">
            <span className="text-[#FF8D20] font-bold">VanMitra</span>
            <span className="mx-2 text-white/30">•</span>
            <span>Trade resources. Create livelihoods.</span>
          </p>
        </div>

      </div>

      {/* Unobtrusive "Skip Intro" Affordance */}
      <div className="absolute bottom-6 sm:bottom-8 left-0 right-0 flex justify-center z-20 pointer-events-auto">
        <button
          type="button"
          onClick={(e) => {
            e.stopPropagation();
            handleSkip();
          }}
          className="text-[11px] font-semibold text-white/50 hover:text-white transition-all tracking-widest uppercase py-1.5 px-4 rounded-full border border-white/10 hover:border-white/30 bg-black/20 hover:bg-black/40 backdrop-blur-xs flex items-center gap-1.5 focus:outline-none focus:ring-1 focus:ring-[#FF8D20]"
        >
          <span>Skip</span>
          <span className="text-[9px] text-white/40">ESC</span>
        </button>
      </div>
    </div>
  );
};
