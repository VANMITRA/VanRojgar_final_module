import 'livelihood_api.dart';

/// The key of the plain-words sentence for a failure (see LivelihoodStrings). The screens show that sentence and a
/// retry; a raw server code is never shown to the person.
String errorMessageKey(Object error) {
  if (error is NetworkException) return 'lv_err_offline';
  if (error is ApiException) {
    final key = error.messageKey;
    final status = error.statusCode;
    if (status == 401) return 'lv_err_signin';
    if (key == 'livelihood.role_not_allowed') return 'lv_err_role';
    if (key == 'livelihood.no_village') return 'lv_err_no_village';
    if (key == 'livelihood.data_not_loaded') return 'lv_err_data';
    if (key == 'livelihood.location_outside_maharashtra') return 'lv_err_outside_mh';
    if (key == 'livelihood.radius_too_large') return 'lv_err_radius';
    if (status >= 500) return 'lv_err_server';
  }
  return 'lv_err_generic';
}
