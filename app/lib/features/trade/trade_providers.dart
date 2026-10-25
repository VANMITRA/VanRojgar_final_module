import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/trade_request.dart';
import '../../shared/models/order.dart';
import '../../shared/models/message.dart';
import '../auth/auth_providers.dart';

// These always show what the server returned. An empty list is shown as empty, and a failed call is shown as an
// error with a retry: the app never fills the screen with invented requests or orders.

final requestsProvider = FutureProvider.family<List<TradeRequestModel>, String>((ref, scope) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/requests', queryParameters: {'scope': scope});
  return (res as List).map((e) => TradeRequestModel.fromJson(e)).toList();
});

final ordersProvider = FutureProvider.family<List<OrderModel>, String>((ref, scope) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/orders', queryParameters: {'scope': scope});
  return (res as List).map((e) => OrderModel.fromJson(e)).toList();
});

final orderDetailProvider = FutureProvider.family<OrderModel, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/orders/$id');
  return OrderModel.fromJson(res);
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
