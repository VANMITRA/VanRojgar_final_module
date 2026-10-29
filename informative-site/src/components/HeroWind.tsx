import React, { useEffect, useMemo, useRef, useState } from "react";

interface LeafParticle {
  id: number;
  size: number;
  color: string;
  yBasePct: number;
  xProgress: number;
  baseSpeed: number;
  wobbleAmp: number;
  wobbleFreq: number;
  phase: number;
  rotation: number;
  rotSpeed: number;
  variant: number;
  opacity: number;
}

interface Firefly {
  id: number;
  leftPct: number;
  topPct: number;
  size: number;
  duration: number;
  delay: number;
  color: string;
}

const LEAF_PATHS = [
  "M2 14C6 4 16 2 26 6C22 16 12 20 2 14Z",
  "M3 12C8 3 19 3 27 11C19 19 8 19 3 12Z",
  "M2 16C7 6 15 2 26 4C23 14 15 20 2 16Z",
];

function createLeaves(count: number): LeafParticle[] {
  const palette = [
    "#8DB85A",
    "#5E8F3A",
    "#F0A15A",
    "#8DB85A",
    "#6FA046",
    "#D8B48A",
    "#8DB85A",
    "#5E8F3A",
    "#F0A15A",
    "#8DB85A",
  ];

  return Array.from({ length: count }, (_, idx) => {
    // Deterministic pseudo-random distribution so mount is smooth and consistent
    const seed1 = ((idx * 37 + 13) % 100) / 100;
    const seed2 = ((idx * 61 + 29) % 100) / 100;
    const seed3 = ((idx * 83 + 7) % 100) / 100;

    return {
      id: idx,
      size: Math.round(10 + seed1 * 18), // 10px to 28px
      color: palette[idx % palette.length],
      yBasePct: 12 + seed2 * 74,
      xProgress: seed3 * 116 - 8, // spread across hero at start, always moving left -> right
      baseSpeed: 4.2 + seed1 * 4.6, // % width per second
      wobbleAmp: 12 + seed2 * 22,
      wobbleFreq: 1.1 + seed3 * 1.4,
      phase: seed1 * Math.PI * 2,
      rotation: seed2 * 360,
      rotSpeed: 18 + seed3 * 36,
      variant: idx % LEAF_PATHS.length,
      opacity: 0.48 + seed2 * 0.4,
    };
  });
}

const FIREFLIES: Firefly[] = Array.from({ length: 14 }, (_, idx) => {
  const s1 = ((idx * 43 + 17) % 100) / 100;
  const s2 = ((idx * 71 + 31) % 100) / 100;
  return {
    id: idx,
    leftPct: 10 + s1 * 80,
    topPct: 38 + s2 * 52,
    size: idx % 3 === 0 ? 4 : 3,
    duration: 2.8 + (idx % 4) * 0.9,
    delay: (idx * 0.45) % 3.5,
    color: idx % 4 === 0 ? "#F0A15A" : "#D8B48A",
  };
});

export const HeroWind: React.FC<{ reducedMotion: boolean }> = ({ reducedMotion }) => {
  const [isMobile, setIsMobile] = useState<boolean>(false);
  const leafRefs = useRef<(HTMLDivElement | null)[]>([]);

  useEffect(() => {
    const check = () => setIsMobile(window.innerWidth < 768);
    check();
    window.addEventListener("resize", check, { passive: true });
    return () => window.removeEventListener("resize", check);
  }, []);

  const leafCount = isMobile ? 10 : 24;
  const leaves = useMemo(() => createLeaves(leafCount), [leafCount]);

  useEffect(() => {
    if (reducedMotion) return;

    const state = leaves.map((leaf) => ({ ...leaf }));
    let lastTime = performance.now();
    let rafId = 0;

    const animate = (now: number) => {
      const dt = Math.min(0.05, (now - lastTime) / 1000);
      lastTime = now;

      // Every 8 seconds, a stronger gust speeds all leaves up for 2 seconds
      const cycleSec = (now / 1000) % 8;
      let gustMultiplier = 1;
      if (cycleSec >= 6) {
        const gustPhase = (cycleSec - 6) / 2; // 0..1 across 2 seconds
        gustMultiplier = 1 + Math.sin(gustPhase * Math.PI) * 1.95;
      }

      for (let i = 0; i < state.length; i++) {
        const p = state[i];
        p.xProgress += p.baseSpeed * gustMultiplier * dt;
        if (p.xProgress > 108) {
          p.xProgress = -8;
        }
        p.phase += p.wobbleFreq * (0.85 + gustMultiplier * 0.25) * dt;
        p.rotation = (p.rotation + p.rotSpeed * gustMultiplier * dt) % 360;

        const el = leafRefs.current[i];
        if (el) {
          const yOffset = Math.sin(p.phase) * p.wobbleAmp;
          el.style.transform = `translate3d(${p.xProgress}vw, ${yOffset}px, 0) rotate(${p.rotation}deg)`;
        }
      }

      rafId = requestAnimationFrame(animate);
    };

    rafId = requestAnimationFrame(animate);
    return () => cancelAnimationFrame(rafId);
  }, [leaves, reducedMotion]);

  if (reducedMotion) {
    return null;
  }

  return (
    <div
      aria-hidden="true"
      className="pointer-events-none absolute inset-0 z-[4] overflow-hidden"
    >
      {/* 14 twinkling fireflies */}
      {FIREFLIES.map((f) => (
        <span
          key={f.id}
          className="absolute rounded-full animate-pulse"
          style={{
            left: `${f.leftPct}%`,
            top: `${f.topPct}%`,
            width: `${f.size}px`,
            height: `${f.size}px`,
            backgroundColor: f.color,
            boxShadow: `0 0 10px 2px ${f.color}`,
            animationDuration: `${f.duration}s`,
            animationDelay: `${f.delay}s`,
            opacity: 0.72,
          }}
        />
      ))}

      {/* Wind-drifting inline SVG leaves */}
      {leaves.map((leaf, i) => (
        <div
          key={leaf.id}
          ref={(el) => {
            leafRefs.current[i] = el;
          }}
          className="absolute left-0 will-change-transform"
          style={{
            top: `${leaf.yBasePct}%`,
            width: `${leaf.size}px`,
            height: `${leaf.size * 0.72}px`,
            opacity: leaf.opacity,
            transform: `translate3d(${leaf.xProgress}vw, 0px, 0) rotate(${leaf.rotation}deg)`,
          }}
        >
          <svg
            viewBox="0 0 28 20"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            className="w-full h-full"
          >
            <path d={LEAF_PATHS[leaf.variant]} fill={leaf.color} />
            <path
              d="M4 13C11 10 18 9 24 7"
              stroke="#172213"
              strokeOpacity="0.32"
              strokeWidth="1"
              strokeLinecap="round"
            />
          </svg>
        </div>
      ))}
    </div>
  );
};
