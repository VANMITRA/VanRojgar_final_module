# VanRojgar UI Redesign: Prompt Playbook

Workflow: **Phase 1** ChatGPT makes a static background image. **Phase 2** Higgsfield makes the landing images.
**Phase 3** Google AI Studio (Gemini) builds the UI code (home, Top Deals, categories, product page, landing page).

## Reference map (from `componets/`)

| Ref image | What we take from it |
|---|---|
| 1 | **Product showcase page**: big hero image on top, 3-4 angle thumbnails on the side, then a billing section (sub-total, delivery fee, total, Checkout). |
| 2 | **Intro and landing**: "Explore ..." headline, "Get Started" button, dots, tilted image cards. Also the home banner, category chips, Best Picks, and product page with old price, % off, colour and size chips. |
| 3, 4, 5 | **Overall UI feel**: soft cream and green, rounded cards, large serif headings, pill buttons, clean cart. Use this look for the whole app. |
| 11 | **Top Deals**: bold section title, tabs with "Starting at Rs X" and "Up to N% OFF", then horizontal product cards with price, struck-out old price, "Lowest in 30 days", ADD button. |
| 14 | **Category grid**: section titles ("Grocery & Kitchen") with 4-column rounded tiles, image on top and a 2-line label below. |
| 6-10, 12-13, 15-18 | Not reviewed yet. Use them for section spacing, tab switching and transitions. Tell me if you want me to go through them. |

## Brand tokens (new palette, replaces the colours in `app/lib/core/theme/tokens.dart`)

Same layout and same roles in both themes. Only the colour values change.

| Role | Light | Dark |
|---|---|---|
| Primary (main buttons, icons) | `#4E7A3A` (text on it: white) | `#8DB85A` (text on it: `#1C2619`) |
| Heading and strong text | `#2F4A2A` (heading green) | `#F4F7EA` (heading cream) |
| Chips, circles, plant cards | `#DDE8C6` (Pista) | chips `#3A5233` with `#DDE8C6` text |
| Cards and panels | white or Pista | `#2E3E2B` (card green) |
| Page background | `#F7F2E8` (beige) | `#1C2619` (dark forest, not pure black) |
| Outline buttons, tree details | `#5A3B22` (brown) | `#D8B48A` (tan) |
| Prices, small highlights | `#A4551A` (orange) | `#F0A15A` (orange) |
| Body text | `#3F4A36` | `#E9EFDC` |
| Muted text | `#7B6A55` | `#A9B49A` |
| Borders | `#E2D6BE` | `#3C4E38` |

Contrast: the dark theme passes 4.5:1 on every text pair. Body text on the page is 13.3, muted is 7.2 on the page and 5.3 on a card, button text is 6.8, orange is 7.4 and tan is 8.1.

Rules for both themes:
- The app follows the phone setting, and the user can switch by hand.
- **Orange is a small accent only.** It is never a button fill.
- **Plant and product images need a transparent background** (PNG or WebP with alpha), so one image sits well on both the light and dark cards.

- Products are forest produce from Nashik tribal communities: honey, bamboo, mahua, tendu leaves, tamarind, lac, bhokar, dry fruits, medicinal herbs.

---

## PHASE 1: Background (ChatGPT, static image, no code)

Why: the current background is code-drawn and glitchy. Use a **single static image asset** instead.
Put the result at `app/assets/backgrounds/van_bg.png` and show it with `Image.asset(fit: BoxFit.cover)` behind the content.

### Prompt 1A: light background (main screens)

```text
Create a seamless, minimalist mobile app background, 1080x2400 px, portrait (9:20).
Style: soft, airy, premium, earthy. Base colour warm beige (#F7F2E8).
Elements: very large, blurred, out-of-focus tropical forest leaves (teak, bamboo, banyan) in the
top-right and bottom-left corners, in pale pista green (#DDE8C6), about 15-20% opacity,
like soft shadows of leaves on a wall. Add a faint warm sunlight glow (#FFF3DC) from the top-left.
A barely visible hint of olive green (#4E7A3A) at 5% in the leaf veins is fine.
Keep the centre 70% almost empty and calm so that cards and text stay readable.
No text, no logos, no people, no hard edges, no patterns, no objects.
Subtle paper-like softness, high resolution, clean.
```

### Prompt 1B: dark background (dark mode, optional)

```text
Minimalist mobile app background, 1080x2400 px, portrait. Very dark forest green base (#1C2619,
not pure black) with soft blurred bamboo and leaf silhouettes at 10% opacity in slightly lighter green
(#2E3E2B), a faint warm amber glow (#F0A15A at 8%) at the top. Centre empty and calm. No text, no objects, no harsh contrast.
```

### Prompt 1C: product backdrop (for the product page, e.g. honey)

```text
Minimalist product-photography backdrop, 1080x1350 px. Soft warm beige (#F7F2E8) to pale pista (#DDE8C6) gradient wall
with a faint, out-of-focus, semi-transparent (frosted, "opaque glass") leaf shadow in the corner,
and a subtle rounded pedestal or stone slab at the bottom centre for placing a product.
Empty centre, soft shadows, no props, no text. Suitable for a honey jar, bamboo craft or herb pack.
```

> **Rule for Gemini later:** never recreate these backgrounds in code. Just place the image and add a
> `0.0 to 0.1` white overlay if text contrast needs it.

---

## PHASE 2: Landing page images (Higgsfield)

Make **4 images**, each 4:5 (1080x1350), consistent style: warm natural light, earthy beige, pista and olive-green palette,
shallow depth of field, realistic photo style, no text or logos in the image.
**Product and plant shots (H4, H5, category tiles) must have a transparent background** so they work on
both the light and dark cards. Add "isolated cut-out on a transparent background (PNG with alpha)" to those
prompts. If the tool cannot do it, remove the background afterwards (remove.bg or Photoshop).
Re-use the same character and style seed across all four for consistency.

### Landing layout

| # | Layout | Image |
|---|---|---|
| 1 | Image on the **left**, text on the right (as in ref 1) | Forest community and produce |
| 2 | Text on the **left**, image on the **right** | Direct farmer-to-buyer trade |
| 3 | Image on the **left**, text on the right | Livelihood map and report |
| 4 | **Minimalist** product hero (honey jar) on a soft translucent backdrop, centred | Product showcase |

### Prompt H1: forest produce

```text
Realistic photo, an Indian tribal woman in a colourful cotton saree smiling, holding a woven bamboo
basket filled with forest produce (mahua flowers, tamarind, tendu leaves, wild honeycomb) at the edge
of a green Sahyadri forest in Nashik, golden morning light, soft bokeh background, warm and dignified,
natural skin tones, vertical 4:5, premium lifestyle photography, no text.
```

### Prompt H2: direct trade

```text
Realistic photo, a forest farmer handing a jar of golden honey to a smiling buyer at a small rustic
wooden stall, bamboo baskets and jute sacks around, soft green forest background, warm daylight,
fair-trade feel, genuine smiles, shallow depth of field, vertical 4:5, no text, no logos.
```

### Prompt H3: livelihood map

```text
Clean top-down photo-illustration of a hand holding a smartphone showing a minimal green map with
glowing location pins, over a blurred forest floor with leaves and a bamboo basket on the side.
Soft cream and green tones, premium, modern, uncluttered, vertical 4:5, no readable text.
```

### Prompt H4: honey hero (minimalist)

```text
Minimalist product photo of a single glass jar of raw golden forest honey with a wooden dipper
resting on top, centred on a pale stone pedestal. Background: soft beige-pista gradient with a faint
translucent frosted leaf shadow. Soft studio light, gentle shadow, lots of empty space around the jar,
high-end brand look, vertical 4:5, no text, no label text, no logo.
(Also render a second version of the jar alone, isolated cut-out on a transparent background.)
```

### Prompt H5: multi-angle set for the product page (ref 1)

Run this once per hero product (honey, bamboo, mahua) with the same subject and background:

```text
Same product as the reference image, [front view | 45-degree side view | top-down view | close-up
texture shot], identical lighting, isolated cut-out on a transparent background (PNG with alpha), soft contact shadow only,
e-commerce quality, no text.
```

### Landing copy (use with the images)

| # | Headline | Sub-text |
|---|---|---|
| 1 | Explore the Forest's Best | Honest produce from the hands that grow it. |
| 2 | Straight from Farmer to You | No middlemen. Fair prices for forest families. |
| 3 | Know What Your Land Can Earn | Your livelihood report and map, in simple words. |
| 4 | Pure. Local. Yours. | Honey, bamboo, mahua and more. **[ Get Started -> ]** |

---

## PHASE 3: Google AI Studio (Gemini) for the UI code

Start a new chat in AI Studio. Paste the **Master Prompt** first, then add each **Screen Prompt** one at a time.
Attach these as images with the prompts: `componets/1.jpeg`, `2.jpeg`, `3.jpeg`, `4.jpeg`, `5.jpeg`, `11.jpeg`, `14.jpeg`
and the Phase 1 and 2 images.

> The real app is **Flutter** (Riverpod and GoRouter). Ask Gemini for Flutter widgets so we can paste them
> into `app/lib/`. If you only want a quick preview, ask for HTML first and then convert it.

### Master Prompt

```text
You are a senior Flutter UI engineer. I am redesigning "VanRojgar", an app for forest-dwelling
communities in Nashik, India, to sell forest produce (honey, bamboo, mahua, tendu, tamarind, lac,
herbs) directly to buyers.

Use the attached screenshots as the UI references:
- Images 3, 4, 5: overall look. Soft beige and pista green, big rounded cards (radius 20-28), elegant serif
  headings, pill buttons, soft shadows, lots of white space. (Take the layout only. The colours come from the
  palette below, not from the screenshots.)
- Image 2: landing/onboarding, home banner, category chips, product card.
- Image 1: product showcase with an angle gallery and a billing summary.
- Image 11: "Top Deals" section with tabs.
- Image 14: category grids with section titles.

Rules:
1. Colours. Same layout and roles in both themes, only the values change.
   LIGHT: primary #4E7A3A (text on it white), heading #2F4A2A, pista #DDE8C6 (chips, circles, plant cards),
   background beige #F7F2E8, brown #5A3B22 (outline buttons, tree details), orange #A4551A (prices, small
   highlights), body #3F4A36, muted #7B6A55, border #E2D6BE.
   DARK: primary #8DB85A (text on it #1C2619), heading cream #F4F7EA, card #2E3E2B, chips #3A5233 with
   #DDE8C6 text, background dark forest #1C2619 (never pure black), tan #D8B48A (outline buttons),
   orange #F0A15A, body #E9EFDC, muted #A9B49A, border #3C4E38.
   Follow the system theme by default, with a manual Light/Dark/System switch in Profile.
   Orange is a small accent only (prices, tiny highlights) and is NEVER a button fill. Main buttons are
   primary green, secondary buttons are outlined brown (light) or tan (dark).
   All text must keep a 4.5:1 contrast. Plant and product images are transparent PNGs, so place them
   on cards without a white box behind them.
2. The background is a STATIC IMAGE asset (assets/backgrounds/van_bg.png). Do NOT draw backgrounds
   with code, gradients, particles or CustomPainter.
3. Fonts: Google Fonts "Playfair Display" (or "DM Serif Display") for headings, "Inter" for body.
4. Animations must be light and cheap: page fade/slide (250-350 ms), a 0.97 scale on press, staggered list
   fade-in, a hero carousel with dots. No continuous heavy animations.
5. Use ThemeData and the existing tokens, with no hard-coded colours inside widgets.
6. Use mock data in a separate file so I can swap it for the API later.
7. Make it responsive to small Android phones (360 px wide). Avoid overflow.
8. Return clean, commented, copy-paste-ready code split by file.
Wait for my screen requests.
```

### Screen 1: Landing and onboarding (3 or 4 slides)

```text
Build the Landing/Onboarding screen, like image 2 (left phone) and image 3 (left).
Show 4 slides with swipe and dots. Layouts alternate:
 Slide 1: image on the LEFT (tilted rounded card), headline and text on the RIGHT.
 Slide 2: text on the LEFT, image on the RIGHT.
 Slide 3: same as slide 1.
 Slide 4: minimalist centred product (honey jar) over a soft translucent frosted backdrop with a faint
          leaf shadow, headline below, and a big "Get Started ->" pill button at the bottom.
Small "Skip" at the top-right, small brand logo top-left, and a handwritten-style tagline accent.
Images: assets/landing/landing_1.png ... landing_4.png. Copy:
 1 "Explore the Forest's Best" / "Honest produce from the hands that grow it."
 2 "Straight from Farmer to You" / "No middlemen. Fair prices for forest families."
 3 "Know What Your Land Can Earn" / "Your livelihood report and map, in simple words."
 4 "Pure. Local. Yours." / button "Get Started"
"Get Started" goes to the route /login (placeholder).
```

### Screen 2: Home

```text
Build the Home screen using images 2 (centre), 5 and 11:
- Top bar: greeting ("Namaste, <name>"), location chip, notification bell, cart icon with badge.
- Search bar with a filter button, and a mic icon on the right.
- Scrollable category chips row (All, Honey, Bamboo, Mahua, Tendu, Herbs, Dry fruits, Crafts), where the
  selected chip is filled green with an icon above the label.
- Hero banner carousel (rounded, image right, text left, "Shop Now" button, dots).
- Then the "Top Deals" section (Screen 3), then "Best Picks", then a "Shop by Category" grid (Screen 4).
- Bottom navigation: Home, Orders (Order Again), Categories, Profile, Cart. It is a floating pill with
  an active-icon highlight.
```

### Screen 3: Top Deals ("Price Drop") section

```text
Build the "Top Deals" section like image 11 ("Power-Packed Deals").
Logic: a deal exists when a farmer lowers a listing price (oldPrice 200 -> price 120).
- Bold centred title "Price Drop Deals" (or "Top Deals") with a small decorative accent behind it.
- Tabs below it as folded-tab cards. Each tab shows a small caption above:
    "Starting at Rs <lowest current price in that category>" (selected tab)
    "Up to <max discount %> OFF" (other tabs)
  Tabs: Top Deals, Bamboo, Honey, Mahua, Herbs... The caption is computed from the data. For example, if
  bamboo products cost 120, 150 and 90 then the Bamboo tab says "Starting at Rs 90".
  "Top Deals" = lowest price across every category.
- Under the tabs, a horizontal list of product cards: image with a heart, unit label (500 g), green outlined
  ADD button, current price in bold with a highlight, struck-out old price, a "Lowest in 30 days" green
  label when it applies, product name (2 lines), the farmer or village name, and a "See more like this" chip.
- A "See all products >" row at the end of the list.
Compute discount % = (old - new) / old * 100 and show a green "% OFF" badge.
Include a helper function that takes List<Listing> and returns the tab captions.
```

### Screen 4: Category grid

```text
Build the "Shop by Category" screen like image 14.
Group titles in bold ("Forest Produce", "Food and Drinks", "Medicinal and Herbal", "Crafts and Bamboo",
"Farm and Dry Goods"). Under each, a 4-column grid of rounded pastel tiles with a product image on top and a
2-line centred label below. Sticky search bar and the category chip row at the top.
Tapping a tile opens the Shop list filtered by that category with a smooth Hero transition.
Use mock images from assets/categories/*.png.
```

### Screen 5: Product page and billing (like image 1)

```text
Build the Product Details screen like image 1 (centre) and image 4 (right):
- Large rounded hero image (with the static soft backdrop). On the right side, a vertical thumbnail strip with
  3-4 angles (front, side, top, texture). Tapping a thumbnail cross-fades the hero.
- Back button and heart on top. Below, the product name, farmer or village, rating, price, struck-out old price
  and % OFF badge, unit chips (250 g / 500 g / 1 kg), a quantity stepper, and a short description with "Read more".
- Bottom bar: "Add to Cart" (outlined) and "Buy Now" (filled).
Then build the Cart/Billing bottom sheet like image 1 (right): item rows with a remove button, sub-total, delivery
fee, total price, and a full-width green "Checkout" button.
```

### Screen 6: Navigation and transitions

```text
Wire everything with GoRouter: Landing -> Home -> Category -> Product -> Cart.
Add a shared page transition (fade through, 300 ms), tab-switch animation for the Top Deals tabs
(the folded tab slides under the selected one), and a staggered grid fade-in. Keep it 60 fps on low-end phones.
```

---

## Checklist

- [ ] Phase 1: background generated and saved to `app/assets/backgrounds/`
- [ ] Phase 2: 4 landing images and product angle sets saved to `app/assets/landing/` and `app/assets/products/`
- [ ] Phase 3: screens 1-6 generated, pasted into `app/lib/`, and `flutter analyze` passes
- [ ] Remove the old code-drawn background (see `app/lib/shared/widgets/hero_banner.dart`, which uses a CustomPainter)
