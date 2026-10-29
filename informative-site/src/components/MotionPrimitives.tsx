import React, { useEffect, useId, useRef, useState } from "react";
import { motion, useInView } from "framer-motion";

export function fadeUp(delay = 0, reducedMotion = false) {
  if (reducedMotion) {
    return {
      initial: { opacity: 1, y: 0 },
      whileInView: { opacity: 1, y: 0 },
      viewport: { once: true },
    };
  }
  return {
    initial: { opacity: 0, y: 24 },
    whileInView: { opacity: 1, y: 0 },
    viewport: { once: true, margin: "-100px" },
    transition: { duration: 0.6, delay, ease: "easeOut" as const },
  };
}

interface CountUpProps {
  target: number;
  decimals?: number;
  prefix?: string;
  suffix?: string;
  reducedMotion?: boolean;
  durationMs?: number;
}

export const CountUp: React.FC<CountUpProps> = ({
  target,
  decimals = 0,
  prefix = "",
  suffix = "",
  reducedMotion = false,
  durationMs = 1500,
}) => {
  const ref = useRef<HTMLSpanElement | null>(null);
  const inView = useInView(ref, { once: true, margin: "-60px" });
  const [displayValue, setDisplayValue] = useState<number>(reducedMotion ? target : 0);

  useEffect(() => {
    if (reducedMotion) {
      setDisplayValue(target);
      return;
    }
    if (!inView) return;

    let frameId = 0;
    const startTime = performance.now();

    const tick = (now: number) => {
      const elapsed = now - startTime;
      const progress = Math.min(1, elapsed / durationMs);
      const eased = 1 - Math.pow(1 - progress, 3);
      setDisplayValue(target * eased);
      if (progress < 1) {
        frameId = requestAnimationFrame(tick);
      } else {
        setDisplayValue(target);
      }
    };

    frameId = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(frameId);
  }, [inView, target, durationMs, reducedMotion]);

  const formatted =
    decimals > 0
      ? displayValue.toFixed(decimals)
      : Math.round(displayValue).toLocaleString("en-US");

  return (
    <span ref={ref} className="tabular-nums">
      {prefix}
      {formatted}
      {suffix}
    </span>
  );
};

interface SectionHeaderProps {
  label: string;
  beforeItalic: string;
  italicWord: string;
  afterItalic?: string;
  subtitle?: string;
  centered?: boolean;
  reducedMotion?: boolean;
  italicTone?: "cream" | "orange";
}

export const SectionHeader: React.FC<SectionHeaderProps> = ({
  label,
  beforeItalic,
  italicWord,
  afterItalic = "",
  subtitle,
  centered = false,
  reducedMotion = false,
  italicTone = "cream",
}) => {
  return (
    <div className={centered ? "text-center max-w-3xl mx-auto mb-12 md:mb-16" : "max-w-3xl mb-12 md:mb-16"}>
      <motion.p
        {...fadeUp(0, reducedMotion)}
        className="text-xs uppercase tracking-[3px] text-[var(--orange)] font-medium mb-4"
      >
        {label}
      </motion.p>
      <motion.h2
        {...fadeUp(0.06, reducedMotion)}
        className="text-4xl sm:text-5xl md:text-6xl font-medium tracking-[-1px] text-[#F4F7EA] leading-[1.08] text-balance"
      >
        {beforeItalic}
        <span
          className={`font-serif-accent font-normal pr-[0.06em] ${
            italicTone === "orange" ? "text-[var(--orange)]" : "text-[#F4F7EA]"
          }`}
        >
          {italicWord}
        </span>
        {afterItalic}
      </motion.h2>
      {subtitle && (
        <motion.p
          {...fadeUp(0.12, reducedMotion)}
          className={`mt-5 text-base sm:text-lg text-[#A9B49A] leading-relaxed ${
            centered ? "mx-auto max-w-2xl" : "max-w-2xl"
          }`}
        >
          {subtitle}
        </motion.p>
      )}
    </div>
  );
};

export const OrganicDivider: React.FC<{ flip?: boolean }> = ({ flip = false }) => {
  const gradId = useId();

  return (
    <div
      aria-hidden="true"
      className="w-full max-w-6xl mx-auto px-6 py-4 opacity-75 pointer-events-none select-none"
    >
      <svg
        viewBox="0 0 1200 28"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className={`w-full h-5 ${flip ? "scale-x-[-1]" : ""}`}
        preserveAspectRatio="none"
      >
        <path
          d="M0 14C180 4 340 24 560 14C780 4 980 22 1200 12"
          stroke={`url(#${gradId})`}
          strokeWidth="1"
        />
        <defs>
          <linearGradient id={gradId} x1="0" y1="14" x2="1200" y2="14" gradientUnits="userSpaceOnUse">
            <stop offset="0%" stopColor="#8DB85A" stopOpacity="0" />
            <stop offset="35%" stopColor="#8DB85A" stopOpacity="0.65" />
            <stop offset="65%" stopColor="#F0A15A" stopOpacity="0.65" />
            <stop offset="100%" stopColor="#F0A15A" stopOpacity="0" />
          </linearGradient>
        </defs>
      </svg>
    </div>
  );
};
