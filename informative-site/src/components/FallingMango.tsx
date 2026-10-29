import React, { useCallback, useEffect, useId, useRef, useState } from "react";
import {
  motion,
  MotionValue,
  useMotionValueEvent,
  useScroll,
  useTransform,
} from "framer-motion";
import { CleanedProduceMap, ProduceKey } from "../utils/cleanImage";

// ============================================================================
// FALLING ITEMS CONFIGURATION (Land on top centre of the heaped mound)
// ============================================================================

interface FallingItemSpec {
  key: ProduceKey;
  startScroll: number;
  exitScroll: number;
  desktopSizePx: number;
  mobileSizePx: number;
  mobileFalls: boolean;
  desktopCurveX: [number, number, number, number];
  mobileCurveX: [number, number, number];
  rotations: [number, number, number, number];
  // Final landing slot at the top centre of the heaped mound (fractions of basket w/h)
  slotXPct: number;
  slotYPct: number;
  landedDesktopPx: number;
  landedMobilePx: number;
  landRotate: number;
  arriveOrder: number; // 0, 1, 2, 3
  swayDurationSec: number;
  swayDelaySec: number;
}

const FALLING_ITEMS: FallingItemSpec[] = [
  {
    key: "mango",
    startScroll: 0.0,
    exitScroll: 0.235,
    desktopSizePx: 92,
    mobileSizePx: 56,
    mobileFalls: true,
    desktopCurveX: [0.72, 0.36, 0.62, 0.44],
    mobileCurveX: [0.85, 0.78, 0.86],
    rotations: [-6, 16, -14, 18],
    slotXPct: 0.44,
    slotYPct: -0.02,
    landedDesktopPx: 88,
    landedMobilePx: 58,
    landRotate: -16,
    arriveOrder: 0,
    swayDurationSec: 7.4,
    swayDelaySec: -2.1,
  },
  {
    key: "awla",
    startScroll: 0.12,
    exitScroll: 0.355,
    desktopSizePx: 78,
    mobileSizePx: 56,
    mobileFalls: true,
    desktopCurveX: [0.68, 0.4, 0.64, 0.38],
    mobileCurveX: [0.86, 0.79, 0.85],
    rotations: [8, -18, 15, -12],
    slotXPct: 0.56,
    slotYPct: 0.0,
    landedDesktopPx: 72,
    landedMobilePx: 48,
    landRotate: 14,
    arriveOrder: 1,
    swayDurationSec: 6.6,
    swayDelaySec: -4.3,
  },
  {
    key: "tamarind",
    startScroll: 0.24,
    exitScroll: 0.59,
    desktopSizePx: 96,
    mobileSizePx: 56,
    mobileFalls: false,
    desktopCurveX: [0.66, 0.35, 0.59, 0.42],
    mobileCurveX: [0.84, 0.8, 0.86],
    rotations: [-10, 14, -16, 12],
    slotXPct: 0.5,
    slotYPct: -0.075,
    landedDesktopPx: 90,
    landedMobilePx: 60,
    landRotate: -9,
    arriveOrder: 2,
    swayDurationSec: 8.3,
    swayDelaySec: -1.4,
  },
  {
    key: "behda",
    startScroll: 0.36,
    exitScroll: 0.81,
    desktopSizePx: 76,
    mobileSizePx: 56,
    mobileFalls: false,
    desktopCurveX: [0.71, 0.44, 0.34, 0.6],
    mobileCurveX: [0.85, 0.79, 0.84],
    rotations: [6, -15, 18, -10],
    slotXPct: 0.49,
    slotYPct: 0.045,
    landedDesktopPx: 68,
    landedMobilePx: 46,
    landRotate: 19,
    arriveOrder: 3,
    swayDurationSec: 7.9,
    swayDelaySec: -5.6,
  },
];

// ============================================================================
// LAYER 1 (BACK): 4 INLINE SVG BAMBOO STALKS
// ============================================================================

interface BambooStalkSpec {
  id: string;
  xPct: number; // horizontal anchor in basket width
  baseYPct: number; // bottom anchor inside basket opening
  widthPx: number; // 14 to 18px on desktop
  heightPx: number; // 140 to 220px on desktop
  angleDeg: number; // -18 to 18 degrees
  leafSides: ("left" | "right")[];
  swayDurationSec: number;
  swayDelaySec: number;
}

const BAMBOO_STALKS: BambooStalkSpec[] = [
  {
    id: "bamboo-stalk-1",
    xPct: 0.31,
    baseYPct: 0.36,
    widthPx: 15,
    heightPx: 176,
    angleDeg: -17,
    leafSides: ["left", "right", "left"],
    swayDurationSec: 8.2,
    swayDelaySec: -1.8,
  },
  {
    id: "bamboo-stalk-2",
    xPct: 0.44,
    baseYPct: 0.34,
    widthPx: 18,
    heightPx: 218,
    angleDeg: -6,
    leafSides: ["left", "right", "right"],
    swayDurationSec: 7.3,
    swayDelaySec: -4.7,
  },
  {
    id: "bamboo-stalk-3",
    xPct: 0.57,
    baseYPct: 0.34,
    widthPx: 17,
    heightPx: 204,
    angleDeg: 8,
    leafSides: ["right", "left", "right"],
    swayDurationSec: 8.7,
    swayDelaySec: -3.1,
  },
  {
    id: "bamboo-stalk-4",
    xPct: 0.69,
    baseYPct: 0.37,
    widthPx: 14,
    heightPx: 158,
    angleDeg: 18,
    leafSides: ["right", "left"],
    swayDurationSec: 6.8,
    swayDelaySec: -5.9,
  },
];

// ============================================================================
// LAYER 2 (MIDDLE HEAPED MOUND) & LAYER 3 (FRONT RIM SPILL + GROUND PIECES)
// Total static pieces = 25 (3 to 4 copies of all 7 produce types, 56-96px desktop, 40-64px phone)
// ============================================================================

interface BasketPieceSpec {
  id: string;
  key: ProduceKey;
  xPct: number;
  yPct: number;
  scale: number; // 0.7 to 1.2
  rotate: number; // -35 to 35 degrees
  mirror?: boolean;
  hasGroundShadow?: boolean;
  swayDurationSec: number;
  swayDelaySec: number;
}

// 19 heaped mound pieces in 3 overlapping rows forming a dome 75-105px above the back rim at centre
const MIDDLE_MOUND_PIECES: BasketPieceSpec[] = [
  // --- Crown / Top Dome Row (5 pieces, highest at x=0.5, lower toward edges) ---
  {
    id: "mound-r3-1",
    key: "custardApple",
    xPct: 0.31,
    yPct: 0.14,
    scale: 0.88,
    rotate: -24,
    mirror: true,
    swayDurationSec: 7.2,
    swayDelaySec: -1.1,
  },
  {
    id: "mound-r3-2",
    key: "mango",
    xPct: 0.41,
    yPct: 0.055,
    scale: 1.08,
    rotate: -18,
    swayDurationSec: 8.4,
    swayDelaySec: -3.7,
  },
  {
    id: "mound-r3-3",
    key: "custardApple",
    xPct: 0.51,
    yPct: 0.025,
    scale: 1.12,
    rotate: 8,
    swayDurationSec: 6.9,
    swayDelaySec: -5.2,
  },
  {
    id: "mound-r3-4",
    key: "tamarind",
    xPct: 0.61,
    yPct: 0.065,
    scale: 1.14,
    rotate: 22,
    mirror: true,
    swayDurationSec: 7.8,
    swayDelaySec: -2.6,
  },
  {
    id: "mound-r3-5",
    key: "awla",
    xPct: 0.7,
    yPct: 0.145,
    scale: 0.84,
    rotate: 27,
    swayDurationSec: 6.4,
    swayDelaySec: -4.9,
  },

  // --- Middle Mound Row (7 pieces, wide across opening, overlapping Row 3 & Row 1 by 25-30%) ---
  {
    id: "mound-r2-1",
    key: "tamarind",
    xPct: 0.22,
    yPct: 0.255,
    scale: 0.96,
    rotate: -31,
    swayDurationSec: 8.1,
    swayDelaySec: -0.9,
  },
  {
    id: "mound-r2-2",
    key: "jamun",
    xPct: 0.32,
    yPct: 0.215,
    scale: 0.95,
    rotate: 15,
    mirror: true,
    swayDurationSec: 7.5,
    swayDelaySec: -6.1,
  },
  {
    id: "mound-r2-3",
    key: "cashew",
    xPct: 0.42,
    yPct: 0.185,
    scale: 0.92,
    rotate: -19,
    swayDurationSec: 6.7,
    swayDelaySec: -2.3,
  },
  {
    id: "mound-r2-4",
    key: "behda",
    xPct: 0.51,
    yPct: 0.175,
    scale: 0.98,
    rotate: 12,
    mirror: true,
    swayDurationSec: 8.6,
    swayDelaySec: -4.1,
  },
  {
    id: "mound-r2-5",
    key: "mango",
    xPct: 0.61,
    yPct: 0.195,
    scale: 1.15,
    rotate: 24,
    mirror: true,
    swayDurationSec: 7.1,
    swayDelaySec: -1.7,
  },
  {
    id: "mound-r2-6",
    key: "cashew",
    xPct: 0.71,
    yPct: 0.22,
    scale: 0.9,
    rotate: -16,
    mirror: true,
    swayDurationSec: 8.8,
    swayDelaySec: -5.5,
  },
  {
    id: "mound-r2-7",
    key: "behda",
    xPct: 0.79,
    yPct: 0.265,
    scale: 0.86,
    rotate: 29,
    swayDurationSec: 6.3,
    swayDelaySec: -3.3,
  },

  // --- Lower Rim-Filling Row (7 pieces filling full basket mouth, clipped cleanly at front rim) ---
  {
    id: "mound-r1-1",
    key: "awla",
    xPct: 0.18,
    yPct: 0.35,
    scale: 0.86,
    rotate: -28,
    mirror: true,
    swayDurationSec: 7.6,
    swayDelaySec: -2.9,
  },
  {
    id: "mound-r1-2",
    key: "custardApple",
    xPct: 0.28,
    yPct: 0.375,
    scale: 1.04,
    rotate: -14,
    swayDurationSec: 8.5,
    swayDelaySec: -6.4,
  },
  {
    id: "mound-r1-3",
    key: "mango",
    xPct: 0.39,
    yPct: 0.395,
    scale: 1.18,
    rotate: 17,
    swayDurationSec: 6.8,
    swayDelaySec: -1.5,
  },
  {
    id: "mound-r1-4",
    key: "jamun",
    xPct: 0.5,
    yPct: 0.405,
    scale: 1.05,
    rotate: -9,
    swayDurationSec: 7.9,
    swayDelaySec: -4.4,
  },
  {
    id: "mound-r1-5",
    key: "tamarind",
    xPct: 0.61,
    yPct: 0.395,
    scale: 1.16,
    rotate: -21,
    swayDurationSec: 8.2,
    swayDelaySec: -0.7,
  },
  {
    id: "mound-r1-6",
    key: "awla",
    xPct: 0.72,
    yPct: 0.375,
    scale: 0.94,
    rotate: 19,
    mirror: true,
    swayDurationSec: 6.5,
    swayDelaySec: -5.1,
  },
  {
    id: "mound-r1-7",
    key: "cashew",
    xPct: 0.82,
    yPct: 0.35,
    scale: 0.84,
    rotate: 32,
    swayDurationSec: 7.4,
    swayDelaySec: -3.8,
  },
];

// 7 front pieces: 2 spilling over the left & right front rim + 5 resting on the ground outside & in front of the basket (19 + 7 = 26 total)
const FRONT_SPILL_AND_GROUND_PIECES: BasketPieceSpec[] = [
  // 2 pieces spilling directly over the left and right front rim
  {
    id: "front-rim-spill-left",
    key: "behda",
    xPct: 0.21,
    yPct: 0.445,
    scale: 0.82,
    rotate: -29,
    hasGroundShadow: false,
    swayDurationSec: 7.4,
    swayDelaySec: -1.9,
  },
  {
    id: "front-rim-spill-right",
    key: "awla",
    xPct: 0.79,
    yPct: 0.445,
    scale: 0.8,
    rotate: 27,
    mirror: true,
    hasGroundShadow: false,
    swayDurationSec: 6.9,
    swayDelaySec: -4.2,
  },

  // Resting on the ground outside the left & right edges + in front of the basket overlapping its base
  {
    id: "front-side-left",
    key: "tamarind",
    xPct: 0.13,
    yPct: 0.84,
    scale: 1.02,
    rotate: -28,
    mirror: true,
    hasGroundShadow: true,
    swayDurationSec: 8.3,
    swayDelaySec: -2.2,
  },
  {
    id: "front-ground-1",
    key: "custardApple",
    xPct: 0.31,
    yPct: 0.91,
    scale: 0.96,
    rotate: -18,
    hasGroundShadow: true,
    swayDurationSec: 8.9,
    swayDelaySec: -1.3,
  },
  {
    id: "front-ground-2",
    key: "mango",
    xPct: 0.46,
    yPct: 0.94,
    scale: 1.06,
    rotate: 24,
    mirror: true,
    hasGroundShadow: true,
    swayDurationSec: 7.2,
    swayDelaySec: -5.7,
  },
  {
    id: "front-ground-3",
    key: "jamun",
    xPct: 0.61,
    yPct: 0.925,
    scale: 0.88,
    rotate: -14,
    mirror: true,
    hasGroundShadow: true,
    swayDurationSec: 6.6,
    swayDelaySec: -3.4,
  },
  {
    id: "front-side-right",
    key: "cashew",
    xPct: 0.85,
    yPct: 0.855,
    scale: 0.84,
    rotate: 31,
    hasGroundShadow: true,
    swayDurationSec: 8.0,
    swayDelaySec: -6.2,
  },
];

// ============================================================================
// SHARED GEOMETRY & SCROLL TIMING HELPERS
// ============================================================================

function frontRimYFraction(xNorm: number): number {
  const clamped = Math.max(0.12, Math.min(0.88, xNorm));
  const distFromCenter = Math.abs(clamped - 0.5) / 0.38;
  return 0.478 - Math.pow(distFromCenter, 1.75) * 0.088;
}

function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * t;
}

function smoothstep(t: number): number {
  const c = Math.max(0, Math.min(1, t));
  return c * c * (3 - 2 * c);
}

function getArrivalWindow(landPhaseStart: number, arriveOrder: number) {
  const totalWindow = Math.max(0.06, 0.996 - landPhaseStart);
  const stepSpan = totalWindow / 4;
  const arriveStart = landPhaseStart + arriveOrder * stepSpan * 0.72;
  const arriveEnd = Math.min(0.996, arriveStart + stepSpan * 1.15);
  const touchDownP = arriveStart + (arriveEnd - arriveStart) * 0.72;
  return { arriveStart, arriveEnd, touchDownP };
}

// Each of the 4 falling items sinks the mound by 3px as it touches down (up to 12px total)
function computeMoundSinkPx(
  p: number,
  landPhaseStart: number,
  maxItemsCount = 4
): number {
  let sink = 0;
  for (let order = 0; order < maxItemsCount; order++) {
    const { touchDownP } = getArrivalWindow(landPhaseStart, order);
    const t = smoothstep((p - (touchDownP - 0.006)) / 0.016);
    sink += t * 3;
  }
  return sink;
}

// Compute responsive piece pixel width: 56..96px on desktop, 40..64px on phone, scaled with basketWidth
function computePieceWidthPx(
  scale: number,
  basketWidth: number,
  isMobile: boolean
): number {
  if (isMobile) {
    const raw = (basketWidth / 340) * 50 * scale;
    return Math.max(40, Math.min(64, raw));
  }
  const raw = (basketWidth / 440) * 78 * scale;
  return Math.max(56, Math.min(96, raw));
}

interface PageMetrics {
  vw: number;
  vh: number;
  isMobile: boolean;
  maxScroll: number;
  treeDocX: number;
  treeDocY: number;
  heroMangoWidth: number;
  basketDocLeft: number;
  basketDocTop: number;
  basketWidth: number;
  basketHeight: number;
  landPhaseStart: number;
}

// ============================================================================
// INLINE SVG BAMBOO STALK COMPONENT
// ============================================================================

const BambooStalkSvg: React.FC<{
  spec: BambooStalkSpec;
  basketWidth: number;
  basketHeight: number;
  reducedMotion: boolean;
}> = ({ spec, basketWidth, basketHeight, reducedMotion }) => {
  const gradId = useId();
  const scaleFactor = Math.min(1.08, Math.max(0.68, basketWidth / 440));
  const stalkW = Math.round(spec.widthPx * scaleFactor);
  const stalkH = Math.round(spec.heightPx * scaleFactor);
  const nodeSpacing = Math.max(26, Math.round(40 * scaleFactor));

  const nodeYs: number[] = [];
  for (let y = stalkH - nodeSpacing; y >= 18; y -= nodeSpacing) {
    nodeYs.push(y);
  }

  const leftPx = basketWidth * spec.xPct;
  const baseTopPx = basketHeight * spec.baseYPct;

  return (
    <div
      style={{
        left: `${leftPx}px`,
        top: `${baseTopPx}px`,
        width: `${stalkW}px`,
        height: `${stalkH}px`,
        transform: `translate(-50%, -100%) rotate(${spec.angleDeg}deg)`,
        transformOrigin: "50% 100%",
      }}
      className="absolute pointer-events-none select-none"
    >
      <div
        style={
          reducedMotion
            ? undefined
            : {
                animationDuration: `${spec.swayDurationSec}s`,
                animationDelay: `${spec.swayDelaySec}s`,
                transformOrigin: "50% 100%",
              }
        }
        className={
          reducedMotion
            ? "w-full h-full"
            : "w-full h-full animate-produce-sway"
        }
      >
        <svg
          viewBox={`0 0 ${stalkW} ${stalkH}`}
          width={stalkW}
          height={stalkH}
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-full h-full overflow-visible drop-shadow-[0_6px_12px_rgba(0,0,0,0.45)]"
        >
          <defs>
            <linearGradient id={gradId} x1="0" y1="0" x2="1" y2="0">
              <stop offset="0%" stopColor="#9BC15A" />
              <stop offset="55%" stopColor="#84AE49" />
              <stop offset="100%" stopColor="#6E9B3D" />
            </linearGradient>
          </defs>

          {/* Small bamboo leaves near the top nodes (2 to 3 per stalk) */}
          {spec.leafSides.map((side, idx) => {
            const anchorY = 16 + idx * Math.round(22 * scaleFactor);
            const isLeft = side === "left";
            const startX = isLeft ? 2 : stalkW - 2;
            const tipX = isLeft ? -26 * scaleFactor : stalkW + 26 * scaleFactor;
            const ctrlX = isLeft ? -11 * scaleFactor : stalkW + 11 * scaleFactor;
            const tipY = anchorY - (idx % 2 === 0 ? 12 : -5) * scaleFactor;
            return (
              <g key={`${spec.id}-leaf-${idx}`}>
                <path
                  d={`M ${startX} ${anchorY} Q ${ctrlX} ${
                    anchorY - 11 * scaleFactor
                  } ${tipX} ${tipY} Q ${ctrlX} ${
                    anchorY + 5 * scaleFactor
                  } ${startX} ${anchorY + 2} Z`}
                  fill={idx % 2 === 0 ? "#9BC15A" : "#7FA947"}
                />
                <path
                  d={`M ${startX} ${anchorY + 1} Q ${ctrlX} ${
                    anchorY - 3 * scaleFactor
                  } ${tipX * 0.9} ${tipY}`}
                  stroke="#4C7126"
                  strokeWidth="0.9"
                  strokeLinecap="round"
                />
              </g>
            );
          })}

          {/* Main bamboo culm body */}
          <rect
            x="0"
            y="2"
            width={stalkW}
            height={stalkH - 2}
            rx={Math.max(3, stalkW * 0.24)}
            fill={`url(#${gradId})`}
          />

          {/* Top cut hollow rim */}
          <ellipse
            cx={stalkW / 2}
            cy="3"
            rx={stalkW / 2}
            ry="2.3"
            fill="#567C2C"
          />

          {/* Soft highlight along the left edge */}
          <rect
            x={Math.max(1.5, stalkW * 0.14)}
            y="5"
            width={Math.max(2, stalkW * 0.16)}
            height={stalkH - 8}
            rx="1.5"
            fill="#E9F5C9"
            fillOpacity="0.34"
          />

          {/* Darker node rings every ~40px */}
          {nodeYs.map((ny) => (
            <g key={`${spec.id}-node-${ny}`}>
              <rect
                x="-0.8"
                y={ny}
                width={stalkW + 1.6}
                height="2.6"
                rx="1.3"
                fill="#486C24"
              />
              <rect
                x="-0.4"
                y={ny + 2.4}
                width={stalkW + 0.8}
                height="1.3"
                rx="0.6"
                fill="#B7D979"
                fillOpacity="0.55"
              />
            </g>
          ))}
        </svg>
      </div>
    </div>
  );
};

// ============================================================================
// SINGLE FALLING PRODUCE ACTOR (Mid-page S-curve + lands on top of mound)
// ============================================================================

interface SingleFallingActorProps {
  spec: FallingItemSpec;
  produce: CleanedProduceMap;
  metrics: PageMetrics;
  scrollYProgress: MotionValue<number>;
  basketRef: React.RefObject<HTMLDivElement | null>;
}

const SingleFallingActor: React.FC<SingleFallingActorProps> = ({
  spec,
  produce,
  metrics,
  scrollYProgress,
  basketRef,
}) => {
  const asset = produce[spec.key];
  const [clipInset, setClipInset] = useState<string>("none");
  const [inTreeIdle, setInTreeIdle] = useState<boolean>(spec.key === "mango");
  const [hasSettled, setHasSettled] = useState<boolean>(false);

  const { arriveStart, arriveEnd } = getArrivalWindow(
    metrics.landPhaseStart,
    spec.arriveOrder
  );

  const computeState = useCallback(
    (p: number) => {
      const currentScrollY = p * metrics.maxScroll;
      const fallSize = metrics.isMobile ? spec.mobileSizePx : spec.desktopSizePx;
      const landedSize = metrics.isMobile
        ? Math.max(
            42,
            Math.min(64, (metrics.basketWidth / 340) * spec.landedMobilePx)
          )
        : Math.max(
            58,
            Math.min(96, (metrics.basketWidth / 440) * spec.landedDesktopPx)
          );

      // 1. Final Basket Arrival & Bounce on TOP CENTRE of the mound
      if (p >= arriveStart - 0.015) {
        const localT = Math.max(
          0,
          Math.min(
            1,
            (p - arriveStart) / Math.max(0.001, arriveEnd - arriveStart)
          )
        );

        const moundSink = computeMoundSinkPx(p, metrics.landPhaseStart);
        const targetX =
          metrics.basketDocLeft + metrics.basketWidth * spec.slotXPct;
        const liveSlotY =
          metrics.basketDocTop -
          currentScrollY +
          metrics.basketHeight * spec.slotYPct +
          moundSink;

        let yOffset = 0;
        if (localT < 0.72) {
          const d = smoothstep(localT / 0.72);
          yOffset = lerp(-230, 0, d);
        } else if (localT < 0.88) {
          const b = (localT - 0.72) / 0.16;
          yOffset = -Math.sin(b * Math.PI) * 15;
        } else {
          yOffset = 0;
        }

        const entryArcX =
          (1 - smoothstep(Math.min(1, localT / 0.72))) *
          (spec.arriveOrder % 2 === 0 ? -24 : 24);
        const fadeIn =
          p < arriveStart
            ? smoothstep((p - (arriveStart - 0.015)) / 0.015)
            : 1;

        const rot = lerp(
          spec.rotations[3],
          spec.landRotate,
          smoothstep(Math.min(1, localT / 0.8))
        );
        const w = lerp(
          fallSize,
          landedSize,
          smoothstep(Math.min(1, localT / 0.75))
        );

        return {
          x: targetX + entryArcX,
          y: liveSlotY + yOffset,
          rotate: rot,
          width: w,
          opacity: fadeIn,
        };
      }

      // 2. Mobile check: only mango and awla fall during mid-page scroll
      if (metrics.isMobile && !spec.mobileFalls) {
        return {
          x: metrics.vw * 0.85,
          y: -140,
          rotate: 0,
          width: fallSize,
          opacity: 0,
        };
      }

      // 3. Before this item's startScroll
      if (p < spec.startScroll) {
        if (spec.key === "mango") {
          return {
            x: metrics.treeDocX,
            y: metrics.treeDocY - currentScrollY,
            rotate: spec.rotations[0],
            width: metrics.heroMangoWidth,
            opacity: 0.95,
          };
        }
        return {
          x: metrics.treeDocX,
          y: -120,
          rotate: spec.rotations[0],
          width: fallSize,
          opacity: 0,
        };
      }

      // 4. After this item's mid-page exit and before basket arrival
      if (p > spec.exitScroll) {
        return {
          x: metrics.vw * 0.5,
          y: metrics.vh + 160,
          rotate: spec.rotations[3],
          width: fallSize,
          opacity: 0,
        };
      }

      // 5. Active Mid-Page Gentle S-Curve Fall
      const t =
        (p - spec.startScroll) /
        Math.max(0.01, spec.exitScroll - spec.startScroll);

      const treeLiveY = metrics.treeDocY - currentScrollY;
      const startY =
        spec.key === "mango"
          ? metrics.treeDocY
          : Math.max(-40, Math.min(metrics.vh * 0.16, treeLiveY));
      const endY = metrics.vh + 120;

      let curY: number;
      if (spec.key === "mango" && t < 0.16) {
        if (t < 0.1) {
          curY = lerp(startY, startY + 86, smoothstep(t / 0.1));
        } else {
          const b = (t - 0.1) / 0.06;
          curY = startY + 86 - Math.sin(b * Math.PI) * 18;
        }
      } else {
        const tFall = spec.key === "mango" ? (t - 0.16) / 0.84 : t;
        const baseStart = spec.key === "mango" ? startY + 86 : startY;
        curY = lerp(baseStart, endY, tFall);
      }

      let curX: number;
      if (metrics.isMobile) {
        const [mx0, mx1, mx2] = spec.mobileCurveX;
        const startX =
          spec.key === "mango" ? metrics.treeDocX : mx0 * metrics.vw;
        if (t < 0.5) {
          curX = lerp(startX, mx1 * metrics.vw, smoothstep(t / 0.5));
        } else {
          curX = lerp(
            mx1 * metrics.vw,
            mx2 * metrics.vw,
            smoothstep((t - 0.5) / 0.5)
          );
        }
      } else {
        const [cx0, cx1, cx2, cx3] = spec.desktopCurveX;
        const startX =
          spec.key === "mango" ? metrics.treeDocX : cx0 * metrics.vw;
        if (t < 0.33) {
          curX = lerp(startX, cx1 * metrics.vw, smoothstep(t / 0.33));
        } else if (t < 0.68) {
          curX = lerp(
            cx1 * metrics.vw,
            cx2 * metrics.vw,
            smoothstep((t - 0.33) / 0.35)
          );
        } else {
          curX = lerp(
            cx2 * metrics.vw,
            cx3 * metrics.vw,
            smoothstep((t - 0.68) / 0.32)
          );
        }
      }

      const [r0, r1, r2, r3] = spec.rotations;
      const curRot =
        t < 0.33
          ? lerp(r0, r1, t / 0.33)
          : t < 0.66
          ? lerp(r1, r2, (t - 0.33) / 0.33)
          : lerp(r2, r3, (t - 0.66) / 0.34);

      const curWidth =
        spec.key === "mango"
          ? lerp(
              metrics.heroMangoWidth,
              fallSize,
              smoothstep(Math.min(1, t / 0.25))
            )
          : fallSize;

      let curOpacity = 0.9;
      if (spec.key !== "mango" && t < 0.08) {
        curOpacity = 0.9 * (t / 0.08);
      } else if (t > 0.9) {
        curOpacity = 0.9 * (1 - (t - 0.9) / 0.1);
      }

      return {
        x: curX,
        y: curY,
        rotate: curRot,
        width: curWidth,
        opacity: curOpacity,
      };
    },
    [arriveEnd, arriveStart, metrics, spec]
  );

  const x = useTransform(scrollYProgress, (p) => computeState(p).x);
  const y = useTransform(scrollYProgress, (p) => computeState(p).y);
  const rotate = useTransform(scrollYProgress, (p) => computeState(p).rotate);
  const width = useTransform(scrollYProgress, (p) => computeState(p).width);
  const opacity = useTransform(scrollYProgress, (p) => computeState(p).opacity);

  useMotionValueEvent(scrollYProgress, "change", (latest) => {
    if (spec.key === "mango") {
      setInTreeIdle(latest < 0.004);
    }

    const nowSettled = latest >= arriveEnd;
    if (nowSettled !== hasSettled) {
      setHasSettled(nowSettled);
    }

    if (latest < arriveStart - 0.01) {
      if (clipInset !== "none") setClipInset("none");
      return;
    }

    const basketEl = basketRef.current;
    if (!basketEl) return;

    const bRect = basketEl.getBoundingClientRect();
    const curW = width.get();
    const curH = curW / Math.max(0.4, asset.aspectRatio);
    const curX = x.get();
    const curY = y.get();

    const xNorm = (curX - bRect.left) / Math.max(1, bRect.width);
    const rimFrac = frontRimYFraction(xNorm);
    const rimViewportY = bRect.top + bRect.height * rimFrac;
    const itemBottomY = curY + curH * 0.5;

    if (itemBottomY > rimViewportY && curY > bRect.top + bRect.height * 0.12) {
      const bottomPx = Math.min(curH, Math.max(0, itemBottomY - rimViewportY));
      setClipInset(`inset(0px 0px ${Math.round(bottomPx)}px 0px)`);
    } else if (clipInset !== "none") {
      setClipInset("none");
    }
  });

  if (!asset.ready) return null;

  return (
    <motion.div
      aria-hidden="true"
      className="fixed top-0 left-0 z-[6] pointer-events-none select-none will-change-transform"
      style={{
        x,
        y,
        width,
        rotate,
        opacity,
        translateX: "-50%",
        translateY: "-50%",
        clipPath: clipInset,
      }}
    >
      <div
        style={
          hasSettled
            ? {
                animationDuration: `${spec.swayDurationSec}s`,
                animationDelay: `${spec.swayDelaySec}s`,
              }
            : undefined
        }
        className={
          inTreeIdle
            ? "animate-island-float"
            : hasSettled
            ? "animate-produce-sway"
            : ""
        }
      >
        <img
          src={asset.src}
          alt=""
          referrerPolicy="no-referrer"
          className="w-full h-auto block drop-shadow-[0_10px_18px_rgba(12,18,10,0.62)]"
        />
      </div>
    </motion.div>
  );
};

// ============================================================================
// WHOLE-PAGE FALLING PRODUCE STORY CONTROLLER
// ============================================================================

interface FallingProduceStoryProps {
  produce: CleanedProduceMap;
  heroIslandRef: React.RefObject<HTMLDivElement | null>;
  basketRef: React.RefObject<HTMLDivElement | null>;
  reducedMotion: boolean;
}

export const FallingProduceStory: React.FC<FallingProduceStoryProps> = ({
  produce,
  heroIslandRef,
  basketRef,
  reducedMotion,
}) => {
  const { scrollYProgress } = useScroll();
  const [metrics, setMetrics] = useState<PageMetrics>({
    vw: 1280,
    vh: 800,
    isMobile: false,
    maxScroll: 8000,
    treeDocX: 980,
    treeDocY: 520,
    heroMangoWidth: 68,
    basketDocLeft: 420,
    basketDocTop: 7900,
    basketWidth: 440,
    basketHeight: 293,
    landPhaseStart: 0.9,
  });

  const measure = useCallback(() => {
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const isMobile = vw < 768;
    const scrollY = window.scrollY;
    const maxScroll = Math.max(1, document.documentElement.scrollHeight - vh);

    let treeDocX = vw * 0.78;
    let treeDocY = vh * 0.62;
    let heroMangoWidth = isMobile ? 28 : 68;

    const islandEl = heroIslandRef.current;
    if (islandEl) {
      const rect = islandEl.getBoundingClientRect();
      const docTop = rect.top + scrollY;
      heroMangoWidth = Math.max(
        isMobile ? 26 : 44,
        rect.width * (isMobile ? 0.058 : 0.07)
      );
      treeDocX = rect.left + rect.width * 0.855;
      treeDocY = docTop + rect.height * 0.295;
    }

    let basketDocLeft = (vw - Math.min(440, vw - 40)) * 0.5;
    let basketDocTop = maxScroll + vh * 0.35;
    let basketWidth = Math.min(440, vw - 40);
    let basketHeight = basketWidth * 0.667;

    const basketEl = basketRef.current;
    if (basketEl) {
      const bRect = basketEl.getBoundingClientRect();
      basketDocLeft = bRect.left;
      basketDocTop = bRect.top + scrollY;
      basketWidth = Math.max(220, bRect.width);
      basketHeight = Math.max(146, bRect.height);
    }

    const basketCrownDocY = basketDocTop + basketHeight * 0.1;
    const triggerScrollY = Math.max(0, basketCrownDocY - vh * 0.82);
    const landPhaseStart = Math.min(
      0.935,
      Math.max(0.84, triggerScrollY / maxScroll)
    );

    setMetrics({
      vw,
      vh,
      isMobile,
      maxScroll,
      treeDocX,
      treeDocY,
      heroMangoWidth,
      basketDocLeft,
      basketDocTop,
      basketWidth,
      basketHeight,
      landPhaseStart,
    });
  }, [heroIslandRef, basketRef]);

  useEffect(() => {
    measure();
    const t1 = window.setTimeout(measure, 250);
    const t2 = window.setTimeout(measure, 950);

    window.addEventListener("resize", measure, { passive: true });
    let ro: ResizeObserver | null = null;
    if (typeof ResizeObserver !== "undefined") {
      ro = new ResizeObserver(() => measure());
      ro.observe(document.body);
    }

    return () => {
      window.clearTimeout(t1);
      window.clearTimeout(t2);
      window.removeEventListener("resize", measure);
      if (ro) ro.disconnect();
    };
  }, [measure, produce.mango.ready, produce.awla.ready]);

  if (reducedMotion) {
    return null;
  }

  return (
    <>
      {FALLING_ITEMS.map((spec) => (
        <SingleFallingActor
          key={spec.key}
          spec={spec}
          produce={produce}
          metrics={metrics}
          scrollYProgress={scrollYProgress}
          basketRef={basketRef}
        />
      ))}
    </>
  );
};

// ============================================================================
// OVERFLOWING 3-LAYER HARVEST BASKET STAGE
// ============================================================================

interface BasketStageProps {
  basketRef: React.RefObject<HTMLDivElement | null>;
  basketSrc: string;
  produce: CleanedProduceMap;
  reducedMotion: boolean;
}

export const BasketStage: React.FC<BasketStageProps> = ({
  basketRef,
  basketSrc,
  produce,
  reducedMotion,
}) => {
  const { scrollYProgress } = useScroll();
  const [basketSize, setBasketSize] = useState<{
    w: number;
    h: number;
    isMobile: boolean;
    landPhaseStart: number;
  }>({
    w: 440,
    h: 293,
    isMobile: false,
    landPhaseStart: 0.9,
  });

  const measureBasket = useCallback(() => {
    const el = basketRef.current;
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const isMobile = vw < 768;
    const scrollY = window.scrollY;
    const maxScroll = Math.max(1, document.documentElement.scrollHeight - vh);

    if (!el) return;
    const rect = el.getBoundingClientRect();
    if (rect.width <= 0 || rect.height <= 0) return;

    const docTop = rect.top + scrollY;
    const crownDocY = docTop + rect.height * 0.1;
    const triggerScrollY = Math.max(0, crownDocY - vh * 0.82);
    const landPhaseStart = Math.min(
      0.935,
      Math.max(0.84, triggerScrollY / maxScroll)
    );

    setBasketSize({
      w: rect.width,
      h: rect.height,
      isMobile,
      landPhaseStart,
    });
  }, [basketRef]);

  useEffect(() => {
    measureBasket();
    const t1 = window.setTimeout(measureBasket, 300);
    window.addEventListener("resize", measureBasket, { passive: true });
    let ro: ResizeObserver | null = null;
    if (typeof ResizeObserver !== "undefined") {
      ro = new ResizeObserver(() => measureBasket());
      ro.observe(document.body);
      if (basketRef.current) ro.observe(basketRef.current);
    }
    return () => {
      window.clearTimeout(t1);
      window.removeEventListener("resize", measureBasket);
      if (ro) ro.disconnect();
    };
  }, [basketRef, measureBasket]);

  // Mound sinks 3px each time one of the 4 falling items lands on top (up to 12px)
  const moundSinkY = useTransform(scrollYProgress, (p) =>
    reducedMotion ? 0 : computeMoundSinkPx(p, basketSize.landPhaseStart)
  );

  return (
    <div
      ref={basketRef}
      className="relative max-w-[440px] w-full mx-auto mt-28 mb-14 md:mt-36 md:mb-16 select-none pointer-events-none"
    >
      {/* Base woven basket image (back wall & inner weave): z-[4] */}
      <img
        src={basketSrc}
        alt="Woven bamboo harvest basket overflowing with forest produce"
        onLoad={measureBasket}
        referrerPolicy="no-referrer"
        className="relative z-[4] w-full h-auto block drop-shadow-[0_26px_44px_rgba(0,0,0,0.58)]"
      />

      {/* BACK LAYER (behind everything else in the basket, standing inside at the back): 4 inline SVG bamboo stalks */}
      <div aria-hidden="true" className="absolute inset-0 z-[4]">
        {BAMBOO_STALKS.map((stalk) => (
          <BambooStalkSvg
            key={stalk.id}
            spec={stalk}
            basketWidth={basketSize.w}
            basketHeight={basketSize.h}
            reducedMotion={reducedMotion}
          />
        ))}
      </div>

      {/* MIDDLE LAYER (z-[5]): Heaped 3-row mound rising 70-110px above the rim; clipped ONLY below the curved front rim line */}
      <div
        aria-hidden="true"
        style={{
          clipPath:
            "polygon(-30% -130%, 130% -130%, 130% 35%, 86% 35.5%, 78% 43.5%, 64% 46.8%, 50% 47.8%, 36% 46.8%, 22% 43.5%, 14% 35.5%, -30% 35%)",
        }}
        className="absolute inset-0 z-[5]"
      >
        <motion.div style={{ y: moundSinkY }} className="relative w-full h-full">
          {MIDDLE_MOUND_PIECES.map((piece) => {
            const asset = produce[piece.key];
            if (!asset.ready) return null;
            const widthPx = computePieceWidthPx(
              piece.scale,
              basketSize.w,
              basketSize.isMobile
            );
            const leftPx = basketSize.w * piece.xPct;
            const topPx = basketSize.h * piece.yPct;

            return (
              <StaticProducePiece
                key={piece.id}
                src={asset.src}
                leftPx={leftPx}
                topPx={topPx}
                widthPx={widthPx}
                rotate={piece.rotate}
                mirror={piece.mirror}
                hasGroundShadow={false}
                swayDurationSec={piece.swayDurationSec}
                swayDelaySec={piece.swayDelaySec}
                reducedMotion={reducedMotion}
              />
            );
          })}

          {/* When prefers-reduced-motion is true, render the 4 top-centre items already resting on the mound */}
          {reducedMotion &&
            FALLING_ITEMS.map((spec) => {
              const asset = produce[spec.key];
              if (!asset.ready) return null;
              const widthPx = basketSize.isMobile
                ? Math.max(
                    42,
                    Math.min(64, (basketSize.w / 340) * spec.landedMobilePx)
                  )
                : Math.max(
                    58,
                    Math.min(96, (basketSize.w / 440) * spec.landedDesktopPx)
                  );
              return (
                <StaticProducePiece
                  key={`static-top-${spec.key}`}
                  src={asset.src}
                  leftPx={basketSize.w * spec.slotXPct}
                  topPx={basketSize.h * spec.slotYPct}
                  widthPx={widthPx}
                  rotate={spec.landRotate}
                  mirror={false}
                  hasGroundShadow={false}
                  swayDurationSec={spec.swayDurationSec}
                  swayDelaySec={spec.swayDelaySec}
                  reducedMotion={true}
                />
              );
            })}
        </motion.div>
      </div>

      {/* FRONT RIM OVERLAY (z-[8]): Covers only the part of mound/falling items below the front rim curve */}
      <img
        src={basketSrc}
        alt=""
        aria-hidden="true"
        referrerPolicy="no-referrer"
        style={{
          clipPath:
            "polygon(8% 35.5%, 22% 43.5%, 36% 46.8%, 50% 47.8%, 64% 46.8%, 78% 43.5%, 92% 35.5%, 98% 100%, 2% 100%)",
        }}
        className="absolute inset-0 z-[8] w-full h-auto block"
      />

      {/* FRONT LAYER (z-[9]): 2 side spill pieces + 4 front ground pieces overlapping the basket base with contact shadows */}
      <div aria-hidden="true" className="absolute inset-0 z-[9]">
        {FRONT_SPILL_AND_GROUND_PIECES.map((piece) => {
          const asset = produce[piece.key];
          if (!asset.ready) return null;
          const widthPx = computePieceWidthPx(
            piece.scale,
            basketSize.w,
            basketSize.isMobile
          );
          const leftPx = basketSize.w * piece.xPct;
          const topPx = basketSize.h * piece.yPct;

          return (
            <StaticProducePiece
              key={piece.id}
              src={asset.src}
              leftPx={leftPx}
              topPx={topPx}
              widthPx={widthPx}
              rotate={piece.rotate}
              mirror={piece.mirror}
              hasGroundShadow={Boolean(piece.hasGroundShadow)}
              swayDurationSec={piece.swayDurationSec}
              swayDelaySec={piece.swayDelaySec}
              reducedMotion={reducedMotion}
            />
          );
        })}
      </div>
    </div>
  );
};

// ============================================================================
// STATIC PRODUCE PIECE WITH MIRROR, CONTACT SHADOW & SLOW +-1.5 DEG SWAY
// ============================================================================

interface StaticProducePieceProps {
  src: string;
  leftPx: number;
  topPx: number;
  widthPx: number;
  rotate: number;
  mirror?: boolean;
  hasGroundShadow: boolean;
  swayDurationSec: number;
  swayDelaySec: number;
  reducedMotion: boolean;
}

const StaticProducePiece: React.FC<StaticProducePieceProps> = ({
  src,
  leftPx,
  topPx,
  widthPx,
  rotate,
  mirror = false,
  hasGroundShadow,
  swayDurationSec,
  swayDelaySec,
  reducedMotion,
}) => {
  return (
    <div
      style={{
        left: `${leftPx}px`,
        top: `${topPx}px`,
        width: `${widthPx}px`,
        transform: "translate(-50%, -50%)",
      }}
      className="absolute"
    >
      {/* Soft dark ground contact shadow (ellipse, blur 8px, opacity 0.35) */}
      {hasGroundShadow && (
        <div
          aria-hidden="true"
          style={{
            width: `${Math.round(widthPx * 0.92)}px`,
            height: `${Math.max(10, Math.round(widthPx * 0.28))}px`,
            backgroundColor: "#050904",
            opacity: 0.35,
            filter: "blur(8px)",
          }}
          className="absolute left-1/2 -bottom-1.5 -translate-x-1/2 rounded-full pointer-events-none"
        />
      )}

      {/* Slow +-1.5 deg sway wrapper */}
      <div
        style={
          reducedMotion
            ? undefined
            : {
                animationDuration: `${swayDurationSec}s`,
                animationDelay: `${swayDelaySec}s`,
              }
        }
        className={reducedMotion ? "w-full" : "w-full animate-produce-sway"}
      >
        <div
          style={{
            transform: `rotate(${rotate}deg) scaleX(${mirror ? -1 : 1})`,
          }}
        >
          <img
            src={src}
            alt=""
            referrerPolicy="no-referrer"
            className="w-full h-auto block drop-shadow-[0_7px_13px_rgba(0,0,0,0.52)]"
          />
        </div>
      </div>
    </div>
  );
};
