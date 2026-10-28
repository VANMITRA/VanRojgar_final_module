import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/sell_catalog.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/l10n/sell_strings.dart';
import 'package:vanrozgar/ui_v2/models/sell_models.dart';
import 'package:vanrozgar/ui_v2/providers/sell_providers.dart';

void main() {
  group('Sell catalog parser (parseSellCatalogMap)', () {
    test('loads all products including those with empty listings', () {
      const inlineCatalog = <String, dynamic>{
        'products': [
          {
            'productCode': 'fruit_mango',
            'categorySlug': 'fruit',
            'image': 'assets/catalog/fruit_mango.jpg',
            'pictureNote': 'ready',
            'notForEating': false,
            'title': {'en': 'Mango', 'hi': 'आम', 'mr': 'आंबा'},
            'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            'listings': [
              {
                'id': 'm1',
                'sellerType': 'gramsabha',
                'pricePerUnitPaise': 9900,
                'mrpPerUnitPaise': 12000,
                'quantityTotal': 100,
                'quantitySold': 20,
                'minOrderQuantity': 5,
                'daysAgo': 2,
              },
            ],
          },
          {
            'productCode': 'shade_banyan',
            'categorySlug': 'shade-trees',
            'image': 'assets/catalog/shade_banyan.jpg',
            'pictureNote': 'ready',
            'notForEating': false,
            'title': {'en': 'Banyan', 'hi': 'बरगद', 'mr': 'वड'},
            'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            'listings': <Map<String, dynamic>>[],
          },
        ],
      };

      final parsed = parseSellCatalogMap(inlineCatalog);
      expect(parsed.length, 2);
      expect(parsed[0].productCode, 'fruit_mango');
      expect(parsed[0].listings.length, 1);
      expect(parsed[1].productCode, 'shade_banyan');
      expect(parsed[1].listings, isEmpty);
    });
  });

  group('Rupee/paise helpers and liveDiscountPercent', () {
    test('parseRupeesToPaise parses integers and up to 2 decimal places', () {
      expect(parseRupeesToPaise('99'), 9900);
      expect(parseRupeesToPaise('99.5'), 9950);
      expect(parseRupeesToPaise('99.05'), 9905);
      expect(parseRupeesToPaise(' 120.75 '), 12075);
      expect(parseRupeesToPaise(''), isNull);
      expect(parseRupeesToPaise('-10'), isNull);
      expect(parseRupeesToPaise('12.345'), isNull);
      expect(parseRupeesToPaise('abc'), isNull);
    });

    test('formatPaiseForInput formats paise cleanly for text inputs', () {
      expect(formatPaiseForInput(9600), '96');
      expect(formatPaiseForInput(9650), '96.50');
      expect(formatPaiseForInput(9605), '96.05');
    });

    test('liveDiscountPercent is non-null ONLY when pricePaise < mrpPaise', () {
      expect(liveDiscountPercent(mrpPaise: 10000, pricePaise: 8000), 20);
      expect(liveDiscountPercent(mrpPaise: 10000, pricePaise: 10000), isNull);
      expect(liveDiscountPercent(mrpPaise: 10000, pricePaise: 12000), isNull);
      expect(liveDiscountPercent(mrpPaise: null, pricePaise: 8000), isNull);
      expect(liveDiscountPercent(mrpPaise: 10000, pricePaise: 0), isNull);
    });
  });

  group('validateListing pure function', () {
    test('valid listing returns no errors', () {
      final errors = validateListing(
        productCode: 'fruit_mango',
        quantityTotal: 100,
        quantitySold: 20,
        mrpPaise: 12000,
        pricePaise: 9600,
        minOrderQuantity: 5,
        fulfilment: 'both',
      );
      expect(errors, isEmpty);
    });

    test('missing product, zero quantity, invalid prices, and invalid fulfilment return errors', () {
      final errors = validateListing(
        productCode: '',
        quantityTotal: 0,
        mrpPaise: 0,
        pricePaise: null,
        minOrderQuantity: 0,
        fulfilment: 'invalid',
      );
      final codes = errors.map((e) => e.code).toSet();
      expect(
        codes,
        containsAll(<String>{
          'product_required',
          'quantity_positive',
          'mrp_positive',
          'price_positive',
          'min_order_positive',
          'fulfilment_invalid',
        }),
      );
    });

    test('price above MRP returns price_above_mrp error', () {
      final errors = validateListing(
        productCode: 'fruit_mango',
        quantityTotal: 50,
        mrpPaise: 10000,
        pricePaise: 10500,
        minOrderQuantity: 5,
      );
      expect(errors.length, 1);
      expect(errors.single.field, ListingField.price);
      expect(errors.single.code, 'price_above_mrp');
    });

    test('minimum order above quantity returns min_order_above_quantity error', () {
      final errors = validateListing(
        productCode: 'fruit_mango',
        quantityTotal: 10,
        mrpPaise: 10000,
        pricePaise: 9000,
        minOrderQuantity: 11,
      );
      expect(errors.length, 1);
      expect(errors.single.field, ListingField.minOrder);
      expect(errors.single.code, 'min_order_above_quantity');
    });

    test('quantity below what is already sold returns quantity_below_sold error', () {
      final errors = validateListing(
        productCode: 'fruit_mango',
        quantityTotal: 15,
        quantitySold: 20,
        mrpPaise: 10000,
        pricePaise: 9000,
        minOrderQuantity: 5,
        unit: 'kg',
      );
      expect(errors.length, 1);
      expect(errors.single.field, ListingField.quantity);
      expect(errors.single.code, 'quantity_below_sold');
      expect(errors.single.message, contains('20 kg'));
    });

    test('validateListingDraft validates text fields directly', () {
      const draft = ListingDraft(
        productCode: 'bamboo',
        quantityText: '40',
        mrpRupeesText: '100',
        priceRupeesText: '120',
        minOrderText: '50',
        fulfilment: 'pickup',
      );
      final errors = validateListingDraft(draft);
      expect(errors.map((e) => e.code), containsAll(<String>['price_above_mrp', 'min_order_above_quantity']));
    });
  });

  group('createListing, updateListing, pauseListing, resumeListing, removeListing and draft provider', () {
    final baseTime = DateTime.utc(2026, 10, 28);

    test('seeded myListingsProvider has 3 sample listings', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final seeded = container.read(myListingsProvider);
      expect(seeded.length, 3);
      expect(seeded.every((l) => l.isSample), isTrue);
    });

    test('createListing prepends at top, updateListing updates in place, pause/resume toggle status, removeListing deletes', () {
      final initial = <MyListing>[
        MyListing(
          id: 'l1',
          productCode: 'bamboo',
          quantityTotal: 50,
          quantitySold: 10,
          mrpPaise: 10000,
          pricePaise: 8000,
          minOrderQuantity: 2,
          fulfilment: 'pickup',
          status: 'active',
          createdAt: baseTime,
        ),
      ];

      final newItem = MyListing(
        id: 'l2',
        productCode: 'fruit_mango',
        quantityTotal: 100,
        quantitySold: 0,
        mrpPaise: 12000,
        pricePaise: 9600,
        minOrderQuantity: 5,
        fulfilment: 'both',
        status: 'active',
        createdAt: baseTime.add(const Duration(minutes: 5)),
      );

      final afterCreate = createListing(initial, newItem);
      expect(afterCreate.length, 2);
      expect(afterCreate.first.id, 'l2');
      expect(afterCreate.first.discountPercent, 20);
      expect(afterCreate.first.quantityAvailable, 100);

      final updatedL2 = newItem.copyWith(pricePaise: 9000, minOrderQuantity: 10);
      final afterUpdate = updateListing(afterCreate, updatedL2);
      expect(afterUpdate.first.pricePaise, 9000);
      expect(afterUpdate.first.minOrderQuantity, 10);
      expect(afterUpdate.first.discountPercent, 25);

      final afterPause = pauseListing(afterUpdate, 'l2');
      expect(afterPause.first.status, 'paused');
      expect(afterPause.first.isPaused, isTrue);

      final afterResume = resumeListing(afterPause, 'l2');
      expect(afterResume.first.status, 'active');
      expect(afterResume.first.isActive, isTrue);

      final afterRemove = removeListing(afterResume, 'l2');
      expect(afterRemove.length, 1);
      expect(afterRemove.single.id, 'l1');
    });

    test('listingDraftProvider preserves half-filled draft across reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(listingDraftProvider.notifier).state = container
          .read(listingDraftProvider)
          .copyWith(
            productCode: 'fruit_mango',
            quantityText: '75',
            mrpRupeesText: '110',
          );

      final saved = container.read(listingDraftProvider);
      expect(saved.productCode, 'fruit_mango');
      expect(saved.quantityText, '75');
      expect(saved.mrpRupeesText, '110');
      expect(saved.minOrderText, '1');
      expect(saved.fulfilment, 'both');
    });
  });

  group('SellStrings Hindi and Marathi have no English letters', () {
    final latinLetter = RegExp(r'[A-Za-z]');

    test('all sl* strings in Hindi and Marathi contain no Latin characters', () {
      for (final lang in [AppLanguage.hi, AppLanguage.mr]) {
        final s = AppStrings.of(lang);
        final texts = <String>[
          s.slMyListingsTitle,
          s.slAddListingButton,
          s.slEditListingTitle,
          s.slPublishButton,
          s.slSellerOnlyTitle,
          s.slSellerOnlyGuestBody,
          s.slSellerOnlyBuyerBody,
          s.slEmptyListings,
          s.slStatusActive,
          s.slStatusPaused,
          s.slEditAction,
          s.slPauseAction,
          s.slResumeAction,
          s.slRemoveAction,
          s.slRemoveDialogTitle,
          s.slRemoveDialogBody('आम'),
          s.slCancelAction,
          s.slStepChooseProduct,
          s.slFixedProductHeading,
          s.slProductSearchHint,
          s.slCatalogPhotoNote,
          s.slStepQuantity,
          s.slQuantityLabel('किग्रा'),
          s.slQuantityLabel(''),
          s.slAlreadySoldHint(10, 'किग्रा'),
          s.slStepPricing,
          s.slMrpLabel('किग्रा'),
          s.slMrpLabel(''),
          s.slPriceLabel('किग्रा'),
          s.slPriceLabel(''),
          s.slDiscountLine(20),
          s.slStepMinOrder,
          s.slMinOrderLabel('किग्रा'),
          s.slMinOrderLabel(''),
          s.slStepFulfilment,
          s.slFulfilBoth,
          s.slFulfilPickupSub,
          s.slFulfilDeliverySub,
          s.slFulfilBothSub,
          s.slStepPreview,
          s.slErrProductRequired,
          s.slErrQuantityPositive,
          s.slErrQuantityBelowSold(10, 'किग्रा'),
          s.slErrMrpPositive,
          s.slErrPricePositive,
          s.slErrPriceAboveMrp,
          s.slErrMinOrderPositive,
          s.slErrMinOrderAboveQuantity,
          s.slErrFulfilmentRequired,
        ];
        for (final text in texts) {
          expect(
            latinLetter.hasMatch(text),
            isFalse,
            reason: '$lang string contains Latin letters: "$text"',
          );
        }
      }
    });
  });
}
