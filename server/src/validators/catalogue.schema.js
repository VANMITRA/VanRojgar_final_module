import { z } from 'zod';

export const createResourceSchema = z.object({
  nameMr: z.string().min(1, 'Marathi name is required').trim(),
  nameEn: z.string().min(1, 'English name is required').trim(),
  categoryId: z.string().regex(/^[0-9a-fA-F]{24}$/, 'Invalid category ID'),
  unit: z.enum(['kg', 'g', 'quintal', 'litre', 'piece', 'bundle', 'jar', 'bag']).default('kg'),
  seasonMonths: z.array(z.number().int().min(1).max(12)).optional(),
  description: z.string().trim().optional(),
});
