import { z } from 'zod';
import { PAYMENT_METHODS } from '../core/payment.js';

export const chooseMethodSchema = z.object({
  method: z.enum(PAYMENT_METHODS)
});

export const reportPaymentSchema = z.object({
  reference: z.string().trim().regex(/^[A-Za-z0-9]{6,35}$/, 'Enter the UPI reference (6 to 35 letters or digits)')
});
