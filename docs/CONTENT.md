# VanRozgar | वनरोजगार: the project in words (a slide deck written as text)

Each "Slide" is one idea. Read top to bottom. Use it for the Round 2 form, the video script and any real slides.

---

## Slide 1: Title
**VanRozgar** (वनरोजगार). One Android app and one website that help forest communities in Nashik district earn from their land and sell forest produce fairly.
Part of the VanMitra family. Built for IEEE Tech4Tomorrow, Round 2.

## Slide 2: The problem
People who hold community forest rights (CFR) own land and forest resources, but they often do not know what work the land can support, and they sell forest produce to middlemen at low prices. Information is scattered and hard to read in their own language.

## Slide 3: Who it is for
- **CFR holders:** families who have claimed community forest land.
- **Farmers and villagers:** sell produce and buy locally.
- **Gram Sabhas:** list produce for the whole village, handle requests and delivery.
- **Buyers:** shops and people who want forest produce.

## Slide 4: What the product is
1. A **website** that explains the idea and shows the produce on offer.
2. An **Android app** where people sign in, trade, and (for CFR holders) get a personal **livelihood report**.
3. Two **servers** behind the app. One login works for both.

## Slide 5: How a purchase works
Landing page -> website -> press "Buy" -> download the app and log in -> paste the **item code** copied from the website -> order -> pay by **UPI** or **cash on delivery**.
The website never takes money. All payment happens inside the app.

## Slide 6: The livelihood report (CFR holders only)
The person enters facts about their land: size, water, animals, tools, past work, location. The app answers:
- what work ideas may suit the land, ranked, with the reason;
- what is nearby within 2 to 10 km, on a map;
- typical rain and temperature by month (from past years, not a forecast);
- government schemes to read about (links to official sites only).
The report can be saved as a PDF in English, Marathi or Hindi.

## Slide 7: The marketplace
Gram Sabhas and farmers list forest products (honey, bamboo, herbs, seeds and more). Buyers send requests; sellers accept, counter or decline. Accepted requests become orders with delivery. Barter is supported. Search works by words, category, price and distance.

## Slide 8: The four logins
| Login | Gets |
|---|---|
| Farmer | Marketplace |
| Buyer | Marketplace (buying side) |
| Gram Sabha | Marketplace, listings, delivery |
| CFR holder | Marketplace **plus** the livelihood report |

## Slide 9: Payments
- **UPI:** free. The app opens the buyer's own UPI app with the amount filled in. The buyer pays and gives the payment reference. The seller confirms the money arrived.
- **Cash on delivery:** the delivery partner collects cash and marks it received.
- No cards, no payment gateway fees. The app is honest that UPI confirmation is by a person.

## Slide 10: Rules the app never breaks
- No false data: every result shows its source and date; anything made up is labelled Sample.
- Suggestions only; community forest land is "use only through the Gram Sabha".
- Nothing that harms wildlife is ever suggested; banned products cannot be listed.
- No numeric scores, only plain labels. Missing facts say "not available".
- Private data stays private: no caste, income or ID numbers; people can delete their answers.
- Three languages: English, Marathi, Hindi. Marathi and Hindi are drafts until a native reader checks them.

## Slide 11: The real data
Only the **14 villages of the Raah Foundation report** (Deola, Dindori, Trimbakeshwar): forest area, saplings, ponds, boulder structures, labour days, meetings, species. Totals match the report. Village positions are approximate and say so. Maps come from OpenStreetMap, weather from Open-Meteo. All credits are in `CREDITS.md`.

## Slide 12: Technology
| Part | Technology |
|---|---|
| Android app | Flutter, Riverpod, GoRouter |
| Website | React, Vite, Tailwind |
| Marketplace server | Node.js, Express, MongoDB |
| Livelihood server | Python, FastAPI, MongoDB |
| Sign-in | Phone + 6-digit PIN, signed tokens shared by both servers |
| Maps | OpenStreetMap through flutter_map |
| Hosting | Render (servers), MongoDB Atlas (database), Vercel (website) |
| Build | GitHub Actions makes the signed APK |

## Slide 13: Architecture in one picture
```
 Website (Vercel)  ->  APK download
                              |
                       Android app (Flutter)
                         |             |
          Marketplace server (Node)   Livelihood server (Python)
                         \             /
                      MongoDB Atlas (one database, one login secret)
```

## Slide 14: Who builds what
- **Kaushal:** the website and landing page.
- **Ayush:** the marketplace, UPI and cash-on-delivery payments, deployment.
- **Soham:** the livelihood module, the roles, joining website and app, testing everything.

## Slide 15: Status (be honest)
Built and tested by automated tests: sign-in, marketplace, report, map, PDF, three languages, 14-village data.
Not done yet: payments, item codes, CFR role, website-to-app flow, live deployment, real-phone test, native review of Marathi and Hindi, checked scheme rows, real resource pins.

## Slide 16: What we need from people
NGO name and letter of support, community representative, visit photos and videos, permission status, team details, the team UPI ID, a native Marathi and Hindi reader.

## Slide 17: Impact (to confirm with real numbers)
Better information for CFR holders, fairer prices through direct trade, local delivery jobs. Beneficiary counts and costs are left blank until people confirm them. We do not invent numbers.

## Slide 18: Plan to the deadline
Freeze on 28 Oct, submit on 29 Oct, 30 Oct is a spare day. Tasks and owners are tracked as GitHub issues and in `docs/tasks.md`.
