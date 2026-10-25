import { z } from 'zod';
import { REGISTER_ROLES, VILLAGE_ROLES } from '../core/roles.js';

export const phoneSchema = z.string().trim().transform((val) => {
  const digits = val.replace(/\D/g, '');
  if (digits.length === 10) {
    return `+91${digits}`;
  }
  if (digits.length === 12 && digits.startsWith('91')) {
    return `+${digits}`;
  }
  if (val.startsWith('+') && digits.length >= 10) {
    return `+${digits}`;
  }
  return val;
}).refine((val) => /^\+91[6-9]\d{9}$/.test(val), {
  message: 'Valid 10-digit Indian mobile number required'
});

// The password of a village user, a Gram Sabha or a buyer is a 6-digit PIN (the API field keeps the
// name `password`). Back-office accounts are seeded with a stronger password and only log in.
export const passwordSchema = z.string()
  .regex(/^\d{6}$/, 'PIN must be exactly 6 digits');

export const registerSchema = z.object({
  role: z.enum(REGISTER_ROLES),
  name: z.string().min(2, 'Name is required').trim(),
  phone: phoneSchema,
  password: passwordSchema,
  language: z.enum(['en', 'hi', 'mr']).default('en'),
  // Role specific fields
  village: z.string().trim().optional(),
  taluka: z.string().trim().optional(),
  district: z.string().trim().default('Nashik'),
  contactPerson: z.string().trim().optional(),
  cfrDetail: z.string().trim().optional(),
  gramSabhaId: z.string().trim().optional(),
  businessName: z.string().trim().optional(),
  city: z.string().trim().optional(),
  email: z.string().email('Invalid email address').trim().optional().or(z.literal(''))
}).superRefine((data, ctx) => {
  if (data.role === 'gramsabha') {
    if (!data.village || !data.taluka) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['village'],
        message: 'Village and taluka are required for Gram Sabha registration'
      });
    }
  }
  if (data.role === 'villager' || data.role === 'cfrholder') {
    if (!data.village) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['village'],
        message: 'Village is required for Farmer and CFR holder registration'
      });
    }
  }
  if (VILLAGE_ROLES.includes(data.role) && data.district) {
    if (data.district.trim().toLowerCase() !== 'nashik') {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['village'],
        message: 'Only Nashik pilot villages are eligible during prototype phase'
      });
    }
  }
});

export const loginSchema = z.object({
  phone: phoneSchema,
  password: z.string().min(1, 'Password is required')
});

export const updateProfileSchema = z.object({
  name: z.string().min(2).trim().optional(),
  email: z.string().email().trim().optional().or(z.literal('')),
  businessName: z.string().trim().optional(),
  city: z.string().trim().optional(),
  language: z.enum(['en', 'hi', 'mr']).optional()
});
