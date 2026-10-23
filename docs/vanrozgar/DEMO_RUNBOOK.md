# VanRozgar Demo Runbook (Nashik Pilot)

**Audience:** FRA Advisors, District Administration, CFR Gram Sabha Representatives, Community Members.  
**Demo Date:** 2026-10-14  

---

## 🔑 Pre-Seeded Demo Accounts

All demo accounts are seeded automatically using `npm run seed`.

| Portal / Role | Name | Mobile Number | Password |
|---|---|---|---|
| **Gram Sabha** | गणेश वारली (सचिव, ग्रामसभा हरसूल) | `+919822011111` | `VanRozgar@2026` |
| **Villager** | सखाराम भिल (तोरणगण) | `+919822022222` | `VanRozgar@2026` |
| **Buyer** | राजेश कुलकर्णी (सह्याद्री आयुर्वेद) | `+919822033333` | `VanRozgar@2026` |
| **Team Admin** | वनमित्र तपासणी अधिकारी | `+919822099999` | `VanMitraAdmin@2026` |

---

## 🎬 Live Walkthrough Script

### Act 1: Gram Sabha Listing & Provenance
1. Open the app and log in with the **Gram Sabha** quick button (`+919822011111`).
2. Point out the **Gram Sabha Dashboard**:
   - Hero banner with Trimbak / Harsul location.
   - Status cards: Active Listings, New Requests, Orders in Progress.
   - CFR Rights badges (`3(1)(c) Minor Forest Produce`, `3(1)(i) CFR Management`).
3. Tap **"+ नवीन उत्पादन जोडा (Add Listing)"**:
   - Choose category: **Forest Produce (वनोपज)**.
   - Name: *शुद्ध रान मध (Pure Wild Honey)*.
   - Quantity: `50 kg` @ `₹450 / kg`.
   - Tick the mandatory **"शाश्वत वन संकलन प्रमाणित (Sustainable Harvest Declaration)"**.
   - Tap **Publish Listing**. Show that it appears immediately in the listings tab.

### Act 2: Buyer Search & Bulk Sustainability Reason
1. Switch account (or use second phone) and log in as **General Buyer** (`+919822033333`).
2. Go to the **Search** tab and type `madh` or `honey`.
3. Highlight:
   - Real calculated distance (e.g. `12.4 km`).
   - Gram Sabha verified trust badge.
   - The provenance card with FRA Section 3(1)(c) title information.
4. Tap **"खरेदी विनंती (Request to Buy)"**:
   - Enter quantity: `50 kg`.
   - Point out that because the quantity reaches the bulk threshold (50 kg), the **"Purpose / Reason"** field appears automatically to comply with forest sustainability rules.
   - Enter reason: *Ayurvedic herbal formulations*.
   - Submit request.

### Act 3: Gram Sabha Approval & Stock Decrement
1. Switch back to the **Gram Sabha** account.
2. In the **Requests (मागण्या)** tab, show the incoming request with the buyer's stated sustainability purpose.
3. Tap **Approve (मंजूर करा)**:
   - Explain that approval executes a transactional atomic decrement on the server.
   - Show that stock decrements from 50 kg to 0 kg and automatically shifts to `sold_out`.
   - Show the newly generated Order in the **Orders** tab.

### Act 4: Order Timeline & Handover
1. Tap on the order to view the **Order Timeline Stepper**:
   - Both parties now have access to verified phone numbers.
2. Gram Sabha taps **"माल सुपूर्द केला (Confirm Handover)"**.
3. Buyer inspects their app and taps **"माल मिळाला (Confirm Received)"**.
4. Order moves to `delivered` and `closed`.

### Act 5: Delivery Partner Livelihood (Stretch)
1. Log in as **Villager** (`+919822022222`).
2. Show the **"वाहन आहे? रोजगाराची संधी!"** livelihood card.
3. Show the **Available Delivery Jobs** tab.
4. Tap **Accept Job**:
   - Demonstrate the atomic lock where only one driver can claim the run.
   - Show the estimated earnings per kilometer.
