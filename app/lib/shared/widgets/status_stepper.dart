import 'package:flutter/material.dart';
import 'vr_text.dart';
import '../../core/theme/tokens.dart';

class StatusStepper extends StatelessWidget {
  final String currentStatus;

  const StatusStepper({
    super.key,
    required this.currentStatus,
  });

  static const List<String> steps = [
    'approved',
    'delivery_assigned',
    'picked_up',
    'on_the_way',
    'delivered',
    'closed',
  ];

  static const Map<String, String> stepLabels = {
    'approved': 'Order Approved (मंजूर झाली)',
    'delivery_assigned': 'Partner Assigned (डिलिव्हरी प्रतिनिधी नियुक्त)',
    'picked_up': 'Picked Up (माल ताब्यात घेतला)',
    'on_the_way': 'On The Way (वाटेवर आहे)',
    'delivered': 'Delivered (माल पोहोचला)',
    'closed': 'Order Completed (ऑर्डर पूर्ण)',
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final currentIndex = steps.indexOf(currentStatus);

    return Column(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (i <= currentIndex)
                        ? (i == currentIndex ? tokens.actionPrimary : tokens.success)
                        : tokens.outline,
                    ),
                    child: Center(
                      child: (i < currentIndex)
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : VrText(
                            '${i + 1}',
                            style: TextStyle(
                              color: (i <= currentIndex) ? Colors.white : tokens.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    ),
                  ),
                  if (i < steps.length - 1)
                    Container(
                      width: 2,
                      height: 28,
                      color: (i < currentIndex) ? tokens.success : tokens.outline,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: VrText(
                    stepLabels[steps[i]] ?? steps[i],
                    style: TextStyle(
                      color: (i <= currentIndex) ? tokens.textPrimary : tokens.textMuted,
                      fontSize: 13,
                      fontWeight: (i == currentIndex) ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
