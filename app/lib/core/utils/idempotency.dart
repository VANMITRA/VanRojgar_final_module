import 'dart:math';

String generateIdempotencyKey() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(9999999);
  return 'idemp_${timestamp}_$random';
}
