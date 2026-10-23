import { OrderService } from '../services/order.service.js';
import { successEnvelope } from '../core/serializers.js';

export class OrderController {
  static async getOrders(req, res, next) {
    try {
      const orders = await OrderService.getOrders({
        user: req.user,
        scope: req.query.scope,
        status: req.query.status
      });
      return res.json(successEnvelope(orders));
    } catch (err) {
      next(err);
    }
  }

  static async getOrderById(req, res, next) {
    try {
      const order = await OrderService.getOrderById(req.params.id, req.user);
      return res.json(successEnvelope(order));
    } catch (err) {
      next(err);
    }
  }

  static async confirmHandover(req, res, next) {
    try {
      const order = await OrderService.confirmHandover(req.params.id, req.user);
      return res.json(successEnvelope(order));
    } catch (err) {
      next(err);
    }
  }

  static async confirmReceived(req, res, next) {
    try {
      const order = await OrderService.confirmReceived(req.params.id, req.user);
      return res.json(successEnvelope(order));
    } catch (err) {
      next(err);
    }
  }

  static async cancelOrder(req, res, next) {
    try {
      const order = await OrderService.cancelOrder(req.params.id, req.user, req.body.note);
      return res.json(successEnvelope(order));
    } catch (err) {
      next(err);
    }
  }
}
