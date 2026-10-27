/**
 * Account roles. There are three: Gram Sabha, CFR holder and Buyer (plus the back-office `team`).
 * There is no Farmer role any more. The old stored value `villager` is treated as a CFR holder everywhere, so old
 * accounts and old app builds keep working (see normaliseRole and scripts/migrate_villager_to_cfrholder.js).
 * `cfrholder` has everything a farmer had, plus the Livelihood report.
 */
export const REGISTER_ROLES = ['gramsabha', 'cfrholder', 'buyer'];

/** What the API still accepts at sign-up: the old `villager` value from older app builds becomes `cfrholder`. */
export const ACCEPTED_REGISTER_ROLES = [...REGISTER_ROLES, 'villager'];

/** The role to use for a stored or sent role value. */
export const normaliseRole = (role) => (role === 'villager' ? 'cfrholder' : role);

/** Roles that belong to a village of the dataset. */
export const VILLAGE_ROLES = ['gramsabha', 'cfrholder'];

/** Roles that may sell. A Buyer never sells: a buyer is a wholesaler or business that resells outside the app. */
export const SELLER_ROLES = ['gramsabha', 'cfrholder'];

/** Roles that list, barter and may apply as a delivery partner as an individual (not the Gram Sabha itself). */
export const FARMER_ROLES = ['cfrholder'];

export const isFarmerRole = (role) => FARMER_ROLES.includes(normaliseRole(role));

export const canSell = (role) => SELLER_ROLES.includes(normaliseRole(role));

/** Only a CFR holder may use the Livelihood report. */
export const canUseLivelihood = (role) => normaliseRole(role) === 'cfrholder';
