import React, { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import { ShieldCheck, Scale, Lock, FileCheck2 } from "lucide-react";
import { fadeUp, SectionHeader } from "./MotionPrimitives";

export interface TimelineStep {
  step: number;
  title: string;
  detail: string;
}

export interface SafeguardItem {
  title: string;
  detail: string;
}

interface TimelineSectionProps {
  steps: TimelineStep[];
  safeguards: SafeguardItem[];
  reducedMotion: boolean;
}

const SAFEGUARD_ICONS = [ShieldCheck, Scale, Lock, FileCheck2];

export const TimelineSection: React.FC<TimelineSectionProps> = ({
  steps,
  safeguards,
  reducedMotion,
}) => {
  const timelineRef = useRef<HTMLDivElement | null>(null);
  const { scrollYProgress } = useScroll({
    target: timelineRef,
    offset: ["start 75%", "end 60%"],
  });

  const scaleY = useTransform(scrollYProgress, [0, 1], [0, 1]);

  return (
    <section
      id="how-it-works"
      className="relative z-[10] max-w-6xl mx-auto px-5 sm:px-8 py-20 md:py-28 scroll-mt-20"
    >
      <SectionHeader
        label="HOW IT WORKS"
        beforeItalic="From listing to "
        italicWord="delivery"
        italicTone="orange"
        centered
        reducedMotion={reducedMotion}
      />

      {/* 8-step vertical timeline with self-drawing line */}
      <div ref={timelineRef} className="relative max-w-3xl mx-auto pl-10 sm:pl-14">
        {/* Background track */}
        <div
          aria-hidden="true"
          className="absolute left-[15px] sm:left-[21px] top-3 bottom-3 w-[2px] bg-[#3C4E38]/70 rounded-full"
        />
        {/* Drawing progress track (green to orange) */}
        <motion.div
          aria-hidden="true"
          style={{ scaleY: reducedMotion ? 1 : scaleY }}
          className="absolute left-[15px] sm:left-[21px] top-3 bottom-3 w-[2px] bg-gradient-to-b from-[#8DB85A] via-[#C3AE5A] to-[var(--orange)] origin-top rounded-full"
        />

        <div className="space-y-6">
          {steps.map((item, idx) => (
            <motion.div
              key={item.step}
              {...fadeUp(idx * 0.06, reducedMotion)}
              className={`relative bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-5 sm:p-6 ${
                idx % 2 === 1 ? "card-hover-orange" : "card-hover-green"
              }`}
            >
              {/* Node marker aligned with the vertical line */}
              <div
                aria-hidden="true"
                className="absolute -left-[33px] sm:-left-[41px] top-6 w-5 h-5 rounded-full bg-[#172213] border-2 border-[#8DB85A] flex items-center justify-center"
              >
                <span className="w-2 h-2 rounded-full bg-[#8DB85A]" />
              </div>

              <div className="flex flex-wrap items-center gap-3">
                <span className="w-7 h-7 rounded-full bg-[var(--orange)] text-[#1C2619] text-xs font-semibold inline-flex items-center justify-center shrink-0 tabular-nums">
                  {item.step}
                </span>
                <h3 className="text-lg sm:text-xl font-medium text-[#F4F7EA]">
                  {item.title}
                </h3>
              </div>
              <p className="mt-2 text-sm sm:text-base text-[#E9EFDC]/90 leading-relaxed">
                {item.detail}
              </p>
            </motion.div>
          ))}
        </div>
      </div>

      {/* 4 Safeguards built in */}
      <div className="mt-20">
        <motion.h3
          {...fadeUp(0, reducedMotion)}
          className="text-2xl sm:text-3xl font-medium text-[#F4F7EA] tracking-[-0.5px] mb-8 text-center"
        >
          Safeguards built in
        </motion.h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
          {safeguards.map((card, idx) => {
            const Icon = SAFEGUARD_ICONS[idx % SAFEGUARD_ICONS.length];
            const isOrange = idx % 2 === 1;
            return (
              <motion.div
                key={card.title}
                {...fadeUp(idx * 0.08, reducedMotion)}
                className={`bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-6 flex flex-col ${
                  isOrange ? "card-hover-orange" : "card-hover-green"
                }`}
              >
                <div
                  className={`w-10 h-10 rounded-full flex items-center justify-center mb-4 ${
                    isOrange
                      ? "bg-[var(--orange-soft)] border border-[var(--orange)]/35 text-[var(--orange)]"
                      : "bg-[#3A5233] border border-[#3C4E38] text-[#8DB85A]"
                  }`}
                >
                  <Icon className="w-5 h-5" />
                </div>
                <h4 className="text-lg font-medium text-[#F4F7EA] mb-2">
                  {card.title}
                </h4>
                <p className="text-sm text-[#A9B49A] leading-relaxed">
                  {card.detail}
                </p>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
};
