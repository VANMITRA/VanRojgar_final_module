import { z } from 'zod';

export const verifyGramSabhaSchema = z.object({
  status: z.enum(['verified', 'rejected']),
  note: z.string().trim().optional()
});

export const reviewPartnerSchema = z.object({
  status: z.enum(['approved', 'rejected', 'paused']),
  note: z.string().trim().optional()
});

export const createRestrictedItemSchema = z.object({
  nameMr: z.string().min(2).trim(),
  nameEn: z.string().min(2).trim(),
  terms: z.array(z.string().trim().min(2)).min(1),
  reasonMr: z.string().min(2).trim(),
  reasonEn: z.string().min(2).trim(),
  schedule: z.string().trim().optional()
});
