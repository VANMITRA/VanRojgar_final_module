import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/shared/widgets/vr_text.dart';

void main() {
  test('bi picks the right half for each separator style', () {
    expect(bi('मुख्यपृष्ठ • Home', 'en'), 'Home');
    expect(bi('मुख्यपृष्ठ • Home', 'mr'), 'मुख्यपृष्ठ');
    expect(bi('Home | मुख्यपृष्ठ', 'en'), 'Home');
    expect(bi('प्रलंबित (Pending)', 'en'), 'Pending');
    expect(bi('प्रलंबित (Pending)', 'mr'), 'प्रलंबित');
    expect(bi('Plain text', 'mr'), 'Plain text');
    expect(bi('₹450 (5 kg)', 'en'), '₹450 (5 kg)');
  });
}
