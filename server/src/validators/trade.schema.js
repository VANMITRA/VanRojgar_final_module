import { z } from 'zod';

export const createRequestSchema = z.object({
  listingId: z.string().min(1, 'Listing ID is required'),
  quantity: z.coerce.number().positive('Quantity must be greater than zero'),
  deliveryPref: z.enum(['pickup', 'delivery']).default('pickup'),
  dropVillage: z.string().trim().optional(),
  reason: z.string().trim().optional()
});

export const updateRequestStatusSchema = z.object({
  action: z.enum(['approve', 'reject', 'cancel']),
  note: z.string().trim().optional()
}).superRefine((data, ctx) => {
  if (data.action === 'reject') {
    const trimmed = (data.note || '').trim();
    if (trimmed.length < 5 || trimmed.length > 300) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['note'],
        message: 'Reason is required (min 5 characters)'
      });
    }
  }
});

export const counterRequestSchema = z.object({
  quantity: z.coerce.number().positive().optional(),
  pricePerUnitRupees: z.coerce.number().min(0).optional(),
  note: z.string().trim().optional()
}).refine(data => data.quantity !== undefined || data.pricePerUnitRupees !== undefined, {
  message: 'Counter offer must specify at least new quantity or price'
});

export const counterRespondSchema = z.object({
  action: z.enum(['accept', 'decline']),
  note: z.string().trim().optional()
});
