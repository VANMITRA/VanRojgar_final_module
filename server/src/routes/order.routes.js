import { Router } from 'express';
import { OrderController } from '../controllers/order.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { idempotencyMiddleware } from '../middleware/idempotency.js';
import { validate } from '../middleware/validate.js';
import { chooseMethodSchema, reportPaymentSchema } from '../validators/payment.schema.js';

export const orderRouter = Router();

orderRouter.get('/', authenticate, OrderController.getOrders);
orderRouter.get('/:id', authenticate, OrderController.getOrderById);
orderRouter.post('/:id/handover', authenticate, OrderController.confirmHandover);
orderRouter.post('/:id/confirm-received', authenticate, idempotencyMiddleware(), OrderController.confirmReceived);
orderRouter.post('/:id/cancel', authenticate, OrderController.cancelOrder);

// Payment: UPI (the buyer pays in their own UPI app, the seller confirms) or cash on delivery
orderRouter.post('/:id/payment/method', authenticate, validate(chooseMethodSchema), OrderController.chooseMethod);
orderRouter.get('/:id/payment/upi', authenticate, OrderController.upiLink);
orderRouter.post('/:id/payment/report', authenticate, validate(reportPaymentSchema), OrderController.reportPayment);
orderRouter.post('/:id/payment/confirm', authenticate, OrderController.confirmPayment);
orderRouter.post('/:id/payment/cash-received', authenticate, OrderController.cashReceived);
