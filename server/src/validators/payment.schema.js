import { z } from 'zod';
import { UPI_REFERENCE } from '../services/payment.service.js';

export const reportPaymentSchema = z.object({
  reference: z.string().trim().regex(UPI_REFERENCE, 'Enter the payment reference shown by your UPI app (8 to 30 letters or digits)')
});
