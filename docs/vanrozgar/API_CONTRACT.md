# VanRozgar API Contract (v1)

Base URL: `/api/v1`

All responses follow the standard envelope:
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "timestamp": "2026-10-12T18:30:00.000Z"
  }
}
```
Errors return:
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable description",
    "fields": { "field": "Error description" },
    "requestId": "uuid"
  }
}
```

---

## 1. System & Health

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `GET` | `/health` | Liveness check & Atlas latency check | Public |
| `GET` | `/meta` | Component phases, notices, bulk thresholds | Public |

---

## 2. Authentication & Profile (`/auth`)

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `POST` | `/auth/register` | Register user (gramsabha, villager, buyer) | Public |
| `POST` | `/auth/login` | Login with phone + password | Public |
| `GET` | `/auth/me` | Fetch authenticated profile | Bearer JWT |
| `PATCH` | `/auth/profile` | Update profile fields | Bearer JWT |
| `POST` | `/auth/logout` | Invalidate session client side | Bearer JWT |

---

## 3. Catalogue & Gram Sabhas

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `GET` | `/categories` | List resource categories | Public |
| `GET` | `/gramsabhas` | List Gram Sabhas (filter by taluka, verified) | Public |
| `GET` | `/gramsabhas/:id`| Gram Sabha profile with CFR rights & MRSAC facts | Public |
| `GET` | `/resources` | List resources in Gram Sabha catalogue | Public |
| `POST` | `/resources` | Add new catalogue resource | Gram Sabha |

---

## 4. Listings (`/listings`)

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `POST` | `/listings` | Create listing (checks restricted items & rights) | GS / Villager |
| `GET` | `/listings/mine`| List current user's listings | Bearer JWT |
| `GET` | `/listings/:id` | Fetch single listing detail | Public |
| `PATCH` | `/listings/:id` | Update listing price/qty/description | Owner |
| `PATCH` | `/listings/:id/status`| Update status (`active`, `paused`, `sold_out`)| Owner / Team |

---

## 5. Purchase Requests (`/requests`)

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `POST` | `/requests` | Create purchase request (`Idempotency-Key` supported)| Buyer / Villager |
| `GET` | `/requests` | Query requests (`scope=mine` or `scope=incoming`) | Bearer JWT |
| `GET` | `/requests/:id` | Fetch request details | Participant |
| `PATCH` | `/requests/:id/status`| Approve, reject or cancel request | Participant |
| `POST` | `/requests/:id/counter`| Propose counter-offer (quantity, price, note) | Seller |
| `POST` | `/requests/:id/counter/respond`| Accept or decline counter-offer | Buyer |

---

## 6. Orders (`/orders`)

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `GET` | `/orders` | List orders (`scope=buying` or `scope=selling`) | Bearer JWT |
| `GET` | `/orders/:id` | Fetch order timeline & revealed contacts | Participant |
| `POST` | `/orders/:id/handover` | Seller confirms handover of goods | Seller |
| `POST` | `/orders/:id/confirm-received`| Buyer confirms receipt of goods (`Idempotency-Key`) | Buyer |
| `POST` | `/orders/:id/cancel` | Cancel order before transit | Participant |

---

## 7. Global Search (`/search`)

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `GET` | `/search` | Global prefix search across listings, GS & resources | Public |

---

## 8. Delivery (`/delivery-partners` & `/deliveries`)

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `POST` | `/delivery-partners/applications` | Apply as delivery partner | Villager |
| `GET` | `/delivery-partners/me` | Fetch partner approval & earnings | Partner |
| `PATCH`| `/delivery-partners/me/availability` | Toggle online/available | Partner |
| `GET` | `/deliveries/jobs` | View available delivery jobs in taluka | Approved Partner |
| `POST` | `/deliveries/jobs/:id/accept` | Atomically accept a delivery job | Approved Partner |
| `PATCH`| `/deliveries/jobs/:id/status` | Advance status (`picked_up`, `on_the_way`, `delivered`)| Assigned Partner |
| `GET` | `/deliveries/mine` | List partner's delivery history | Partner |

---

## 9. Barter (`/barter-requests`)

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `POST` | `/barter-requests` | Propose barter exchange offer | GS / Villager |
| `GET` | `/barter-requests` | List incoming or sent barter offers | Bearer JWT |
| `POST` | `/barter-requests/:id/respond`| Accept, reject or counter barter terms | Participant |

---

## 10. Admin Back Office (`/admin`)

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `GET` | `/admin/gramsabhas` | List pending Gram Sabhas for verification | Team |
| `PATCH`| `/admin/gramsabhas/:id/verification`| Verify or reject Gram Sabha with note | Team |
| `GET` | `/admin/delivery-partners` | List pending partner applications | Team |
| `PATCH`| `/admin/delivery-partners/:id/approval`| Approve or reject partner application | Team |
| `POST` | `/admin/restricted-items` | Add restricted/protected species | Team |
