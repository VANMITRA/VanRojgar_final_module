/// The three blocks of Nashik district that hold the 14 villages of the dataset (the Raah Foundation CFR report), as the
/// server stores them (English `value`) with a Marathi and English label. Registration, delivery service areas and
/// anything else that asks for a taluka use this list.
const List<({String value, String label})> nashikTalukas = [
  (value: 'Deola', label: 'देवळा (Deola)'),
  (value: 'Dindori', label: 'दिंडोरी (Dindori)'),
  (value: 'Trimbakeshwar', label: 'त्र्यंबकेश्वर (Trimbakeshwar)'),
];

/// Marathi and English label for a taluka value, or the value itself when it is not one of the 3.
String talukaLabel(String value) {
  for (final t in nashikTalukas) {
    if (t.value == value) return t.label;
  }
  return value;
}
