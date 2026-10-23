import { z } from 'zod';

export const createBarterSchema = z.object({
  toListId: z.string().min(1, 'Target listing is required'),
  fromListId: z.string().optional(),
  offeredTitle: z.string().min(2, 'Offered item name is required').trim(),
  offeredQuantity: z.coerce.number().positive(),
  offeredUnit: z.string().min(1),
  wantedQuantity: z.coerce.number().positive(),
  note: z.string().trim().optional()
});

export const respondBarterSchema = z.object({
  action: z.enum(['accept', 'reject', 'counter']),
  counterOfferedTitle: z.string().optional(),
  counterOfferedQuantity: z.coerce.number().positive().optional(),
  counterWantedQuantity: z.coerce.number().positive().optional(),
  note: z.string().trim().optional()
});
