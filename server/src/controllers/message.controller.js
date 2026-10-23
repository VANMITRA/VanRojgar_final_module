import { MessageService } from '../services/message.service.js';
import { successEnvelope } from '../core/serializers.js';

export class MessageController {
  static async getMessages(req, res, next) {
    try {
      const messages = await MessageService.getMessages(req.user, req.query.limit);
      return res.json(successEnvelope(messages));
    } catch (err) {
      next(err);
    }
  }

  static async getUnreadCount(req, res, next) {
    try {
      const count = await MessageService.getUnreadCount(req.user);
      return res.json(successEnvelope(count));
    } catch (err) {
      next(err);
    }
  }

  static async markAsRead(req, res, next) {
    try {
      const result = await MessageService.markAsRead(req.user, req.body.messageIds);
      return res.json(successEnvelope(result));
    } catch (err) {
      next(err);
    }
  }
}
