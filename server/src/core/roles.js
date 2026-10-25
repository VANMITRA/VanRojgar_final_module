/**
 * Account roles (docs/tasks.md "Roles").
 * `villager` is the stored value for the Farmer role (kept so old accounts keep working).
 * `cfrholder` is a farmer who also holds community forest rights: the only role with the Livelihood report.
 */
export const REGISTER_ROLES = ['gramsabha', 'villager', 'cfrholder', 'buyer'];

/** Roles that belong to a village of the dataset. */
export const VILLAGE_ROLES = ['gramsabha', 'villager', 'cfrholder'];

/** Roles that behave as a farmer in the marketplace (list, barter, apply as delivery partner). */
export const FARMER_ROLES = ['villager', 'cfrholder'];

export const isFarmerRole = (role) => FARMER_ROLES.includes(role);

/** Only a CFR holder may use the Livelihood report. */
export const canUseLivelihood = (role) => role === 'cfrholder';
