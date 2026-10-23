import { z } from 'zod';

export const searchQuerySchema = z.object({
  q: z.string().trim().optional(),
  category: z.string().trim().optional(),
  minPrice: z.coerce.number().min(0).optional(),
  maxPrice: z.coerce.number().min(0).optional(),
  minQty: z.coerce.number().min(0).optional(),
  taluka: z.string().trim().optional(),
  district: z.string().trim().optional(),
  mode: z.enum(['sell', 'barter', 'both']).optional(),
  verifiedOnly: z.enum(['true', 'false']).transform(v => v === 'true').optional(),
  lat: z.coerce.number().optional(),
  lng: z.coerce.number().optional(),
  radiusKm: z.coerce.number().positive().optional(),
  sort: z.enum(['nearest', 'price_asc', 'price_desc', 'rating_desc', 'newest']).default('newest'),
  limit: z.coerce.number().min(1).max(50).default(20),
  cursor: z.string().optional()
});
