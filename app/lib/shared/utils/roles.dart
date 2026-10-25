/// Account roles (docs/tasks.md "Roles").
///
/// `villager` is the stored value of the Farmer role (kept so old accounts keep working).
/// `cfrholder` is a farmer who also holds community forest rights: the only role with the Livelihood report.
const String roleGramSabha = 'gramsabha';
const String roleFarmer = 'villager';
const String roleCfrHolder = 'cfrholder';
const String roleBuyer = 'buyer';

/// Where a signed-in person lands. Each role has its own portal shell.
String homeRouteFor(String? role) => switch (role) {
      roleGramSabha => '/gs',
      roleBuyer => '/b',
      roleCfrHolder => '/c',
      _ => '/v',
    };

/// Only a CFR holder sees the Livelihood tab and may call the livelihood server.
bool canUseLivelihood(String? role) => role == roleCfrHolder;

/// Roles that belong to a village of the dataset (they pick one when they sign up).
bool isVillageRole(String? role) => role == roleGramSabha || role == roleFarmer || role == roleCfrHolder;

/// The name shown to a person for their role, in English and Marathi.
String roleLabelFor(String? role) => switch (role) {
      roleGramSabha => 'FRC • ग्रामसभा',
      roleBuyer => 'BUYER • खरेदीदार',
      roleCfrHolder => 'CFR HOLDER • सीएफआर धारक',
      _ => 'FARMER • शेतकरी',
    };
