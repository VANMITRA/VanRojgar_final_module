import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/models/community_models.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/providers/community_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';

/// Shared helpers for the Round 2 tests (delivery, messages, barter). Only small inline data is used.

const AuthUser cfrUser = AuthUser(name: 'Ramesh Madavi', role: 'cfrholder', phone: '+919823012345', villageId: 'dongargaon');
const AuthUser gramSabhaUser = AuthUser(name: 'Sunita Gram Sabha', role: 'gramsabha', phone: '+919823099999', villageId: 'bhatode');
const AuthUser buyerUser = AuthUser(name: 'Kiran More', role: 'buyer', phone: '+919876543210');

class FakeDelivery implements DeliveryRepository {
  DeliveryPartnerProfile? profile;
  List<DeliveryJob> open;
  List<DeliveryJob> mine;
  bool failActions = false;
  final List<String> calls = [];

  FakeDelivery({this.profile, this.open = const [], this.mine = const []});

  @override
  Future<DeliveryPartnerProfile?> myProfile() async => profile;

  @override
  Future<void> apply(DeliveryApplication a) async {
    calls.add('apply:${a.vehicleType}:${a.vehicleNumber}:${a.capacityKg}:${a.licenceNumber}:${a.serviceTalukas.join('+')}');
    if (failActions) throw StateError('boom');
    profile = DeliveryPartnerProfile(
      approvalStatus: 'pending',
      vehicleType: a.vehicleType,
      vehicleNumber: a.vehicleNumber,
      capacityKg: a.capacityKg,
      serviceTalukas: a.serviceTalukas,
      available: false,
      earningsPaise: 0,
      jobsCompleted: 0,
    );
  }

  @override
  Future<void> setAvailable(bool available) async {
    calls.add('available:$available');
    if (failActions) throw StateError('boom');
    final p = profile!;
    profile = DeliveryPartnerProfile(
      approvalStatus: p.approvalStatus,
      vehicleType: p.vehicleType,
      vehicleNumber: p.vehicleNumber,
      capacityKg: p.capacityKg,
      serviceTalukas: p.serviceTalukas,
      available: available,
      earningsPaise: p.earningsPaise,
      jobsCompleted: p.jobsCompleted,
    );
  }

  @override
  Future<List<DeliveryJob>> openJobs() async => open;

  @override
  Future<void> acceptJob(String jobId) async {
    calls.add('accept:$jobId');
    if (failActions) throw StateError('boom');
    final job = open.firstWhere((j) => j.id == jobId);
    open = open.where((j) => j.id != jobId).toList();
    mine = [...mine, copyJob(job, status: 'accepted')];
  }

  @override
  Future<void> updateJobStatus(String jobId, String status, {String? note}) async {
    calls.add('status:$jobId:$status');
    if (failActions) throw StateError('boom');
    mine = [for (final j in mine) j.id == jobId ? copyJob(j, status: status) : j];
  }

  @override
  Future<List<DeliveryJob>> myJobs() async => mine;
}

DeliveryJob copyJob(DeliveryJob j, {String? status}) => DeliveryJob(
      id: j.id,
      pickupVillage: j.pickupVillage,
      pickupTaluka: j.pickupTaluka,
      dropVillage: j.dropVillage,
      dropTaluka: j.dropTaluka,
      goodsSummary: j.goodsSummary,
      weightKg: j.weightKg,
      distanceKm: j.distanceKm,
      feePaise: j.feePaise,
      collectCashPaise: j.collectCashPaise,
      cashCollected: j.cashCollected,
      status: status ?? j.status,
      timeline: j.timeline,
    );

DeliveryPartnerProfile partner({
  String status = 'approved',
  bool available = true,
  int earningsPaise = 125000,
  int jobsCompleted = 7,
  String? reviewNote,
}) =>
    DeliveryPartnerProfile(
      approvalStatus: status,
      vehicleType: 'tempo',
      vehicleNumber: 'MH15 AB 1234',
      capacityKg: 800,
      serviceTalukas: const ['Deola'],
      available: available,
      earningsPaise: earningsPaise,
      jobsCompleted: jobsCompleted,
      reviewNote: reviewNote,
    );

DeliveryJob job(
  String id, {
  String status = 'available',
  int collectCashPaise = 0,
  String goods = '40 kg bamboo baskets',
  List<DeliveryStep> timeline = const [],
}) =>
    DeliveryJob(
      id: id,
      pickupVillage: 'Dongargaon',
      pickupTaluka: 'Deola',
      dropVillage: 'Bhatode',
      dropTaluka: 'Dindori',
      goodsSummary: goods,
      weightKg: 40,
      distanceKm: 12.5,
      feePaise: 45000,
      collectCashPaise: collectCashPaise,
      status: status,
      timeline: timeline,
    );

class FakeMessages implements MessagesRepository {
  List<AppMessage> items;
  final List<String> readIds = [];

  FakeMessages(this.items);

  @override
  Future<List<AppMessage>> messages() async => items;

  @override
  Future<int> unreadCount() async => items.where((m) => !m.isRead).length;

  @override
  Future<void> markRead(List<String> messageIds) async {
    readIds.addAll(messageIds);
    items = [
      for (final m in items)
        messageIds.contains(m.id)
            ? AppMessage(
                id: m.id,
                type: m.type,
                title: m.title,
                body: m.body,
                orderId: m.orderId,
                requestId: m.requestId,
                barterId: m.barterId,
                readAt: DateTime(2026, 10, 29),
                createdAt: m.createdAt,
              )
            : m,
    ];
  }
}

AppMessage message(
  String id, {
  bool read = false,
  String? orderId,
  String? requestId,
  String? barterId,
  DateTime? createdAt,
}) =>
    AppMessage(
      id: id,
      type: 'request_received',
      title: {'en': 'New request $id', 'mr': 'नवीन मागणी $id'},
      body: {'en': 'A buyer sent a request $id.', 'mr': 'खरेदीदाराने मागणी पाठवली $id.'},
      orderId: orderId,
      requestId: requestId,
      barterId: barterId,
      readAt: read ? DateTime(2026, 10, 28) : null,
      createdAt: createdAt ?? DateTime(2026, 10, 28, 10),
    );

class FakeBarter implements BarterRepository {
  List<BarterOffer> incoming;
  List<BarterOffer> outgoing;
  bool failActions = false;
  final List<String> calls = [];
  NewBarterOffer? created;

  FakeBarter({this.incoming = const [], this.outgoing = const []});

  @override
  Future<List<BarterOffer>> offers({required bool incoming}) async => incoming ? this.incoming : outgoing;

  @override
  Future<void> create(NewBarterOffer offer) async {
    calls.add('create');
    if (failActions) throw StateError('boom');
    created = offer;
  }

  @override
  Future<void> respond(
    String offerId,
    String action, {
    String? counterOfferedTitle,
    int? counterOfferedQuantity,
    int? counterWantedQuantity,
    String? note,
  }) async {
    calls.add('$action:$offerId:${counterOfferedTitle ?? ''}:${counterOfferedQuantity ?? ''}:${counterWantedQuantity ?? ''}:${note ?? ''}');
    if (failActions) throw StateError('boom');
    final status = action == 'accept' ? 'accepted' : (action == 'reject' ? 'rejected' : 'countered');
    BarterOffer update(BarterOffer o) => o.id != offerId ? o : barterOffer(o.id, incoming: o.isIncoming, status: status);
    incoming = incoming.map(update).toList();
    outgoing = outgoing.map(update).toList();
  }
}

BarterOffer barterOffer(String id, {bool incoming = true, String status = 'pending'}) => BarterOffer(
      id: id,
      status: status,
      wantedListingId: 'L$id',
      wantedTitle: 'Bamboo basket',
      wantedUnit: 'piece',
      offeredTitle: 'Rice',
      offeredQuantity: 20,
      offeredUnit: 'kg',
      wantedQuantity: 10,
      note: 'Fresh rice',
      isIncoming: incoming,
      otherPartyName: 'Asha Patil',
      versions: [
        BarterVersion(
          version: 1,
          offeredTitle: 'Rice',
          offeredQuantity: 20,
          offeredUnit: 'kg',
          wantedQuantity: 10,
          note: 'Fresh rice',
          at: DateTime(2026, 10, 20),
        ),
        BarterVersion(
          version: 2,
          offeredTitle: 'Rice',
          offeredQuantity: 25,
          offeredUnit: 'kg',
          wantedQuantity: 10,
          at: DateTime(2026, 10, 21),
        ),
      ],
      createdAt: DateTime(2026, 10, 20),
    );

Widget communityApp({
  AppLanguage language = AppLanguage.en,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1.0,
  AuthUser? user,
  DeliveryRepository? delivery,
  MessagesRepository? messages,
  BarterRepository? barter,
  List<Override> extra = const [],
}) {
  return ProviderScope(
    overrides: [
      uiV2LanguageProvider.overrideWith((ref) => language),
      uiV2ThemeModeProvider.overrideWith((ref) => mode),
      authUserProvider.overrideWith((ref) => user),
      if (delivery != null) deliveryRepositoryProvider.overrideWithValue(delivery),
      if (messages != null) messagesRepositoryProvider.overrideWithValue(messages),
      if (barter != null) barterRepositoryProvider.overrideWithValue(barter),
      ...extra,
    ],
    child: MaterialApp.router(
      theme: VanRozgarTheme.lightTheme,
      darkTheme: VanRozgarTheme.darkTheme,
      themeMode: mode,
      routerConfig: uiV2Router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
    ),
  );
}

void tall(WidgetTester tester, {double w = 360, double h = 1800}) {
  tester.view.physicalSize = Size(w * 2.0, h * 2.0);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> openPath(WidgetTester tester, Widget app, String path) async {
  uiV2LandingSeen.value = true;
  uiV2Router.go(path);
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

/// Letters of the Latin alphabet that are allowed on Hindi and Marathi screens: brand and place names, UPI, Google.
final RegExp _latin = RegExp(r'[A-Za-z]{2,}');

/// Every visible [Text] on screen that has English words (other than [allowed] words).
List<String> englishTexts(WidgetTester tester, {Set<String> allowed = const {}}) {
  final found = <String>[];
  for (final w in tester.widgetList<Text>(find.byType(Text))) {
    final text = w.data ?? w.textSpan?.toPlainText() ?? '';
    var rest = text;
    for (final a in allowed) {
      rest = rest.replaceAll(a, '');
    }
    if (_latin.hasMatch(rest)) found.add(text);
  }
  return found;
}
