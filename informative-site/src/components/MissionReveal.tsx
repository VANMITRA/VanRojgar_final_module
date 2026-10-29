import React, { useRef } from "react";
import { motion, useScroll, useTransform, MotionValue } from "framer-motion";

interface WordItemProps {
  word: string;
  isHighlighted: boolean;
  progress: MotionValue<number>;
  range: [number, number];
  reducedMotion: boolean;
}

const WordItem: React.FC<WordItemProps> = ({
  word,
  isHighlighted,
  progress,
  range,
  reducedMotion,
}) => {
  const opacity = useTransform(progress, range, [0.15, 1]);

  return (
    <motion.span
      style={{ opacity: reducedMotion ? 1 : opacity }}
      className={`inline-block mr-[0.28em] transition-colors ${
        isHighlighted
          ? "text-[#F4F7EA] font-serif-accent font-normal text-[1.08em]"
          : "text-[#A9B49A]"
      }`}
    >
      {word}
    </motion.span>
  );
};

interface MissionRevealProps {
  text: string;
  highlightedWords: string[];
  reducedMotion: boolean;
}

export const MissionReveal: React.FC<MissionRevealProps> = ({
  text,
  highlightedWords,
  reducedMotion,
}) => {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start 82%", "end 42%"],
  });

  const words = text.split(" ");
  const highlightSet = new Set(highlightedWords.map((w) => w.toLowerCase()));

  return (
    <section
      ref={containerRef}
      aria-label="Mission"
      className="relative z-[10] max-w-5xl mx-auto px-5 sm:px-8 py-20 md:py-32"
    >
      <p className="text-xs uppercase tracking-[3px] text-[var(--orange)] font-medium mb-6 text-center">
        OUR MISSION
      </p>
      <p className="text-2xl sm:text-4xl md:text-5xl font-medium tracking-[-0.8px] leading-[1.32] text-center max-w-4xl mx-auto">
        {words.map((rawWord, idx) => {
          const clean = rawWord.replace(/[.,:;!?]/g, "").toLowerCase();
          const isHighlighted = highlightSet.has(clean);
          const start = idx / words.length;
          const end = Math.min(1, start + 1.6 / words.length);
          return (
            <WordItem
              key={`${rawWord}-${idx}`}
              word={rawWord}
              isHighlighted={isHighlighted}
              progress={scrollYProgress}
              range={[start, end]}
              reducedMotion={reducedMotion}
            />
          );
        })}
      </p>
    </section>
  );
};
