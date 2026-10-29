import React, { useState } from "react";
import { motion } from "framer-motion";
import { Leaf } from "lucide-react";
import { fadeUp, SectionHeader } from "./MotionPrimitives";

export interface ResourceItem {
  en: string;
  local: string;
  image?: string;
}

interface ResourceTileProps {
  plant: ResourceItem;
  index: number;
  reducedMotion: boolean;
}

const ResourceTile: React.FC<ResourceTileProps> = ({
  plant,
  index,
  reducedMotion,
}) => {
  const [imageMissing, setImageMissing] = useState<boolean>(!plant.image);

  const isOrange = index % 2 === 1;

  // Fallback to the leaf-icon tile for this item only if its image is missing
  if (imageMissing || !plant.image) {
    return (
      <motion.div
        {...fadeUp(index * 0.05, reducedMotion)}
        className={`w-[calc((100%-1rem)/2)] sm:w-[calc((100%-2rem)/3)] lg:w-[calc((100%-4rem)/5)] bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-5 flex items-center gap-3.5 transition-all duration-300 md:hover:-translate-y-[6px] ${
          isOrange ? "card-hover-orange" : "card-hover-green"
        }`}
      >
        <div
          className={`w-9 h-9 rounded-full flex items-center justify-center shrink-0 ${
            isOrange
              ? "bg-[var(--orange-soft)] border border-[var(--orange)]/35 text-[var(--orange)]"
              : "bg-[#3A5233] text-[#8DB85A]"
          }`}
        >
          <Leaf className="w-4 h-4" />
        </div>
        <div className="min-w-0">
          <div className="text-sm sm:text-base font-medium text-[#F4F7EA] truncate">
            {plant.en}
          </div>
          {plant.local && (
            <div className="text-xs text-[#D8B48A] font-devanagari mt-0.5">
              ({plant.local})
            </div>
          )}
        </div>
      </motion.div>
    );
  }

  return (
    <motion.div
      {...fadeUp(index * 0.05, reducedMotion)}
      className={`group w-[calc((100%-1rem)/2)] sm:w-[calc((100%-2rem)/3)] lg:w-[calc((100%-4rem)/5)] h-[225px] sm:h-[248px] bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] overflow-hidden flex flex-col transition-all duration-300 ease-out md:hover:-translate-y-[6px] ${
        isOrange ? "card-hover-orange" : "card-hover-green"
      }`}
    >
      {/* Top 65%: photo filling edge-to-edge */}
      <div className="h-[65%] w-full overflow-hidden rounded-t-[20px] bg-[#172213]/60">
        <img
          src={plant.image}
          alt={plant.en}
          loading="lazy"
          referrerPolicy="no-referrer"
          onError={() => setImageMissing(true)}
          className="w-full h-full object-cover transition-transform duration-300 ease-out md:group-hover:scale-[1.06]"
        />
      </div>

      {/* Bottom 35%: English name in medium weight + Marathi name small in tan */}
      <div className="h-[35%] px-4 py-2.5 flex flex-col justify-center">
        <div className="text-sm sm:text-base font-medium text-[#F4F7EA] leading-tight truncate">
          {plant.en}
        </div>
        {plant.local && (
          <div className="text-xs text-[#D8B48A] font-devanagari mt-1 truncate">
            {plant.local}
          </div>
        )}
      </div>
    </motion.div>
  );
};

export const ResourcesSection: React.FC<{
  resources: ResourceItem[];
  reducedMotion: boolean;
}> = ({ resources, reducedMotion }) => {
  return (
    <section
      id="resources"
      className="relative z-[10] max-w-6xl mx-auto px-5 sm:px-8 py-20 md:py-28 scroll-mt-20"
    >
      <SectionHeader
        label="FOREST PRODUCE"
        beforeItalic="Resources we "
        italicWord="cover"
        italicTone="orange"
        reducedMotion={reducedMotion}
      />

      {/* 5 cols on desktop with centred last row, 3 on tablet, 2 on phone */}
      <div className="flex flex-wrap justify-center gap-4">
        {resources.map((plant, idx) => (
          <ResourceTile
            key={plant.en}
            plant={plant}
            index={idx}
            reducedMotion={reducedMotion}
          />
        ))}
      </div>
    </section>
  );
};
