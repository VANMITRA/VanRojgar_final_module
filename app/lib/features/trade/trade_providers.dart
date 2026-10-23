import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/trade_request.dart';
import '../../shared/models/order.dart';
import '../../shared/models/message.dart';
import '../auth/auth_providers.dart';
import 'demo_trade_data.dart';

final requestsProvider = FutureProvider.family<List<TradeRequestModel>, String>((ref, scope) async {
  try {
    final api = ref.watch(apiClientProvider);
    final res = await api.get('/requests', queryParameters: {'scope': scope});
    final list = (res as List).map((e) => TradeRequestModel.fromJson(e)).toList();
    if (list.isNotEmpty) return list;
    return DemoTradeData.getDemoRequests(scope: scope);
  } catch (_) {
    return DemoTradeData.getDemoRequests(scope: scope);
  }
});

final ordersProvider = FutureProvider.family<List<OrderModel>, String>((ref, scope) async {
  try {
    final api = ref.watch(apiClientProvider);
    final res = await api.get('/orders', queryParameters: {'scope': scope});
    final list = (res as List).map((e) => OrderModel.fromJson(e)).toList();
    if (list.isNotEmpty) return list;
    return DemoTradeData.getDemoOrders(scope: scope);
  } catch (_) {
    return DemoTradeData.getDemoOrders(scope: scope);
  }
});

final orderDetailProvider = FutureProvider.family<OrderModel, String>((ref, id) async {
  try {
    final api = ref.watch(apiClientProvider);
    final res = await api.get('/orders/$id');
    return OrderModel.fromJson(res);
  } catch (_) {
    return DemoTradeData.getDemoOrder(id);
  }
});


final messagesProvider = FutureProvider<List<MessageModel>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/messages');
  return (res as List).map((e) => MessageModel.fromJson(e)).toList();
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/messages/unread-count');
  return (res['unreadCount'] as num?)?.toInt() ?? 0;
});
