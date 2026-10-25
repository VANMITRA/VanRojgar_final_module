import { z } from 'zod';
import { PRODUCT_CODE_PATTERN } from '../core/productCode.js';

const productCode = z.string().trim().toLowerCase().regex(PRODUCT_CODE_PATTERN, 'Product code must be lowercase letters and hyphens');

export const unitEnum = z.enum(['kg', 'g', 'quintal', 'litre', 'piece', 'bundle', 'jar', 'bag']);

export const createListingSchema = z.object({
  titleMr: z.string().min(2, 'Marathi title is required').trim(),
  titleEn: z.string().min(2, 'English title is required').trim(),
  categoryId: z.string().min(1, 'Category is required'),
  productCode: productCode.optional(),
  description: z.string().trim().optional(),
  quantityAvailable: z.coerce.number().positive('Quantity must be greater than zero'),
  unit: unitEnum,
  pricePerUnitRupees: z.coerce.number().min(0, 'Price must be non-negative'),
  mode: z.enum(['sell', 'barter', 'both']).default('sell'),
  barterWants: z.string().trim().optional(),
  sourceForestArea: z.string().trim().optional(),
  collectionNote: z.string().trim().optional(),
  sustainableDeclared: z.boolean().refine(val => val === true, {
    message: 'Sustainability declaration must be confirmed'
  }),
  fulfilment: z.enum(['pickup', 'delivery', 'both']).default('both'),
  latitude: z.coerce.number().optional(),
  longitude: z.coerce.number().optional(),
  village: z.string().trim().optional(),
  taluka: z.string().trim().optional()
}).refine(data => {
  if (data.mode === 'barter' || data.mode === 'both') {
    return Boolean(data.barterWants && data.barterWants.length >= 2);
  }
  return true;
}, {
  message: 'Barter wishlist details are required when mode includes barter',
  path: ['barterWants']
});

export const updateListingSchema = z.object({
  titleMr: z.string().min(2).trim().optional(),
  titleEn: z.string().min(2).trim().optional(),
  description: z.string().trim().optional(),
  productCode: productCode.optional(),
  quantityAvailable: z.coerce.number().min(0).optional(),
  pricePerUnitRupees: z.coerce.number().min(0).optional(),
  mode: z.enum(['sell', 'barter', 'both']).optional(),
  barterWants: z.string().trim().optional(),
  status: z.enum(['active', 'paused', 'sold_out', 'rejected']).optional(),
  fulfilment: z.enum(['pickup', 'delivery', 'both']).optional()
});

export const updateListingStatusSchema = z.object({
  status: z.enum(['active', 'paused', 'sold_out', 'rejected'])
});
