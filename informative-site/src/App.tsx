import React, { useEffect, useRef, useState } from "react";
import {
  motion,
  AnimatePresence,
  useScroll,
  useTransform,
  useReducedMotion,
} from "framer-motion";
import {
  Menu,
  X,
  ArrowUpRight,
  Download,
  Github,
  Sprout,
  Handshake,
  Compass,
  Clock,
  Users,
  UserCheck,
  Search,
  Truck,
  Check,
  MapPin,
  Smartphone,
  Languages,
  Layers,
  BookOpen,
  ArrowRight,
  Package,
  RefreshCw,
} from "lucide-react";
import { useCleanedBasket, useCleanedProduceSet } from "./utils/cleanImage";
import {
  CountUp,
  fadeUp,
  OrganicDivider,
  SectionHeader,
} from "./components/MotionPrimitives";
import { HeroWind } from "./components/HeroWind";
import { BasketStage, FallingProduceStory } from "./components/FallingMango";
import { MissionReveal } from "./components/MissionReveal";
import { TimelineSection } from "./components/TimelineSection";
import {
  VillageMediaEntry,
  VillagesSection,
  VillageStoryBlockData,
} from "./components/VillagesSection";
import { ResourceItem, ResourcesSection } from "./components/ResourcesSection";

// ============================================================================
// TOP-LEVEL CONSTANTS & EDITABLE SECTION DATA
// ============================================================================

export const MARKETPLACE_URL = "https://vanmitra-marketplace.vercel.app";
export const APK_URL =
  "https://github.com/VANMITRA/VanRojgar_final_module/releases/download/website-apk/VanMitra.apk";
export const GITHUB_URL = "https://github.com/VANMITRA/VanRojgar_final_module";
export interface TeamMember {
  name: string;
  role: string;
  description: string;
  isLead?: boolean;
}

export const TEAM: TeamMember[] = [
  {
    name: "Ayush Sahare",
    role: "Team Lead",
    description:
      "Co-creator of the idea; project direction, team coordination and field visits",
    isLead: true,
  },
  {
    name: "Samruddhi Shinde",
    role: "Front End and UI Design",
    description:
      "Creator of the idea; front end and UI design of both websites; field visits",
  },
  {
    name: "Sanskruti Ruyarkar",
    role: "Field Research",
    description:
      "Co-creator of the idea; field research and documentation; field visits",
  },
  {
    name: "Kaushal Talekar",
    role: "App Front End and Base Website",
    description:
      "Built the front end of the Android app and the base marketplace website",
  },
  {
    name: "Soham Patki",
    role: "Backend Developer",
    description: "Built the servers, database and APIs behind the app",
  },
];

export const VILLAGE_MEDIA: Record<string, VillageMediaEntry> = {
  ambai: {
    photos: [
      {
        file: "/field/ambai-01-gram-panchayat-discussion.jpg",
        caption: "Discussion with the Gram Panchayat, Ambai",
      },
      {
        file: "/field/ambai-02-gram-panchayat-and-team.jpg",
        caption: "Gram Panchayat members and the team, Ambai",
      },
      {
        file: "/field/ambai-03-hill-walk.jpg",
        caption:
          "Climbing the hill with Gram Panchayat members and RAAH Foundation",
      },
      {
        file: "/field/ambai-04-view-from-the-hill.jpg",
        caption: "View of the forest area from the hill",
      },
      {
        file: "/field/ambai-05-ifr-land.jpg",
        caption: "IFR land of the villagers, seen during the hill walk",
      },
      {
        file: "/field/ambai-06-interview.jpg",
        caption: "Interview with a member of the foundation",
      },
      {
        file: "/field/ambai-07-team-with-villagers.jpg",
        caption:
          "Team with villagers, Gram Panchayat members and RAAH Foundation",
      },
    ],
    videos: [],
    interviews: [],
  },
  kochargaon: {
    photos: [
      {
        file: "/field/kochargaon-01-village-and-cfr-boundary.jpg",
        caption: "Kochargaon village and the area around the CFR boundary",
      },
      {
        file: "/field/kochargaon-02-cfr-committee-board.jpg",
        caption: "CFR management committee board, Kochargaon",
      },
      {
        file: "/field/kochargaon-03-watch-tower.jpg",
        caption: "Studying the area from the watch tower, Kochargaon",
      },
      {
        file: "/field/kochargaon-04-land-around-cfr-boundary.jpg",
        caption: "View of the land around the CFR boundary",
      },
      {
        file: "/field/kochargaon-05-meeting-gram-panchayat-and-raah.jpg",
        caption:
          "Meeting with Gram Panchayat members and RAAH Foundation, Kochargaon",
      },
    ],
    videos: [],
    interviews: [],
  },
};

const NAV_LINKS = [
  { label: "Problem", href: "#problem" },
  { label: "Solution", href: "#solution" },
  { label: "How it works", href: "#how-it-works" },
  { label: "Resources", href: "#resources" },
  { label: "Impact", href: "#impact" },
  { label: "Villages", href: "#villages" },
  { label: "Progress", href: "#progress" },
  { label: "Team", href: "#team" },
];

const HERO_DATA = {
  badge: "IEEE Tech for Tomorrow 2026 · Team Forest Nexus",
  subtitle:
    "VanMitra is a marketplace app and website for forest produce, linking Gram Sabhas, CFR villagers, buyers and local workers in Nashik.",
  stats: [
    { value: 14, suffix: "", label: "Gram Sabhas" },
    { value: 2019, suffix: " ha", label: "CFR forest" },
    { value: 69, suffix: "", label: "plants" },
    { value: 4, suffix: "", label: "account types" },
  ],
};

const MISSION_TEXT =
  "Forest villages hold the rights and grow the resources. We are building the direct route between them and the buyers: a fair price for sellers, easy search for buyers, and paid local work with every order.";
const MISSION_HIGHLIGHTS = ["direct", "route", "fair"];

const PROBLEM_DATA = {
  intro:
    "Forest communities have the rights and are growing the resources, but still lack a direct, fair route to buyers.",
  facts: [
    {
      stat: "10.4 crore Scheduled Tribe people in India.",
      body: "Many earn 20–40% of annual income from minor forest produce.",
      source: "PIB / Ministry of Tribal Affairs, 20 Aug 2026",
    },
    {
      stat: "8,668 community forest rights titles in Maharashtra (1,23,329 across India).",
      body: "Legal recognition exists across thousands of forest communities.",
      source: "Lok Sabha USQ 2072, data to 31 Dec 2025",
    },
    {
      stat: "25.6% of Nashik district is Scheduled Tribe: 15,64,369 of 61,07,187.",
      body: "Over a quarter of the district population belongs to Scheduled Tribe communities.",
      source: "Census of India 2011",
    },
  ],
  cards: [
    {
      title: "Rights without a market",
      detail: "A title alone brings no buyers.",
      icon: Sprout,
    },
    {
      title: "Dependence on middlemen",
      detail: "Produce is often sold to intermediaries at low prices.",
      icon: Handshake,
    },
    {
      title: "Limited reach",
      detail:
        "MSP covers 87 items. Van Dhan Kendras link 12.48 lakh members, against 10.4 crore ST people.",
      icon: Compass,
    },
    {
      title: "Temporary programme work",
      detail:
        "Restoration work in 14 villages created about 12,710 labour days. Our view: when it ends, that income needs a lasting source, and that source is trade in forest produce.",
      icon: Clock,
    },
  ],
};

const SOLUTION_DATA = {
  subtitle:
    "VanMitra is a direct marketplace for forest produce that creates local jobs with every order.",
  steps: [
    {
      num: "1",
      title: "List",
      detail:
        "Producers list produce from their own land. Gram Sabhas list community produce.",
    },
    {
      num: "2",
      title: "Reach",
      detail: "Buyers beyond the village find listings and request directly.",
    },
    {
      num: "3",
      title: "Trade",
      detail:
        "Request, counter-offer, approve, order, with a timeline both sides see.",
    },
    {
      num: "4",
      title: "Work",
      detail:
        "Each order creates paid local work in delivery, handling and packing.",
    },
  ],
  accounts: [
    {
      title: "Gram Sabha member",
      detail:
        "Lists community produce after a CFR-rights check; can barter with other Gram Sabhas.",
      icon: Users,
    },
    {
      title: "CFR villager",
      detail:
        "Lists produce from own land, sets the price, accepts or counters requests.",
      icon: UserCheck,
    },
    {
      title: "General buyer",
      detail:
        "Searches by name and distance, sees seller and harvest details, requests and tracks.",
      icon: Search,
    },
    {
      title: "Delivery partner",
      detail: "Applies, gets approved, claims delivery jobs.",
      icon: Truck,
    },
  ],
  differences: [
    {
      problem: "Rights without a market",
      answer: "Gram Sabhas get their own channel, checked against CFR rights.",
    },
    {
      problem: "Selling to middlemen",
      answer: "Direct trade; the seller sets the price and decides each offer.",
    },
    {
      problem: "Buyers only in the locality",
      answer: "Listings visible to buyers beyond the village.",
    },
    {
      problem: "Temporary programme work",
      answer: "Ongoing paid work tied to every order.",
    },
  ],
  chips: [
    "Phone number + OTP login",
    "मराठी · हिंदी · English",
    "Protected species are blocked",
  ],
};

const HOW_IT_WORKS_STEPS = [
  { step: 1, title: "Join", detail: "Phone number + OTP; browsing is open." },
  {
    step: 2,
    title: "List",
    detail: "Restricted-species and harvest checks run.",
  },
  { step: 3, title: "Discover", detail: "Search by name and distance." },
  {
    step: 4,
    title: "Agree",
    detail: "Request, counter, approve or reject.",
  },
  {
    step: 5,
    title: "Order",
    detail: "Stock is reduced safely, no overselling.",
  },
  { step: 6, title: "Prepare", detail: "Local workers sort and pack." },
  {
    step: 7,
    title: "Deliver",
    detail: "An approved partner claims the job.",
  },
  { step: 8, title: "Close", detail: "Seller and buyer confirm." },
];

const SAFEGUARDS_DATA = [
  {
    title: "Restricted species",
    detail: "Wildlife Protection Act list checked on every listing.",
  },
  {
    title: "CFR rights check",
    detail: "Gram Sabha listings checked against FRA Sec. 3(1)(c).",
  },
  {
    title: "Account security",
    detail: "Hashed credentials, login lockout, rate limits.",
  },
  {
    title: "Harvest declaration",
    detail: "On every listing; stated purpose for bulk orders.",
  },
];

const FEATURES_DATA = [
  {
    title: "Resources with details",
    detail: "Each listing shows quantity, price, harvest details and seller origin.",
    icon: Package,
    pills: [] as { text: string; tone: "green" | "tan" | "muted" }[],
  },
  {
    title: "Village pages with real data",
    detail: "Dedicated pages present CFR forest area and species for each village.",
    icon: MapPin,
    pills: [],
  },
  {
    title: "Request flow",
    detail: "Buyers send an offer, sellers respond, and both follow clear states.",
    icon: Handshake,
    pills: [
      { text: "Accepted", tone: "green" as const },
      { text: "Counter offer", tone: "tan" as const },
      { text: "Rejected", tone: "muted" as const },
    ],
  },
  {
    title: "Barter between Gram Sabhas",
    detail: "Gram Sabhas can exchange community forest produce directly.",
    icon: RefreshCw,
    pills: [],
  },
  {
    title: "Delivery partners",
    detail: "Approved local partners claim delivery jobs and earn on completion.",
    icon: Truck,
    pills: [],
  },
  {
    title: "Phone OTP login",
    detail: "Fast sign-in using a phone number and one-time verification code.",
    icon: Smartphone,
    pills: [],
  },
];

const RESOURCES_LIST: ResourceItem[] = [
  { en: "Bamboo", local: "बांबू", image: "/resources/bamboo.jpg" },
  { en: "Moh", local: "मोह", image: "/resources/moh.jpg" },
  { en: "Tamarind", local: "चिंच", image: "/resources/tamarind.jpg" },
  { en: "Awla", local: "आवळा", image: "/resources/awla.jpg" },
  { en: "Cashew", local: "काजू", image: "/resources/cashew.jpg" },
  { en: "Mango", local: "आंबा", image: "/resources/mango.jpg" },
  { en: "Behda", local: "", image: "/resources/behda.jpg" },
  { en: "Hirda", local: "", image: "/resources/hirda.jpg" },
  { en: "Custard apple", local: "सीताफळ", image: "/resources/custard-apple.jpg" },
  { en: "Jamun", local: "", image: "/resources/jamun.jpg" },
  { en: "Bael", local: "", image: "/resources/bael.jpg" },
  { en: "Ber", local: "", image: "/resources/ber.jpg" },
  { en: "Karanj", local: "", image: "/resources/karanj.jpg" },
];

const IMPACT_DATA = {
  source: "Raah Foundation, Nashik, quarterly update, 1 Oct 2026, and MRSAC.",
  metrics: [
    {
      primary: 217708,
      secondary: null as number | null,
      suffix: "",
      label: "saplings planted",
    },
    {
      primary: 12710,
      secondary: null,
      suffix: "",
      label: "labour days of local work",
    },
    {
      primary: 11,
      secondary: null,
      suffix: "",
      label: "forest ponds (about 5.31 crore litres of storage)",
    },
    {
      primary: 794,
      secondary: null,
      suffix: "",
      label: "loose boulder structures",
    },
    {
      primary: 19,
      secondary: 4,
      suffix: "",
      label: "CFRMC meetings and wildlife awareness sessions",
    },
    {
      primary: 2019,
      secondary: null,
      suffix: " ha",
      label: "under restoration in 14 villages",
    },
  ],
  blocks: [
    { block: "Trimbakeshwar", areaHa: 1139, villages: 8 },
    { block: "Deola", areaHa: 575, villages: 4 },
    { block: "Dindori", areaHa: 305, villages: 2 },
  ],
  speciesPlanted: ["bamboo", "moh", "chinch", "sitaphal", "awla", "kaju", "amba"],
  whoBenefits: [
    {
      group: "Sellers and producers",
      items: [
        "Larger pool of buyers",
        "Control over listings and prices",
        "A first step into digital trade",
      ],
    },
    {
      group: "Gram Sabhas",
      items: [
        "A channel for community produce",
        "Visibility for village produce",
        "More activity stays in the village",
      ],
    },
    {
      group: "Buyers",
      items: [
        "Easy access to listings",
        "A direct channel to sellers",
        "Seller and harvest details shown",
        "Built-in legal safeguards",
      ],
    },
    {
      group: "Local workers",
      items: [
        "Collection and handling",
        "Sorting and packing",
        "Loading and movement",
        "Delivery work",
      ],
    },
  ],
  note: "Sellers set the price and choose which offers to accept. Earnings are not guaranteed.",
};

const VILLAGES_VISITED: {
  intro: string;
  blocks: VillageStoryBlockData[];
  learned: string[];
} = {
  intro:
    "We visited two villages in Nashik district, on two days. We walked the forest, saw the boundaries on the ground, and talked with villagers, Gram Panchayat members and local organisations.",
  blocks: [
    {
      key: "ambai",
      label: "Village 1 · 15 October 2026",
      name: "Ambai",
      location: "Trimbakeshwar, Nashik",
      mirrored: false,
      points: [
        "Met the Gram Panchayat, including the Adhyaksha and members.",
        "Two coordinators of RAAH Foundation and a member of FES Foundation were with us.",
        "Walked up the hill on foot and saw the plants, trees, forest resources, CFR and IFR boundaries, and how villagers use the forest every day.",
        "Saw IFR land: plots the villagers cultivate and fenced fields on the hill slope.",
        "Saw the CFR boundary from the top of the hill.",
      ],
    },
    {
      key: "kochargaon",
      label: "Village 2 · 16 October 2026",
      name: "Kochargaon",
      location: "Dindori, Nashik",
      mirrored: true,
      points: [
        "Visited with an FRA coordinator; a member of FES Foundation joined again.",
        "Different from Ambai: in Ambai the village boundary and the CFR boundary are joined, in Kochargaon there is a gap between the end of the village and the start of the CFR boundary.",
        "Saw boards of the Community Forest Rights Management Committee with the RAAH Foundation logo.",
        "Studied the area from the watch tower.",
        "Met villagers, Gram Panchayat members and a RAAH Foundation member.",
        "RAAH Foundation recently planted more than 70,000 saplings in the CFR area of Kochargaon.",
      ],
    },
  ],
  learned: [
    "Not all villages are the same.",
    "IFR land lies next to the CFR forest area.",
    "Walking the forest showed us the resources and the daily life of the people.",
    "Local organisations like RAAH Foundation and FES help villages a lot.",
  ],
};

const FEASIBILITY_DATA = {
  topCards: [
    {
      title: "Simple login",
      detail: "Phone number + OTP, no email, no password rules.",
      icon: Smartphone,
    },
    {
      title: "Local languages",
      detail: "Marathi, Hindi, English; key buttons in Marathi and English.",
      icon: Languages,
    },
    {
      title: "Simple flow",
      detail: "One action per screen, a plain order timeline.",
      icon: Layers,
    },
    {
      title: "Help to list",
      detail:
        "Gram Sabha and CFRMC members help neighbours list, building on meetings already held.",
      icon: Users,
    },
  ],
  wideCards: [
    {
      title: "Open access, permission by action",
      detail:
        "Anyone can browse; listing, community listing, buying and delivering each need their own permission; one account per person so roles can change.",
    },
    {
      title: "Safe by design",
      detail:
        "Only one delivery partner can claim a job; retried order requests never duplicate.",
    },
    {
      title: "Easy to scale",
      detail:
        "New villages load from data files, so adding a village is a data task, not new code; pilot in the 14 CFR villages in 3 blocks, then other Nashik blocks.",
    },
  ],
  builtWith: [
    "Flutter",
    "Node.js",
    "Python FastAPI",
    "MongoDB",
    "GitHub Actions",
  ],
};

const COMPARISON_DATA = {
  rows: [
    {
      channel: "Local middlemen",
      summary: "Local buyers only, little price visibility.",
      highlight: false,
    },
    {
      channel: "TRIFED / PM Van Dhan",
      summary: "Government procurement; no open direct trade or delivery jobs.",
      highlight: false,
    },
    {
      channel: "eNAM",
      summary: "Built for mandi trade, not CFR forest produce.",
      highlight: false,
    },
    {
      channel: "Amazon / IndiaMART",
      summary: "Not built for Gram Sabhas, CFR rules or village logistics.",
      highlight: false,
    },
    {
      channel: "VanMitra",
      summary:
        "Direct trade for individuals and Gram Sabhas, legal safeguards, local languages, local jobs.",
      highlight: true,
    },
  ],
  references: [
    "Raah Foundation, Quarterly Update on Ecological Restoration in CFR Areas of Nashik, 1 Oct 2026",
    "Forest Rights Act, 2006, and Rules (amended 2012)",
    "Wildlife (Protection) Act, 1972",
    "PIB, Unlocking India's Tribal Forest Economy, 20 Aug 2026",
    "Lok Sabha Unstarred Question 2072, answered 12 Feb 2026",
    "Census of India 2011, Nashik district",
    "TRIFED, Pradhan Mantri Van Dhan Yojana",
    "eNAM, National Agriculture Market",
  ],
};

const PROGRESS_DATA = {
  built: [
    "Marketplace with listings, search, request / counter / reject, orders and timeline",
    "Delivery work with application, approval, job claim, status and earnings",
    "Safeguards (species and CFR checks, harvest declaration, admin review)",
    "One account with action-based permissions",
    "Android app in Marathi, Hindi and English with phone number + OTP",
    "Handling, packing and movement jobs linked to orders",
    "Livelihood server with one sign-in across both servers",
    "Test suites and automatic builds",
  ],
  next: [
    "Load the 14-village data and show CFR status and planted species per village",
    "Suggest eligible produce, still legally checked",
    "Expert check of the restricted-species list",
    "Track listings per village, completed orders, delivery jobs and price received",
  ],
  roadmap: [
    "Agree with Gram Sabhas",
    "Load village data",
    "Pilot in 14 villages",
    "Extend to other Nashik blocks",
  ],
};

// ============================================================================
// MAIN APPLICATION
// ============================================================================

export default function App() {
  const prefersReduced = useReducedMotion() ?? false;
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const heroSectionRef = useRef<HTMLElement | null>(null);
  const heroIslandRef = useRef<HTMLDivElement | null>(null);
  const basketRef = useRef<HTMLDivElement | null>(null);

  const cleanedProduce = useCleanedProduceSet();
  const cleanedBasketSrc = useCleanedBasket("/basket.png");

  // Parallax for hero island (moves slightly slower than page scroll)
  const { scrollYProgress: heroScrollProgress } = useScroll({
    target: heroSectionRef,
    offset: ["start start", "end start"],
  });
  const islandParallaxY = useTransform(
    heroScrollProgress,
    [0, 1],
    prefersReduced ? [0, 0] : [0, 72]
  );

  useEffect(() => {
    const onScroll = () => {
      setScrolled(window.scrollY > 40);
    };
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const maxBlockArea = Math.max(...IMPACT_DATA.blocks.map((b) => b.areaHa));

  return (
    <div className="min-h-screen bg-[#172213] text-[#E9EFDC] relative overflow-x-clip">
      {/* Whole-page falling produce story layer (z-[6], behind z-[10] cards/photos & z-[70] lightbox, above z-[5] basket pile) */}
      <FallingProduceStory
        produce={cleanedProduce}
        heroIslandRef={heroIslandRef}
        basketRef={basketRef}
        reducedMotion={prefersReduced}
      />

      {/* ====================================================================
          NAVBAR
      ==================================================================== */}
      <header
        className={`fixed top-0 inset-x-0 z-50 transition-all duration-300 ${
          scrolled ? "py-3 px-4 sm:px-8" : "py-5 px-4 sm:px-8"
        }`}
      >
        <div
          className={`max-w-6xl mx-auto flex items-center justify-between gap-6 rounded-full px-4 sm:px-6 py-2.5 transition-all duration-300 ${
            scrolled ? "liquid-glass shadow-[0_12px_36px_rgba(0,0,0,0.32)]" : ""
          }`}
        >
          {/* Left: round logo + VanMitra + वनमित्र */}
          <a
            href="#top"
            className="flex items-center gap-2.5 shrink-0 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#8DB85A] rounded-full"
          >
            <img
              src="/logo-192.png"
              alt="VanMitra logo"
              className="w-9 h-9 md:w-11 md:h-11 rounded-full border border-[#F4F7EA]/30 shrink-0 block"
            />
            <span className="text-base sm:text-lg font-medium tracking-tight text-[#F4F7EA] whitespace-nowrap">
              VanMitra
            </span>
            <span className="text-xs text-[#A9B49A] font-devanagari whitespace-nowrap">
              वनमित्र
            </span>
          </a>

          {/* Centre: section links */}
          <nav
            aria-label="Primary"
            className="hidden lg:flex items-center gap-5 xl:gap-6 text-sm text-[#A9B49A]"
          >
            {NAV_LINKS.map((link) => (
              <a
                key={link.href}
                href={link.href}
                className="hover:text-[#F4F7EA] transition-colors whitespace-nowrap shrink-0"
              >
                {link.label}
              </a>
            ))}
          </nav>

          {/* Right: Open website glass pill + mobile menu trigger */}
          <div className="flex items-center gap-2.5 shrink-0">
            <a
              href={MARKETPLACE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="hidden sm:inline-flex items-center gap-1.5 btn-orange-primary rounded-full px-4 py-2 text-xs sm:text-sm font-medium text-[#1C2619] whitespace-nowrap"
            >
              <span>Open website</span>
              <ArrowUpRight className="w-3.5 h-3.5 text-[#1C2619]" />
            </a>

            <button
              type="button"
              onClick={() => setMobileMenuOpen(true)}
              aria-label="Open navigation menu"
              className="lg:hidden inline-flex items-center justify-center w-10 h-10 rounded-full liquid-glass text-[#F4F7EA]"
            >
              <Menu className="w-5 h-5" />
            </button>
          </div>
        </div>
      </header>

      {/* Full-screen mobile glass menu */}
      <AnimatePresence>
        {mobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="fixed inset-0 z-[60] bg-[#172213]/92 backdrop-blur-xl flex flex-col justify-between p-6"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <span className="text-lg font-medium text-[#F4F7EA]">
                  VanMitra
                </span>
                <span className="text-xs text-[#A9B49A] font-devanagari">
                  वनमित्र
                </span>
              </div>
              <button
                type="button"
                onClick={() => setMobileMenuOpen(false)}
                aria-label="Close navigation menu"
                className="w-10 h-10 rounded-full liquid-glass flex items-center justify-center text-[#F4F7EA]"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <nav className="flex flex-col items-center gap-5 my-auto">
              {NAV_LINKS.map((link) => (
                <a
                  key={link.href}
                  href={link.href}
                  onClick={() => setMobileMenuOpen(false)}
                  className="text-2xl font-medium text-[#E9EFDC] hover:text-[#8DB85A] transition-colors"
                >
                  {link.label}
                </a>
              ))}
            </nav>

            <div className="flex flex-col gap-3 max-w-xs mx-auto w-full pb-4">
              <a
                href={MARKETPLACE_URL}
                target="_blank"
                rel="noopener noreferrer"
                onClick={() => setMobileMenuOpen(false)}
                className="w-full inline-flex items-center justify-center gap-2 rounded-full btn-orange-primary text-[#1C2619] px-6 py-3.5 text-sm font-medium"
              >
                <span>Open website</span>
                <ArrowUpRight className="w-4 h-4 text-[#1C2619]" />
              </a>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ====================================================================
          HERO (Full viewport, wind leaves behind text & in front of island)
      ==================================================================== */}
      <section
        id="top"
        ref={heroSectionRef}
        className="relative min-h-screen pt-28 sm:pt-32 pb-8 flex flex-col items-center justify-start overflow-hidden"
      >
        {/* Wind leaves & twinkling fireflies: z-[4] (behind z-[10] headline, in front of z-[2] island) */}
        <HeroWind reducedMotion={prefersReduced} />

        {/* Hero Text Content: z-[10] */}
        <div className="relative z-[10] max-w-4xl mx-auto px-5 sm:px-8 text-center flex flex-col items-center">
          {/* Small glass pill on top */}
          <motion.div
            {...fadeUp(0, prefersReduced)}
            className="liquid-glass rounded-full px-4 py-1.5 text-xs sm:text-sm text-[#E9EFDC] tracking-wide mb-6"
          >
            {HERO_DATA.badge}
          </motion.div>

          {/* Headline */}
          <motion.h1
            {...fadeUp(0.08, prefersReduced)}
            className="text-5xl md:text-7xl lg:text-8xl font-medium tracking-[-1.5px] text-[#F4F7EA] leading-[1.03] text-balance"
          >
            Sell{" "}
            <span className="font-serif-accent font-normal pr-[0.04em]">
              direct
            </span>
            . Earn{" "}
            <span className="font-serif-accent font-normal pr-[0.04em]">
              local
            </span>
            .
          </motion.h1>

          {/* Subtitle */}
          <motion.p
            {...fadeUp(0.16, prefersReduced)}
            className="mt-6 text-base sm:text-lg md:text-xl text-[#A9B49A] max-w-2xl leading-relaxed"
          >
            {HERO_DATA.subtitle}
          </motion.p>

          {/* Two CTA Buttons */}
          <motion.div
            {...fadeUp(0.24, prefersReduced)}
            className="mt-8 flex flex-wrap items-center justify-center gap-3.5"
          >
            <a
              href={MARKETPLACE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-full btn-orange-primary text-[#1C2619] px-6 py-3 text-sm sm:text-base font-medium whitespace-nowrap"
            >
              <span>Open the website</span>
              <ArrowUpRight className="w-4 h-4 text-[#1C2619]" />
            </a>
            <a
              href={APK_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-full btn-app-orange text-[#F4F7EA] px-6 py-3 text-sm sm:text-base font-medium whitespace-nowrap"
            >
              <Download className="w-4 h-4 text-[var(--orange)]" />
              <span>Get the app</span>
            </a>
          </motion.div>

          {/* Row of 4 glass number tiles */}
          <motion.div
            {...fadeUp(0.32, prefersReduced)}
            className="mt-9 grid grid-cols-2 sm:grid-cols-4 gap-3 sm:gap-4 w-full max-w-3xl"
          >
            {HERO_DATA.stats.map((tile, idx) => (
              <div
                key={tile.label}
                className={`liquid-glass rounded-[20px] px-4 py-3.5 text-center ${
                  idx % 2 === 1 ? "card-hover-orange" : "card-hover-green"
                }`}
              >
                <div className="text-xl sm:text-2xl md:text-3xl font-semibold text-[var(--orange)] tracking-tight">
                  <CountUp
                    target={tile.value}
                    suffix={tile.suffix}
                    reducedMotion={prefersReduced}
                  />
                </div>
                <div className="text-xs sm:text-sm text-[#A9B49A] mt-0.5">
                  {tile.label}
                </div>
              </div>
            ))}
          </motion.div>
        </div>

        {/* Floating 3D Forest Island: z-[2], soft warm orange radial glow behind & seamless edge melt into #172213 */}
        <motion.div
          style={{ y: islandParallaxY }}
          className="relative z-[2] w-full max-w-[1100px] mx-auto mt-2 sm:-mt-4 px-2 sm:px-6 pointer-events-none select-none"
        >
          {/* Soft warm glow behind the hero island (12% orange fading smoothly to transparent, zero box) */}
          <div
            aria-hidden="true"
            style={{
              background:
                "radial-gradient(ellipse 56% 44% at 50% 48%, rgba(240, 161, 90, 0.13) 0%, rgba(240, 161, 90, 0.06) 46%, transparent 74%)",
            }}
            className="absolute -inset-x-10 -inset-y-8 pointer-events-none"
          />
          <div ref={heroIslandRef} className="relative animate-island-float w-full">
            <img
              src="/hero-island.png"
              alt="Floating forest island with pond, bamboo, moh, tamarind, awla, cashew, custard apple and mango tree"
              referrerPolicy="no-referrer"
              className="w-full h-auto block hero-island-mask"
            />
          </div>
        </motion.div>
      </section>

      {/* ====================================================================
          MISSION (Scroll word reveal)
      ==================================================================== */}
      <MissionReveal
        text={MISSION_TEXT}
        highlightedWords={MISSION_HIGHLIGHTS}
        reducedMotion={prefersReduced}
      />

      <OrganicDivider />

      {/* ====================================================================
          1. THE PROBLEM
      ==================================================================== */}
      <section
        id="problem"
        className="relative z-[10] max-w-6xl mx-auto px-5 sm:px-8 py-20 md:py-28 scroll-mt-20"
      >
        <SectionHeader
          label="THE PROBLEM"
          beforeItalic="Rights "
          italicWord="without"
          afterItalic=" a market"
          italicTone="orange"
          subtitle={PROBLEM_DATA.intro}
          reducedMotion={prefersReduced}
        />

        {/* Fact strip (3 glass cards) */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-5 mb-8">
          {PROBLEM_DATA.facts.map((fact, idx) => (
            <motion.div
              key={fact.source}
              {...fadeUp(idx * 0.08, prefersReduced)}
              className={`liquid-glass rounded-[20px] p-6 flex flex-col justify-between ${
                idx % 2 === 1 ? "card-hover-orange" : "card-hover-green"
              }`}
            >
              <div>
                <p className="text-base sm:text-lg font-medium text-[#F4F7EA] leading-snug">
                  {fact.stat}
                </p>
                <p className="mt-2.5 text-sm text-[#E9EFDC]/85 leading-relaxed">
                  {fact.body}
                </p>
              </div>
              <p className="mt-4 pt-3 border-t border-[#3C4E38]/60 text-xs text-[#A9B49A]">
                ({fact.source})
              </p>
            </motion.div>
          ))}
        </div>

        {/* 4 problem cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
          {PROBLEM_DATA.cards.map((item, idx) => {
            const Icon = item.icon;
            const isOrange = idx % 2 === 1;
            return (
              <motion.div
                key={item.title}
                {...fadeUp(idx * 0.08, prefersReduced)}
                className={`bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-6 sm:p-7 ${
                  isOrange ? "card-hover-orange" : "card-hover-green"
                }`}
              >
                <div
                  className={`w-10 h-10 rounded-full flex items-center justify-center mb-4 ${
                    isOrange
                      ? "bg-[var(--orange-soft)] border border-[var(--orange)]/35 text-[var(--orange)]"
                      : "bg-[#3A5233] border border-[#3C4E38] text-[#8DB85A]"
                  }`}
                >
                  <Icon className="w-5 h-5" />
                </div>
                <h3 className="text-xl font-medium text-[#F4F7EA]">
                  {item.title}
                </h3>
                <p className="mt-2 text-sm sm:text-base text-[#A9B49A] leading-relaxed">
                  {item.detail}
                </p>
              </motion.div>
            );
          })}
        </div>
      </section>

      <OrganicDivider flip />

      {/* ====================================================================
          2. OUR SOLUTION
      ==================================================================== */}
      <section
        id="solution"
        className="relative z-[10] max-w-6xl mx-auto px-5 sm:px-8 py-20 md:py-28 scroll-mt-20"
      >
        <SectionHeader
          label="OUR SOLUTION"
          beforeItalic="A direct market for "
          italicWord="forest"
          afterItalic=" produce"
          subtitle={SOLUTION_DATA.subtitle}
          reducedMotion={prefersReduced}
        />

        {/* 4-step row with connected green-to-orange line */}
        <div className="relative mb-14">
          <div
            aria-hidden="true"
            className="hidden lg:block absolute left-12 right-12 top-9 h-[1px] bg-gradient-to-r from-[#8DB85A]/75 via-[#C3AE5A]/70 to-[var(--orange)]/80"
          />
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 relative">
            {SOLUTION_DATA.steps.map((step, idx) => (
              <motion.div
                key={step.num}
                {...fadeUp(idx * 0.08, prefersReduced)}
                className={`bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-6 relative ${
                  idx % 2 === 1 ? "card-hover-orange" : "card-hover-green"
                }`}
              >
                <div className="w-9 h-9 rounded-full bg-[var(--orange)] text-[#1C2619] font-semibold text-sm flex items-center justify-center mb-4 tabular-nums">
                  {step.num}
                </div>
                <h3 className="text-lg font-medium text-[#F4F7EA]">
                  {step.title}
                </h3>
                <p className="mt-2 text-sm text-[#A9B49A] leading-relaxed">
                  {step.detail}
                </p>
              </motion.div>
            ))}
          </div>
        </div>

        {/* 4 account cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-14">
          {SOLUTION_DATA.accounts.map((acc, idx) => {
            const Icon = acc.icon;
            const isOrange = idx % 2 === 1;
            return (
              <motion.div
                key={acc.title}
                {...fadeUp(idx * 0.08, prefersReduced)}
                className={`liquid-glass rounded-[20px] p-6 ${
                  isOrange ? "card-hover-orange" : "card-hover-green"
                }`}
              >
                <div
                  className={`w-10 h-10 rounded-full flex items-center justify-center mb-4 ${
                    isOrange
                      ? "bg-[var(--orange-soft)] border border-[var(--orange)]/35 text-[var(--orange)]"
                      : "bg-[#3A5233] border border-[#3C4E38] text-[#8DB85A]"
                  }`}
                >
                  <Icon className="w-5 h-5" />
                </div>
                <h3 className="text-lg font-medium text-[#F4F7EA]">
                  {acc.title}
                </h3>
                <p className="mt-2 text-sm text-[#E9EFDC]/85 leading-relaxed">
                  {acc.detail}
                </p>
              </motion.div>
            );
          })}
        </div>

        {/* Table: Why VanMitra is different */}
        <motion.div
          {...fadeUp(0.12, prefersReduced)}
          className="bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-6 sm:p-8"
        >
          <h3 className="text-xl sm:text-2xl font-medium text-[#F4F7EA] mb-5">
            Why VanMitra is different
          </h3>
          <div className="overflow-x-auto -mx-2 px-2">
            <table className="w-full min-w-[520px] text-left border-collapse">
              <thead>
                <tr className="border-b border-[#3C4E38] text-xs uppercase tracking-[2px] text-[#A9B49A]">
                  <th className="py-3 pr-4 font-medium w-[42%]">Problem</th>
                  <th className="py-3 pl-4 font-medium">Our answer</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#3C4E38]/60 text-sm sm:text-base">
                {SOLUTION_DATA.differences.map((row) => (
                  <tr key={row.problem}>
                    <td className="py-4 pr-4 text-[#D8B48A] font-medium align-top">
                      {row.problem}
                    </td>
                    <td className="py-4 pl-4 text-[#E9EFDC] align-top">
                      {row.answer}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* 3 Chips */}
          <div className="mt-6 pt-5 border-t border-[#3C4E38]/60 flex flex-wrap gap-2.5">
            {SOLUTION_DATA.chips.map((chip) => (
              <span
                key={chip}
                className="inline-flex items-center rounded-full bg-[#3A5233] border border-[#3C4E38] px-4 py-1.5 text-xs sm:text-sm text-[#E9EFDC] font-devanagari"
              >
                {chip}
              </span>
            ))}
          </div>
        </motion.div>
      </section>

      <OrganicDivider />

      {/* ====================================================================
          3. HOW IT WORKS
      ==================================================================== */}
      <TimelineSection
        steps={HOW_IT_WORKS_STEPS}
        safeguards={SAFEGUARDS_DATA}
        reducedMotion={prefersReduced}
      />

      <OrganicDivider flip />

      {/* ====================================================================
          4. FEATURES
      ==================================================================== */}
      <section
        id="features"
        className="relative z-[10] max-w-6xl mx-auto px-5 sm:px-8 py-20 md:py-28"
      >
        <SectionHeader
          label="FEATURES"
          beforeItalic="Tools for "
          italicWord="direct"
          afterItalic=" trade"
          reducedMotion={prefersReduced}
        />

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {FEATURES_DATA.map((feat, idx) => {
            const Icon = feat.icon;
            const isOrange = idx % 2 === 1;
            return (
              <motion.div
                key={feat.title}
                {...fadeUp(idx * 0.08, prefersReduced)}
                className={`bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-6 flex flex-col justify-between ${
                  isOrange ? "card-hover-orange" : "card-hover-green"
                }`}
              >
                <div>
                  <div
                    className={`w-10 h-10 rounded-full flex items-center justify-center mb-4 ${
                      isOrange
                        ? "bg-[var(--orange-soft)] border border-[var(--orange)]/35 text-[var(--orange)]"
                        : "bg-[#3A5233] border border-[#3C4E38] text-[#8DB85A]"
                    }`}
                  >
                    <Icon className="w-5 h-5" />
                  </div>
                  <h3 className="text-lg font-medium text-[#F4F7EA]">
                    {feat.title}
                  </h3>
                  <p className="mt-2 text-sm text-[#A9B49A] leading-relaxed">
                    {feat.detail}
                  </p>
                </div>

                {feat.pills.length > 0 && (
                  <div className="mt-4 pt-3 border-t border-[#3C4E38]/60 flex flex-wrap gap-2">
                    {feat.pills.map((pill) => (
                      <span
                        key={pill.text}
                        className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-medium ${
                          pill.tone === "green"
                            ? "bg-[#8DB85A]/20 text-[#8DB85A] border border-[#8DB85A]/40"
                            : pill.tone === "tan"
                            ? "bg-[var(--orange)] text-[#1C2619] font-semibold"
                            : "bg-[#172213]/70 text-[#A9B49A] border border-[#3C4E38]"
                        }`}
                      >
                        {pill.text}
                      </span>
                    ))}
                  </div>
                )}
              </motion.div>
            );
          })}
        </div>
      </section>

      <OrganicDivider />

      {/* ====================================================================
          5. RESOURCES WE COVER (13 photo cards, 5/3/2 centred grid)
      ==================================================================== */}
      <ResourcesSection
        resources={RESOURCES_LIST}
        reducedMotion={prefersReduced}
      />

      <OrganicDivider flip />

      {/* ====================================================================
          6. DATA AND IMPACT
      ==================================================================== */}
      <section
        id="impact"
        className="relative z-[10] max-w-6xl mx-auto px-5 sm:px-8 py-20 md:py-28 scroll-mt-20"
      >
        <SectionHeader
          label="DATA AND IMPACT"
          beforeItalic="Data and "
          italicWord="impact"
          subtitle={`Source: ${IMPACT_DATA.source}`}
          reducedMotion={prefersReduced}
        />

        {/* 6 Big count-up tiles */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 mb-12">
          {IMPACT_DATA.metrics.map((m, idx) => (
            <motion.div
              key={m.label}
              {...fadeUp(idx * 0.08, prefersReduced)}
              className={`liquid-glass rounded-[20px] p-6 sm:p-7 ${
                idx % 2 === 1 ? "card-hover-orange" : "card-hover-green"
              }`}
            >
              <div className="text-3xl sm:text-4xl md:text-5xl font-semibold text-[var(--orange)] tracking-tight">
                <CountUp
                  target={m.primary}
                  suffix={m.secondary === null ? m.suffix : ""}
                  reducedMotion={prefersReduced}
                />
                {m.secondary !== null && (
                  <>
                    <span className="text-[#8DB85A] mx-1.5">+</span>
                    <CountUp
                      target={m.secondary}
                      reducedMotion={prefersReduced}
                    />
                  </>
                )}
              </div>
              <p className="mt-2.5 text-sm sm:text-base text-[#A9B49A] leading-relaxed">
                {m.label}
              </p>
            </motion.div>
          ))}
        </div>

        {/* Div Bar Chart: CFR area by block + species planted */}
        <motion.div
          {...fadeUp(0.1, prefersReduced)}
          className="bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-6 sm:p-8 mb-12"
        >
          <h3 className="text-xl sm:text-2xl font-medium text-[#F4F7EA] mb-6">
            CFR area by block
          </h3>

          <div className="space-y-5">
            {IMPACT_DATA.blocks.map((b, idx) => {
              const widthPct = (b.areaHa / maxBlockArea) * 100;
              return (
                <div key={b.block}>
                  <div className="flex flex-wrap items-baseline justify-between gap-2 text-sm sm:text-base mb-2">
                    <span className="font-medium text-[#F4F7EA]">
                      {b.block}
                    </span>
                    <span className="text-[#E9EFDC] tabular-nums">
                      {b.areaHa.toLocaleString("en-US")} ha{" "}
                      <span className="text-[#A9B49A]">
                        ({b.villages} villages)
                      </span>
                    </span>
                  </div>
                  <div className="w-full h-3.5 rounded-full bg-[#172213] border border-[#3C4E38] overflow-hidden">
                    <motion.div
                      initial={{ scaleX: prefersReduced ? 1 : 0 }}
                      whileInView={{ scaleX: 1 }}
                      viewport={{ once: true, margin: "-60px" }}
                      transition={{
                        duration: 0.85,
                        delay: idx * 0.12,
                        ease: "easeOut",
                      }}
                      style={{ width: `${widthPct}%` }}
                      className="h-full rounded-full bg-gradient-to-r from-[#8DB85A] to-[#D8B48A] origin-left"
                    />
                  </div>
                </div>
              );
            })}
          </div>

          <div className="mt-7 pt-5 border-t border-[#3C4E38]/70 flex flex-wrap items-center gap-2">
            <span className="text-xs uppercase tracking-[2px] text-[#A9B49A] mr-2">
              Species planted:
            </span>
            {IMPACT_DATA.speciesPlanted.map((sp) => (
              <span
                key={sp}
                className="rounded-full bg-[#3A5233] border border-[#3C4E38] px-3 py-1 text-xs text-[#E9EFDC]"
              >
                {sp}
              </span>
            ))}
          </div>
        </motion.div>

        {/* Who benefits (4 columns with ticks) */}
        <div>
          <motion.h3
            {...fadeUp(0, prefersReduced)}
            className="text-2xl sm:text-3xl font-medium text-[#F4F7EA] mb-6"
          >
            Who benefits
          </motion.h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {IMPACT_DATA.whoBenefits.map((col, idx) => (
              <motion.div
                key={col.group}
                {...fadeUp(idx * 0.08, prefersReduced)}
                className={`bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-6 ${
                  idx % 2 === 1 ? "card-hover-orange" : "card-hover-green"
                }`}
              >
                <h4 className="text-lg font-medium text-[#F4F7EA] mb-4">
                  {col.group}
                </h4>
                <ul className="space-y-2.5">
                  {col.items.map((pt) => (
                    <li
                      key={pt}
                      className="flex items-start gap-2.5 text-sm text-[#E9EFDC]/90 leading-relaxed"
                    >
                      <Check className="w-4 h-4 text-[#8DB85A] shrink-0 mt-0.5" />
                      <span>{pt}</span>
                    </li>
                  ))}
                </ul>
              </motion.div>
            ))}
          </div>
          <p className="mt-6 text-xs sm:text-sm text-[#A9B49A] text-center">
            {IMPACT_DATA.note}
          </p>
        </div>
      </section>

      <OrganicDivider />

      {/* ====================================================================
          7. WE WENT TO THE VILLAGES (Two full-width blocks + dotted leaf trail)
      ==================================================================== */}
      <VillagesSection
        intro={VILLAGES_VISITED.intro}
        blocks={VILLAGES_VISITED.blocks}
        mediaMap={VILLAGE_MEDIA}
        learned={VILLAGES_VISITED.learned}
        reducedMotion={prefersReduced}
      />

      <OrganicDivider flip />

      {/* ====================================================================
          8. FEASIBILITY AND VIABILITY (+ Built with glass chips row)
      ==================================================================== */}
      <section
        id="feasibility"
        className="relative z-[10] max-w-6xl mx-auto px-5 sm:px-8 py-20 md:py-28"
      >
        <SectionHeader
          label="FEASIBILITY AND VIABILITY"
          beforeItalic="Easy to use is the "
          italicWord="test"
          reducedMotion={prefersReduced}
        />

        {/* 4 usability cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-6">
          {FEASIBILITY_DATA.topCards.map((card, idx) => {
            const Icon = card.icon;
            const isOrange = idx % 2 === 1;
            return (
              <motion.div
                key={card.title}
                {...fadeUp(idx * 0.08, prefersReduced)}
                className={`bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-6 ${
                  isOrange ? "card-hover-orange" : "card-hover-green"
                }`}
              >
                <div
                  className={`w-10 h-10 rounded-full flex items-center justify-center mb-4 ${
                    isOrange
                      ? "bg-[var(--orange-soft)] border border-[var(--orange)]/35 text-[var(--orange)]"
                      : "bg-[#3A5233] border border-[#3C4E38] text-[#8DB85A]"
                  }`}
                >
                  <Icon className="w-5 h-5" />
                </div>
                <h3 className="text-lg font-medium text-[#F4F7EA]">
                  {card.title}
                </h3>
                <p className="mt-2 text-sm text-[#A9B49A] leading-relaxed">
                  {card.detail}
                </p>
              </motion.div>
            );
          })}
        </div>

        {/* 3 wide cards */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          {FEASIBILITY_DATA.wideCards.map((card, idx) => (
            <motion.div
              key={card.title}
              {...fadeUp(idx * 0.08, prefersReduced)}
              className={`liquid-glass rounded-[20px] p-6 sm:p-7 ${
                idx % 2 === 1 ? "card-hover-orange" : "card-hover-green"
              }`}
            >
              <h3 className="text-lg sm:text-xl font-medium text-[#F4F7EA]">
                {card.title}
              </h3>
              <p className="mt-2.5 text-sm sm:text-base text-[#E9EFDC]/85 leading-relaxed">
                {card.detail}
              </p>
            </motion.div>
          ))}
        </div>

        {/* Thin row of small glass chips: Built with */}
        <motion.div
          {...fadeUp(0.16, prefersReduced)}
          className="mt-8 pt-6 border-t border-[#3C4E38]/60 flex flex-wrap items-center gap-2.5"
        >
          <span className="text-xs uppercase tracking-[2.5px] text-[#A9B49A] mr-1.5">
            Built with
          </span>
          {FEASIBILITY_DATA.builtWith.map((tech) => (
            <span
              key={tech}
              className="liquid-glass rounded-full px-3.5 py-1 text-xs text-[#E9EFDC] whitespace-nowrap"
            >
              {tech}
            </span>
          ))}
        </motion.div>
      </section>

      <OrganicDivider />

      {/* ====================================================================
          9. WHERE OTHERS FALL SHORT + REFERENCES
      ==================================================================== */}
      <section
        id="comparison"
        className="relative z-[10] max-w-6xl mx-auto px-5 sm:px-8 py-20 md:py-28"
      >
        <SectionHeader
          label="COMPARISON"
          beforeItalic="Where others fall "
          italicWord="short"
          italicTone="orange"
          reducedMotion={prefersReduced}
        />

        <motion.div
          {...fadeUp(0.08, prefersReduced)}
          className="bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-6 sm:p-8 mb-10"
        >
          <div className="overflow-x-auto -mx-2 px-2">
            <table className="w-full min-w-[520px] text-left border-collapse">
              <thead>
                <tr className="border-b border-[#3C4E38] text-xs uppercase tracking-[2px] text-[#A9B49A]">
                  <th className="py-3.5 px-4 font-medium w-[34%]">Option</th>
                  <th className="py-3.5 px-4 font-medium">
                    How it works for forest villages
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#3C4E38]/60 text-sm sm:text-base">
                {COMPARISON_DATA.rows.map((row) => (
                  <tr
                    key={row.channel}
                    className={
                      row.highlight
                        ? "bg-[#8DB85A]/15 text-[#F4F7EA]"
                        : "text-[#E9EFDC]"
                    }
                  >
                    <td
                      className={`py-4 px-4 font-medium align-top ${
                        row.highlight ? "text-[#8DB85A]" : "text-[#F4F7EA]"
                      }`}
                    >
                      {row.channel}
                    </td>
                    <td className="py-4 px-4 align-top">{row.summary}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </motion.div>

        {/* Compact References list */}
        <motion.div
          {...fadeUp(0.14, prefersReduced)}
          className="liquid-glass rounded-[20px] p-6 sm:p-7"
        >
          <div className="flex items-center gap-2 text-xs uppercase tracking-[2.5px] text-[#A9B49A] mb-4">
            <BookOpen className="w-4 h-4 text-[#D8B48A]" />
            <span>References</span>
          </div>
          <ol className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-2 text-xs sm:text-sm text-[#A9B49A] list-decimal list-inside">
            {COMPARISON_DATA.references.map((ref) => (
              <li key={ref} className="leading-relaxed">
                {ref}
              </li>
            ))}
          </ol>
        </motion.div>
      </section>

      <OrganicDivider flip />

      {/* ====================================================================
          10. PROJECT PROGRESS
      ==================================================================== */}
      <section
        id="progress"
        className="relative z-[10] max-w-6xl mx-auto px-5 sm:px-8 py-20 md:py-28 scroll-mt-20"
      >
        <SectionHeader
          label="PROJECT PROGRESS"
          beforeItalic="Project "
          italicWord="progress"
          reducedMotion={prefersReduced}
        />

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-10">
          {/* Built */}
          <motion.div
            {...fadeUp(0.06, prefersReduced)}
            className="bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-6 sm:p-8 card-hover-green"
          >
            <div className="inline-flex items-center rounded-full bg-[#8DB85A] text-[#1C2619] px-3.5 py-1 text-xs font-semibold uppercase tracking-[1.5px] mb-5">
              Built
            </div>
            <ul className="space-y-3">
              {PROGRESS_DATA.built.map((item) => (
                <li
                  key={item}
                  className="flex items-start gap-2.5 text-sm sm:text-base text-[#E9EFDC] leading-relaxed"
                >
                  <Check className="w-4 h-4 text-[#8DB85A] shrink-0 mt-1" />
                  <span>{item}</span>
                </li>
              ))}
            </ul>
          </motion.div>

          {/* Next */}
          <motion.div
            {...fadeUp(0.14, prefersReduced)}
            className="bg-[#2E3E2B]/55 border border-[#3C4E38] rounded-[20px] p-6 sm:p-8 card-hover-orange"
          >
            <div className="inline-flex items-center rounded-full bg-[#3A5233] border border-[#3C4E38] text-[#D8B48A] px-3.5 py-1 text-xs font-semibold uppercase tracking-[1.5px] mb-5">
              Next
            </div>
            <ul className="space-y-3">
              {PROGRESS_DATA.next.map((item) => (
                <li
                  key={item}
                  className="flex items-start gap-2.5 text-sm sm:text-base text-[#E9EFDC]/90 leading-relaxed"
                >
                  <ArrowRight className="w-4 h-4 text-[var(--orange)] shrink-0 mt-1" />
                  <span>{item}</span>
                </li>
              ))}
            </ul>
          </motion.div>
        </div>

        {/* 4-step road */}
        <motion.div
          {...fadeUp(0.2, prefersReduced)}
          className="liquid-glass rounded-[20px] p-6 sm:p-7"
        >
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {PROGRESS_DATA.roadmap.map((step, idx) => (
              <div
                key={step}
                className="flex items-center gap-3 bg-[#172213]/65 border border-[#3C4E38] rounded-2xl p-4"
              >
                <span className="w-7 h-7 rounded-full bg-[var(--orange)] text-[#1C2619] text-xs font-semibold flex items-center justify-center shrink-0 tabular-nums">
                  {idx + 1}
                </span>
                <span className="text-sm font-medium text-[#F4F7EA]">
                  {step}
                </span>
              </div>
            ))}
          </div>
        </motion.div>
      </section>

      <OrganicDivider />

      {/* ====================================================================
          11. TEAM FOREST NEXUS
      ==================================================================== */}
      <section
        id="team"
        className="relative z-[10] max-w-6xl mx-auto px-5 sm:px-8 py-20 md:py-24 scroll-mt-20"
      >
        <SectionHeader
          label="THE TEAM"
          beforeItalic="Team "
          italicWord="Forest Nexus"
          italicTone="orange"
          centered
          reducedMotion={prefersReduced}
        />

        <div className="flex flex-wrap justify-center gap-5">
          {TEAM.map((member, idx) => {
            const initials = member.name
              .split(" ")
              .map((p) => p[0])
              .join("")
              .slice(0, 2)
              .toUpperCase();
            const isOrange = idx % 2 === 1;
            return (
              <motion.div
                key={member.name}
                {...fadeUp(idx * 0.08, prefersReduced)}
                className={`liquid-glass rounded-[20px] p-6 text-center flex flex-col items-center justify-start w-full sm:w-[calc((100%-1.25rem)/2)] lg:w-[calc((100%-2.5rem)/3)] sm:min-h-[256px] md:hover:-translate-y-[6px] ${
                  isOrange ? "card-hover-orange" : "card-hover-green"
                }`}
              >
                {member.isLead && (
                  <span className="absolute top-4 right-4 inline-flex items-center rounded-full bg-[var(--orange)] text-[#1C2619] px-2.5 py-0.5 text-[11px] font-semibold tracking-wide">
                    Team Lead
                  </span>
                )}
                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#8DB85A] to-[#4F7836] text-[#1C2619] font-semibold text-sm flex items-center justify-center mb-3.5 shrink-0 shadow-[0_6px_16px_rgba(0,0,0,0.28)]">
                  {initials}
                </div>
                <h3 className="text-base sm:text-lg font-medium text-[#F4F7EA]">
                  {member.name}
                </h3>
                <p className="text-xs sm:text-sm text-[#D8B48A] font-medium mt-1">
                  {member.role}
                </p>
                <p className="text-xs sm:text-sm text-[#A9B49A] leading-relaxed mt-3 max-w-[30ch]">
                  {member.description}
                </p>
              </motion.div>
            );
          })}
        </div>

        <motion.p
          {...fadeUp(0.12, prefersReduced)}
          className="mt-10 text-center text-sm sm:text-base text-[#A9B49A]"
        >
          Built by Team Forest Nexus for IEEE Tech for Tomorrow 2026
        </motion.p>
      </section>

      <OrganicDivider flip />

      {/* ====================================================================
          12. FINAL SECTION (The harvest basket & ending of the scroll story)
      ==================================================================== */}
      <section
        id="try-vanmitra"
        className="relative min-h-[720px] md:min-h-[900px] max-w-5xl mx-auto px-5 sm:px-8 pt-20 pb-20 md:pt-28 md:pb-24 text-center flex flex-col justify-between"
      >
        <div className="relative z-[10]">
          <motion.div
            {...fadeUp(0, prefersReduced)}
            className="relative w-[88px] h-[88px] mx-auto mb-6 flex items-center justify-center"
          >
            <div
              aria-hidden="true"
              style={{
                background:
                  "radial-gradient(circle, rgba(240, 161, 90, 0.36) 0%, rgba(240, 161, 90, 0.14) 52%, transparent 76%)",
              }}
              className="absolute -inset-6 rounded-full blur-md pointer-events-none"
            />
            <img
              src="/logo-512.png"
              alt="VanMitra logo"
              className="relative w-[88px] h-[88px] rounded-full block"
            />
          </motion.div>

          <SectionHeader
            label="GET STARTED"
            beforeItalic="See VanMitra in "
            italicWord="action"
            centered
            reducedMotion={prefersReduced}
          />
        </div>

        {/* Overflowing 3-layer harvest basket: bamboo stalks (z-[4]), heaped mound (z-[5]), falling items landing on top (z-[6]), front rim (z-[8]), and front spill & ground pieces (z-[9]) */}
        <BasketStage
          basketRef={basketRef}
          basketSrc={cleanedBasketSrc}
          produce={cleanedProduce}
          reducedMotion={prefersReduced}
        />

        <div>
          {/* Three CTA buttons & Android note */}
          <motion.div
            {...fadeUp(0.1, prefersReduced)}
            className="relative z-[10] mt-2 flex flex-wrap items-center justify-center gap-3.5"
          >
            <a
              href={MARKETPLACE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-full btn-orange-primary text-[#1C2619] px-6 py-3.5 text-sm sm:text-base font-medium whitespace-nowrap"
            >
              <span>Open the website</span>
              <ArrowUpRight className="w-4 h-4 text-[#1C2619]" />
            </a>

            <a
              href={APK_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-full btn-app-orange text-[#F4F7EA] px-6 py-3.5 text-sm sm:text-base font-medium whitespace-nowrap"
            >
              <Download className="w-4 h-4 text-[var(--orange)]" />
              <span>Get the app</span>
            </a>

            <a
              href={GITHUB_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-full liquid-glass text-[#F4F7EA] px-6 py-3.5 text-sm sm:text-base font-medium hover:bg-white/[0.08] transition-colors whitespace-nowrap"
            >
              <Github className="w-4 h-4 text-[#D8B48A]" />
              <span>View on GitHub</span>
            </a>
          </motion.div>

          <p className="relative z-[10] mt-4 text-xs sm:text-sm text-[#A9B49A]">
            If Android shows a warning, allow the install from this source.
          </p>
        </div>
      </section>

      {/* ====================================================================
          FOOTER
      ==================================================================== */}
      <footer className="relative z-[10] border-t border-[#3C4E38]/60 py-8 px-5 text-center text-xs sm:text-sm text-[#A9B49A]">
        <div className="max-w-6xl mx-auto flex flex-wrap items-center justify-center gap-3">
          <img
            src="/logo-192.png"
            alt="VanMitra logo"
            className="w-10 h-10 rounded-full shrink-0 block"
          />
          <span>
            © 2026 VanMitra · Team Forest Nexus · IEEE Tech for Tomorrow 2026
          </span>
        </div>
      </footer>
    </div>
  );
}
