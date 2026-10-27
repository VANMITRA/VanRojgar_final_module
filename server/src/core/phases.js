export const CURRENT_PHASE = 'B2';

export const COMPONENTS = [
  { name: 'platform', phase: 'B0', status: 'ready', description: 'Health, meta, config, error envelope, security' },
  { name: 'auth', phase: 'B1', status: 'ready', description: 'Registration, JWT login, profile, 3 roles' },
  { name: 'catalogue', phase: 'B1', status: 'ready', description: 'Categories, Gram Sabhas, resources' },
  { name: 'listings', phase: 'B1', status: 'ready', description: 'Listing CRUD, stock management, restricted-item check' },
  { name: 'trade', phase: 'B1', status: 'ready', description: 'Purchase requests, counter-offers, transactional approval' },
  { name: 'orders', phase: 'B1', status: 'ready', description: 'Order timeline, handover, confirm-received' },
  { name: 'messages', phase: 'B1', status: 'ready', description: 'In-app transaction notifications and unread counts' },
  { name: 'search', phase: 'B2', status: 'ready', description: 'Grouped search, filters, geo distance' },
  { name: 'seed', phase: 'B2', status: 'ready', description: 'Nashik CFR claims & MRSAC resource profiles seed' },
  { name: 'admin', phase: 'B2', status: 'ready', description: 'Back-office Gram Sabha verification, restricted items' },
  { name: 'delivery', phase: 'B3', status: 'ready', description: 'Delivery partner application, job claim, tracking' },
  { name: 'barter', phase: 'B3', status: 'ready', description: 'Barter requests, counter, mutual acceptance' },
  { name: 'media', phase: 'B4', status: 'planned', description: 'Photo uploads & storage' },
  { name: 'reviews', phase: 'B4', status: 'planned', description: 'Order reviews & ratings' },
  { name: 'impact', phase: 'B4', status: 'planned', description: 'Impact aggregation & reporting' }
];

export const NOTICES = [
  { id: 'n1', text: 'Protected species cannot be listed. Every listing needs a sustainable-harvest declaration.', active: true },
  { id: 'n2', text: 'VanRozgar prototype: the 14 CFR villages of the Raah Foundation report in Nashik district.', active: true },
  { id: 'n3', text: 'Community Forest Rights Section 3(1)(c) enables sustainable MFP trade.', active: true }
];
