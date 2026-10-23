import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/app_exception.dart';
import '../security/token_store.dart';

/// Offline demo backend that lives inside the app. It answers the same API calls as the
/// real server from data stored on the phone, so the app can be shown with no PC/server.
/// Activated automatically when a demo account logs in while the server is unreachable.
class DemoBackend {
  static const _kActive = 'vr_demo_mode';
  static const _kState = 'vr_demo_state_v1';
  static const _bulk = {'mass': 50, 'count': 100};
  static bool _loaded = false;
  static bool _active = false;
  static late Map<String, dynamic> _s;
  static int _seq = 0;

  static Future<bool> isActive() async {
    if (!_loaded) {
      final sp = await SharedPreferences.getInstance();
      _active = sp.getBool(_kActive) ?? false;
      _loaded = true;
      if (_active) await _loadState();
    }
    return _active;
  }

  static Future<void> deactivate() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kActive, false);
    _active = false;
    _loaded = true;
  }

  /// True when [phone]/[password] belong to a built-in demo account.
  static Future<bool> canLogin(String phone, String password) async {
    await _ensureSeeded();
    return _findUser(phone, password) != null;
  }

  static Future<void> activate() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kActive, true);
    _active = true;
    _loaded = true;
    await _loadState();
  }

  // ---------------------------------------------------------------- state
  static Future<void> _ensureSeeded() async {
    if (_loaded && _hasState) return;
    await _loadState();
  }

  static bool get _hasState => _loadedState;
  static bool _loadedState = false;

  static Future<void> _loadState() async {
    if (_loadedState) return;
    final sp = await SharedPreferences.getInstance();
    final saved = sp.getString(_kState);
    if (saved != null) {
      _s = jsonDecode(saved) as Map<String, dynamic>;
    } else {
      _s = await _buildSeed();
    }
    _seq = DateTime.now().millisecondsSinceEpoch % 100000000;
    _loadedState = true;
  }

  static Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kState, jsonEncode(_s));
  }

  static String _id(String p) => '$p${(_seq++).toRadixString(36)}';

  static Future<Map<String, dynamic>> _buildSeed() async {
    final raw = jsonDecode(await rootBundle.loadString('assets/demo/seed.json')) as Map<String, dynamic>;
    final cats = <Map<String, dynamic>>[];
    for (final c in raw['categories'] as List) {
      cats.add({'_id': 'cat_${c['slug']}', ...Map<String, dynamic>.from(c as Map)});
    }
    final gss = <Map<String, dynamic>>[];
    for (final v in raw['villages'] as List) {
      gss.add({
        '_id': 'gs_${v['villageEn']}'.toLowerCase(),
        'name': {'mr': 'ग्रामसभा ${v['villageMr']}', 'en': '${v['villageEn']} Gram Sabha (demo label)'},
        'village': {'mr': v['villageMr'], 'en': v['villageEn']},
        'taluka': 'Nashik',
        'district': 'Nashik',
        'verificationStatus': 'verified_seed',
        'cfr': {'rights': [], 'approvedAreaHa': 0, 'claimCount': 0},
      });
    }
    final users = <Map<String, dynamic>>[];
    for (final a in raw['accounts'] as List) {
      final role = a['role'] as String;
      final gs = gss.where((g) => g['village']['mr'] == a['village']).toList();
      users.add({
        '_id': 'u_${(a['phone'] as String).substring(3)}',
        'name': a['name'],
        'phone': a['phone'],
        'role': role,
        'language': a['language'] ?? 'mr',
        'village': a['village'],
        'taluka': a['taluka'],
        'district': 'Nashik',
        'businessName': a['businessName'],
        'city': a['city'],
        'gramSabhaId': gs.isEmpty ? null : gs.first['_id'],
        'isDeliveryApplicant': false,
        'status': 'active',
        'password': role == 'team' ? 'VanMitraAdmin@2026' : 'VanRozgar@2026',
      });
    }
    final listings = <Map<String, dynamic>>[];
    var n = 0;
    for (final l in raw['listings'] as List) {
      final gs = gss.firstWhere((g) => g['village']['mr'] == l['village']);
      final owner = users.firstWhere((u) => u['role'] == 'gramsabha' && u['gramSabhaId'] == gs['_id']);
      final cat = cats.firstWhere((c) => c['slug'] == l['categorySlug']);
      listings.add({
        '_id': 'l_${(n++).toString().padLeft(3, '0')}',
        'ownerType': 'gramsabha',
        'ownerId': owner['_id'],
        'gramSabhaId': gs['_id'],
        'title': {'mr': l['titleMr'], 'en': l['titleEn']},
        'categoryId': cat['_id'],
        'description': l['description'],
        'quantityAvailable': l['quantityAvailable'],
        'unit': l['unit'],
        'pricePerUnitPaise': (l['pricePerUnitRupees'] as num).toInt() * 100,
        'mode': l['mode'],
        'village': l['village'],
        'taluka': 'Nashik',
        'district': 'Nashik',
        'status': 'active',
        'provenance': {'sourceForestArea': 'Cultivated / approved source (demo)', 'sustainableDeclared': true},
        'fulfilment': 'both',
        'flags': {'rightsNotOnRecord': false},
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    return {
      'categories': cats,
      'gramsabhas': gss,
      'users': users,
      'listings': listings,
      'requests': <dynamic>[],
      'orders': <dynamic>[],
      'messages': <dynamic>[],
      'partners': <dynamic>[],
      'deliveries': <dynamic>[],
    };
  }

  // -------------------------------------------------------------- helpers
  static List<Map<String, dynamic>> _list(String k) =>
      (_s[k] as List).map((e) => e as Map<String, dynamic>).toList();

  static Map<String, dynamic>? _findUser(String phone, String password) {
    if (!_loadedState) return null;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final norm = '+91${digits.length > 10 ? digits.substring(digits.length - 10) : digits}';
    for (final u in _list('users')) {
      if (u['phone'] == norm && u['password'] == password) return u;
    }
    return null;
  }

  static Map<String, dynamic> _publicUser(Map<String, dynamic> u) => {...u}..remove('password');

  static Future<Map<String, dynamic>?> _me() async {
    final t = await TokenStore.getToken();
    if (t == null || !t.startsWith('demo.')) return null;
    final id = t.substring(5);
    for (final u in _list('users')) {
      if (u['_id'] == id) return u;
    }
    return null;
  }

  static AppException _err(String code, String msg, {Map<String, dynamic>? fields}) =>
      AppException(code: code, message: msg, fields: fields);

  static Map<String, dynamic> _gs(String id) => _list('gramsabhas').firstWhere((g) => g['_id'] == id);

  static Map<String, dynamic> _listingOut(Map<String, dynamic> l, {bool withGs = false}) {
    final out = {...l};
    if (withGs) out['gramSabha'] = _gs(l['gramSabhaId'] as String);
    return out;
  }

  static Map<String, dynamic> _userRef(String id) {
    final u = _list('users').firstWhere((x) => x['_id'] == id, orElse: () => {});
    return {'_id': id, 'name': u['name'], 'phone': u['phone'], 'village': u['village'], 'city': u['city']};
  }

  static Map<String, dynamic> _reqOut(Map<String, dynamic> r) {
    final l = _list('listings').firstWhere((x) => x['_id'] == r['listingId']);
    return {...r, 'listingId': l, 'requesterId': _userRef(r['requesterId'] as String), 'sellerId': _userRef(r['sellerId'] as String)};
  }

  static Map<String, dynamic> _orderOut(Map<String, dynamic> o) =>
      {...o, 'buyerId': _userRef(o['buyerId'] as String), 'sellerId': _userRef(o['sellerId'] as String)};

  static void _msg(String to, String type, String titleMr, String titleEn, String bodyMr, String bodyEn) {
    (_s['messages'] as List).insert(0, {
      '_id': _id('m_'), 'recipientId': to, 'type': type,
      'title': {'mr': titleMr, 'en': titleEn}, 'body': {'mr': bodyMr, 'en': bodyEn},
      'readAt': null, 'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static int _threshold(String unit) => ['kg', 'g', 'quintal', 'litre'].contains(unit) ? _bulk['mass']! : _bulk['count']!;

  // ---------------------------------------------------------------- router
  /// Returns the API `data` payload, or throws [AppException] like the real client.
  static Future<dynamic> handle(String method, String path, {Map<String, dynamic>? query, dynamic data}) async {
    await _loadState();
    final p = path.split('?').first.replaceFirst(RegExp(r'^/'), '');
    final q = <String, dynamic>{...?query};
    if (path.contains('?')) q.addAll(Uri.splitQueryString(path.split('?')[1]));
    final body = (data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{});
    final seg = p.split('/');
    final key = '$method ${seg.first}';

    // public
    if (key == 'GET meta') {
      return {
        'product': 'VanRozgar',
        'notices': [
          {'id': 'd0', 'text': 'ऑफलाइन डेमो मोड — डेटा या फोनमध्ये साठवला आहे • Offline demo mode — data is stored on this phone'},
          {'id': 'd1', 'text': 'नाशिक पायलट: १० ग्रामसभा • Nashik pilot: 10 Gram Sabhas'},
        ],
        'bulkThresholds': {'mass_kg': 50, 'volume_l': 50, 'count': 100},
      };
    }
    if (key == 'GET categories') return _list('categories');
    if (key == 'POST auth' && seg[1] == 'login') {
      final u = _findUser('${body['phone']}', '${body['password']}');
      if (u == null) throw _err('UNAUTHENTICATED', 'Invalid phone number or password');
      return {'token': 'demo.${u['_id']}', 'user': _publicUser(u)};
    }
    if (key == 'POST auth' && seg[1] == 'register') return _register(body);

    final me = await _me();
    if (key == 'GET gramsabhas') {
      if (seg.length == 1) return _list('gramsabhas');
      return {'gramSabha': _gs(seg[1]), 'claims': [], 'villageProfile': null};
    }
    if (key == 'GET search') return _search(q);
    if (key == 'GET listings' && seg.length == 2 && seg[1] != 'mine') {
      final l = _list('listings').firstWhere((x) => x['_id'] == seg[1], orElse: () => {});
      if (l.isEmpty) throw _err('NOT_FOUND', 'Listing not found');
      return _listingOut(l, withGs: true);
    }
    if (me == null) throw _err('UNAUTHENTICATED', 'Authorization token required');
    final uid = me['_id'] as String;
    final role = me['role'] as String;

    switch (key) {
      case 'GET auth':
        return _publicUser(me);
      case 'PATCH auth':
        for (final k in ['name', 'email', 'businessName', 'city', 'language']) {
          if (body[k] != null) me[k] = body[k];
        }
        await _save();
        return _publicUser(me);
      case 'GET listings': // mine
        return _list('listings').where((l) => l['ownerId'] == uid).map(_listingOut).toList();
      case 'POST listings':
        return _createListing(me, body);
      case 'PATCH listings':
        final l = _list('listings').firstWhere((x) => x['_id'] == seg[1], orElse: () => {});
        if (l.isEmpty) throw _err('NOT_FOUND', 'Listing not found');
        if (l['ownerId'] != uid) throw _err('FORBIDDEN', 'You do not own this listing');
        if (seg.length > 2) {
          if (body['status'] == 'rejected') throw _err('FORBIDDEN', 'Only the VanRozgar team can reject a listing');
          l['status'] = body['status'];
        } else {
          if (body['quantityAvailable'] != null) l['quantityAvailable'] = body['quantityAvailable'];
          if (body['pricePerUnitRupees'] != null) l['pricePerUnitPaise'] = ((body['pricePerUnitRupees'] as num) * 100).round();
          if (body['description'] != null) l['description'] = body['description'];
        }
        await _save();
        return _listingOut(l);
      case 'POST requests':
        if (seg.length == 1) return _createRequest(me, body);
        if (seg.length == 3 && seg[2] == 'counter') return counter(seg[1], body);
        if (seg.length == 4) return counterRespond(seg[1], body);
        throw _err('NOT_IMPLEMENTED', 'Not available in offline demo mode');
      case 'GET requests':
        if (seg.length == 2) {
          final r = _list('requests').firstWhere((x) => x['_id'] == seg[1], orElse: () => {});
          if (r.isEmpty) throw _err('NOT_FOUND', 'Request not found');
          if (r['requesterId'] != uid && r['sellerId'] != uid && role != 'team') throw _err('FORBIDDEN', 'You do not have access to this request');
          return _reqOut(r);
        }
        final incoming = q['scope'] == 'incoming';
        return _list('requests')
            .where((r) => (incoming ? r['sellerId'] : r['requesterId']) == uid && (q['status'] == null || r['status'] == q['status']))
            .map(_reqOut)
            .toList();
      case 'PATCH requests':
        return _requestAction(me, seg[1], body);
      case 'GET orders':
        if (seg.length == 2) {
          final o = _list('orders').firstWhere((x) => x['_id'] == seg[1], orElse: () => {});
          if (o.isEmpty) throw _err('NOT_FOUND', 'Order not found');
          if (o['buyerId'] != uid && o['sellerId'] != uid && role != 'team') throw _err('FORBIDDEN', 'You do not have access to this order');
          return _orderOut(o);
        }
        final selling = q['scope'] == 'selling';
        return _list('orders').where((o) => (selling ? o['sellerId'] : o['buyerId']) == uid).map(_orderOut).toList();
      case 'GET messages':
        if (seg.length == 2) return {'unreadCount': _list('messages').where((m) => m['recipientId'] == uid && m['readAt'] == null).length};
        return _list('messages').where((m) => m['recipientId'] == uid).toList();
      case 'POST messages':
        for (final m in _list('messages')) {
          if (m['recipientId'] == uid) m['readAt'] ??= DateTime.now().toIso8601String();
        }
        await _save();
        return {'success': true};
      case 'GET delivery-partners':
        final pt = _list('partners').where((x) => x['userId'] == uid).toList();
        if (pt.isEmpty) throw _err('NOT_FOUND', 'Delivery partner profile not found');
        return pt.first;
      case 'POST delivery-partners':
        if (role != 'villager') throw _err('FORBIDDEN', 'Only forest villagers can apply as delivery partners');
        final partner = {'_id': _id('p_'), 'userId': uid, 'vehicle': {'type': body['vehicleType'], 'number': body['vehicleNumber'], 'capacityKg': body['capacityKg']}, 'serviceTalukas': body['serviceTalukas'], 'approvalStatus': 'pending', 'available': true, 'earningsPaise': 0, 'jobsCompleted': 0};
        (_s['partners'] as List).add(partner);
        me['isDeliveryApplicant'] = true;
        await _save();
        return partner;
      case 'PATCH delivery-partners':
        return {'available': body['available']};
      case 'GET deliveries':
        if (seg.length > 1 && seg[1] == 'jobs') throw _err('FORBIDDEN', 'Only approved delivery partners can view available transport jobs');
        return [];
      case 'GET barter-requests':
        return [];
      case 'GET admin':
        return [];
    }
    if (key == 'POST orders') return _orderAction(me, seg[1], seg.length > 2 ? seg[2] : '');
    throw _err('NOT_IMPLEMENTED', 'Not available in offline demo mode');
  }

  // ------------------------------------------------------------ handlers
  static Future<dynamic> _register(Map<String, dynamic> b) async {
    final role = b['role'] as String? ?? 'villager';
    final digits = '${b['phone']}'.replaceAll(RegExp(r'\D'), '');
    final phone = '+91${digits.length > 10 ? digits.substring(digits.length - 10) : digits}';
    if (_list('users').any((u) => u['phone'] == phone)) throw _err('CONFLICT', 'User with this phone number is already registered');
    final gs = _list('gramsabhas').where((g) => g['village']['mr'] == b['village'] || g['village']['en'] == b['village']).toList();
    if ((role == 'gramsabha' || role == 'villager') && gs.isEmpty) {
      throw _err('VALIDATION_ERROR', 'Only Nashik pilot villages are eligible during prototype phase', fields: {'village': 'Select one of the 10 pilot villages'});
    }
    final u = {
      '_id': _id('u_'), 'name': b['name'], 'phone': phone, 'role': role, 'language': b['language'] ?? 'mr',
      'village': b['village'], 'taluka': 'Nashik', 'district': 'Nashik', 'businessName': b['businessName'], 'city': b['city'],
      'gramSabhaId': role == 'buyer' || gs.isEmpty ? null : gs.first['_id'], 'isDeliveryApplicant': false, 'status': 'active',
      'password': b['password'],
    };
    (_s['users'] as List).add(u);
    await _save();
    return {'token': 'demo.${u['_id']}', 'user': _publicUser(u)};
  }

  static Map<String, dynamic> _search(Map<String, dynamic> q) {
    final text = '${q['q'] ?? ''}'.toLowerCase().trim();
    var items = _list('listings').where((l) => l['status'] == 'active').toList();
    if (text.isNotEmpty) {
      final toks = text.split(RegExp(r'\s+'));
      items = items.where((l) {
        final cat = _list('categories').firstWhere((c) => c['_id'] == l['categoryId']);
        final hay = '${l['title']['en']} ${l['title']['mr']} ${l['village']} ${cat['name']['en']} ${cat['name']['mr']}'.toLowerCase();
        final words = hay.split(RegExp(r'[^\p{L}\p{N}]+', unicode: true));
        return toks.every((t) => words.any((w) => w.startsWith(t)));
      }).toList();
    }
    if (q['category'] != null && '${q['category']}'.isNotEmpty) {
      items = items.where((l) => l['categoryId'] == q['category'] || l['categoryId'] == 'cat_${q['category']}').toList();
    }
    final minP = num.tryParse('${q['minPrice'] ?? ''}'), maxP = num.tryParse('${q['maxPrice'] ?? ''}');
    if (minP != null) items = items.where((l) => (l['pricePerUnitPaise'] as num) >= minP * 100).toList();
    if (maxP != null) items = items.where((l) => (l['pricePerUnitPaise'] as num) <= maxP * 100).toList();
    if (q['mode'] != null) items = items.where((l) => l['mode'] == q['mode']).toList();
    final sort = q['sort'];
    if (sort == 'price_asc') items.sort((a, b) => (a['pricePerUnitPaise'] as num).compareTo(b['pricePerUnitPaise'] as num));
    if (sort == 'price_desc') items.sort((a, b) => (b['pricePerUnitPaise'] as num).compareTo(a['pricePerUnitPaise'] as num));
    final limit = int.tryParse('${q['limit'] ?? 20}') ?? 20;
    final offset = int.tryParse('${q['cursor'] ?? 0}') ?? 0;
    final page = items.skip(offset).take(limit).map((l) => {..._listingOut(l, withGs: true), 'distanceKm': null}).toList();
    final more = offset + limit < items.length;
    final gss = text.isEmpty
        ? <Map<String, dynamic>>[]
        : _list('gramsabhas').where((g) => '${g['village']['en']} ${g['village']['mr']}'.toLowerCase().contains(text)).take(5).toList();
    return {'listings': page, 'gramsabhas': gss, 'resources': [], 'nextCursor': more ? '${offset + limit}' : null};
  }

  static Future<dynamic> _createListing(Map<String, dynamic> me, Map<String, dynamic> b) async {
    if (me['role'] == 'buyer') throw _err('FORBIDDEN', 'Buyers cannot create listings');
    if (me['gramSabhaId'] == null) throw _err('VALIDATION_ERROR', 'A valid Gram Sabha association is required to create listings');
    final qty = num.tryParse('${b['quantityAvailable']}') ?? 0;
    if (qty <= 0) throw _err('VALIDATION_ERROR', 'Quantity must be greater than zero', fields: {'quantityAvailable': 'Quantity must be greater than zero'});
    final gs = _gs(me['gramSabhaId'] as String);
    final l = {
      '_id': _id('l_'), 'ownerType': me['role'], 'ownerId': me['_id'], 'gramSabhaId': gs['_id'],
      'title': {'mr': b['titleMr'], 'en': b['titleEn']}, 'categoryId': b['categoryId'], 'description': b['description'],
      'quantityAvailable': qty, 'unit': b['unit'], 'pricePerUnitPaise': (((num.tryParse('${b['pricePerUnitRupees']}') ?? 0)) * 100).round(),
      'mode': b['mode'] ?? 'sell', 'barterWants': b['barterWants'], 'village': gs['village']['mr'], 'taluka': 'Nashik', 'district': 'Nashik',
      'status': 'active', 'provenance': {'sourceForestArea': b['sourceForestArea'], 'sustainableDeclared': true},
      'fulfilment': b['fulfilment'] ?? 'both', 'flags': {'rightsNotOnRecord': false}, 'createdAt': DateTime.now().toIso8601String(),
    };
    (_s['listings'] as List).insert(0, l);
    await _save();
    return l;
  }

  static Future<dynamic> _createRequest(Map<String, dynamic> me, Map<String, dynamic> b) async {
    final l = _list('listings').firstWhere((x) => x['_id'] == b['listingId'], orElse: () => {});
    if (l.isEmpty) throw _err('NOT_FOUND', 'Listing not found');
    if (l['status'] != 'active') throw _err('CONFLICT', 'Listing is not active');
    if (l['ownerId'] == me['_id']) throw _err('FORBIDDEN', 'You cannot create a purchase request for your own listing');
    final qty = num.tryParse('${b['quantity']}') ?? 0;
    if (qty <= 0) throw _err('VALIDATION_ERROR', 'Quantity must be greater than zero', fields: {'quantity': 'Quantity must be greater than zero'});
    if (qty > (l['quantityAvailable'] as num)) throw _err('INSUFFICIENT_STOCK', 'Requested quantity exceeds available stock');
    final reason = '${b['reason'] ?? ''}'.trim();
    if (qty >= _threshold(l['unit'] as String) && reason.length < 5) {
      throw _err('BULK_REASON_REQUIRED', 'Large orders require a reason', fields: {'reason': 'Please provide purpose and planned use'});
    }
    final r = {
      '_id': _id('r_'), 'listingId': l['_id'], 'requesterId': me['_id'], 'requesterRole': me['role'], 'sellerId': l['ownerId'],
      'gramSabhaId': l['gramSabhaId'], 'quantity': qty, 'unit': l['unit'], 'deliveryPref': b['deliveryPref'] ?? 'pickup',
      'dropVillage': b['dropVillage'] ?? me['village'], 'reason': reason.isEmpty ? null : reason, 'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(), 'history': [],
    };
    (_s['requests'] as List).insert(0, r);
    _msg(l['ownerId'] as String, 'request_created', 'नवीन खरेदी विनंती: ${l['title']['mr']}', 'New purchase request: ${l['title']['en']}',
        '${me['name']} यांनी $qty ${l['unit']} ची विनंती केली', '${me['name']} requested $qty ${l['unit']}');
    await _save();
    return r;
  }

  static Map<String, dynamic> _approve(Map<String, dynamic> r, String byId, {num? pricePaise}) {
    final l = _list('listings').firstWhere((x) => x['_id'] == r['listingId']);
    final qty = r['quantity'] as num;
    if (l['status'] != 'active' || (l['quantityAvailable'] as num) < qty) throw _err('INSUFFICIENT_STOCK', 'Stock has changed or is insufficient');
    l['quantityAvailable'] = (l['quantityAvailable'] as num) - qty;
    if (l['quantityAvailable'] == 0) l['status'] = 'sold_out';
    r['status'] = 'approved';
    final price = (pricePaise ?? l['pricePerUnitPaise']) as num;
    final o = {
      '_id': _id('o_'), 'requestId': r['_id'], 'buyerId': r['requesterId'], 'sellerId': r['sellerId'], 'gramSabhaId': r['gramSabhaId'],
      'line': {'listingId': l['_id'], 'title': l['title'], 'quantity': qty, 'unit': l['unit'], 'pricePerUnitPaise': price, 'totalPaise': (qty * price).round()},
      'fulfilment': {'method': r['deliveryPref'], 'dropVillage': r['dropVillage']}, 'orderStatus': 'approved', 'paymentStatus': 'demo_pending',
      'timeline': [{'status': 'approved', 'at': DateTime.now().toIso8601String(), 'note': 'Order approved and stock reserved'}],
      'createdAt': DateTime.now().toIso8601String(),
    };
    (_s['orders'] as List).insert(0, o);
    _msg(r['requesterId'] as String, 'request_approved', 'ऑर्डर मंजूर झाली!', 'Order Approved!',
        '${l['title']['mr']} साठी तुमची ऑर्डर मंजूर झाली आहे.', 'Your order for ${l['title']['en']} has been approved.');
    return o;
  }

  static Future<dynamic> _requestAction(Map<String, dynamic> me, String id, Map<String, dynamic> b) async {
    final r = _list('requests').firstWhere((x) => x['_id'] == id, orElse: () => {});
    if (r.isEmpty) throw _err('NOT_FOUND', 'Request not found');
    final isSeller = r['sellerId'] == me['_id'];
    final action = b['action'];
    if (action == null) throw _err('VALIDATION_ERROR', 'Unsupported action');
    if (action == 'approve') {
      if (!isSeller) throw _err('FORBIDDEN', 'Only the seller can approve requests');
      if (r['status'] != 'pending' && r['status'] != 'countered') throw _err('INVALID_TRANSITION', "Cannot transition request from '${r['status']}' to 'approved'");
      final o = _approve(r, me['_id'] as String);
      await _save();
      return {'request': _reqOut(r), 'order': _orderOut(o)};
    }
    if (action == 'reject') {
      if (!isSeller) throw _err('FORBIDDEN', 'Only the seller can reject requests');
      final note = '${b['note'] ?? ''}'.trim();
      if (note.length < 5) throw _err('VALIDATION_ERROR', 'Reason is required (min 5 characters)', fields: {'note': 'Reason is required (min 5 characters)'});
      if (r['status'] != 'pending' && r['status'] != 'countered') throw _err('INVALID_TRANSITION', "Cannot transition request from '${r['status']}' to 'rejected'");
      r['status'] = 'rejected';
      r['decisionNote'] = note;
      _msg(r['requesterId'] as String, 'request_rejected', 'विनंती नाकारली', 'Request rejected', 'कारण: $note', 'Reason: $note');
      await _save();
      return {'request': _reqOut(r)};
    }
    if (action == 'cancel') {
      if (r['requesterId'] != me['_id']) throw _err('FORBIDDEN', 'Only the buyer can cancel their request');
      if (r['status'] != 'pending' && r['status'] != 'countered') throw _err('INVALID_TRANSITION', "Cannot transition request from '${r['status']}' to 'cancelled'");
      r['status'] = 'cancelled';
      await _save();
      return {'request': _reqOut(r)};
    }
    // counter / counter-respond are sent as extra path segments by the app
    throw _err('VALIDATION_ERROR', 'Unsupported action');
  }

  static Future<dynamic> counter(String id, Map<String, dynamic> b) async {
    final me = await _me();
    final r = _list('requests').firstWhere((x) => x['_id'] == id, orElse: () => {});
    if (me == null || r.isEmpty) throw _err('NOT_FOUND', 'Request not found');
    if (r['sellerId'] != me['_id']) throw _err('FORBIDDEN', 'Only the seller can propose a counter-offer');
    if (r['status'] != 'pending') throw _err('INVALID_TRANSITION', "Cannot transition request from '${r['status']}' to 'countered'");
    final l = _list('listings').firstWhere((x) => x['_id'] == r['listingId']);
    final price = b['pricePerUnitRupees'] != null ? ((b['pricePerUnitRupees'] as num) * 100).round() : l['pricePerUnitPaise'];
    r['status'] = 'countered';
    r['counter'] = {'quantity': b['quantity'] ?? r['quantity'], 'pricePerUnitPaise': price, 'note': b['note'], 'version': 1};
    _msg(r['requesterId'] as String, 'request_countered', 'विक्रेत्याची प्रति-ऑफर', 'Seller Counter-Offer', 'विक्रेत्याने नवीन दर/प्रमाण प्रस्तावित केले', 'Seller proposed new terms');
    await _save();
    return _reqOut(r);
  }

  static Future<dynamic> counterRespond(String id, Map<String, dynamic> b) async {
    final me = await _me();
    final r = _list('requests').firstWhere((x) => x['_id'] == id, orElse: () => {});
    if (me == null || r.isEmpty) throw _err('NOT_FOUND', 'Request not found');
    if (r['requesterId'] != me['_id']) throw _err('FORBIDDEN', 'Only the buyer can respond to a counter-offer');
    if (r['status'] != 'countered') throw _err('CONFLICT', 'Request is not in countered status');
    if (b['action'] == 'accept') {
      final c = r['counter'] as Map<String, dynamic>;
      if (c['quantity'] != null) r['quantity'] = c['quantity'];
      final o = _approve(r, me['_id'] as String, pricePaise: c['pricePerUnitPaise'] as num?);
      await _save();
      return {'request': _reqOut(r), 'order': _orderOut(o)};
    }
    r['status'] = 'cancelled';
    await _save();
    return {'request': _reqOut(r)};
  }

  static Future<dynamic> _orderAction(Map<String, dynamic> me, String id, String action) async {
    final o = _list('orders').firstWhere((x) => x['_id'] == id, orElse: () => {});
    if (o.isEmpty) throw _err('NOT_FOUND', 'Order not found');
    final st = o['orderStatus'];
    void step(String s, String note) {
      o['orderStatus'] = s;
      (o['timeline'] as List).add({'status': s, 'at': DateTime.now().toIso8601String(), 'note': note});
    }

    if (action == 'handover') {
      if (o['sellerId'] != me['_id']) throw _err('FORBIDDEN', 'Only the seller can confirm handover');
      if (st != 'approved') throw _err('CONFLICT', "Cannot confirm handover from status '$st'");
      step('handed_over', 'Seller confirmed handover of produce');
      _msg(o['buyerId'] as String, 'order_status_changed', 'माल सुपूर्द केला!', 'Produce Handed Over!', 'विक्रेत्याने मालाची सुपूर्दगी केली आहे', 'Seller confirmed handover');
    } else if (action == 'confirm-received') {
      if (o['buyerId'] != me['_id']) throw _err('FORBIDDEN', 'Only the buyer can confirm receipt');
      if (!['handed_over', 'on_the_way', 'delivered'].contains(st)) throw _err('CONFLICT', "Cannot confirm receipt on order with status '$st'");
      step('delivered', 'Buyer confirmed receipt of goods');
      step('closed', 'Order successfully completed and closed');
      _msg(o['sellerId'] as String, 'order_status_changed', 'ऑर्डर पूर्ण झाली!', 'Order Delivered & Completed!', 'खरेदीदाराने माल मिळाल्याची पुष्टी केली', 'Buyer confirmed receipt');
    } else if (action == 'cancel') {
      if (o['buyerId'] != me['_id'] && o['sellerId'] != me['_id']) throw _err('FORBIDDEN', 'You do not have access to cancel this order');
      if (['handed_over', 'delivered', 'closed', 'cancelled'].contains(st)) throw _err('CONFLICT', 'Cannot cancel an order after handover/delivery');
      final l = _list('listings').firstWhere((x) => x['_id'] == o['line']['listingId']);
      l['quantityAvailable'] = (l['quantityAvailable'] as num) + (o['line']['quantity'] as num);
      if (l['status'] == 'sold_out') l['status'] = 'active';
      step('cancelled', 'Order cancelled');
    } else {
      throw _err('NOT_IMPLEMENTED', 'Not available in offline demo mode');
    }
    await _save();
    return _orderOut(o);
  }
}
