import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/shared/models/listing.dart';
import 'package:vanrozgar/shared/widgets/item_code_chip.dart';

void main() {
  test('a listing from the server carries its item code, and one without a code still parses', () {
    final json = {
      '_id': 'a1',
      'ownerType': 'gramsabha',
      'ownerId': 'o1',
      'gramSabhaId': 'g1',
      'title': {'mr': 'मध', 'en': 'Honey'},
      'itemCode': 'VR-K7M2QX',
      'quantityAvailable': 5,
      'unit': 'jar',
      'pricePerUnitPaise': 35000,
      'village': 'देवगाव',
      'taluka': 'Trimbakeshwar',
    };
    expect(ListingModel.fromJson(json).itemCode, 'VR-K7M2QX');
    json.remove('itemCode');
    expect(ListingModel.fromJson(json).itemCode, isNull);
  });

  testWidgets('the item code chip shows the code and copies it', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ItemCodeChip(code: 'VR-K7M2QX'))));
    expect(find.text('VR-K7M2QX'), findsOneWidget);
    await tester.tap(find.byKey(const Key('item-code-copy')));
    await tester.pump();
    expect(copied, 'VR-K7M2QX');
    expect(find.text('Copied VR-K7M2QX'), findsOneWidget);
  });
}
