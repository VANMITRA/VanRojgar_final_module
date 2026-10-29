import { useEffect, useState } from "react";

export interface CleanedImageResult {
  src: string;
  aspectRatio: number;
  ready: boolean;
}

export type ProduceKey =
  | "mango"
  | "awla"
  | "tamarind"
  | "behda"
  | "cashew"
  | "custardApple"
  | "jamun";

export type CleanedProduceMap = Record<ProduceKey, CleanedImageResult>;

const PRODUCE_PATHS: Record<ProduceKey, string> = {
  mango: "/mango.png",
  awla: "/produce/awla.png",
  tamarind: "/produce/tamarind.png",
  behda: "/produce/behda.png",
  cashew: "/produce/cashew.png",
  custardApple: "/produce/custard-apple.png",
  jamun: "/produce/jamun.png",
};

function stripOuterWhiteBackgroundIfOpaque(
  data: Uint8ClampedArray,
  width: number,
  height: number
) {
  const topLeftAlpha = data[3];
  const topRightIdx = (width - 1) * 4;
  const bottomLeftIdx = (height - 1) * width * 4;
  const bottomRightIdx = ((height - 1) * width + (width - 1)) * 4;

  const isOpaqueWhite = (idx: number) =>
    data[idx + 3] > 245 &&
    data[idx] > 242 &&
    data[idx + 1] > 242 &&
    data[idx + 2] > 242;

  if (
    topLeftAlpha > 245 &&
    isOpaqueWhite(0) &&
    isOpaqueWhite(topRightIdx) &&
    isOpaqueWhite(bottomLeftIdx) &&
    isOpaqueWhite(bottomRightIdx)
  ) {
    const visited = new Uint8Array(width * height);
    const queue = new Int32Array(width * height);
    let head = 0;
    let tail = 0;

    const enqueueIfBg = (x: number, y: number) => {
      const p = y * width + x;
      if (visited[p]) return;
      const idx = p * 4;
      const r = data[idx];
      const g = data[idx + 1];
      const b = data[idx + 2];
      if (r > 234 && g > 234 && b > 230 && Math.abs(r - b) < 22) {
        visited[p] = 1;
        queue[tail++] = p;
      }
    };

    for (let x = 0; x < width; x++) {
      enqueueIfBg(x, 0);
      enqueueIfBg(x, height - 1);
    }
    for (let y = 0; y < height; y++) {
      enqueueIfBg(0, y);
      enqueueIfBg(width - 1, y);
    }

    while (head < tail) {
      const p = queue[head++];
      const idx = p * 4;
      data[idx + 3] = 0;
      const x = p % width;
      const y = (p - x) / width;
      if (x > 0) enqueueIfBg(x - 1, y);
      if (x < width - 1) enqueueIfBg(x + 1, y);
      if (y > 0) enqueueIfBg(x, y - 1);
      if (y < height - 1) enqueueIfBg(x, y + 1);
    }

    for (let y = 1; y < height - 1; y++) {
      for (let x = 1; x < width - 1; x++) {
        const p = y * width + x;
        const idx = p * 4;
        if (data[idx + 3] === 0) continue;
        const hasClearedNeighbour =
          data[(p - 1) * 4 + 3] === 0 ||
          data[(p + 1) * 4 + 3] === 0 ||
          data[(p - width) * 4 + 3] === 0 ||
          data[(p + width) * 4 + 3] === 0;
        if (hasClearedNeighbour) {
          const lum = (data[idx] + data[idx + 1] + data[idx + 2]) / 3;
          if (lum > 220) {
            data[idx + 3] = Math.min(
              data[idx + 3],
              Math.max(0, Math.round((250 - lum) * 6))
            );
          }
        }
      }
    }
  }
}

function cleanTransparentPng(imagePath: string): Promise<CleanedImageResult> {
  return new Promise((resolve) => {
    const img = new Image();
    img.decoding = "async";
    img.onload = () => {
      try {
        const w = img.naturalWidth;
        const h = img.naturalHeight;
        const canvas = document.createElement("canvas");
        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext("2d", { willReadFrequently: true });
        if (!ctx) {
          resolve({ src: imagePath, aspectRatio: w / Math.max(1, h), ready: true });
          return;
        }

        ctx.drawImage(img, 0, 0);
        const imageData = ctx.getImageData(0, 0, w, h);
        const data = imageData.data;

        stripOuterWhiteBackgroundIfOpaque(data, w, h);

        let minX = w;
        let minY = h;
        let maxX = 0;
        let maxY = 0;
        let hasVisible = false;

        // Set alpha to 0 for every pixel with alpha below 40 and find visible crop bounds
        for (let y = 0; y < h; y++) {
          for (let x = 0; x < w; x++) {
            const idx = (y * w + x) * 4;
            if (data[idx + 3] < 40) {
              data[idx + 3] = 0;
            } else {
              hasVisible = true;
              if (x < minX) minX = x;
              if (y < minY) minY = y;
              if (x > maxX) maxX = x;
              if (y > maxY) maxY = y;
            }
          }
        }

        ctx.putImageData(imageData, 0, 0);

        if (!hasVisible) {
          resolve({ src: imagePath, aspectRatio: w / Math.max(1, h), ready: true });
          return;
        }

        const cropW = Math.max(1, maxX - minX + 1);
        const cropH = Math.max(1, maxY - minY + 1);
        const croppedCanvas = document.createElement("canvas");
        croppedCanvas.width = cropW;
        croppedCanvas.height = cropH;
        const croppedCtx = croppedCanvas.getContext("2d");
        if (!croppedCtx) {
          resolve({ src: imagePath, aspectRatio: w / Math.max(1, h), ready: true });
          return;
        }

        croppedCtx.drawImage(canvas, minX, minY, cropW, cropH, 0, 0, cropW, cropH);
        resolve({
          src: croppedCanvas.toDataURL("image/png"),
          aspectRatio: cropW / cropH,
          ready: true,
        });
      } catch {
        resolve({
          src: imagePath,
          aspectRatio: img.naturalWidth / Math.max(1, img.naturalHeight),
          ready: true,
        });
      }
    };
    img.onerror = () => {
      resolve({ src: imagePath, aspectRatio: 1, ready: false });
    };
    img.src = imagePath;
  });
}

const INITIAL_PRODUCE_MAP: CleanedProduceMap = {
  mango: { src: PRODUCE_PATHS.mango, aspectRatio: 0.78, ready: false },
  awla: { src: PRODUCE_PATHS.awla, aspectRatio: 1.05, ready: false },
  tamarind: { src: PRODUCE_PATHS.tamarind, aspectRatio: 1.15, ready: false },
  behda: { src: PRODUCE_PATHS.behda, aspectRatio: 1.1, ready: false },
  cashew: { src: PRODUCE_PATHS.cashew, aspectRatio: 0.65, ready: false },
  custardApple: { src: PRODUCE_PATHS.custardApple, aspectRatio: 0.92, ready: false },
  jamun: { src: PRODUCE_PATHS.jamun, aspectRatio: 1.18, ready: false },
};

export function useCleanedProduceSet(): CleanedProduceMap {
  const [produceMap, setProduceMap] =
    useState<CleanedProduceMap>(INITIAL_PRODUCE_MAP);

  useEffect(() => {
    let cancelled = false;
    const keys = Object.keys(PRODUCE_PATHS) as ProduceKey[];

    Promise.all(
      keys.map(async (key) => {
        const cleaned = await cleanTransparentPng(PRODUCE_PATHS[key]);
        return [key, cleaned] as const;
      })
    ).then((entries) => {
      if (cancelled) return;
      const next = { ...INITIAL_PRODUCE_MAP };
      for (const [key, val] of entries) {
        next[key] = val;
      }
      setProduceMap(next);
    });

    return () => {
      cancelled = true;
    };
  }, []);

  return produceMap;
}

export function useCleanedBasket(imagePath: string): string {
  const [cleanedSrc, setCleanedSrc] = useState<string>(imagePath);

  useEffect(() => {
    let cancelled = false;
    const img = new Image();
    img.decoding = "async";
    img.onload = () => {
      if (cancelled) return;
      try {
        const w = img.naturalWidth;
        const h = img.naturalHeight;
        const canvas = document.createElement("canvas");
        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext("2d", { willReadFrequently: true });
        if (!ctx) return;

        ctx.drawImage(img, 0, 0);
        const imageData = ctx.getImageData(0, 0, w, h);
        const data = imageData.data;

        const wasOpaqueCorner = data[3] > 245;
        stripOuterWhiteBackgroundIfOpaque(data, w, h);

        let modified = wasOpaqueCorner;
        for (let i = 3; i < data.length; i += 4) {
          if (data[i] > 0 && data[i] < 18) {
            data[i] = 0;
            modified = true;
          }
        }

        if (modified && !cancelled) {
          ctx.putImageData(imageData, 0, 0);
          setCleanedSrc(canvas.toDataURL("image/png"));
        }
      } catch {
        // Keep original path on fallback
      }
    };
    img.src = imagePath;

    return () => {
      cancelled = true;
    };
  }, [imagePath]);

  return cleanedSrc;
}
