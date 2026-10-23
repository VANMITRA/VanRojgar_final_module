import '../../shared/models/trade_request.dart';
import '../../shared/models/order.dart';
import '../../shared/models/listing.dart';

/// Realistic demo data for Requests and Orders to visualize and test the complete workflow.
class DemoTradeData {
  DemoTradeData._();

  static final ListingModel _honeyListing = ListingModel(
    id: 'lst-honey-01',
    ownerType: 'gramsabha',
    ownerId: 'usr-gs-harsul',
    gramSabhaId: 'gs-harsul',
    titleMr: 'शुद्ध रान मध (Wild Forest Honey)',
    titleEn: 'Pure Wild Forest Honey',
    titleHi: 'शुद्ध जंगली शहद (Wild Forest Honey)',
    quantityAvailable: 120,
    unit: 'kg',
    pricePerUnitPaise: 45000,
    mode: 'both',
    fulfilment: 'both',
    village: 'हरसूल',
    taluka: 'TBK',
    district: 'Nashik',
    status: 'active',
  );

  static final ListingModel _mahuaListing = ListingModel(
    id: 'lst-mahua-02',
    ownerType: 'gramsabha',
    ownerId: 'usr-gs-harsul',
    gramSabhaId: 'gs-harsul',
    titleMr: 'सुकलेली महुआ फुले (Dried Mahua Flowers)',
    titleEn: 'Sun-dried Mahua Flowers',
    titleHi: 'सूखे महुआ के फूल (Sun-dried Mahua Flowers)',
    quantityAvailable: 250,
    unit: 'kg',
    pricePerUnitPaise: 9000,
    mode: 'sell',
    fulfilment: 'both',
    village: 'तोरणगण',
    taluka: 'TBK',
    district: 'Nashik',
    status: 'active',
  );

  static final ListingModel _ashwaListing = ListingModel(
    id: 'lst-ashwa-03',
    ownerType: 'gramsabha',
    ownerId: 'usr-gs-harsul',
    gramSabhaId: 'gs-harsul',
    titleMr: 'अश्वगंधा मुळे (Organic Ashwagandha Roots)',
    titleEn: 'Organic Ashwagandha Roots',
    titleHi: 'जैविक अश्वगंधा जड़ें (Organic Ashwagandha Roots)',
    quantityAvailable: 80,
    unit: 'kg',
    pricePerUnitPaise: 32000,
    mode: 'sell',
    fulfilment: 'pickup',
    village: 'हरसूल',
    taluka: 'TBK',
    district: 'Nashik',
    status: 'active',
  );

  static final ListingModel _bambooListing = ListingModel(
    id: 'lst-bamboo-04',
    ownerType: 'gramsabha',
    ownerId: 'usr-gs-harsul',
    gramSabhaId: 'gs-harsul',
    titleMr: 'पारंपारिक बांबू टोपल्या (Handwoven Bamboo Baskets)',
    titleEn: 'Handwoven Bamboo Utility Baskets',
    titleHi: 'पारंपरिक बांस की टोकरियां (Handwoven Bamboo Baskets)',
    quantityAvailable: 45,
    unit: 'piece',
    pricePerUnitPaise: 15000,
    mode: 'both',
    fulfilment: 'both',
    village: 'हरसूल',
    taluka: 'TBK',
    district: 'Nashik',
    status: 'active',
  );

  static final ListingModel _gumListing = ListingModel(
    id: 'lst-gum-05',
    ownerType: 'gramsabha',
    ownerId: 'usr-gs-harsul',
    gramSabhaId: 'gs-harsul',
    titleMr: 'नैसर्गिक कडुनिंब डिंक (Wild Neem & Dhavada Gum)',
    titleEn: 'Wild Natural Forest Gum',
    titleHi: 'प्राकृतिक नीम व धावड़ा गोंद (Wild Natural Forest Gum)',
    quantityAvailable: 65,
    unit: 'kg',
    pricePerUnitPaise: 28000,
    mode: 'sell',
    fulfilment: 'both',
    village: 'हरसूल',
    taluka: 'TBK',
    district: 'Nashik',
    status: 'active',
  );

  static List<TradeRequestModel> getDemoRequests({required String scope}) {
    return [
      TradeRequestModel(
        id: 'req-demo-01',
        listingId: _honeyListing.id,
        requesterId: 'usr-buyer-rajesh',
        requesterName: 'राजेश कुलकर्णी (सह्याद्री आयुर्वेद)',
        requesterVillage: 'Nashik Hub',
        requesterRole: 'buyer',
        sellerId: 'usr-gs-harsul',
        quantity: 50,
        unit: 'kg',
        deliveryPref: 'delivery',
        dropVillage: 'नाशिक औद्योगिक केंद्र (Nashik MIDC)',
        reason: 'सेंद्रिय च्यवनप्राश निर्मितीसाठी शुद्ध मध खरेदी (Organic Chyawanprash production)',
        status: 'pending',
        listing: _honeyListing,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      ),
      TradeRequestModel(
        id: 'req-demo-02',
        listingId: _mahuaListing.id,
        requesterId: 'usr-buyer-rajesh',
        requesterName: 'राजेश कुलकर्णी (सह्याद्री आयुर्वेद)',
        requesterVillage: 'Nashik',
        requesterRole: 'buyer',
        sellerId: 'usr-gs-harsul',
        quantity: 80,
        unit: 'kg',
        deliveryPref: 'pickup',
        reason: 'औषधी अर्क प्रक्रियेसाठी महुआ फुले (Herbal extract distillation)',
        status: 'countered',
        counter: {
          'quantity': 70,
          'pricePerUnitPaise': 9500,
          'note': '७० किलो उपलब्ध आहे. प्रति किलो ९५ रु दर योग्य राहील (Available: 70 kg at ₹95/kg)',
          'version': 1,
        },
        listing: _mahuaListing,
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
      TradeRequestModel(
        id: 'req-demo-03',
        listingId: _ashwaListing.id,
        requesterId: 'usr-buyer-rajesh',
        requesterName: 'राजेश कुलकर्णी (सह्याद्री आयुर्वेद)',
        requesterVillage: 'Nashik',
        requesterRole: 'buyer',
        sellerId: 'usr-gs-harsul',
        quantity: 25,
        unit: 'kg',
        deliveryPref: 'pickup',
        reason: 'दर्जा तपासणी आणि प्रारंभिक बॅच (Quality verification trial batch)',
        status: 'approved',
        decisionNote: 'ग्रामसभेने विनंती मंजूर केली. माल गोदामात तयार आहे (Approved, ready at depot).',
        listing: _ashwaListing,
        createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      ),
    ];
  }

  static List<OrderModel> getDemoOrders({required String scope}) {
    return [
      OrderModel(
        id: 'ord-demo-01',
        requestId: 'req-demo-01',
        buyerId: 'usr-buyer-rajesh',
        buyerName: 'राजेश कुलकर्णी (सह्याद्री आयुर्वेद)',
        buyerPhone: '+919822033333',
        sellerId: 'usr-gs-harsul',
        sellerName: 'ग्रामसभा हरसूल (सचिव: गणेश वारली)',
        sellerPhone: '+919822011111',
        line: OrderLine(
          listingId: _honeyListing.id,
          titleMr: _honeyListing.titleMr,
          titleEn: _honeyListing.titleEn,
          quantity: 50,
          unit: 'kg',
          pricePerUnitPaise: 45000,
          totalPaise: 2250000, // ₹22,500
        ),
        orderStatus: 'handed_over',
        paymentStatus: 'completed',
        timeline: [
          {
            'status': 'approved',
            'note': 'ग्रामसभेद्वारे ऑर्डर मंजूर (Order Approved by Gram Sabha)',
            'at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          },
          {
            'status': 'delivery_assigned',
            'note': 'डिलिव्हरी प्रतिनिधी सखाराम भिल नियुक्त (Assigned to Sakharam Bhil)',
            'at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          },
          {
            'status': 'picked_up',
            'note': 'ग्रामसभा गोदामातून माल ताब्यात घेतला (Picked up from Harsul depot)',
            'at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
          {
            'status': 'handed_over',
            'note': 'खरेदीदाराला माल सुपूर्द केला (Handed over at Nashik delivery hub)',
            'at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
          },
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      ),
      OrderModel(
        id: 'ord-demo-02',
        requestId: 'req-demo-04',
        buyerId: 'usr-buyer-rajesh',
        buyerName: 'राजेश कुलकर्णी (सह्याद्री आयुर्वेद)',
        buyerPhone: '+919822033333',
        sellerId: 'usr-gs-harsul',
        sellerName: 'ग्रामसभा हरसूल (सचिव: गणेश वारली)',
        sellerPhone: '+919822011111',
        line: OrderLine(
          listingId: _bambooListing.id,
          titleMr: _bambooListing.titleMr,
          titleEn: _bambooListing.titleEn,
          quantity: 20,
          unit: 'piece',
          pricePerUnitPaise: 15000,
          totalPaise: 300000, // ₹3,000
        ),
        orderStatus: 'delivered',
        paymentStatus: 'completed',
        timeline: [
          {
            'status': 'approved',
            'note': 'ऑर्डर मंजूर (Order Approved)',
            'at': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
          },
          {
            'status': 'picked_up',
            'note': 'बांबू कारागिरांकडून गोळा केले (Collected from artisan pada)',
            'at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          },
          {
            'status': 'on_the_way',
            'note': 'वाहतूक सुरू (In transit to buyer)',
            'at': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          },
          {
            'status': 'delivered',
            'note': 'ऑर्डर यशस्वीरीत्या पोहोचली व पुष्टी झाली (Verified received & completed)',
            'at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          },
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
      ),
      OrderModel(
        id: 'ord-demo-03',
        requestId: 'req-demo-05',
        buyerId: 'usr-buyer-rajesh',
        buyerName: 'राजेश कुलकर्णी (सह्याद्री आयुर्वेद)',
        buyerPhone: '+919822033333',
        sellerId: 'usr-gs-harsul',
        sellerName: 'ग्रामसभा हरसूल (सचिव: गणेश वारली)',
        sellerPhone: '+919822011111',
        line: OrderLine(
          listingId: _gumListing.id,
          titleMr: _gumListing.titleMr,
          titleEn: _gumListing.titleEn,
          quantity: 30,
          unit: 'kg',
          pricePerUnitPaise: 28000,
          totalPaise: 840000, // ₹8,400
        ),
        orderStatus: 'on_the_way',
        paymentStatus: 'demo_pending',
        timeline: [
          {
            'status': 'approved',
            'note': 'ऑर्डर मंजूर (Order Approved)',
            'at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
          {
            'status': 'picked_up',
            'note': 'डिलिव्हरी प्रतिनिधीने माल घेतला (Loaded onto Vehicle MH 15 AB 1234)',
            'at': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
          },
          {
            'status': 'on_the_way',
            'note': 'नाशिक केंद्राकडे वाहतूक सुरू (En route to destination)',
            'at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          },
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
    ];
  }

  static OrderModel getDemoOrder(String id) {
    final list = getDemoOrders(scope: 'all');
    return list.firstWhere(
      (o) => o.id == id,
      orElse: () => list.first,
    );
  }
}
