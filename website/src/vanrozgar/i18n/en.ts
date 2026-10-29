/* English is the source wording, so its UI list is empty. The legal pages are kept here as structured text. */
export type Body=(string|string[])[];
export type Doc={title:string,updated:string,sections:{h:string,body:Body}[]};
export type Legal={updatedLabel:string,contents:string,terms:Doc,privacy:Doc};

const legal:Legal={
  updatedLabel:'Last updated: 28 October 2026',
  contents:'Contents',
  terms:{title:'Terms and conditions',updated:'28 October 2026',sections:[
    {h:'About VanRozgar',body:['VanRozgar is an online marketplace. Gram Sabhas and CFR villagers list forest produce, and buyers send requests for it. VanRozgar only connects people. We do not buy, own, store or sell the produce. Payment is not made on VanRozgar: the buyer and the Gram Sabha agree how and when to pay once a request is accepted.']},
    {h:'Who can use VanRozgar',body:[[
      'Anyone can browse the website. To send requests, list produce or deliver, you need an account.',
      'You must be 18 years or older to create an account.',
      'Accounts are of four types: Gram Sabha member, CFR villager, General buyer and Delivery partner. Each type has its own rules below.',
      'Log in with your phone number and an OTP. Never share your OTP with anyone. You are responsible for what happens in your account.',
      'Give true details. One person may have only one account.']]},
    {h:'Gram Sabha accounts and CFR villagers',body:[[
      'A Gram Sabha account needs a photo or scan of the CFR title, and a signed Gram Sabha resolution that names the authorised persons and their positions. At most 4 people may use one Gram Sabha account. To change a person, upload a new signed resolution.',
      'A CFR villager must upload a signed letter from the Gram Sabha that names the villager.',
      'The VanRozgar team checks every document by hand. We may ask for more papers, or refuse an account.',
      'Fake or changed documents will lead to the account being closed.']]},
    {h:'Listing and selling produce',body:[[
      'Sell only produce that you have the right to collect and sell.',
      'Enter true quantities and prices. A quantity marked Estimated may change until the Gram Sabha enters its real stock.',
      'Describe the produce correctly. Follow the safety notes: never describe an item marked "Not for eating" as food.',
      'Do not list any of these: wildlife or any part of an animal; timber from trees that were cut down; protected or endangered plants; alcohol or other intoxicating items; anything that is dangerous or banned by law.',
      'Trees and plants such as timber trees are sold as saplings only, not as wood.']]},
    {h:'Requests and approvals',body:[[
      'A request is not an order until the Gram Sabha accepts it.',
      'The Gram Sabha may accept, counter (offer a different amount) or reject any request, and a rejection shows a reason.',
      'A buyer may cancel a request while it is pending. After it is accepted, tell the Gram Sabha if you need to change it.',
      'Be honest about why you need the produce and when you need it.']]},
    {h:'Delivery partners',body:[[
      'A delivery partner needs a valid driving licence and vehicle papers. The VanRozgar team checks them before the partner can see jobs.',
      'Delivery partners are independent. They are not employees of VanRozgar. Payment for a trip is agreed before the trip.',
      'Handle goods with care, follow traffic laws, and confirm pick-up and drop in the app.']]},
    {h:'Prices, pictures and information',body:[[
      'Prices are set by Gram Sabhas and villagers.',
      'Pictures on VanRozgar are illustrations made with computer tools. They may look different from the produce you receive.',
      'Information about uses, seasons and storage is general. It is not medical advice. Traditional-use items are not a cure for any illness.']]},
    {h:'Good behaviour',body:[[
      'Be polite. Do not abuse, threaten, spam or send false requests.',
      'Do not cause harm to wildlife, trees or other natural resources. See "Our commitments to nature" in the Privacy policy.',
      'Do not try to cheat the approval steps, make fake accounts, or copy data from the site by machine.']]},
    {h:'Our rights',body:['We may suspend or close an account, remove a listing, or refuse a request that breaks these terms or the law. We may change these terms. We will show the date at the top, and using VanRozgar after a change means you accept it.']},
    {h:'Our responsibility',body:['VanRozgar is a platform. We do not promise the quality, quantity or delivery time of any produce, or that every request will be accepted. Deals are between the buyer, the Gram Sabha, the villager and the delivery partner. They should try to settle any problem between themselves first, and may contact us for help. As far as the law allows, VanRozgar is not responsible for losses from these deals.']},
    {h:'Law',body:['These terms follow the laws of India.']},
  ]},
  privacy:{title:'Privacy policy',updated:'28 October 2026',sections:[
    {h:'Our commitments to nature',body:['VanRozgar exists to help forest villages earn without harming the forest. We stand by these promises:',[
      '**We do not support harm to wildlife.** No animal, bird, insect or other creature, and no part of one, may be listed or sold. Produce must be collected in ways that do not hurt animals or their homes.',
      '**We do not support deforestation.** No tree may be cut or damaged to supply a product. We list only produce that can be taken without killing the tree: fruit, flowers, seeds, leaves, gum, and poles from mature bamboo. Timber trees are sold as saplings only.',
      '**We do not support waste or harm of natural resources.** Collect only what is needed, leave enough for the forest to grow back, keep water and soil clean, and do not burn or pollute.',
      'We may remove any listing, or close any account, that breaks these promises.']]},
    {h:'What we collect',body:[[
      'Your name, phone number and language choice. Email and address when you give them.',
      'Your village, Gram Sabha and position (for Gram Sabha members).',
      'Land details you enter: survey number, area, place, crops or trees.',
      'Documents you upload: signed letters, CFR title papers, resolutions, land extracts, driving licence and vehicle papers, and photos.',
      'Your requests, answers, cart and wishlist.',
      'Basic technical information about your device and browser.']]},
    {h:'Why we use it',body:[[
      'To create and protect your account, and to check people with our team\'s help.',
      'To show listings, send and answer requests, and arrange delivery.',
      'To send you an OTP and status messages by SMS.',
      'To keep the site safe, fix problems and follow the law.']]},
    {h:'Who can see what',body:[[
      'A Gram Sabha can see the requests made to it, with the buyer\'s name, phone number and needs.',
      'A delivery partner sees only the pick-up and drop details of the job.',
      'Land details and documents are private. Only you, your Gram Sabha (to confirm you) and the VanRozgar team can see them.',
      'Your phone number is never shown to the public. We do not sell your personal data.']]},
    {h:'How we protect it',body:['We keep data on protected servers, and only team members who need it can open it. Keep your OTP secret. No system is completely safe, so tell us at once if you think your account was misused.']},
    {h:'How long we keep it',body:['We keep your data while your account is active, and for as long as the law or a fair record needs. If you ask us to delete your account, we delete your data within a reasonable time, except what we must keep.']},
    {h:'Your choices',body:['You can see and correct your details in Profile and settings. You can ask us to delete your account and data, take back your consent, and choose your language and theme.']},
    {h:'SMS and notices',body:['We send OTPs and status messages. We do not send advertising without your permission.']},
    {h:'Saved settings on your device',body:['VanRozgar saves your login, language, theme and cart on your device so the site works well. We do not use advertising trackers.']},
    {h:'Children',body:['VanRozgar is for adults. We do not knowingly collect data from children.']},
    {h:'Changes',body:['We may update this policy. The date at the top will change, and for big changes we will tell you in the app.']},
  ]},
};

export default {ui:{} as Record<string,string>,legal,details:null as any};
