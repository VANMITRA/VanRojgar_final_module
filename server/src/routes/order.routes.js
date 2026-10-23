import { Router } from 'express';
import { OrderController } from '../controllers/order.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { idempotencyMiddleware } from '../middleware/idempotency.js';

export const orderRouter = Router();

orderRouter.get('/', authenticate, OrderController.getOrders);
orderRouter.get('/:id', authenticate, OrderController.getOrderById);
orderRouter.post('/:id/handover', authenticate, OrderController.confirmHandover);
orderRouter.post('/:id/confirm-received', authenticate, idempotencyMiddleware(), OrderController.confirmReceived);
orderRouter.post('/:id/cancel', authenticate, OrderController.cancelOrder);
