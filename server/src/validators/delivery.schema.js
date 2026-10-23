import { z } from 'zod';

export const deliveryApplicationSchema = z.object({
  vehicleType: z.enum(['bike', 'tempo', 'pickup', 'tractor']),
  vehicleNumber: z.string().min(3).trim(),
  capacityKg: z.coerce.number().positive(),
  licenceNumber: z.string().min(4).trim(),
  serviceTalukas: z.array(z.string().trim()).min(1, 'Select at least one taluka to serve')
});

export const updateAvailabilitySchema = z.object({
  available: z.boolean()
});

export const updateDeliveryStatusSchema = z.object({
  status: z.enum(['picked_up', 'on_the_way', 'delivered']),
  note: z.string().trim().optional()
});
