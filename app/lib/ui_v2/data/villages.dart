import '../l10n/app_strings.dart';

/// One of the 14 pilot villages (from the Raah Foundation data in server/src/seed/data/raah).
class VillageInfo {
  final String id;
  final String nameEn;
  final String nameMr;
  final String taluka;

  const VillageInfo(this.id, this.nameEn, this.nameMr, this.taluka);

  /// English in English; Marathi spelling in Hindi and Marathi (a Hindi spelling is not in the data yet).
  String label(AppLanguage lang) => lang == AppLanguage.en ? nameEn : nameMr;
}

/// The 14 pilot villages, in the order of the Raah data.
const List<VillageInfo> pilotVillages = [
  VillageInfo('dongargaon', 'Dongargaon', 'डोंगरगाव', 'Deola'),
  VillageInfo('kanchane', 'Kanchane', 'कांचने', 'Deola'),
  VillageInfo('kumbharde', 'Kumbharde', 'कुंभार्डे', 'Deola'),
  VillageInfo('varshi', 'Varshi', 'वर्षी', 'Deola'),
  VillageInfo('bhatode', 'Bhatode', 'भाटोडे', 'Dindori'),
  VillageInfo('kochargaon', 'Kochargaon', 'कोचरगाव', 'Dindori'),
  VillageInfo('ambai', 'Ambai', 'अंबाई', 'Trimbakeshwar'),
  VillageInfo('chakore', 'Chakore', 'चाकोरे', 'Trimbakeshwar'),
  VillageInfo('devgaon', 'Devgaon', 'देवगाव', 'Trimbakeshwar'),
  VillageInfo('met-chandrachi', 'Met Chandrachi', 'मेट चंद्राची', 'Trimbakeshwar'),
  VillageInfo('pahine', 'Pahine', 'पहिने', 'Trimbakeshwar'),
  VillageInfo('take-harsh', 'Take Harsh', 'टाके हर्ष', 'Trimbakeshwar'),
  VillageInfo('talwade', 'Talwade', 'तळवाडे', 'Trimbakeshwar'),
  VillageInfo('waghera', 'Waghera', 'वाघेरा', 'Trimbakeshwar'),
];
