/**
 * Build-time settings. Nothing secret belongs here: everything in `import.meta.env` ends up in the public bundle.
 *   VITE_API_URL  the marketplace server, e.g. https://vanrozgar-api.onrender.com (empty = show sample listings)
 *   VITE_APK_URL  where the Android app can be downloaded
 */
const DEFAULT_APK_URL = 'https://github.com/VANMITRA/VanRojgar_final_module/releases/download/website-apk/VanMitra.apk';

const clean = (value: unknown): string => String(value ?? '').trim().replace(/\/+$/, '');

export const API_URL: string = clean(import.meta.env.VITE_API_URL);
export const APK_URL: string = clean(import.meta.env.VITE_APK_URL) || DEFAULT_APK_URL;
