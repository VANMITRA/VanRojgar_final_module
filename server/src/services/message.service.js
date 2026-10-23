import { Message } from '../models/Message.js';

export class MessageService {
  static async getMessages(user, limit = 50) {
    return Message.find({ recipientId: user._id })
      .sort({ createdAt: -1 })
      .limit(Number(limit));
  }

  static async getUnreadCount(user) {
    const unreadCount = await Message.countDocuments({
      recipientId: user._id,
      readAt: null
    });
    return { unreadCount };
  }

  static async markAsRead(user, messageIds = []) {
    const filter = { recipientId: user._id };
    if (messageIds && messageIds.length > 0) {
      filter._id = { $in: messageIds };
    }
    await Message.updateMany(filter, { $set: { readAt: new Date() } });
    return { success: true };
  }
}
