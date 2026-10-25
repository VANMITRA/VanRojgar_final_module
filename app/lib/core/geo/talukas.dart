/// The 14 talukas of Nashik district, as the server stores them (English `value`) with a Marathi and English label.
/// One list for registration, delivery service areas and anything else that asks for a taluka.
const List<({String value, String label})> nashikTalukas = [
  (value: 'Nashik', label: 'नाशिक (Nashik)'),
  (value: 'Dindori', label: 'दिंडोरी (Dindori)'),
  (value: 'Peth', label: 'पेठ (Peth)'),
  (value: 'Igatpuri', label: 'इगतपुरी (Igatpuri)'),
  (value: 'Trimbakeshwar', label: 'त्र्यंबकेश्वर (Trimbakeshwar)'),
  (value: 'Surgana', label: 'सुरगाणा (Surgana)'),
  (value: 'Sinnar', label: 'सिन्नर (Sinnar)'),
  (value: 'Chandwad', label: 'चांदवड (Chandwad)'),
  (value: 'Kalwan', label: 'कळवण (Kalwan)'),
  (value: 'Deola', label: 'देवळा (Deola)'),
  (value: 'Malegaon', label: 'मालेगाव (Malegaon)'),
  (value: 'Baglan', label: 'बागलाण (Baglan)'),
  (value: 'Nandgaon', label: 'नांदगाव (Nandgaon)'),
  (value: 'Yeola', label: 'येवला (Yeola)'),
];

/// Marathi and English label for a taluka value, or the value itself when it is not one of the 14.
String talukaLabel(String value) {
  for (final t in nashikTalukas) {
    if (t.value == value) return t.label;
  }
  return value;
}
