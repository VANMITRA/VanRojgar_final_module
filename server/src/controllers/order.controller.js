import { OrderService } from '../services/order.service.js';
import { PaymentService } from '../services/payment.service.js';
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

  static async chooseMethod(req, res, next) {
    try {
      return res.json(successEnvelope(await PaymentService.chooseMethod(req.params.id, req.user, req.body.method)));
    } catch (err) {
      next(err);
    }
  }

  static async upiLink(req, res, next) {
    try {
      return res.json(successEnvelope(await PaymentService.upiLink(req.params.id, req.user)));
    } catch (err) {
      next(err);
    }
  }

  static async reportPayment(req, res, next) {
    try {
      return res.json(successEnvelope(await PaymentService.reportPayment(req.params.id, req.user, req.body.reference)));
    } catch (err) {
      next(err);
    }
  }

  static async confirmPayment(req, res, next) {
    try {
      return res.json(successEnvelope(await PaymentService.confirmPayment(req.params.id, req.user)));
    } catch (err) {
      next(err);
    }
  }

  static async cashReceived(req, res, next) {
    try {
      return res.json(successEnvelope(await PaymentService.cashReceived(req.params.id, req.user)));
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
