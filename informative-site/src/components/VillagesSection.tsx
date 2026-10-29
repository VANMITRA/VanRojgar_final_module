import React, { useCallback, useEffect, useId, useRef, useState } from "react";
import { createPortal } from "react-dom";
import {
  AnimatePresence,
  motion,
  MotionValue,
  useScroll,
  useTransform,
} from "framer-motion";
import { Check, ChevronLeft, ChevronRight, X } from "lucide-react";
import { fadeUp, SectionHeader } from "./MotionPrimitives";

export interface VillagePhotoItem {
  file: string;
  caption: string;
}

export interface VillageVideoItem {
  file: string;
  caption?: string;
}

export interface VillageInterviewItem {
  name: string;
  role: string;
  note: string;
}

export interface VillageMediaEntry {
  photos: VillagePhotoItem[];
  videos: VillageVideoItem[];
  interviews: VillageInterviewItem[];
}

export interface VillageStoryBlockData {
  key: string;
  label: string;
  name: string;
  location: string;
  points: string[];
  mirrored: boolean;
}

interface VillagesSectionProps {
  intro: string;
  blocks: VillageStoryBlockData[];
  mediaMap: Record<string, VillageMediaEntry>;
  learned: string[];
  reducedMotion: boolean;
}

interface CollageTileProps {
  photo: VillagePhotoItem;
  index: number;
  className: string;
  blockProgress: MotionValue<number>;
  reducedMotion: boolean;
  onOpen: () => void;
}

const PARALLAX_OFFSETS = [14, -18, 22, -12, 18, -20, 12];

const CollageTile: React.FC<CollageTileProps> = ({
  photo,
  index,
  className,
  blockProgress,
  reducedMotion,
  onOpen,
}) => {
  const delta = PARALLAX_OFFSETS[index % PARALLAX_OFFSETS.length];
  const parallaxY = useTransform(
    blockProgress,
    [0, 1],
    reducedMotion ? [0, 0] : [delta, -delta]
  );

  return (
    <motion.div
      style={{ y: parallaxY }}
      initial={reducedMotion ? { opacity: 1, x: 0 } : { opacity: 0, x: 40 }}
      whileInView={{ opacity: 1, x: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{
        duration: 0.65,
        delay: index * 0.07,
        ease: "easeOut",
      }}
      className={className}
    >
      <button
        type="button"
        onClick={onOpen}
        className="group relative w-full h-full rounded-[20px] overflow-hidden border border-[#3C4E38]/80 bg-[#2E3E2B]/55 shadow-[0_18px_40px_rgba(0,0,0,0.42)] block text-left cursor-pointer focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#8DB85A]"
      >
        <img
          src={photo.file}
          alt={photo.caption}
          loading="lazy"
          referrerPolicy="no-referrer"
          className="w-full h-full object-cover transition-transform duration-300 ease-out group-hover:scale-[1.04]"
        />
        <div
          aria-hidden="true"
          className="absolute inset-x-0 bottom-0 h-20 bg-gradient-to-t from-black/80 via-black/35 to-transparent pointer-events-none"
        />
        <div className="absolute bottom-2.5 left-2.5 right-2.5 flex justify-start pointer-events-none">
          <span className="liquid-glass rounded-full px-3 py-1 text-[11px] sm:text-xs text-[#F4F7EA] max-w-full truncate">
            {photo.caption}
          </span>
        </div>
      </button>
    </motion.div>
  );
};

// Cubic bezier evaluator for P0=(680,10), P1=(680,82), P2=(320,82), P3=(320,154) in 1000x164 viewBox
function evalTrailBezier(t: number) {
  const u = 1 - t;
  const p0x = 680,
    p0y = 10;
  const p1x = 680,
    p1y = 82;
  const p2x = 320,
    p2y = 82;
  const p3x = 320,
    p3y = 154;

  const x =
    u * u * u * p0x +
    3 * u * u * t * p1x +
    3 * u * t * t * p2x +
    t * t * t * p3x;
  const y =
    u * u * u * p0y +
    3 * u * u * t * p1y +
    3 * u * t * t * p2y +
    t * t * t * p3y;

  const dx =
    3 * u * u * (p1x - p0x) +
    6 * u * t * (p2x - p1x) +
    3 * t * t * (p3x - p2x);
  const dy =
    3 * u * u * (p1y - p0y) +
    6 * u * t * (p2y - p1y) +
    3 * t * t * (p3y - p2y);

  const angle = (Math.atan2(dy, dx) * 180) / Math.PI;
  return { x, y, angle };
}

const DottedVillageTrail: React.FC<{ reducedMotion: boolean }> = ({
  reducedMotion,
}) => {
  const maskId = useId();
  const trailRef = useRef<HTMLDivElement | null>(null);
  const { scrollYProgress } = useScroll({
    target: trailRef,
    offset: ["start 82%", "end 38%"],
  });

  const pathLength = useTransform(scrollYProgress, [0, 1], [0, 1]);
  const leafX = useTransform(scrollYProgress, (p) =>
    evalTrailBezier(reducedMotion ? 0.5 : p).x
  );
  const leafY = useTransform(scrollYProgress, (p) =>
    evalTrailBezier(reducedMotion ? 0.5 : p).y
  );
  const leafRotate = useTransform(
    scrollYProgress,
    (p) => evalTrailBezier(reducedMotion ? 0.5 : p).angle - 20
  );

  const curveD = "M 680 10 C 680 82, 320 82, 320 154";

  return (
    <div
      ref={trailRef}
      aria-hidden="true"
      className="w-full max-w-5xl mx-auto py-4 sm:py-6 px-4 pointer-events-none select-none"
    >
      <svg
        viewBox="0 0 1000 164"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="w-full h-24 sm:h-36 overflow-visible"
      >
        <defs>
          <mask id={maskId}>
            <motion.path
              d={curveD}
              stroke="white"
              strokeWidth="8"
              strokeLinecap="round"
              fill="none"
              style={{ pathLength: reducedMotion ? 1 : pathLength }}
            />
          </mask>
        </defs>

        {/* Subtle background dotted guide */}
        <path
          d={curveD}
          stroke="#3C4E38"
          strokeOpacity="0.45"
          strokeWidth="1.6"
          strokeDasharray="4 8"
          strokeLinecap="round"
        />

        {/* Scroll-drawing dotted path */}
        <path
          d={curveD}
          stroke="#8DB85A"
          strokeWidth="2"
          strokeDasharray="4 8"
          strokeLinecap="round"
          mask={`url(#${maskId})`}
        />

        {/* Small leaf riding along the drawing path */}
        <motion.g
          style={{
            x: leafX,
            y: leafY,
            rotate: leafRotate,
          }}
        >
          <path
            d="M-11 2C-7 -7 3 -9 12 -4C8 6 -2 9 -11 2Z"
            fill="#8DB85A"
          />
          <path
            d="M-9 2C-3 0 3 -1 9 -3"
            stroke="#172213"
            strokeOpacity="0.45"
            strokeWidth="1.1"
            strokeLinecap="round"
          />
        </motion.g>
      </svg>
    </div>
  );
};

interface MobilePhotoCarouselProps {
  photos: VillagePhotoItem[];
  onOpenPhoto: (idx: number) => void;
}

const MobilePhotoCarousel: React.FC<MobilePhotoCarouselProps> = ({
  photos,
  onOpenPhoto,
}) => {
  const scrollerRef = useRef<HTMLDivElement | null>(null);
  const [activeIndex, setActiveIndex] = useState(0);

  const handleScroll = () => {
    const el = scrollerRef.current;
    if (!el || el.children.length === 0) return;
    const firstCard = el.children[0] as HTMLElement;
    const stepWidth = firstCard.offsetWidth + 14;
    if (stepWidth <= 0) return;
    const idx = Math.round(el.scrollLeft / stepWidth);
    setActiveIndex(Math.max(0, Math.min(photos.length - 1, idx)));
  };

  const scrollToSlide = (idx: number) => {
    const el = scrollerRef.current;
    if (!el || !el.children[idx]) return;
    const target = el.children[idx] as HTMLElement;
    el.scrollTo({ left: target.offsetLeft, behavior: "smooth" });
    setActiveIndex(idx);
  };

  if (photos.length === 0) return null;

  return (
    <div className="md:hidden w-full mt-6">
      <div
        ref={scrollerRef}
        onScroll={handleScroll}
        className="flex overflow-x-auto snap-x snap-mandatory gap-3.5 pb-2 no-scrollbar"
      >
        {photos.map((photo, idx) => (
          <button
            key={photo.file}
            type="button"
            onClick={() => onOpenPhoto(idx)}
            className="relative w-[85%] shrink-0 snap-center aspect-[4/3] rounded-[20px] overflow-hidden border border-[#3C4E38]/80 bg-[#2E3E2B]/55 shadow-[0_14px_32px_rgba(0,0,0,0.4)] text-left"
          >
            <img
              src={photo.file}
              alt={photo.caption}
              loading="lazy"
              referrerPolicy="no-referrer"
              className="w-full h-full object-cover"
            />
            <div
              aria-hidden="true"
              className="absolute inset-x-0 bottom-0 h-20 bg-gradient-to-t from-black/80 via-black/35 to-transparent pointer-events-none"
            />
            <div className="absolute bottom-2.5 left-2.5 right-2.5 flex justify-start pointer-events-none">
              <span className="liquid-glass rounded-full px-3 py-1 text-xs text-[#F4F7EA] max-w-full truncate">
                {photo.caption}
              </span>
            </div>
          </button>
        ))}
      </div>

      {/* Small carousel dots */}
      <div className="flex items-center justify-center gap-2 mt-3.5">
        {photos.map((photo, idx) => (
          <button
            key={photo.file}
            type="button"
            aria-label={`View photo ${idx + 1}`}
            onClick={() => scrollToSlide(idx)}
            className={`h-1.5 rounded-full transition-all duration-200 ${
              idx === activeIndex
                ? "w-5 bg-[#8DB85A]"
                : "w-1.5 bg-[#3C4E38] hover:bg-[#A9B49A]"
            }`}
          />
        ))}
      </div>
    </div>
  );
};

interface VillageBlockRowProps {
  block: VillageStoryBlockData;
  media: VillageMediaEntry;
  reducedMotion: boolean;
  onOpenLightbox: (photos: VillagePhotoItem[], index: number) => void;
}

const VillageBlockRow: React.FC<VillageBlockRowProps> = ({
  block,
  media,
  reducedMotion,
  onOpenLightbox,
}) => {
  const rowRef = useRef<HTMLDivElement | null>(null);
  const { scrollYProgress } = useScroll({
    target: rowRef,
    offset: ["start end", "end start"],
  });

  const photos = media?.photos ?? [];
  const videos = media?.videos ?? [];
  const interviews = media?.interviews ?? [];

  const topPhotos = photos.slice(0, 3);
  const bottomPhotos = photos.slice(3);

  const bottomColClass =
    bottomPhotos.length === 4
      ? "col-span-3"
      : bottomPhotos.length === 3
      ? "col-span-4"
      : bottomPhotos.length === 2
      ? "col-span-6"
      : "col-span-12";

  return (
    <div
      ref={rowRef}
      className="min-h-0 md:min-h-[82vh] flex flex-col justify-center py-6 md:py-10"
    >
      <div
        className={`flex flex-col ${
          block.mirrored ? "md:flex-row-reverse" : "md:flex-row"
        } items-start md:items-center gap-8 lg:gap-12`}
      >
        {/* Text column (~40% on desktop; first on mobile: label, heading, line, bullets) */}
        <motion.div
          {...fadeUp(0.04, reducedMotion)}
          className="w-full md:w-[40%] shrink-0"
        >
          <p className="text-xs uppercase tracking-[3px] text-[#A9B49A] font-medium">
            {block.label}
          </p>
          <h3 className="mt-3 font-serif-display text-5xl sm:text-6xl lg:text-7xl text-[#F4F7EA] leading-[1.02] tracking-[-0.5px]">
            {block.name}
          </h3>
          <p className="mt-2 text-sm sm:text-base text-[#D8B48A] font-medium">
            {block.location}
          </p>

          <ul className="mt-6 space-y-3.5">
            {block.points.map((pt) => (
              <li
                key={pt}
                className="flex items-start gap-2.5 text-sm sm:text-base text-[#E9EFDC]/90 leading-relaxed"
              >
                <span
                  aria-hidden="true"
                  className="w-1.5 h-1.5 rounded-full bg-[#8DB85A] shrink-0 mt-2"
                />
                <span>{pt}</span>
              </li>
            ))}
          </ul>

          {/* Render videos ONLY if videos array has items */}
          {videos.length > 0 && (
            <div className="mt-6 space-y-3">
              {videos.map((vid) => (
                <div key={vid.file}>
                  <video
                    src={vid.file}
                    controls
                    className="w-full rounded-[20px] border border-[#3C4E38]"
                  />
                  {vid.caption && (
                    <p className="mt-1.5 text-xs text-[#A9B49A]">
                      {vid.caption}
                    </p>
                  )}
                </div>
              ))}
            </div>
          )}

          {/* Render interviews ONLY if interviews array has items */}
          {interviews.length > 0 && (
            <div className="mt-6 space-y-3">
              {interviews.map((iv) => (
                <div
                  key={`${iv.name}-${iv.role}`}
                  className="liquid-glass rounded-[20px] p-4"
                >
                  <div className="text-sm font-medium text-[#F4F7EA]">
                    {iv.name} ·{" "}
                    <span className="text-[#A9B49A]">{iv.role}</span>
                  </div>
                  <p className="mt-1 text-sm text-[#E9EFDC]/90">{iv.note}</p>
                </div>
              ))}
            </div>
          )}
        </motion.div>

        {/* Photos column (~60% on desktop: collage with 1 big photo & smaller photos around it; swipe carousel on mobile) */}
        {photos.length > 0 && (
          <div className="w-full md:w-[60%]">
            {/* Desktop Collage Grid */}
            <div className="hidden md:grid grid-cols-12 gap-3.5 lg:gap-4">
              {topPhotos[0] && (
                <CollageTile
                  photo={topPhotos[0]}
                  index={0}
                  className="col-span-8 row-span-2 h-[290px] lg:h-[344px]"
                  blockProgress={scrollYProgress}
                  reducedMotion={reducedMotion}
                  onOpen={() => onOpenLightbox(photos, 0)}
                />
              )}

              {topPhotos[1] && (
                <CollageTile
                  photo={topPhotos[1]}
                  index={1}
                  className="col-span-4 h-[138px] lg:h-[164px]"
                  blockProgress={scrollYProgress}
                  reducedMotion={reducedMotion}
                  onOpen={() => onOpenLightbox(photos, 1)}
                />
              )}

              {topPhotos[2] && (
                <CollageTile
                  photo={topPhotos[2]}
                  index={2}
                  className="col-span-4 h-[138px] lg:h-[164px]"
                  blockProgress={scrollYProgress}
                  reducedMotion={reducedMotion}
                  onOpen={() => onOpenLightbox(photos, 2)}
                />
              )}

              {bottomPhotos.map((photo, bIdx) => {
                const realIdx = bIdx + 3;
                return (
                  <CollageTile
                    key={photo.file}
                    photo={photo}
                    index={realIdx}
                    className={`${bottomColClass} h-[132px] lg:h-[156px]`}
                    blockProgress={scrollYProgress}
                    reducedMotion={reducedMotion}
                    onOpen={() => onOpenLightbox(photos, realIdx)}
                  />
                );
              })}
            </div>

            {/* Mobile Horizontal Swipe Carousel with snap & dots */}
            <MobilePhotoCarousel
              photos={photos}
              onOpenPhoto={(idx) => onOpenLightbox(photos, idx)}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export const VillagesSection: React.FC<VillagesSectionProps> = ({
  intro,
  blocks,
  mediaMap,
  learned,
  reducedMotion,
}) => {
  const [lightbox, setLightbox] = useState<{
    photos: VillagePhotoItem[];
    index: number;
  } | null>(null);

  const touchStartX = useRef<number | null>(null);

  const closeLightbox = useCallback(() => setLightbox(null), []);

  const goPrev = useCallback(() => {
    setLightbox((curr) => {
      if (!curr) return null;
      const nextIdx = (curr.index - 1 + curr.photos.length) % curr.photos.length;
      return { ...curr, index: nextIdx };
    });
  }, []);

  const goNext = useCallback(() => {
    setLightbox((curr) => {
      if (!curr) return null;
      const nextIdx = (curr.index + 1) % curr.photos.length;
      return { ...curr, index: nextIdx };
    });
  }, []);

  useEffect(() => {
    if (!lightbox) return;
    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") closeLightbox();
      if (e.key === "ArrowLeft") goPrev();
      if (e.key === "ArrowRight") goNext();
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [lightbox, closeLightbox, goPrev, goNext]);

  const activePhoto = lightbox ? lightbox.photos[lightbox.index] : null;

  return (
    <section
      id="villages"
      className="relative z-[10] max-w-6xl mx-auto px-5 sm:px-8 py-20 md:py-28 scroll-mt-20"
    >
      <SectionHeader
        label="FIELD VISITS"
        beforeItalic="We went to the "
        italicWord="villages"
        italicTone="orange"
        subtitle={intro}
        reducedMotion={reducedMotion}
      />

      {blocks.map((block, idx) => (
        <React.Fragment key={block.key}>
          <VillageBlockRow
            block={block}
            media={
              mediaMap[block.key] ?? {
                photos: [],
                videos: [],
                interviews: [],
              }
            }
            reducedMotion={reducedMotion}
            onOpenLightbox={(photos, photoIdx) =>
              setLightbox({ photos, index: photoIdx })
            }
          />
          {idx < blocks.length - 1 && (
            <DottedVillageTrail reducedMotion={reducedMotion} />
          )}
        </React.Fragment>
      ))}

      {/* What we learned strip */}
      <motion.div
        {...fadeUp(0.12, reducedMotion)}
        className="mt-10 liquid-glass rounded-[20px] p-6 sm:p-8"
      >
        <h3 className="text-xl font-medium text-[#F4F7EA] mb-4">
          What we learned
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {learned.map((item) => (
            <div key={item} className="flex items-start gap-2.5">
              <Check className="w-4 h-4 text-[#8DB85A] shrink-0 mt-1" />
              <p className="text-sm sm:text-base text-[#E9EFDC] leading-relaxed">
                {item}
              </p>
            </div>
          ))}
        </div>
      </motion.div>

      {/* Full-screen Lightbox portaled to document.body (z-[70], strictly above z-50 navbar & z-[6] falling mango) */}
      {typeof document !== "undefined" &&
        createPortal(
          <AnimatePresence>
            {lightbox && activePhoto && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.2 }}
                onClick={closeLightbox}
                onTouchStart={(e) => {
                  touchStartX.current = e.touches[0]?.clientX ?? null;
                }}
                onTouchEnd={(e) => {
                  if (touchStartX.current === null) return;
                  const endX =
                    e.changedTouches[0]?.clientX ?? touchStartX.current;
                  const diff = endX - touchStartX.current;
                  if (Math.abs(diff) > 45) {
                    if (diff > 0) goPrev();
                    else goNext();
                  }
                  touchStartX.current = null;
                }}
                role="dialog"
                aria-modal="true"
                aria-label={activePhoto.caption}
                className="fixed inset-0 z-[70] bg-[#172213]/94 backdrop-blur-xl flex flex-col items-center justify-center p-4 sm:p-8"
              >
                {/* Top close bar */}
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    closeLightbox();
                  }}
                  aria-label="Close lightbox"
                  className="absolute top-5 right-5 w-11 h-11 rounded-full liquid-glass flex items-center justify-center text-[#F4F7EA] hover:bg-white/[0.1] transition-colors cursor-pointer"
                >
                  <X className="w-5 h-5" />
                </button>

                {/* Photo, side arrows & caption */}
                <div
                  onClick={(e) => e.stopPropagation()}
                  className="max-w-5xl w-full flex flex-col items-center"
                >
                  <div className="relative inline-flex items-center justify-center min-w-[140px]">
                    {/* Previous arrow (left of photo) */}
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        goPrev();
                      }}
                      aria-label="Previous photo"
                      className="absolute z-10 top-1/2 -translate-y-1/2 left-2 md:left-auto md:right-[calc(100%+20px)] w-10 h-10 md:w-12 md:h-12 rounded-full flex items-center justify-center text-[#F4F7EA] bg-[#172213]/72 border border-white/20 backdrop-blur-md shadow-[0_4px_16px_rgba(0,0,0,0.5)] md:bg-white/[0.06] md:border-white/25 md:shadow-[inset_0_1px_1px_rgba(255,255,255,0.2),0_8px_24px_rgba(0,0,0,0.4)] md:hover:bg-white/[0.15] md:hover:border-white/40 md:hover:scale-[1.08] transition-all duration-200 ease-out cursor-pointer"
                    >
                      <ChevronLeft className="w-5 h-5 md:w-6 md:h-6" />
                    </button>

                    <img
                      key={activePhoto.file}
                      src={activePhoto.file}
                      alt={activePhoto.caption}
                      referrerPolicy="no-referrer"
                      className="block max-h-[76vh] w-auto max-w-[calc(100vw-32px)] sm:max-w-[calc(100vw-64px)] md:max-w-[min(56rem,calc(100vw-176px))] object-contain rounded-[20px] border border-[#3C4E38] shadow-[0_24px_60px_rgba(0,0,0,0.65)]"
                    />

                    {/* Next arrow (right of photo) */}
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        goNext();
                      }}
                      aria-label="Next photo"
                      className="absolute z-10 top-1/2 -translate-y-1/2 right-2 md:right-auto md:left-[calc(100%+20px)] w-10 h-10 md:w-12 md:h-12 rounded-full flex items-center justify-center text-[#F4F7EA] bg-[#172213]/72 border border-white/20 backdrop-blur-md shadow-[0_4px_16px_rgba(0,0,0,0.5)] md:bg-white/[0.06] md:border-white/25 md:shadow-[inset_0_1px_1px_rgba(255,255,255,0.2),0_8px_24px_rgba(0,0,0,0.4)] md:hover:bg-white/[0.15] md:hover:border-white/40 md:hover:scale-[1.08] transition-all duration-200 ease-out cursor-pointer"
                    >
                      <ChevronRight className="w-5 h-5 md:w-6 md:h-6" />
                    </button>
                  </div>

                  <div className="mt-4 flex flex-wrap items-center justify-center gap-3">
                    <span className="liquid-glass rounded-full px-4 py-2 text-xs sm:text-sm text-[#F4F7EA] text-center">
                      {activePhoto.caption}
                    </span>
                    <span className="text-xs text-[#A9B49A] tabular-nums">
                      {lightbox.index + 1} / {lightbox.photos.length}
                    </span>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>,
          document.body
        )}
    </section>
  );
};
