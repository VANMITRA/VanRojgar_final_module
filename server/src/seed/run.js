import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import bcrypt from 'bcryptjs';
import { connectDB, disconnectDB } from '../core/db.js';
import { logger } from '../core/logger.js';
import { config } from '../core/config.js';
import { Category } from '../models/Category.js';
import { RestrictedItem } from '../models/RestrictedItem.js';
import { GramSabha } from '../models/GramSabha.js';
import { User } from '../models/User.js';
import { Listing } from '../models/Listing.js';
import { Request } from '../models/Request.js';
import { Order } from '../models/Order.js';
import { buildSearchTokens } from '../core/normalise.js';
import { inferProductCode } from '../core/productCode.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export async function seed() {
  logger.info('🌱 Starting VanRozgar idempotent database seeder...');
  await connectDB();

  // 1. Categories
  const categoriesRaw = JSON.parse(fs.readFileSync(path.join(__dirname, 'data/categories.json'), 'utf-8'));
  for (const cat of categoriesRaw) {
    await Category.findOneAndUpdate(
      { slug: cat.slug },
      { $set: cat },
      { upsert: true, new: true }
    );
  }
  logger.info(`✅ Synced ${categoriesRaw.length} categories`);

  // 2. Restricted Items
  const restrictedRaw = JSON.parse(fs.readFileSync(path.join(__dirname, 'data/restricted.json'), 'utf-8'));
  for (const item of restrictedRaw) {
    await RestrictedItem.findOneAndUpdate(
      { 'name.en': item.name.en },
      { $set: item },
      { upsert: true, new: true }
    );
  }
  logger.info(`✅ Synced ${restrictedRaw.length} restricted items`);

  // 3. Village points & Gram Sabhas
  const villagesRaw = JSON.parse(fs.readFileSync(path.join(__dirname, 'data/village_points.json'), 'utf-8'));
  const gsMap = new Map();

  for (const v of villagesRaw) {
    const searchTerms = buildSearchTokens(v.villageMr, v.villageEn, v.taluka, 'ग्रामसभा');
    const gs = await GramSabha.findOneAndUpdate(
      { taluka: v.taluka, 'village.mr': v.villageMr },
      {
        $set: {
          name: { mr: `ग्रामसभा ${v.villageMr}`, en: `Gram Sabha ${v.villageEn}` },
          village: { mr: v.villageMr, en: v.villageEn },
          taluka: v.taluka,
          district: 'Nashik',
          ...(v.coordinates ? { location: { type: 'Point', coordinates: v.coordinates } } : {}),
          verificationStatus: 'verified_seed',
          verificationNote: `Demo label — confirm Gram Sabha boundary locally before live use (${v.source})`,
          cfr: {
            rights: [], // demo label: real CFR data not imported
            approvedAreaHa: 0,
            claimCount: 0
          },
          searchTerms
        }
      },
      { upsert: true, new: true }
    );
    gsMap.set(`${v.taluka}:${v.villageMr}`, gs);
  }
  logger.info(`✅ Synced ${villagesRaw.length} CFR Gram Sabhas with geo points`);

  // Remove stale seeded data outside the 10 pilot villages
  const pilotKeys = villagesRaw.map((v) => v.villageMr);
  await GramSabha.deleteMany({ verificationStatus: 'verified_seed', 'village.mr': { $nin: pilotKeys } });

  // 4. Demo Accounts
  const demoUsersRaw = JSON.parse(fs.readFileSync(path.join(__dirname, 'data/demo_accounts.json'), 'utf-8'));
  const userMap = new Map();

  for (const u of demoUsersRaw) {
    // The back-office account has a known demo password: never create it in production unless one is set.
    if (u.role === 'team' && config.NODE_ENV === 'production' && !process.env.SEED_TEAM_PASSWORD) continue;
    const pass = u.role === 'team' ? config.SEED_TEAM_PASSWORD : config.SEED_DEMO_PASSWORD;
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(pass, salt);

    let gramSabhaId = null;
    if (u.village && u.taluka) {
      const gs = gsMap.get(`${u.taluka}:${u.village}`);
      if (gs) gramSabhaId = gs._id;
    }

    const user = await User.findOneAndUpdate(
      { phone: u.phone },
      {
        $set: {
          name: u.name,
          phone: u.phone,
          businessName: u.businessName,
          city: u.city,
          email: u.email,
          role: u.role,
          language: u.language || 'mr',
          passwordHash,
          village: u.village,
          taluka: u.taluka,
          gramSabhaId,
          isDeliveryApplicant: u.isDeliveryApplicant || false,
          status: 'active'
        }
      },
      { upsert: true, new: true }
    );
    userMap.set(u.role === 'gramsabha' ? `gs:${u.village}` : u.role, user);
  }
  // Remove stale demo Gram Sabha secretaries (and their listings) from earlier seeds
  const newPhones = demoUsersRaw.map((u) => u.phone);
  const staleUsers = await User.find({ role: 'gramsabha', phone: { $regex: /^\+91982201/, $nin: newPhones } });
  if (staleUsers.length) {
    const ids = staleUsers.map((u) => u._id);
    await Listing.deleteMany({ ownerId: { $in: ids } });
    await User.deleteMany({ _id: { $in: ids } });
  }
  logger.info(`✅ Synced ${demoUsersRaw.length} demo accounts (passwords initialized)`);

  // 5. Demo Listings
  const demoListingsRaw = JSON.parse(fs.readFileSync(path.join(__dirname, 'data/demo_listings.json'), 'utf-8'));
  const keep = [];

  for (const item of demoListingsRaw) {
    const cat = await Category.findOne({ slug: item.categorySlug });
    const gs = gsMap.get(`${item.taluka}:${item.village}`);
    const gsUser = userMap.get(`gs:${item.village}`);
    if (!gs || !gsUser) throw new Error(`No Gram Sabha/user for village ${item.village}`);

    const pricePerUnitPaise = item.pricePerUnitRupees * 100;
    const searchTerms = buildSearchTokens(
      item.titleMr,
      item.titleEn,
      item.village,
      item.taluka,
      cat ? cat.name.mr : '',
      cat ? cat.name.en : '',
      cat?.name?.hi || ''
    );


    await Listing.findOneAndUpdate(
      { 'title.en': item.titleEn, village: item.village, taluka: item.taluka },
      {
        $set: {
          ownerType: 'gramsabha',
          ownerId: gsUser._id,
          gramSabhaId: gs._id,
          title: { mr: item.titleMr, en: item.titleEn, hi: item.titleHi || '' },
          categoryId: cat ? cat._id : null,
          description: item.description,
          productCode: inferProductCode(item.titleEn, item.titleMr) ?? undefined,
          quantityAvailable: item.quantityAvailable,
          unit: item.unit,
          pricePerUnitPaise,
          mode: item.mode,
          barterWants: item.barterWants,
          provenance: {
            sourceForestArea: 'Cultivated / approved source (demo)',
            collectionNote: 'Demo sample — managed/cultivated source only; no wild-hive or reserve collection',
            sustainableDeclared: true
          },
          fulfilment: 'both',
          ...(gs.location && gs.location.coordinates && gs.location.coordinates.length ? { location: gs.location } : {}),
          village: item.village,
          taluka: item.taluka,
          district: 'Nashik',
          status: 'active',
          imageUrl: item.imageUrl,
          searchTerms
        }
      },
      { upsert: true, new: true }
    );
    keep.push(`${item.titleEn}|${item.village}`);
  }
  const seedOwners = [...userMap.keys()].filter((k) => k.startsWith('gs:')).map((k) => userMap.get(k)._id);
  await Listing.deleteMany({ ownerId: { $in: seedOwners }, $expr: { $not: { $in: [{ $concat: ['$title.en', '|', '$village'] }, keep] } } });
  logger.info(`✅ Synced ${demoListingsRaw.length} active market listings`);

  // 6. Demo Trade Requests & Orders
  // Legacy demo trades referenced the old wild-product listings (removed for the 10-village pilot);
  // skipped until they are rewritten against the new catalogue.
  const gsUser = null;
  const buyerUser = userMap.get('buyer');
  if (buyerUser && gsUser) {
    const honeyListing = await Listing.findOne({ 'title.en': 'Pure Wild Forest Honey' });
    const mahuaListing = await Listing.findOne({ 'title.en': 'Sun-dried Mahua Flowers' });
    const ashwaListing = await Listing.findOne({ 'title.en': 'Organic Ashwagandha Roots' });
    const bambooListing = await Listing.findOne({ 'title.en': 'Handwoven Bamboo Utility Baskets' });
    const gumListing = await Listing.findOne({ 'title.en': 'Wild Natural Forest Gum' });

    if (honeyListing && mahuaListing && ashwaListing) {
      // 6a. Demo Requests
      const req1 = await Request.findOneAndUpdate(
        { requesterId: buyerUser._id, listingId: honeyListing._id },
        {
          $set: {
            requesterId: buyerUser._id,
            requesterRole: 'buyer',
            sellerId: gsUser._id,
            gramSabhaId: honeyListing.gramSabhaId,
            listingId: honeyListing._id,
            quantity: 50,
            unit: 'kg',
            deliveryPref: 'delivery',
            dropVillage: 'नाशिक औद्योगिक केंद्र (Nashik MIDC)',
            reason: 'सेंद्रिय च्यवनप्राश निर्मितीसाठी शुद्ध मध खरेदी (Organic Chyawanprash production)',
            status: 'pending',
            history: [{ status: 'pending', at: new Date(), by: buyerUser._id, note: 'Buyer initiated purchase request' }]
          }
        },
        { upsert: true, new: true }
      );

      const req2 = await Request.findOneAndUpdate(
        { requesterId: buyerUser._id, listingId: mahuaListing._id },
        {
          $set: {
            requesterId: buyerUser._id,
            requesterRole: 'buyer',
            sellerId: gsUser._id,
            gramSabhaId: mahuaListing.gramSabhaId,
            listingId: mahuaListing._id,
            quantity: 80,
            unit: 'kg',
            deliveryPref: 'pickup',
            reason: 'औषधी अर्क प्रक्रियेसाठी महुआ फुले (Herbal extract distillation)',
            status: 'countered',
            counter: {
              quantity: 70,
              pricePerUnitPaise: 9500,
              note: '७० किलो उपलब्ध आहे. प्रति किलो ९५ रु दर योग्य राहील (Available: 70 kg at ₹95/kg)',
              version: 1
            },
            history: [
              { status: 'pending', at: new Date(Date.now() - 86400000), by: buyerUser._id },
              { status: 'countered', at: new Date(), by: gsUser._id, note: 'Counter offered by Gram Sabha' }
            ]
          }
        },
        { upsert: true, new: true }
      );

      const req3 = await Request.findOneAndUpdate(
        { requesterId: buyerUser._id, listingId: ashwaListing._id },
        {
          $set: {
            requesterId: buyerUser._id,
            requesterRole: 'buyer',
            sellerId: gsUser._id,
            gramSabhaId: ashwaListing.gramSabhaId,
            listingId: ashwaListing._id,
            quantity: 25,
            unit: 'kg',
            deliveryPref: 'pickup',
            reason: 'दर्जा तपासणी आणि प्रारंभिक बॅच (Quality verification trial batch)',
            status: 'approved',
            decisionNote: 'ग्रामसभेने विनंती मंजूर केली. माल गोदामात तयार आहे (Approved, ready at depot).',
            history: [
              { status: 'pending', at: new Date(Date.now() - 172800000), by: buyerUser._id },
              { status: 'approved', at: new Date(), by: gsUser._id, note: 'Approved by Gram Sabha' }
            ]
          }
        },
        { upsert: true, new: true }
      );
      logger.info('✅ Synced 3 demo trade requests (pending, countered, approved)');

      // 6b. Demo Orders
      await Order.findOneAndUpdate(
        { requestId: req1._id },
        {
          $set: {
            requestId: req1._id,
            buyerId: buyerUser._id,
            sellerId: gsUser._id,
            gramSabhaId: honeyListing.gramSabhaId,
            line: {
              listingId: honeyListing._id,
              title: honeyListing.title,
              quantity: 50,
              unit: 'kg',
              pricePerUnitPaise: honeyListing.pricePerUnitPaise,
              totalPaise: 50 * honeyListing.pricePerUnitPaise
            },
            fulfilment: { method: 'delivery', dropVillage: 'Nashik MIDC' },
            orderStatus: 'handed_over',
            paymentStatus: 'completed',
            timeline: [
              { status: 'approved', at: new Date(Date.now() - 259200000), note: 'ग्रामसभेद्वारे ऑर्डर मंजूर (Order Approved)' },
              { status: 'delivery_assigned', at: new Date(Date.now() - 172800000), note: 'डिलिव्हरी प्रतिनिधी नियुक्त (Assigned)' },
              { status: 'picked_up', at: new Date(Date.now() - 86400000), note: 'गोदामातून माल ताब्यात घेतला (Picked up)' },
              { status: 'handed_over', at: new Date(), note: 'खरेदीदाराला माल सुपूर्द केला (Handed over)' }
            ]
          }
        },
        { upsert: true, new: true }
      );

      if (bambooListing) {
        await Order.findOneAndUpdate(
          { sellerId: gsUser._id, 'line.listingId': bambooListing._id },
          {
            $set: {
              requestId: req3._id,
              buyerId: buyerUser._id,
              sellerId: gsUser._id,
              gramSabhaId: bambooListing.gramSabhaId,
              line: {
                listingId: bambooListing._id,
                title: bambooListing.title,
                quantity: 20,
                unit: 'piece',
                pricePerUnitPaise: bambooListing.pricePerUnitPaise,
                totalPaise: 20 * bambooListing.pricePerUnitPaise
              },
              fulfilment: { method: 'pickup' },
              orderStatus: 'delivered',
              paymentStatus: 'completed',
              timeline: [
                { status: 'approved', at: new Date(Date.now() - 518400000), note: 'ऑर्डर मंजूर (Order Approved)' },
                { status: 'picked_up', at: new Date(Date.now() - 432000000), note: 'बांबू कारागिरांकडून गोळा केले (Collected)' },
                { status: 'on_the_way', at: new Date(Date.now() - 345600000), note: 'वाहतूक सुरू (In transit)' },
                { status: 'delivered', at: new Date(Date.now() - 259200000), note: 'ऑर्डर यशस्वीरीत्या पोहोचली (Delivered & Verified)' }
              ]
            }
          },
          { upsert: true, new: true }
        );
      }

      if (gumListing) {
        await Order.findOneAndUpdate(
          { sellerId: gsUser._id, 'line.listingId': gumListing._id },
          {
            $set: {
              requestId: req2._id,
              buyerId: buyerUser._id,
              sellerId: gsUser._id,
              gramSabhaId: gumListing.gramSabhaId,
              line: {
                listingId: gumListing._id,
                title: gumListing.title,
                quantity: 30,
                unit: 'kg',
                pricePerUnitPaise: gumListing.pricePerUnitPaise,
                totalPaise: 30 * gumListing.pricePerUnitPaise
              },
              fulfilment: { method: 'delivery', dropVillage: 'Nashik Central' },
              orderStatus: 'on_the_way',
              paymentStatus: 'demo_pending',
              timeline: [
                { status: 'approved', at: new Date(Date.now() - 86400000), note: 'ऑर्डर मंजूर (Order Approved)' },
                { status: 'picked_up', at: new Date(Date.now() - 21600000), note: 'डिलिव्हरी वाहनात माल भरला (Loaded)' },
                { status: 'on_the_way', at: new Date(Date.now() - 7200000), note: 'नाशिक केंद्राकडे वाहतूक सुरू (In transit)' }
              ]
            }
          },
          { upsert: true, new: true }
        );
      }
      logger.info('✅ Synced 3 demo orders (handed_over, delivered, on_the_way)');
    }
  }

  logger.info('🎉 Seed completed successfully!');

  await disconnectDB();
}

import { pathToFileURL } from 'url';
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  seed().catch((err) => {
    logger.error({ err }, '❌ Seed script failed');
    process.exit(1);
  });
}
