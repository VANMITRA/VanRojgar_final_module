# API contract for the VanMitra app (ui_v2)

This is what the SERVERS offer today, taken from the server code (`server/src`, `livelihood_server/app`). Screens are built against this. If a screen needs something that is not here, it goes into `CHANGE_REQUESTS.md`; it is not invented.

- Shop/marketplace server: Node, base path `/api/v1`. Every answer is `{ "success": true, "data": ..., "meta": {...} }`. Errors are `{ "success": false, "error": { "code", "message", "details" } }`.
- Livelihood server: Python (FastAPI), its own base URL, same sign-in token.
- Money is always an integer in PAISE. Quantities are numbers in the listing's `unit`. Languages: `en`, `hi`, `mr`.
- Sign-in: `Authorization: Bearer <token>`. Browsing the shop needs no sign-in.

## Roles
`buyer`, `gramsabha`, `cfrholder` (an old `villager` counts as `cfrholder`). Only `gramsabha` and `cfrholder` sell. Only `cfrholder` may use the Livelihood report. A `cfrholder` may apply as a delivery partner.

## 1. Account (`/auth`)
| Call | Body / result |
|---|---|
| `POST /auth/register` | `role`, `name`, `phone` (10 digits, +91 added), `password` (exactly 6 digits = the PIN), `language`; for `gramsabha`: `village`, `taluka` required; for `cfrholder`: `village` required; buyers may add `businessName`, `city`, `email`. Result `{ token, user }`. Only Nashik villages are accepted. |
| `POST /auth/login` | `phone`, `password` -> `{ token, user }`. Wrong details: 401 "Invalid phone number or password". Suspended: 403. |
| `GET /auth/me` | the signed-in `user` |
| `PATCH /auth/profile` | any of `name`, `email`, `businessName`, `city`, `language` |
| `POST /auth/logout` | 204 |
Not available yet: Google sign-in, password reset.

## 2. Shop, public (`/shop`)
| Call | Result |
|---|---|
| `GET /shop/home` | `{ deals, topDeals, bestSellers, newArrivals, categories, openListings }`. `topDeals[]` = one tile per product: `productCode, title{mr,en,hi}, category{slug,name}, unit, imageUrl, sellerCount, minPricePaise, startingAtPaise, maxPricePaise, bestDiscountPercent, totalAvailable, totalSold, newestAt`. `categories[]` = `{ id, slug, name, listingCount }` (only categories that have stock). |
| `GET /shop/products?q=&category=<slug>&sort=popular|price_asc|discount_desc|newest&limit=&cursor=` | `{ products[] (same shape as topDeals), nextCursor, total }` |
| `GET /shop/products/:code/sellers?unit=&sort=` | `{ productCode, title, sellerCount, lowestPricePaise, highestPricePaise, totalAvailable, sellers[] }`; each seller = a listing (below) plus `seller{ownerId,name,type,village,taluka}` (`name` = the seller's account name) and `isLowestPrice`. 404 when nobody sells it. |
| `GET /shop/stock?ids=a,b,c` | up to 50 listing ids -> `[{ id, status, unit, quantityAvailable, quantityTotal, quantitySold, soldPercent }]` (live "sold / left") |

A **listing** has: `_id, ownerId, ownerType, title{mr,en,hi}, categoryId, description, itemCode, productCode, unit, quantityAvailable, quantityTotal, quantitySold, soldPercent, minOrderQuantity, pricePerUnitPaise, mrpPerUnitPaise, discountPaise, discountPercent, mode (sell|barter|both), barterWants, fulfilment (pickup|delivery|both), village, taluka, district, imageUrl, status (active|paused|sold_out|rejected), createdAt`.
The listing also has `isSample` (a data flag of old test rows). The app must never show a label for it; real data has none.
Pictures: `imageUrl` is not filled yet and uploads (`/images`) answer 501 "not implemented". Until then the app uses the product picture it already ships by `productCode`.

## 3. Catalogue (public)
- `GET /categories` -> categories (`_id, slug, name{mr,en,hi}`). A new listing needs the category `_id`.
- `GET /gramsabhas`, `GET /gramsabhas/:id`, `GET /resources`.

## 4. Seller listings (`/listings`, signed in as seller)
| Call | Notes |
|---|---|
| `POST /listings` | Needs: `titleMr`, `titleEn`, `categoryId`, `quantityAvailable`, `unit` (kg, g, quintal, litre, piece, bundle, jar, bag), `pricePerUnitRupees`, `sustainableDeclared: true` (the seller must confirm). Optional: `productCode`, `description`, `mrpPerUnitRupees` (selling price may not be above MRP), `minOrderQuantity` (not above the quantity), `fulfilment`, `mode`, `barterWants`, `village`, `taluka`, `sourceForestArea`, `collectionNote`, `latitude`, `longitude`. |
| `GET /listings/mine` | the seller's own listings |
| `PATCH /listings/:id` | `quantityAvailable, pricePerUnitRupees, mrpPerUnitRupees, minOrderQuantity, fulfilment, status, titles, description` |
| `PATCH /listings/:id/status` | `status`: active, paused, sold_out, rejected |
| `GET /listings/:id`, `GET /listings/code/:code`, `GET /listings/map` | read |
There is no delete: "remove" = status `paused` (or `sold_out`).
**Rules the server applies when a listing is created** (read from `listing.service.js`):
1. A CFR holder may list unless the server setting `ALLOW_VILLAGER_LISTINGS` is set to `false` (it is on by default; 403 "Villager direct listings are currently disabled in this pilot" otherwise).
2. A Gram Sabha account must be linked to a Gram Sabha record (found by its village). A Gram Sabha whose claim is still "pending" cannot list until the VanRozgar team approves the claim (403).
3. Titles are checked against a restricted-items list (protected forest produce); a match is refused (422) with the reason.
4. The seller must confirm `sustainableDeclared: true`.

## 5. Requests (the checkout and the seller's decision) (`/requests`, `/shop/cart/checkout`)
- `POST /shop/cart/checkout` (signed in): `{ items:[{listingId, quantity}], deliveryPref: pickup|delivery, paymentMethod: upi|cod (default cod), dropVillage, reason }`. Result `{ created:[{listingId, quantity, request}], failed:[{listingId, code, message}] }`. One request per listing. Not available: below the seller's minimum order, above stock. A big quantity needs a `reason` of 5+ characters.
- `GET /requests?scope=mine|incoming&status=` (`mine` = requests I sent as buyer, `incoming` = requests addressed to me as seller), `GET /requests/:id`.
- `PATCH /requests/:id/status` `{ action: approve|reject|cancel, note }`. `reject` needs a `note` of 5 to 300 characters. Seller approves/rejects; buyer cancels.
- `POST /requests/:id/counter` (seller) `{ quantity?, pricePerUnitRupees?, note? }`, then the buyer: `POST /requests/:id/counter/accept` or `/counter/decline`.
- Request statuses: `pending`, `approved`, `rejected`, `countered`, `cancelled`. A request has `listingId, requesterId, sellerId, quantity, unit, deliveryPref, dropVillage, paymentMethod, reason, status, decisionNote, counter{quantity,pricePerUnitPaise,note,version}, history[{status,at,note}]`.
- STOCK: the listing's `quantityAvailable` goes down **when the seller approves** (done atomically, so two buyers cannot take the same kilos); `quantitySold` = total minus available.

## 6. Orders (after approval) (`/orders`)
Approving a request creates an order. `orderStatus`: `approved, delivery_assigned, picked_up, on_the_way, handed_over, delivered, closed, cancelled`. `paymentStatus`: UPI `awaiting_payment -> payment_reported -> payment_confirmed`; cash on delivery `cod_pending -> cash_received`.
| Call | Who |
|---|---|
| `GET /orders?scope=buying|selling&status=` | list |
| `GET /orders/:id` | one: `line{listingId,title,quantity,unit,pricePerUnitPaise,totalPaise}`, `fulfilment{method,dropVillage}`, `paymentMethod`, `paymentStatus`, `payment{reference,...}`, `timeline[]` |
| `POST /orders/:id/payment/report` `{ reference }` | buyer, UPI: "I have paid" |
| `POST /orders/:id/payment/confirm` | seller, UPI |
| `POST /orders/:id/payment/cash-received` | cash on delivery |
| `POST /orders/:id/handover`, `/confirm-received`, `/cancel` | seller / buyer |
| `GET /orders/payment-options`, `GET /orders/:id/payment/upi-link` | the UPI link is built on the server; the app never shows a UPI id itself |

## 7. Delivery partner (`/delivery-partners`, `/deliveries`)
- `POST /delivery-partners/applications` `{ vehicleType: bike|tempo|pickup|tractor, vehicleNumber, capacityKg, licenceNumber, serviceTalukas[] }` (cfrholder). Approval status: `pending, approved, rejected, paused` (a team member approves).
- `GET /delivery-partners/me` (profile: vehicle, serviceTalukas, approvalStatus, available, earningsPaise, jobsCompleted), `PATCH /delivery-partners/me/availability` `{ available }`.
- `GET /deliveries/jobs` (open jobs for an approved partner), `POST /deliveries/jobs/:id/accept`, `PATCH /deliveries/jobs/:id/status` `{ status: picked_up|on_the_way|delivered, note }`, `GET /deliveries/mine`.
- A job (`Delivery`): `pickup{village,taluka}`, `drop{village,taluka}`, `goodsSummary`, `weightKg`, `distanceKm`, `feePaise`, `collectCashPaise`, `cashCollected`, `status (available, accepted, picked_up, on_the_way, delivered, cancelled)`, `timeline[]`.

## 8. Messages (`/messages`)
`GET /messages` (latest 50): `{ _id, type, title{mr,en}, body{mr,en}, orderId?, requestId?, barterId?, readAt, createdAt }`; `GET /messages/unread-count`; `POST /messages/read` `{ messageIds[] }`. These are notices the server writes (a request arrived, approved, ...); there is no free chat.
Message text exists in Marathi and English only (no Hindi): the Hindi screen shows the English text of a server message unless we add Hindi on the server.

## 9. Barter (`/barter-requests`)
`POST /barter-requests` `{ toListId, fromListId?, offeredTitle, offeredQuantity, offeredUnit, wantedQuantity, note }`; `GET /barter-requests?scope=mine|incoming`; `POST /barter-requests/:id/respond` `{ action: accept|reject|counter, counterOfferedTitle?, counterOfferedQuantity?, counterWantedQuantity?, note }`. Statuses: `pending, accepted, rejected, countered`; each side accepts the same version.
A listing is barterable when `mode` is `barter` or `both` (it then carries `barterWants`). A buyer account cannot barter (403), nobody can barter with themselves (403), a listing that is not barterable answers 409.

## 10. Livelihood report (separate server, `cfrholder` only)
`GET/PUT/DELETE /profile` (the person's answers), `POST /report` (build a report), `GET /report/latest`, `GET /ideas/{code}`, `GET /schemes` (10 government schemes, official links only), `POST /resources/nearby`, `GET /meta`. Radius default 5 km, capped at 10 km. Rules that never break (from `docs/BACKEND.md`): no harm to wildlife; community forest = use only through the Gram Sabha; labels only, no numbers; missing facts show "not available"; each result carries source and date; ideas are drafts.
`POST /demo/report` and the bundled SAMPLE dataset exist only for development; the app must not use them.

## Known gaps (the screens must not pretend these exist)
1. Google sign-in, password reset.
2. Picture upload (501).
3. Real delete of a listing (only pause / sold out).
4. Hindi text in server messages.
5. Delivery partner approval is done by a team member (admin routes), not in the app.
