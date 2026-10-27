import { z } from 'zod';
import { unitEnum } from './listing.schema.js';

export const productsQuerySchema = z.object({
  q: z.string().trim().optional(),
  category: z.string().trim().optional(), // category slug
  sort: z.enum(['popular', 'price_asc', 'discount_desc', 'newest']).default('popular'),
  limit: z.coerce.number().min(1).max(50).default(24),
  cursor: z.string().optional()
});

export const sellersQuerySchema = z.object({
  unit: unitEnum.optional(),
  sort: z.enum(['price_asc', 'discount_desc', 'newest']).default('price_asc')
});

export const stockQuerySchema = z.object({
  ids: z.string().trim().min(1, 'ids is required').transform((v) => v.split(',').map((s) => s.trim()).filter(Boolean))
    .refine((list) => list.length >= 1 && list.length <= 50, 'Give between 1 and 50 listing ids')
    .refine((list) => list.every((id) => /^[a-f0-9]{24}$/i.test(id)), 'Every id must be a valid listing id')
});

export const cartCheckoutSchema = z.object({
  items: z.array(z.object({
    listingId: z.string().min(1, 'Listing ID is required'),
    quantity: z.coerce.number().positive('Quantity must be greater than zero')
  })).min(1, 'The cart is empty').max(20, 'At most 20 products in one checkout'),
  deliveryPref: z.enum(['pickup', 'delivery']).default('pickup'),
  paymentMethod: z.enum(['upi', 'cod']).default('cod'),
  dropVillage: z.string().trim().optional(),
  reason: z.string().trim().optional()
}).refine((d) => new Set(d.items.map((i) => i.listingId)).size === d.items.length, {
  message: 'The same product appears twice. Add up its quantity instead.',
  path: ['items']
});
