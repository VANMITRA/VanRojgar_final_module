# Round 2 draft: report, data and map (Soham's side)

**Status:** draft for the team to confirm. **[confirm]** marks anything only a person can supply. Nothing here is a measured result. The marketplace answers are in `ayush.md`.

## What this part does
- A personal livelihood report: what is around a person's land (water, wells, forest, protected areas), and ideas for work that may suit them, each with a plain reason and the legal and wildlife checks that ran. It suggests; the person decides, and for community forest the Gram Sabha decides.
- Labels not scores. No idea is shown that needs selling or leasing forest land, hunting or trapping, or cutting timber (the four legal checks).
- Marathi, Hindi and English. The report can be saved as a PDF in the person's language.
- A map: the plot, the search circle (2 to 10 km), mapped resources and, optionally, marketplace listings.

## Data, and how honest it is
| Data | State |
|---|---|
| Community forest claims | Real: 950 rows, 771 villages, 14 talukas, from the district CFR register. Cleaned of all personal columns. 49 rows have no decision recorded and 167 have no right type; the app says "not recorded" |
| Village facts (forest, water, wells, soil, schools) | Real: 680 villages from the MRSAC geoportal, figures as printed. 853 of 950 claim rows matched a village; 96 names did not |
| Resources near a plot (the pins) | **Still the labelled SAMPLE set near Trimbak.** A builder for real OpenStreetMap data exists and has not been run (the public service was busy). OSM in rural areas is patchy and is labelled low confidence |
| Village positions | **Not available.** A village without a surveyed centre uses its taluka town as an approximate centre and says so; a person who saves their plot location gets a report about their own land |
| Weather | Typical monthly rain and maximum temperature from Open-Meteo (5 full years), cached, falling back to a labelled sample. **Not a forecast**. Market prices were not added: no free reliable source was found |
| Scheme register | 10 real government schemes, each linking only to its official website, no amounts. **No person has checked any row yet** (the app says so). 2 NGO rows are still labelled samples |
| Idea library | 16 ideas, a draft. **Not expert-reviewed**; the app says so |

## Numbers for the form (every one needs a person)
| Item | Figure | Source to cite |
|---|---|---|
| Community claims on the register | 950 [confirm how many are in the pilot village(s)] | the CFR register |
| Villages with claims | 771 | the CFR register |
| Direct and indirect beneficiaries | **[confirm]**, estimated from the pilot village's claim and household data | to be supplied |
| Cost to run | free tiers today (database, two servers, weather, map tiles) **[confirm limits on the day]** | provider pages |

## Technology readiness
Proposed after the phone test, honestly. Not claimed here.

## Known limits to say out loud
No test on a real phone yet; nothing deployed yet; real resource pins and village positions are not loaded; Marathi and Hindi are unread by a native speaker; the idea library and scheme rows are unreviewed.
