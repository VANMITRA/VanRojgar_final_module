import { Order } from '../models/Order.js';
import { Message } from '../models/Message.js';
import { Delivery } from '../models/Delivery.js';
import { Listing } from '../models/Listing.js';
import { AppError, ErrorCodes } from '../core/errors.js';

export class OrderService {
  static async getOrders({ user, scope = 'buying', status }) {
    const filter = {};
    if (scope === 'selling') {
      filter.sellerId = user._id;
    } else {
      filter.buyerId = user._id;
    }
    if (status) {
      filter.orderStatus = status;
    }

    return Order.find(filter)
      .populate('buyerId', 'name phone village')
      .populate('sellerId', 'name phone village')
      .populate('gramSabhaId', 'name village taluka')
      .sort({ createdAt: -1 });
  }

  static async getOrderById(id, user) {
    const order = await Order.findById(id)
      .populate('buyerId', 'name phone village city')
      .populate('sellerId', 'name phone village contactPerson')
      .populate('gramSabhaId')
      .populate('deliveryId');

    if (!order) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Order not found', 404);
    }

    const isParty = order.buyerId._id.toString() === user._id.toString() ||
                    order.sellerId._id.toString() === user._id.toString() ||
                    user.role === 'team';

    if (!isParty) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'You do not have access to this order', 403);
    }

    return order;
  }

  static async confirmHandover(id, user) {
    const order = await Order.findById(id);
    if (!order) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Order not found', 404);
    }

    if (order.sellerId.toString() !== user._id.toString()) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only the seller can confirm handover', 403);
    }

    if (!['approved', 'delivery_assigned', 'picked_up'].includes(order.orderStatus)) {
      throw new AppError(ErrorCodes.CONFLICT, `Cannot confirm handover from status '${order.orderStatus}'`, 409);
    }

    order.orderStatus = 'handed_over';
    order.timeline.push({
      status: 'handed_over',
      at: new Date(),
      actorId: user._id,
      note: 'Seller confirmed handover of produce'
    });
    await order.save();

    await Message.create({
      recipientId: order.buyerId,
      actorId: user._id,
      type: 'order_status_changed',
      orderId: order._id,
      title: { mr: 'माल सुपूर्द केला!', en: 'Produce Handed Over!' },
      body: {
        mr: `विक्रेत्याने मालाची सुपूर्दगी केली आहे`,
        en: `Seller confirmed handover of ${order.line.title.en}`
      }
    });

    return order;
  }

  static async confirmReceived(id, user) {
    const order = await Order.findById(id);
    if (!order) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Order not found', 404);
    }

    if (order.buyerId.toString() !== user._id.toString()) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'Only the buyer can confirm receipt', 403);
    }

    if (!['handed_over', 'on_the_way', 'delivered'].includes(order.orderStatus)) {
      throw new AppError(ErrorCodes.CONFLICT, `Cannot confirm receipt on order with status '${order.orderStatus}'`, 409);
    }

    order.orderStatus = 'delivered';
    order.timeline.push({
      status: 'delivered',
      at: new Date(),
      actorId: user._id,
      note: 'Buyer confirmed receipt of goods'
    });

    // Auto mark as closed
    order.timeline.push({
      status: 'closed',
      at: new Date(),
      actorId: user._id,
      note: 'Order successfully completed and closed'
    });
    order.orderStatus = 'closed';

    await order.save();

    if (order.deliveryId) {
      await Delivery.findByIdAndUpdate(order.deliveryId, {
        status: 'delivered',
        $push: {
          timeline: {
            status: 'delivered',
            at: new Date(),
            note: 'Buyer confirmed receipt'
          }
        }
      });
    }

    await Message.create({
      recipientId: order.sellerId,
      actorId: user._id,
      type: 'order_status_changed',
      orderId: order._id,
      title: { mr: 'ऑर्डर यशस्वीरीत्या पोहोचली!', en: 'Order Delivered & Completed!' },
      body: {
        mr: `खरेदीदाराने माल मिळाल्याची पुष्टी केली आहे`,
        en: `Buyer confirmed receipt of ${order.line.title.en}`
      }
    });

    return order;
  }

  static async cancelOrder(id, user, note = '') {
    const order = await Order.findById(id);
    if (!order) {
      throw new AppError(ErrorCodes.NOT_FOUND, 'Order not found', 404);
    }

    const isParty = order.buyerId.toString() === user._id.toString() ||
                    order.sellerId.toString() === user._id.toString() ||
                    user.role === 'team';

    if (!isParty) {
      throw new AppError(ErrorCodes.FORBIDDEN, 'You do not have access to cancel this order', 403);
    }

    if (['handed_over', 'delivered', 'closed', 'cancelled'].includes(order.orderStatus)) {
      throw new AppError(ErrorCodes.CONFLICT, `Cannot cancel an order with status '${order.orderStatus}'`, 409);
    }

    order.orderStatus = 'cancelled';
    order.timeline.push({
      status: 'cancelled',
      at: new Date(),
      actorId: user._id,
      note: note || 'Order cancelled'
    });
    await order.save();

    // Restore stock to listing
    if (order.line?.listingId && order.line?.quantity) {
      await Listing.findByIdAndUpdate(order.line.listingId, {
        $inc: { quantityAvailable: order.line.quantity }
      }).catch(() => {});
    }

    // Cancel delivery job if pending
    if (order.deliveryId) {
      await Delivery.findByIdAndUpdate(order.deliveryId, {
        status: 'cancelled',
        $push: {
          timeline: {
            status: 'cancelled',
            at: new Date(),
            note: 'Associated order was cancelled'
          }
        }
      }).catch(() => {});
    }

    // Notify other party
    const otherPartyId = user._id.toString() === order.buyerId.toString() ? order.sellerId : order.buyerId;
    await Message.create({
      recipientId: otherPartyId,
      actorId: user._id,
      type: 'order_status_changed',
      orderId: order._id,
      title: { mr: 'ऑर्डर रद्द झाली', en: 'Order Cancelled' },
      body: {
        mr: `ऑर्डर रद्द करण्यात आली: ${note || 'कोणतेही कारण नमूद केलेले नाही'}`,
        en: `Order was cancelled: ${note || 'No reason provided'}`
      }
    });

    return order;
  }
}
