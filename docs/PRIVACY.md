# Privacy (draft for the team to read and confirm)

Same text as the app's **About & Privacy** screen (`app/lib/features/about/about_screen.dart`). If one changes, change the other.

**What we keep:** name, phone number, village, role and language. The 6-digit PIN is stored only as a one-way hash (bcrypt), never as the PIN.

**CFR holders:** the details given for the livelihood report (land size, water, animals, tools, plot position) are kept on the livelihood server and shown only to that person.

**Listings are public.** Their position is rounded to about 1 km. A phone number is never shown on a listing.

**Phone location** is used only if the person allows it, to place their plot. They can type a position instead.

**Third parties:** no advertising and no analytics in the app. Map pictures come from OpenStreetMap (it can see the network address when tiles load). Typical weather comes from Open-Meteo, fetched by our server for the village position only.

**Deletion:** to have an account and report deleted, contact the VanMitra team. There is no self-service delete yet (open item).

**To confirm before the judges:** a named contact for deletion requests; that no other SDK collects data in the APK build.
