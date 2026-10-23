import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const configSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(3000),
  MONGODB_URI: z.string().min(1).default('mongodb://127.0.0.1:27017/vanrozgar'),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),
  GIT_SHA: z.string().default('unknown'),
  CORS_ORIGINS: z.string().default(''),
  JWT_SECRET: z.string().min(16).default('vanrozgar-default-dev-secret-super-safe-key-12345'),
  JWT_EXPIRES_IN: z.string().default('7d'),
  BCRYPT_COST: z.coerce.number().default(10),
  BULK_THRESHOLDS: z.string().default('{"mass_kg":50,"volume_l":50,"count":100}'),
  ALLOW_VILLAGER_LISTINGS: z.string().transform(v => v === 'true').default('true'),
  RATE_LIMIT_LOGIN: z.string().default('120/15m'),
  RATE_LIMIT_SEARCH: z.string().default('120/1m'),
  DELIVERY_RATE_PAISE_PER_KM: z.coerce.number().default(1200),
  SEED_DEMO_PASSWORD: z.string().default('123456'),
  SEED_TEAM_PASSWORD: z.string().default('VanMitraAdmin@2026'),
});

const parsed = configSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ Invalid environment variables:', JSON.stringify(parsed.error.format(), null, 2));
  throw new Error('Environment configuration validation failed');
}

export function parseRateLimit(str, defaultMax = 60, defaultWindowSeconds = 60) {
  if (!str) return { max: defaultMax, windowSeconds: defaultWindowSeconds };
  const match = String(str).match(/^(\d+)\/(\d+)?([smhd])?$/);
  if (!match) return { max: defaultMax, windowSeconds: defaultWindowSeconds };
  const max = parseInt(match[1], 10);
  const num = match[2] ? parseInt(match[2], 10) : 1;
  const unit = match[3] || 's';
  const multipliers = { s: 1, m: 60, h: 3600, d: 86400 };
  const windowSeconds = num * (multipliers[unit] || 60);
  return { max, windowSeconds };
}

if (parsed.data.NODE_ENV === 'production' && (!process.env.MONGODB_URI || !process.env.JWT_SECRET)) {
  throw new Error('MONGODB_URI and JWT_SECRET must be set in production');
}

export const config = {
  ...parsed.data,
  bulkThresholds: JSON.parse(parsed.data.BULK_THRESHOLDS)
};
