import { Language } from '../types';

export interface Translations {
  tagline: string;
  motto: string;
  ecosystemSynergy: string;
  nav: {
    overview: string;
    ecosystem: string;
    howItWorks: string;
    portals: string;
    marketplace: string;
    barter: string;
    delivery: string;
    impact: string;
    explore: string;
    backToSite: string;
    previousTab: string;
    nextTab: string;
    activeWindow: string;
    openTab: string;
    exploreSection: string;
    switchToDarkMode: string;
    switchToLightMode: string;
  };
  concepts: {
    communityCommerce: string;
    sustainableLivelihoods: string;
    employmentGeneration: string;
  };
  categories: {
    all: string;
    medicinal: string;
    forest_produce: string;
    handicrafts: string;
    water_land: string;
    others: string;
  };
  portals: {
    gramSabha: {
      name: string;
      desc: string;
      badge: string;
    };
    villager: {
      name: string;
      desc: string;
      badge: string;
    };
    buyer: {
      name: string;
      desc: string;
      badge: string;
    };
  };
  modes: {
    sell: string;
    barter: string;
    both: string;
  };
  common: {
    searchPlaceholder: string;
    distance: string;
    quantity: string;
    price: string;
    suggestedFairPrice: string;
    verifiedGramSabha: string;
    sustainableCollection: string;
    requestToBuy: string;
    offerBarter: string;
    largeOrderReason: string;
    largeOrderReasonHelp: string;
    earnWithDelivery: string;
    deliveryPartnerDesc: string;
    startRegistration: string;
    viewDetails: string;
    close: string;
    confirm: string;
    submit: string;
    cancel: string;
    status: string;
    openProductDecisions: string;
  };
  hero: {
    badge: string;
    cfrCommerce: string;
    headlineBefore: string;
    headlineHighlight: string;
    headlineAfter: string;
    description: string;
    howItWorks: string;
    statsActiveGs: string;
    statsRuralEarnings: string;
    statsDeliveries: string;
    driverEnRoute: string;
    routeMeta: string;
  };
  featuredProducts: {
    badge: string;
    title: string;
    desc: string;
    allProducts: string;
    viewDetails: string;
    exploreMarketplace: string;
    showAll: string;
    showFewer: string;
    showingCount: string;
    emptyTitle: string;
    emptyDesc: string;
    resetFilter: string;
    verified: string;
    groupPooled: string;
    availableStock: string;
  };
  ecosystemSection: {
    badge: string;
    title: string;
    desc: string;
    parentTitle: string;
    parentBadge: string;
    parentDesc: string;
    parentModules: {
      title: string;
      desc: string;
      status: string;
    }[];
    bridgeBadge: string;
    bridgeDesc: string;
    moduleTitle: string;
    moduleBadge: string;
    moduleDesc: string;
    pillars: {
      title: string;
      desc: string;
    }[];
  };
  explorerSection: {
    badge: string;
    title: string;
    desc: string;
    sortBy: string;
    sortNearest: string;
    sortPriceAsc: string;
    sortRatingDesc: string;
    modeLabel: string;
    modeAll: string;
    modeBuy: string;
    modeBarter: string;
    clear: string;
    groupPooled: string;
    fairRange: string;
    offeredAt: string;
    noResultsTitle: string;
    noResultsDesc: string;
    resetFilters: string;
  };
  howItWorksSection: {
    badge: string;
    title: string;
    desc: string;
    stepPrefix: string;
    prevBtn: string;
    nextBtn: string;
    liveStatusTitle: string;
    steps: {
      step: string;
      title: string;
      actor: string;
      summary: string;
      details: string[];
      previewBadge: string;
    }[];
  };
  portalsSection: {
    badge: string;
    title: string;
    desc: string;
    deliveryClarification: string;
    activeSpecBadge: string;
    bottomTabsLabel: string;
    coreCapsLabel: string;
    restrictionsLabel: string;
    matrixTitle: string;
    matrixDesc: string;
    colFeature: string;
    colGramSabha: string;
    colVillager: string;
    colBuyer: string;
    portalSpecs: {
      title: string;
      subtitle: string;
      badge: string;
      description: string;
      bottomTabs: string[];
      keyFeatures: string[];
      notAllowed: string[];
    }[];
    comparisonRows: {
      feature: string;
      gs: string | boolean;
      vil: string | boolean;
      buy: string | boolean;
    }[];
  };
  barterSection: {
    badge: string;
    title: string;
    desc: string;
    simulatorTitle: string;
    liveTestBadge: string;
    simulatorDesc: string;
    simToggleLabel: string;
    sparseDataTitle: string;
    sparseDataDesc: string;
    partyATitle: string;
    partyASub: string;
    partyBTitle: string;
    partyBSub: string;
    commodityLabel: string;
    qtyOfferedLabel: string;
    qtyRequestedLabel: string;
    totalBenchmarkVal: string;
    exchangeRatioLabel: string;
    equivalenceStatus: string;
    balancedVerdict: string;
    favoursReceiverVerdict: string;
    favoursSenderVerdict: string;
    footnoteTitle: string;
    footnoteDesc: string;
  };
  groupSellingSection: {
    badge: string;
    title: string;
    desc: string;
    contributingTitle: string;
    totalPoolLabel: string;
    contributedPrefix: string;
    equalRuleNote: string;
    pooledFunnelLabel: string;
    bulkBuyerPurchaseLabel: string;
    simBuyerOrder: string;
    minLabel: string;
    maxLabel: string;
    totalOrderVal: string;
    villagePayoutTitle: string;
  };
  deliverySection: {
    badge: string;
    title: string;
    desc: string;
    journeySteps: {
      step: string;
      title: string;
      actor: string;
      desc: string;
    }[];
    unlockedBadge: string;
    dashTitle: string;
    dashDesc: string;
    totalEarningsLabel: string;
    completedHaulsLabel: string;
    partnerRatingLabel: string;
    ratedByLabel: string;
    availabilityTitle: string;
    availabilitySub: string;
    activeText: string;
    offlineText: string;
    availableJobsTitle: string;
    jobsOpenNearby: string;
    pickupLabel: string;
    dropLabel: string;
    routeLabel: string;
    openJobBadge: string;
    fairnessRules: {
      title: string;
      desc: string;
    }[];
  };
  impactSection: {
    badge: string;
    title: string;
    demoDataWarning: string;
    desc: string;
    filterAll: string;
    filterDistrictSuffix: string;
    earningsCardTitle: string;
    earningsCardSub: string;
    jobsCardTitle: string;
    jobsCardSub: string;
    familiesCardTitle: string;
    familiesCardSub: string;
    trendTitle: string;
    trendSub: string;
    trendBadge: string;
    volumeTitle: string;
    volumeSub: string;
    commissionNotice: string;
  };
  trustSection: {
    badge: string;
    title: string;
    desc: string;
    tagTitle: string;
    tagBadge: string;
    tagIntro: string;
    tagPillars: {
      title: string;
      desc: string;
    }[];
    largeOrderTitle: string;
    largeOrderBadge: string;
    largeOrderIntro: string;
    largeOrderRules: {
      title: string;
      desc: string;
    }[];
  };
  openDecisionsSection: {
    badge: string;
    title: string;
    desc: string;
    statusLabel: string;
    decisions: {
      id: string;
      title: string;
      question: string;
      demoPlaceholder: string;
      impact: string;
    }[];
  };
  footer: {
    subtitle: string;
    summary: string;
    compliance: string;
    ecosystemTitle: string;
    backOfficeTitle: string;
    backOfficeText: string;
    helplineLabel: string;
    helplineNumber: string;
    replayIntro: string;
    allRightsReserved: string;
    fraLaw: string;
    privacyPolicy: string;
  };
  listingModal: {
    verifiedBadge: string;
    verifiedReviews: string;
    sourceAreaLabel: string;
    harvestMethodLabel: string;
    sustainablePledge: string;
    listedPriceLabel: string;
    inStoreStock: string;
    fairPriceGuideTitle: string;
    fairPriceNotice: string;
    requestPurchaseTab: string;
    offerBarterTab: string;
    barterDisabledNotice: string;
    quantityDesiredLabel: string;
    sustainabilityTitle: string;
    sustainabilityNotice: string;
    reasonInputLabel: string;
    reasonPlaceholder: string;
    fulfillmentModeLabel: string;
    deliveryOptionTitle: string;
    deliveryOptionSub: string;
    pickupOptionTitle: string;
    pickupOptionSub: string;
    estimatedAmountLabel: string;
    paymentDecisionNotice: string;
    grandTotalLabel: string;
    barterWantsLabel: string;
    exchangeResourceLabel: string;
    exchangeQtyLabel: string;
    equityMeterTitle: string;
    offeredValLabel: string;
    targetValLabel: string;
    cancelBtn: string;
    submitPurchaseBtn: string;
    submitBarterBtn: string;
  };
}

export const translations: Record<Language, Translations> = {
  en: {
    tagline: 'Trade resources. Create livelihoods.',
    motto: 'Where forest resources become rural livelihoods under Community Forest Rights.',
    ecosystemSynergy: 'VanMitra-AI protects forest rights; VanMitra turns them into rural income.',
    nav: {
      overview: 'Overview',
      ecosystem: 'Ecosystem',
      howItWorks: 'How it Works',
      portals: '3 Portals',
      marketplace: 'Marketplace',
      barter: 'Barter & Fair Price',
      delivery: 'Delivery Jobs',
      impact: 'Impact',
      explore: 'Explore',
      backToSite: 'Back to Overview',
      previousTab: 'Previous Tab',
      nextTab: 'Next Tab',
      activeWindow: 'Dedicated Window View',
      openTab: 'Open Tab',
      exploreSection: 'Explore Tab',
      switchToDarkMode: 'Switch to dark mode',
      switchToLightMode: 'Switch to light mode',
    },
    concepts: {
      communityCommerce: 'Community Commerce',
      sustainableLivelihoods: 'Sustainable Livelihoods',
      employmentGeneration: 'Employment Generation',
    },
    categories: {
      all: 'All Categories',
      medicinal: 'Medicinal Plants (Jadibuti)',
      forest_produce: 'Forest Produce (Honey, Mahua)',
      handicrafts: 'Handicrafts & Bamboo',
      water_land: 'Water & Land Resources',
      others: 'Other Resources',
    },
    portals: {
      gramSabha: {
        name: 'Gram Sabha Portal',
        desc: 'We manage a CFR village and want to sell or exchange locally conserved forest resources.',
        badge: 'Seller & Steward',
      },
      villager: {
        name: 'Landowner / Villager Portal',
        desc: 'I live in or own land in a CFR village and want to buy resources or earn through delivery.',
        badge: 'Community Member',
      },
      buyer: {
        name: 'General Buyer Portal',
        desc: 'I am a person or business outside CFR villages looking for authentic bulk forest raw materials.',
        badge: 'Enterprise & Consumer',
      },
    },
    modes: {
      sell: 'For Sale',
      barter: 'Barter Swap',
      both: 'Sale & Barter',
    },
    common: {
      searchPlaceholder: 'Search forest produce, jadibuti, bamboo crafts...',
      distance: 'away',
      quantity: 'Available',
      price: 'Fair Price',
      suggestedFairPrice: 'Suggested Fair Price Guide',
      verifiedGramSabha: 'Verified Gram Sabha',
      sustainableCollection: 'Sustainably Collected under CFR',
      requestToBuy: 'Request to Buy',
      offerBarter: 'Offer Barter Exchange',
      largeOrderReason: 'Reason for Bulk Request (Required)',
      largeOrderReasonHelp: 'A large order can exhaust a village seasonal stock. The reason ensures harvest sustainability and prevents speculative over-extraction.',
      earnWithDelivery: 'Have a vehicle? Earn money delivering resources.',
      deliveryPartnerDesc: 'Become a certified village delivery partner and earn fair per-trip remuneration.',
      startRegistration: 'Register Vehicle',
      viewDetails: 'View Details',
      close: 'Close',
      confirm: 'Confirm',
      submit: 'Submit Request',
      cancel: 'Cancel',
      status: 'Status',
      openProductDecisions: 'Open Product Decisions',
    },
    hero: {
      badge: 'VanMitra-AI Ecosystem Module',
      cfrCommerce: '★ CFR Forest Commerce',
      headlineBefore: 'Where forest resources become',
      headlineHighlight: 'rural livelihoods.',
      headlineAfter: '',
      description: 'VanMitra connects forest-stewarding Gram Sabhas, tribal producers, and ethical enterprises on a single transparent marketplace, while creating paid transport gigs for village drivers.',
      howItWorks: 'How it Works',
      statsActiveGs: 'CFR Gram Sabhas Active',
      statsRuralEarnings: 'Rural Earnings',
      statsDeliveries: 'Deliveries Completed',
      driverEnRoute: 'Village Driver En Route',
      routeMeta: 'MH-48 · 22 km (~₹370)',
    },
    featuredProducts: {
      badge: 'Certified Community Produce',
      title: 'Explore Forest Products',
      desc: 'Ethically harvested forest produce, medicinal plants, handicrafts, and community resources directly from CFR Gram Sabhas.',
      allProducts: 'All Products',
      viewDetails: 'View Details',
      exploreMarketplace: 'Explore Full Marketplace',
      showAll: 'Show all ({count})',
      showFewer: 'Show fewer',
      showingCount: 'Showing {count} of {total} products',
      emptyTitle: 'No products in this category',
      emptyDesc: 'There are currently no listed items matching this category filter.',
      resetFilter: 'Show all products',
      verified: 'FRA Verified',
      groupPooled: 'Group Pooled',
      availableStock: 'Available stock:',
    },
    ecosystemSection: {
      badge: 'The VanMitra Ecosystem Architecture',
      title: 'Rights Recognition Leads to Economic Empowerment',
      desc: 'VanMitra-AI legally maps and protects forest rights under the Forest Rights Act (FRA 2006). VanMitra is the integrated economic module that turns those legal rights into sustainable rural income.',
      parentTitle: 'VanMitra-AI',
      parentBadge: 'Governance & CFR',
      parentDesc: 'Covers the exact 5 core pillars of forest title rights recognition:',
      parentModules: [
        {
          title: 'Dashboard',
          desc: 'Central command for village CFR claims status, meetings, and forest area records.',
          status: 'Active Governance',
        },
        {
          title: 'Claims (Form B & C)',
          desc: 'Digital filing and Rule 13 evidence verification for Community Forest Rights claims.',
          status: 'Title Recognition',
        },
        {
          title: 'Gram Sabha Records',
          desc: 'Quorum tracking, official resolutions, and sustainable harvest quotas.',
          status: 'Community Authority',
        },
        {
          title: 'Atlas Map',
          desc: 'Cadastral GIS boundary mapping of recognized community forest compartments.',
          status: 'Spatial Verification',
        },
        {
          title: 'Profile & Settings',
          desc: 'Gram Sabha office-bearer credentials, multilingual switch, and secure verification.',
          status: 'Verified Identity',
        },
      ],
      bridgeBadge: 'Livelihood Bridge',
      bridgeDesc: 'Recognized CFR areas yield certified natural resources',
      moduleTitle: 'VanMitra',
      moduleBadge: 'Marketplace & Jobs',
      moduleDesc: 'Operates the Amazon-style buyer–seller model adapted for Community Forest Rights:',
      pillars: [
        {
          title: '1. Direct Community Commerce',
          desc: 'Gram Sabhas autonomously list wild herbs, honey, bamboo crafts, and water rights with fair-price guidance.',
        },
        {
          title: '2. Provenance & Harvest Protection',
          desc: 'Only verified CFR Gram Sabhas can list; bulk buyers must state a reason to prevent seasonal over-harvesting.',
        },
        {
          title: '3. Local Transport Employment',
          desc: 'Villagers with pickup trucks, tempos, and bikes earn guaranteed per-trip income delivering orders.',
        },
      ],
    },
    explorerSection: {
      badge: 'Live Community Marketplace',
      title: 'Resource Explorer',
      desc: 'Discover authentic natural resources produced by forest-dependent Gram Sabhas with verified provenance tags and fair-price guidance.',
      sortBy: 'Sort by:',
      sortNearest: 'Nearest Distance (km)',
      sortPriceAsc: 'Lowest Price First',
      sortRatingDesc: 'Highest Rated (Stars)',
      modeLabel: 'Mode:',
      modeAll: 'All',
      modeBuy: 'Buy',
      modeBarter: 'Barter',
      clear: 'Clear',
      groupPooled: 'Group Pooled',
      fairRange: 'Fair Range:',
      offeredAt: 'Offered at',
      noResultsTitle: 'No resources match your filters',
      noResultsDesc: 'Try searching for "Honey", "Ashwagandha", "Bamboo", or browse all categories.',
      resetFilters: 'Reset all filters',
    },
    howItWorksSection: {
      badge: 'End-to-End Workflow',
      title: 'How VanMitra Operates',
      desc: 'Every step preserves forest sustainability, community decision-making, and guarantees fair livelihoods for local transporters.',
      stepPrefix: 'Step',
      prevBtn: 'Previous Step',
      nextBtn: 'Next Step',
      liveStatusTitle: 'Live Workflow Status',
      steps: [
        {
          step: '01',
          title: 'Gram Sabha Lists Resources',
          actor: 'Gram Sabha (Seller)',
          summary: 'Forest councils register seasonal produce with photos, sustainable harvest source details, and pricing.',
          details: [
            'Suggested fair-price guide range calculated from regional CFR transactions.',
            'Choose mode: Sell for cash, Barter for needed resources, or Both.',
            'Gram Sabha accounts are pre-verified by the field team before listings go public.',
          ],
          previewBadge: 'Autonomous Pricing & Provenance',
        },
        {
          step: '02',
          title: 'Search by Distance & Price',
          actor: 'Villager or Buyer',
          summary: 'Buyers filter nearby Gram Sabhas by kilometer distance, stock availability, and verified ratings.',
          details: [
            'Distance calculated from saved village coordinates.',
            'Clear distinction between individual village harvests and pooled group listings.',
            'View sustainable harvesting confirmation and forest compartment details.',
          ],
          previewBadge: 'Hyperlocal Discovery',
        },
        {
          step: '03',
          title: 'Purchase Request or Barter Offer',
          actor: 'Buyer or Villager',
          summary: 'Submit formal request specifying quantity, destination, and fulfillment method (pickup vs delivery).',
          details: [
            'Barter available strictly between Gram Sabhas and villagers; external buyers purchase only.',
            'Interactive balance meter checks if proposed barter exchange is fair.',
            'Mandatory reason required for bulk requests (≥25 units) to safeguard village sustainable harvesting.',
          ],
          previewBadge: 'Equitable Exchange',
        },
        {
          step: '04',
          title: 'Gram Sabha Reviews & Decides',
          actor: 'Gram Sabha Forest Committee',
          summary: 'Forest committee examines incoming requests, buyer intent reasons, and barter balance.',
          details: [
            'Three direct actions: Approve, Reject, or Counter-Offer with adjusted quantity/price.',
            'Counter-offers return to buyer for immediate accept or decline.',
            'Approving locks reserved inventory and immediately posts a delivery gig.',
          ],
          previewBadge: 'Community Stewardship',
        },
        {
          step: '05',
          title: 'Verified Village Driver Assigned',
          actor: 'Local Delivery Partner',
          summary: 'Nearby approved villagers with registered vehicles view the delivery job and claim it.',
          details: [
            'Only vetted drivers with valid transport credentials see pickup & drop contact numbers.',
            'Fixed or per-km remuneration (model to be finalized) paid on delivery.',
            'Gram Sabha confirms handover before vehicle departs village depot.',
          ],
          previewBadge: 'Rural Employment Generation',
        },
        {
          step: '06',
          title: 'Delivered, Rated & Impact Recorded',
          actor: 'Buyer & Network',
          summary: 'Buyer confirms safe receipt, rates the produce quality and delivery driver separately.',
          details: [
            'Earnings credited to Gram Sabha community fund and driver balance.',
            'Every rating is strictly tied to a confirmed order—zero fake reviews.',
            'Transaction metrics automatically update the public Impact Dashboard.',
          ],
          previewBadge: 'Closed Loop Accountability',
        },
      ],
    },
    portalsSection: {
      badge: 'Three Tailored Experiences',
      title: 'Exactly Three Login Portals',
      desc: 'All three portals share the same unified marketplace catalog. What changes is the home screen, navigation tabs, and permissions.',
      deliveryClarification: 'Delivery is not a 4th portal—it is an earning capability inside the Villager portal.',
      activeSpecBadge: 'Active Spec',
      bottomTabsLabel: 'Bottom Navigation Bar Tabs:',
      coreCapsLabel: 'Core Capabilities:',
      restrictionsLabel: 'Role Restrictions:',
      matrixTitle: 'Portal Permissions & Features Matrix',
      matrixDesc: 'Side-by-side comparison across the three user roles.',
      colFeature: 'Feature / Permission',
      colGramSabha: 'Gram Sabha',
      colVillager: 'Landowner / Villager',
      colBuyer: 'General Buyer',
      portalSpecs: [
        {
          title: 'Gram Sabha Portal',
          subtitle: 'Village Forest Councils Managing CFR',
          badge: 'The Seller & Steward',
          description: 'Built for elected Gram Sabha CFR committees to catalog locally conserved forest commodities, manage requests, and direct collective village revenue.',
          bottomTabs: ['Home (Dashboard)', 'My Listings', 'Requests', 'Orders', 'Profile'],
          keyFeatures: [
            'Add & edit listings with suggested fair-price guidance',
            'Set mode: Sell, Barter, or Both (+ barter wants)',
            'Approve, Reject, or Counter-Offer incoming buyer requests',
            'Join multi-village group listings to pool bulk commodities',
            '"Confirm handover" workflow when driver departs village depot',
            'Accounts verified by field team before listings go live',
          ],
          notAllowed: ['Cannot accept delivery gigs (only individual vehicle owners can)'],
        },
        {
          title: 'Landowner / Villager Portal',
          subtitle: 'Resident of CFR Village',
          badge: 'Community Member & Driver',
          description: 'Designed for local villagers to exchange scarce resources with other Gram Sabhas and earn independent income by providing vehicle delivery services.',
          bottomTabs: ['Home', 'Search', 'My Requests', 'Orders', 'Profile (+ More)'],
          keyFeatures: [
            'Search and compare listings by distance and price',
            'Request to purchase or offer bilateral Barter exchange',
            'Track orders step-by-step from approval to village delivery',
            'Confirm receipt and rate produce quality and delivery driver',
            '"Earn with delivery" card to register vehicles (truck/tempo/bike)',
            'Unlocks integrated "My Deliveries" job portal upon team verification',
          ],
          notAllowed: ['Cannot post listings without Gram Sabha executive authority'],
        },
        {
          title: 'General Buyer Portal',
          subtitle: 'Enterprises & Urban Consumers',
          badge: 'Commercial Buyer',
          description: 'Tailored for herbal brands, Ayurvedic pharmacies, and conscious processors seeking verified, ethically harvested forest raw materials.',
          bottomTabs: ['Home (Bulk First)', 'Search', 'My Requests', 'Orders', 'Profile'],
          keyFeatures: [
            'Bulk and combined group listings prioritized on home screen',
            'Can order from multi-producer group listings in a single transaction',
            'Full provenance transparency (forest compartment & harvest method)',
            'Mandatory sustainability reason for large bulk orders (≥25 units)',
            'Track orders and provide verified enterprise feedback',
          ],
          notAllowed: [
            'No Barter option (purchase strictly for currency)',
            'No Delivery option (delivery fulfilled by rural network or buyer pickup)',
          ],
        },
      ],
      comparisonRows: [
        { feature: 'Primary Goal', gs: 'Sell or barter village forest produce', vil: 'Procure goods or earn via transport', buy: 'Purchase bulk authentic raw material' },
        { feature: 'Can Post Listings', gs: true, vil: false, buy: false },
        { feature: 'Can Propose Barter', gs: true, vil: true, buy: false },
        { feature: 'Delivery Work Option', gs: false, vil: true, buy: false },
        { feature: 'Group Selling / Bulk First', gs: true, vil: false, buy: true },
        { feature: 'Mandatory Reason on Large Orders', gs: 'Reviews Reason', vil: 'Submits Reason (≥25 units)', buy: 'Submits Reason (≥25 units)' },
        { feature: 'Bottom Navigation Tabs', gs: '5 tabs (Listings focused)', vil: '5 tabs + Deliveries when active', buy: '5 tabs (Search & Bulk focused)' },
        { feature: 'Verification Requirement', gs: 'Team checks CFR title at signup', vil: 'Village Gram Sabha affiliation', buy: 'Basic business contact verification' },
      ],
    },
    barterSection: {
      badge: 'Fair Trade & Traditional Exchange',
      title: 'Barter Balance Meter & Fair-Price Guidance',
      desc: 'Different Gram Sabhas possess complementary natural wealth—one has medicinal plants, another has clean highland water. VanMitra enables balanced bilateral barter backed by transparent market reference valuation.',
      simulatorTitle: 'Interactive Barter Equity Simulator',
      liveTestBadge: 'Live Test',
      simulatorDesc: 'Adjust quantities on both sides to evaluate whether the proposed exchange is balanced.',
      simToggleLabel: 'Simulate New Resource:',
      sparseDataTitle: '"Not enough regional sales data yet" state:',
      sparseDataDesc: 'When a newly added forest resource is listed for the first time without historical sales volume, VanMitra indicates "Not enough data yet". Both Gram Sabhas negotiate mutually agreeable quantities directly without an enforced price benchmark.',
      partyATitle: 'Gram Sabha A (Offered Goods)',
      partyASub: 'Seller Origin',
      partyBTitle: 'Gram Sabha B (Requested Goods)',
      partyBSub: 'Counterparty',
      commodityLabel: 'Commodity:',
      qtyOfferedLabel: 'Quantity Offered:',
      qtyRequestedLabel: 'Quantity Requested:',
      totalBenchmarkVal: 'Total Benchmark Value:',
      exchangeRatioLabel: 'Exchange Ratio',
      equivalenceStatus: 'Equivalence Status:',
      balancedVerdict: 'Balanced Fair Exchange',
      favoursReceiverVerdict: 'Favourable to Counterparty',
      favoursSenderVerdict: 'Under-Offered Proposition',
      footnoteTitle: 'Constitutional Rule:',
      footnoteDesc: 'The suggested fair price is guidance only. Gram Sabhas always autonomously set their own price or barter terms. General buyers cannot participate in barter.',
    },
    groupSellingSection: {
      badge: 'Collaborative Supply',
      title: 'Group Selling: Pooled Harvest Simulator',
      desc: 'Single tribal hamlets often harvest modest seasonal volumes. VanMitra enables adjoining Gram Sabhas to pool their harvest into a single combined listing, unlocking bulk commercial contracts while guaranteeing individual village payouts.',
      contributingTitle: '3 Contributing Gram Sabhas',
      totalPoolLabel: 'Total Pool:',
      contributedPrefix: 'Contributed:',
      equalRuleNote: 'Each village manages its own harvest and receives payment strictly proportional to its contributed share.',
      pooledFunnelLabel: 'Pooled into 1 Listing',
      bulkBuyerPurchaseLabel: 'Bulk Buyer Purchase',
      simBuyerOrder: 'Simulate Buyer Order:',
      minLabel: 'Min: 10 kg',
      maxLabel: 'Max Pool: 100 kg',
      totalOrderVal: 'Total Order Value:',
      villagePayoutTitle: 'Transparent Village Payout Breakdown:',
    },
    deliverySection: {
      badge: 'Livelihood & Transport Generation',
      title: 'Delivery Partner Journey',
      desc: 'Moving resources between forest councils creates guaranteed paid transport work for villagers who own a pickup truck, tempo, or bike. Delivery is not a separate portal—it unlocks within the villager’s regular app.',
      journeySteps: [
        {
          step: '01',
          title: 'In-App Discovery',
          actor: 'Villager Portal',
          desc: 'Local villagers see the "Earn with delivery" card on their Home and More screens. Not a separate app—fully integrated.',
        },
        {
          step: '02',
          title: 'Explainer & Vehicle Sign-up',
          actor: 'Registration Form',
          desc: 'Driver submits vehicle type (pickup truck, tempo, motorcycle), plate number, payload capacity (kg), and driving license.',
        },
        {
          step: '03',
          title: 'Team Back-Office Verification',
          actor: 'VanMitra Field Team',
          desc: 'Credentials and vehicle fitness verified by local coordinators to protect village cargo and road safety.',
        },
        {
          step: '04',
          title: '"My Deliveries" Tab Unlocked',
          actor: 'Authorized Driver',
          desc: 'Approved drivers receive instant access to the active haul feed, route distances, guaranteed trip pay, and availability switch.',
        },
      ],
      unlockedBadge: 'Unlocked Inside Landowner / Villager App',
      dashTitle: 'Inside "My Deliveries" Dashboard',
      dashDesc: 'Once approved, a villager gains access to the live hauling queue. When an order is approved by a Gram Sabha seller, a delivery job is created automatically with calculated route remuneration.',
      totalEarningsLabel: 'Total Driver Earnings',
      completedHaulsLabel: 'completed village hauls',
      partnerRatingLabel: 'Partner Rating',
      ratedByLabel: 'Rated by Gram Sabhas & buyers',
      availabilityTitle: '"I am available for delivery work"',
      availabilitySub: 'Driver controls own schedule; jobs only show when active.',
      activeText: 'Active',
      offlineText: 'Offline',
      availableJobsTitle: 'Available Village Haul Jobs:',
      jobsOpenNearby: 'jobs open nearby',
      pickupLabel: 'Pickup:',
      dropLabel: 'Drop:',
      routeLabel: 'Route:',
      openJobBadge: 'Open Job',
      fairnessRules: [
        {
          title: 'Zero Exposure for Unverified Users',
          desc: 'Pickup points and buyer phone numbers remain strictly masked until a vetted driver taps "Accept job".',
        },
        {
          title: 'Driver Autonomy & Leave Anytime',
          desc: 'Villagers can toggle "I am available" off anytime or leave the delivery roster without affecting their normal villager account.',
        },
        {
          title: 'Performance & Fair Review',
          desc: 'Partners with low ratings are not automatically removed by an algorithm; they receive human team guidance before any pause.',
        },
      ],
    },
    impactSection: {
      badge: 'Community Metrics',
      title: 'Impact Dashboard',
      demoDataWarning: '★ Illustrative Data (Simulated for Evaluation & Pitch Presentations)',
      desc: 'Evidence for government innovation showcases, tribal development departments, and partner NGOs. Real production figures will replace these upon live state deployment.',
      filterAll: 'All Pilot Districts',
      filterDistrictSuffix: 'District',
      earningsCardTitle: 'Total Direct Earnings Paid',
      earningsCardSub: 'Paid to village Gram Sabha funds & producers',
      jobsCardTitle: 'Delivery Jobs Created',
      jobsCardSub: 'Paid trips for rural vehicle owners',
      familiesCardTitle: 'Tribal Families Benefited',
      familiesCardSub: 'Across recognized CFR area',
      trendTitle: 'Monthly Rural Revenue Trend (₹ in Thousands)',
      trendSub: 'Historical growth curve across pilot clusters',
      trendBadge: '+252% Q3 Growth',
      volumeTitle: 'Resource Category Volume Share',
      volumeSub: 'Breakdown of traded commodities',
      commissionNotice: '100% of revenue flows directly to Gram Sabha accounts or vehicle delivery partners. Zero middleman commission.',
    },
    trustSection: {
      badge: 'Ecological Integrity',
      title: 'Trust & Provenance Tag Explained',
      desc: 'Unlike commercial e-commerce, VanMitra is rooted in the Forest Rights Act. We build trust by verifying every forest council and protecting seasonal carrying capacity.',
      tagTitle: 'The CFR Provenance Tag',
      tagBadge: 'On Every Listing',
      tagIntro: 'Every card carries an immutable provenance signature giving buyers total confidence in biological authenticity:',
      tagPillars: [
        {
          title: 'Pre-Verified Gram Sabha Authority:',
          desc: 'Field coordinators cross-reference village CFR title orders with District Level Committees before listings are visible.',
        },
        {
          title: 'Forest Compartment & Micro-Habitat:',
          desc: 'Records the exact watershed ridge or sacred grove (Devrai) where wild honey or wild roots were gathered.',
        },
        {
          title: 'Non-Destructive Harvesting Pledge:',
          desc: 'Listing creation requires confirmation that comb nuclei are left intact, or tuber root tips are replanted for natural regeneration.',
        },
      ],
      largeOrderTitle: 'Large Order Reason Rule',
      largeOrderBadge: 'Threshold ≥ 25 Units',
      largeOrderIntro: 'Why VanMitra enforces a mandatory explanation box on large buyer quantities:',
      largeOrderRules: [
        {
          title: 'Prevents Depleting Seasonal Village Reserves:',
          desc: 'Wild forest produce is finite. A single bulk buyer cannot unilaterally clear out an entire village’s reserve.',
        },
        {
          title: 'Informed Gram Sabha Approval:',
          desc: 'The Gram Sabha committee reads the declared commercial intent before voting to approve, counter, or reject the order.',
        },
        {
          title: 'Flags Speculative Hoarding:',
          desc: 'Helps the platform spot unusual or predatory buying patterns from outside market speculators.',
        },
      ],
    },
    openDecisionsSection: {
      badge: 'Honest Product Architecture',
      title: 'Open Product Decisions',
      desc: 'Per the implementation specification, we do not invent arbitrary commission formulas, payment gateways, or policies. These 6 critical operational decisions remain explicitly documented for stakeholder alignment.',
      statusLabel: 'Status:',
      decisions: [
        {
          id: 'D-01',
          title: 'Payment Settlement Architecture',
          question: 'How is payment handled: online gateway, cash on delivery (COD), or centralized escrow settled by the VanMitra team?',
          demoPlaceholder: '"Payment method: to be confirmed"',
          impact: 'Tribal bank accounts have varying direct-debit infrastructure. Cash on delivery is common in weekly haats, but escrow protects bulk transactions.',
        },
        {
          id: 'D-02',
          title: 'Delivery Remuneration Formula',
          question: 'Is driver compensation fixed by kilometer distance (e.g. ₹12/km + base), or individually negotiated per trip?',
          demoPlaceholder: '"Delivery pay: shown per job (model to be confirmed)"',
          impact: 'Sahyadri ghat roads have steep elevation changes where distance alone does not reflect fuel expenditure or vehicle wear.',
        },
        {
          id: 'D-03',
          title: 'Delivery Option in Gram Sabha Portal',
          question: 'Should the delivery partner option appear strictly in the Villager portal, or also inside the Gram Sabha portal?',
          demoPlaceholder: 'Current architecture: Active in Villager portal only',
          impact: 'Gram Sabha represents the collective council, whereas vehicles are typically owned by individual villagers or self-help groups (SHGs).',
        },
        {
          id: 'D-04',
          title: 'Launch Language Scope',
          question: 'Are English, Hindi, and Marathi sufficient for launch, or should indigenous dialects (Gondi, Korku, Bhili) be supported from Day 1?',
          demoPlaceholder: 'Launch tier: EN / हिन्दी / मराठी live in prototype',
          impact: 'Many Katkari and Madia Gond elders communicate primarily in indigenous spoken dialects without written script familiarity.',
        },
        {
          id: 'D-05',
          title: 'Low-Network / Offline Sync Behavior',
          question: 'Should the mobile client function offline in zero-connectivity forest valleys and batch-sync orders when entering network range?',
          demoPlaceholder: 'Architecture ready for local IndexedDB / SQLite caching',
          impact: 'Forest collection often occurs deep in valleys where cellular signal drops completely for 4–8 hours.',
        },
        {
          id: 'D-06',
          title: 'New Resource Category Governance',
          question: 'Who is authorized to create new resource categories: the central admin team, or Gram Sabhas directly with post-facto review?',
          demoPlaceholder: 'Current version includes flexible "Others" category input',
          impact: 'Balancing standardized botanical taxonomy with vernacular tribal names for localized medicinal roots.',
        },
      ],
    },
    footer: {
      subtitle: 'Community Forest Resource Marketplace',
      summary: 'VanMitra-AI protects forest rights; VanMitra turns them into sustainable rural livelihoods. Empowering Gram Sabhas through transparent community commerce and local transport jobs.',
      compliance: 'Forest Rights Act (FRA 2006) Compliant',
      ecosystemTitle: 'VanMitra Ecosystem',
      backOfficeTitle: 'Internal Back-Office Notice',
      backOfficeText: 'The VanMitra Team Back-Office (used to verify Gram Sabha CFR title documents and review vehicle driver registrations) is strictly an internal administrative tool. It is not a public user login portal.',
      helplineLabel: 'Helpline:',
      helplineNumber: '1800-209-6060 (Toll Free)',
      replayIntro: 'Replay Intro',
      allRightsReserved: '© 2026 VanMitra · VanMitra-AI Ecosystem. All rights reserved.',
      fraLaw: 'Forest Rights Act 2006',
      privacyPolicy: 'Privacy Policy',
    },
    listingModal: {
      verifiedBadge: 'Verified CFR Community Forest Resource',
      verifiedReviews: 'verified reviews',
      sourceAreaLabel: 'Source Forest Area:',
      harvestMethodLabel: 'Harvesting Method:',
      sustainablePledge: 'Sustainably collected without root destruction or canopy depletion.',
      listedPriceLabel: 'Listed Price',
      inStoreStock: 'in village store',
      fairPriceGuideTitle: 'Suggested Fair Price Guide',
      fairPriceNotice: 'Derived from recent CFR transactions. Gram Sabha sets final price autonomously.',
      requestPurchaseTab: 'Request to Purchase',
      offerBarterTab: 'Offer Barter Exchange',
      barterDisabledNotice: 'Barter not available for external buyers',
      quantityDesiredLabel: 'Quantity Desired',
      sustainabilityTitle: 'Sustainability Requirement: Large Order',
      sustainabilityNotice: 'A large order can exhaust a village seasonal stock. The reason ensures harvest sustainability and protects CFR forest ecosystems.',
      reasonInputLabel: 'Reason for Request / Intended Usage',
      reasonPlaceholder: 'e.g. Raw material for scheduled herbal formulation or community reserve.',
      fulfillmentModeLabel: 'Fulfillment Mode',
      deliveryOptionTitle: 'Village Vehicle Delivery',
      deliveryOptionSub: 'Paid local driver',
      pickupOptionTitle: 'Self-Collect at Village',
      pickupOptionSub: 'Pickup from CFR depot',
      estimatedAmountLabel: 'Estimated Amount:',
      paymentDecisionNotice: 'Pay in the app: UPI or cash on delivery',
      grandTotalLabel: 'Total:',
      barterWantsLabel: 'Gram Sabha Wants:',
      exchangeResourceLabel: 'Resource You Offer in Exchange',
      exchangeQtyLabel: 'Offered Quantity (units)',
      equityMeterTitle: 'Barter Equity Meter',
      offeredValLabel: 'Offered Val:',
      targetValLabel: 'Target Val:',
      cancelBtn: 'Cancel',
      submitPurchaseBtn: 'Submit Purchase Request',
      submitBarterBtn: 'Submit Barter Proposal',
    },
  },
  hi: {
    tagline: 'वन संपदा का व्यापार। ग्रामीण आजीविका का विस्तार।',
    motto: 'सामुदायिक वन अधिकार (CFR) के अंतर्गत वन संसाधनों से ग्रामीण समृद्धि का सृजन।',
    ecosystemSynergy: 'वनमित्र-AI वन अधिकार सुरक्षित करता है; वनमित्र उन्हें ग्रामीण आय में बदलता है।',
    nav: {
      overview: 'अवलोकन',
      ecosystem: 'पारिस्थितिकी तंत्र',
      howItWorks: 'कार्य प्रणाली',
      portals: '३ मुख्य पोर्टल',
      marketplace: 'संसाधन बाज़ार',
      barter: 'विनिमय व उचित मूल्य',
      delivery: 'वितरण रोज़गार',
      impact: 'सामाजिक प्रभाव',
      explore: 'अन्वेषण',
      backToSite: 'मुख्य पृष्ठ पर लौटें',
      previousTab: 'पिछला टैब',
      nextTab: 'अगला टैब',
      activeWindow: 'समर्पित विंडो दृश्य',
      openTab: 'टैब खोलें',
      exploreSection: 'अनुभाग देखें',
      switchToDarkMode: 'डार्क मोड पर जाएं',
      switchToLightMode: 'लाइट मोड पर जाएं',
    },
    concepts: {
      communityCommerce: 'सामुदायिक व्यापार',
      sustainableLivelihoods: 'सतत आजीविका',
      employmentGeneration: 'रोज़गार सृजन',
    },
    categories: {
      all: 'सभी श्रेणियां',
      medicinal: 'औषधीय पौधे व जड़ी-बूटी',
      forest_produce: 'वनोपज (शहद, महुआ, लाख)',
      handicrafts: 'हस्तशिल्प व बांस उत्पाद',
      water_land: 'जल व भूमि संसाधन',
      others: 'अन्य प्राकृतिक संपदा',
    },
    portals: {
      gramSabha: {
        name: 'ग्राम सभा पोर्टल',
        desc: 'हम सीएफआर वन क्षेत्र का प्रबंधन करते हैं और स्थानीय वन संसाधनों का विक्रय या वस्तु-विनिमय करना चाहते हैं।',
        badge: 'विक्रेता व वन संरक्षक',
      },
      villager: {
        name: 'भूस्वामी / ग्रामीण पोर्टल',
        desc: 'मैं सीएफआर ग्राम में रहता हूँ, संसाधन खरीदना चाहता हूँ और वाहन चलाकर डिलीवरी से आय अर्जित कर सकता हूँ।',
        badge: 'ग्राम निवासी',
      },
      buyer: {
        name: 'सामान्य खरीदार पोर्टल',
        desc: 'मैं सीएफआर क्षेत्र से बाहर का व्यक्ति या आयुर्वेदिक संस्थान हूँ और प्रामाणिक कच्चा माल थोक में खरीदना चाहता हूँ।',
        badge: 'बाहरी खरीदार / संस्थान',
      },
    },
    modes: {
      sell: 'केवल विक्रय',
      barter: 'वस्तु-विनिमय',
      both: 'विक्रय व विनिमय',
    },
    common: {
      searchPlaceholder: 'जड़ी-बूटी, शुद्ध शहद, बांस शिल्प खोजें...',
      distance: 'दूरी',
      quantity: 'उपलब्ध मात्रा',
      price: 'मूल्य',
      suggestedFairPrice: 'सुझाया गया उचित मूल्य',
      verifiedGramSabha: 'सत्यापित ग्राम सभा',
      sustainableCollection: 'पारिस्थितिकीय रूप से सतत संकलन',
      requestToBuy: 'खरीद अनुरोध भेजें',
      offerBarter: 'वस्तु विनिमय प्रस्ताव दें',
      largeOrderReason: 'थोक मात्रा हेतु कारण (अनिवार्य)',
      largeOrderReasonHelp: 'बड़ा ऑर्डर गांव के मौसमी स्टॉक को समाप्त कर सकता है। कारण बताने से सतत कटाई सुरक्षित रहती है और अनधिकृत व्यापार रुकता है।',
      earnWithDelivery: 'वाहन है? संसाधन पहुंचाकर कमाई करें।',
      deliveryPartnerDesc: 'गांव के प्रमाणित डिलीवरी पार्टनर बनें और प्रत्येक यात्रा पर सम्मानजनक पारिश्रमिक पाएं।',
      startRegistration: 'वाहन पंजीकृत करें',
      viewDetails: 'विवरण देखें',
      close: 'बंद करें',
      confirm: 'पुष्टि करें',
      submit: 'अनुरोध प्रस्तुत करें',
      cancel: 'रद्द करें',
      status: 'स्थिति',
      openProductDecisions: 'खुले उत्पाद निर्णय',
    },
    hero: {
      badge: 'वनमित्र-AI पारिस्थितिकी तंत्र मॉड्यूल',
      cfrCommerce: '★ सीएफआर वन व्यापार',
      headlineBefore: 'जहां वन संपदा बनती है',
      headlineHighlight: 'ग्रामीण आजीविका।',
      headlineAfter: '',
      description: 'वनमित्र वन संरक्षक ग्राम सभाओं, जनजातीय उत्पादकों और नैतिक उद्यमों को एक पारदर्शी बाज़ार से जोड़ता है, साथ ही ग्रामीण वाहन चालकों के लिए सशुल्क परिवहन रोज़गार का निर्माण करता है।',
      howItWorks: 'कार्य प्रणाली देखें',
      statsActiveGs: 'सक्रिय सीएफआर ग्राम सभाएं',
      statsRuralEarnings: 'सीधी ग्रामीण आय',
      statsDeliveries: 'सफल डिलीवरी यात्राएं',
      driverEnRoute: 'ग्राम वाहन चालक मार्ग पर है',
      routeMeta: 'MH-48 · २२ किमी (~₹३७०)',
    },
    featuredProducts: {
      badge: 'प्रमाणित सामुदायिक वन संपदा',
      title: 'वन उत्पाद देखें',
      desc: 'सामुदायिक वन अधिकार (CFR) ग्राम सभाओं द्वारा सतत रूप से संकलित वनोपज, औषधीय जड़ी-बूटियां, हस्तशिल्प और प्राकृतिक संसाधन।',
      allProducts: 'सभी उत्पाद',
      viewDetails: 'विवरण देखें',
      exploreMarketplace: 'संपूर्ण बाज़ार देखें',
      showAll: 'सभी दिखाएं ({count})',
      showFewer: 'कम दिखाएं',
      showingCount: '{total} में से {count} उत्पाद प्रदर्शित',
      emptyTitle: 'इस श्रेणी में कोई उत्पाद उपलब्ध नहीं',
      emptyDesc: 'वर्तमान में इस श्रेणी फिल्टर से मेल खाने वाली कोई सूची मौजूद नहीं है।',
      resetFilter: 'सभी उत्पाद देखें',
      verified: 'एफआरए प्रमाणित',
      groupPooled: 'सामूहिक संकलन',
      availableStock: 'उपलब्ध स्टॉक:',
    },
    ecosystemSection: {
      badge: 'वनमित्र पारिस्थितिकी तंत्र वास्तुकला',
      title: 'वन अधिकार मान्यता से आर्थिक सशक्तिकरण की ओर',
      desc: 'वनमित्र-AI वन अधिकार अधिनियम (FRA 2006) के अंतर्गत सामुदायिक वन अधिकारों का डिजिटल मानचित्रण व संरक्षण करता है। वनमित्र वह आर्थिक मंच है जो इन कानूनी अधिकारों को प्रत्यक्ष ग्रामीण आय में परिवर्तित करता है।',
      parentTitle: 'वनमित्र-AI',
      parentBadge: 'शासन व वन अधिकार',
      parentDesc: 'वन अधिकार मान्यता के ५ प्रमुख स्तंभों का डिजिटल प्रबंधन:',
      parentModules: [
        {
          title: 'डैशबोर्ड (Dashboard)',
          desc: 'ग्राम सीएफआर दावों की स्थिति, बैठकों व आरक्षित वन क्षेत्र अभिलेखों का केंद्रीय नियंत्रण कक्ष।',
          status: 'सक्रिय शासन',
        },
        {
          title: 'दावे (Form B व C)',
          desc: 'सामुदायिक वन अधिकारों के लिए डिजिटल आवेदन एवं नियम १३ के साक्ष्य सत्यापन की सुविधा।',
          status: 'अधिकार मान्यता',
        },
        {
          title: 'ग्राम सभा अभिलेख',
          desc: 'कोरम उपस्थिति, आधिकारिक प्रस्ताव और सतत वनोपज संकलन कोटा का दस्तावेजीकरण।',
          status: 'सामुदायिक अधिकार',
        },
        {
          title: 'एटलस मानचित्र (Atlas Map)',
          desc: 'मान्यता प्राप्त सामुदायिक वन कंपार्टमेंट का जीआईएस भूकर सीमांकन।',
          status: 'भौगोलिक सत्यापन',
        },
        {
          title: 'प्रोफ़ाइल व सेटिंग्स',
          desc: 'ग्राम सभा पदाधिकारियों के परिचय पत्र, बहुभाषी विकल्प और सुरक्षित प्रमाणीकरण।',
          status: 'सत्यापित पहचान',
        },
      ],
      bridgeBadge: 'आजीविका सेतु',
      bridgeDesc: 'मान्यता प्राप्त वन क्षेत्रों से प्रमाणित प्राकृतिक संपदा का उत्पादन',
      moduleTitle: 'वनमित्र (VanMitra)',
      moduleBadge: 'बाज़ार व रोज़गार',
      moduleDesc: 'सामुदायिक वन अधिकारों के अनुरूप अनुकूलित अमेज़ॅन-शैली का क्रेता-विक्रेता मॉडल:',
      pillars: [
        {
          title: '१. प्रत्यक्ष सामुदायिक व्यापार',
          desc: 'ग्राम सभाएं जड़ी-बूटियों, शुद्ध शहद, बांस शिल्प व जल संसाधनों को उचित मूल्य मार्गदर्शन के साथ सूचीबद्ध करती हैं।',
        },
        {
          title: '२. उत्पत्ति प्रामाणिकता व संरक्षण',
          desc: 'केवल सत्यापित सीएफआर ग्राम सभाएं ही उत्पाद बेच सकती हैं; अति-दोहन रोकने हेतु बड़े खरीदारों को कारण बताना अनिवार्य है।',
        },
        {
          title: '३. स्थानीय वाहन परिवहन रोज़गार',
          desc: 'पिकअप, टेम्पो और बाइक वाले ग्रामीण सुरक्षित रूप से डिलीवरी करके प्रत्येक यात्रा पर निश्चित आय अर्जित करते हैं।',
        },
      ],
    },
    explorerSection: {
      badge: 'प्रत्यक्ष सामुदायिक बाज़ार',
      title: 'संसाधन अन्वेषक (Resource Explorer)',
      desc: 'वन-संरक्षक ग्राम सभाओं द्वारा उत्पादित प्रामाणिक वन संपदा खोजें, सत्यापित स्रोत टैग और निष्पक्ष बाज़ार मूल्य मार्गदर्शन के साथ।',
      sortBy: 'क्रमबद्ध करें:',
      sortNearest: 'निकटतम दूरी (किमी)',
      sortPriceAsc: 'न्यूनतम मूल्य पहले',
      sortRatingDesc: 'सर्वश्रेष्ठ रेटिंग (तारे)',
      modeLabel: 'प्रकार:',
      modeAll: 'सभी',
      modeBuy: 'खरीदें',
      modeBarter: 'विनिमय',
      clear: 'साफ़ करें',
      groupPooled: 'सामूहिक संकलन',
      fairRange: 'उचित दायरा:',
      offeredAt: 'उपलब्ध दर',
      noResultsTitle: 'आपके फ़िल्टर से कोई संसाधन मेल नहीं खाता',
      noResultsDesc: '"शहद", "अश्वगंधा", "बांस" खोजें अथवा सभी श्रेणियों का चयन करें।',
      resetFilters: 'फ़िल्टर पुनः सेट करें',
    },
    howItWorksSection: {
      badge: 'संपूर्ण कार्यप्रणाली',
      title: 'वनमित्र कैसे कार्य करता है',
      desc: 'प्रत्येक चरण वन संरक्षण, ग्राम सभा के स्वायत्त निर्णयों और स्थानीय वाहन चालकों के लिए न्यायसंगत आजीविका की गारंटी देता है।',
      stepPrefix: 'चरण',
      prevBtn: 'पिछला चरण',
      nextBtn: 'अगला चरण',
      liveStatusTitle: 'सक्रिय कार्यप्रवाह स्थिति',
      steps: [
        {
          step: '०१',
          title: 'ग्राम सभा संसाधन सूचीबद्ध करती है',
          actor: 'ग्राम सभा (विक्रेता)',
          summary: 'वन समितियां मौसमी उपज को छायाचित्रों, सतत कटाई स्रोत विवरण और मूल्य के साथ दर्ज करती हैं।',
          details: [
            'क्षेत्रीय सीएफआर सौदों के आधार पर परिकलित सुझाया गया निष्पक्ष मूल्य दायरा।',
            'माध्यम चुनें: नकद विक्रय, आवश्यक संसाधन हेतु वस्तु विनिमय, अथवा दोनों।',
            'सार्वजनिक होने से पूर्व क्षेत्रीय टीम द्वारा ग्राम सभा का कड़ाई से सत्यापन।',
          ],
          previewBadge: 'स्वायत्त मूल्य व प्रामाणिकता',
        },
        {
          step: '०२',
          title: 'दूरी व मूल्य के अनुसार खोज',
          actor: 'ग्रामीण अथवा खरीदार',
          summary: 'खरीदार निकटतम ग्राम सभाओं को किलोमीटर दूरी, उपलब्ध स्टॉक और सत्यापित रेटिंग के आधार पर खोजते हैं।',
          details: [
            'सहेजे गए ग्राम निर्देशांकों से सटीक दूरी का आकलन।',
            'एकल ग्राम उपज और बहु-ग्राम सामूहिक पूल सूची में स्पष्ट अंतर।',
            'पारिस्थितिकीय रूप से सतत संकलन की पुष्टि व वन कंपार्टमेंट विवरण।',
          ],
          previewBadge: 'अति-स्थानीय अन्वेषण',
        },
        {
          step: '०३',
          title: 'खरीद अनुरोध अथवा विनिमय प्रस्ताव',
          actor: 'क्रेता अथवा ग्रामीण',
          summary: 'मात्रा, गंतव्य और आपूर्ति विधि (स्वयं उठाव अथवा वाहन डिलीवरी) निर्दिष्ट करते हुए औपचारिक अनुरोध प्रस्तुत करें।',
          details: [
            'वस्तु-विनिमय केवल ग्राम सभाओं और ग्रामीणों के मध्य; बाहरी खरीदारों हेतु केवल नकद क्रय।',
            'डिजिटल बैलेंस मीटर जांचता है कि प्रस्तावित विनिमय दोनों पक्षों के लिए निष्पक्ष है या नहीं।',
            'थोक अनुरोधों (≥२५ इकाई) के लिए सतत संकलन सुनिश्चित करने हेतु कारण बताना अनिवार्य।',
          ],
          previewBadge: 'न्यायसंगत आदान-प्रदान',
        },
        {
          step: '०४',
          title: 'ग्राम सभा समीक्षा व निर्णय',
          actor: 'ग्राम सभा वन समिति',
          summary: 'वन समिति आने वाले अनुरोधों, खरीदार के घोषित कारण और विनिमय संतुलन की गहन समीक्षा करती है।',
          details: [
            'तीन प्रत्यक्ष विकल्प: स्वीकृत करें, अस्वीकार करें, अथवा मात्रा/मूल्य में संशोधन का जवाबी प्रस्ताव दें।',
            'जवाबी प्रस्ताव तुरंत खरीदार के पास स्वीकृति हेतु पहुंचता है।',
            'स्वीकृति मिलते ही स्टॉक आरक्षित हो जाता है और वाहन डिलीवरी कार्य पोस्ट हो जाता है।',
          ],
          previewBadge: 'सामुदायिक संरक्षण निर्णय',
        },
        {
          step: '०५',
          title: 'सत्यापित ग्रामीण चालक का चयन',
          actor: 'स्थानीय डिलीवरी पार्टनर',
          summary: 'निकटवर्ती अनुमोदित वाहन-स्वामी ग्रामीण इस डिलीवरी कार्य को देखते हैं और स्वीकार करते हैं।',
          details: [
            'केवल वैध परिवहन अनुज्ञापत्र वाले चालकों को ही संपर्क व गंतव्य विवरण दिखाई देता है।',
            'सुरक्षित पारिश्रमिक डिलीवरी पूर्ण होने पर सीधे चालक को देय होता है।',
            'ग्राम डिपो से वाहन प्रस्थान करने से पूर्व ग्राम सभा सुपुर्दगी की पुष्टि करती है।',
          ],
          previewBadge: 'ग्रामीण परिवहन रोज़गार',
        },
        {
          step: '०६',
          title: 'आपूर्ति, रेटिंग व प्रभाव दर्ज',
          actor: 'खरीदार व नेटवर्क',
          summary: 'खरीदार सुरक्षित प्राप्ति की पुष्टि करता है तथा उत्पाद की गुणवत्ता व डिलीवरी चालक को अलग-अलग रेटिंग देता है।',
          details: [
            'आय सीधे ग्राम सभा सामुदायिक कोष और चालक के खाते में जमा होती है।',
            'प्रत्येक समीक्षा वास्तविक पुष्टि-युक्त ऑर्डर से जुड़ी होती है—शून्य बनावटी समीक्षा।',
            'लेनदेन के आंकड़े स्वतः सार्वजनिक इम्पैक्ट डैशबोर्ड को अपडेट करते हैं।',
          ],
          previewBadge: 'पूर्ण जवाबदेही व पारदर्शिता',
        },
      ],
    },
    portalsSection: {
      badge: 'तीन विशिष्ट अनुभव',
      title: 'सटीक रूप से तीन लॉगिन पोर्टल',
      desc: 'तीनों पोर्टल एक ही एकीकृत बाज़ार डेटाबेस साझा करते हैं। जो बदलता है वह है मुख्य स्क्रीन, नेविगेशन टैब और उपयोगकर्ता अनुमतियां।',
      deliveryClarification: 'डिलीवरी कोई चौथा पोर्टल नहीं है—यह ग्रामीण पोर्टल के भीतर एक अंतर्निहित कमाई सुविधा है।',
      activeSpecBadge: 'सक्रिय विनिर्देश',
      bottomTabsLabel: 'निचले नेविगेशन बार के टैब:',
      coreCapsLabel: 'मुख्य क्षमताएं:',
      restrictionsLabel: 'भूमिका प्रतिबंध:',
      matrixTitle: 'पोर्टल अनुमतियां व तुलनात्मक मैट्रिक्स',
      matrixDesc: 'तीनों उपयोगकर्ता भूमिकाओं की सीधी तुलना।',
      colFeature: 'सुविधा / अनुमति',
      colGramSabha: 'ग्राम सभा',
      colVillager: 'भूस्वामी / ग्रामीण',
      colBuyer: 'सामान्य खरीदार',
      portalSpecs: [
        {
          title: 'ग्राम सभा पोर्टल',
          subtitle: 'सामुदायिक वन अधिकार (CFR) प्रबंधित करने वाली वन समितियां',
          badge: 'विक्रेता व वन संरक्षक',
          description: 'निर्वाचित ग्राम सभा सीएफआर समितियों के लिए निर्मित, ताकि वे स्थानीय रूप से संरक्षित वन उत्पादों को सूचीबद्ध कर सकें, अनुरोधों का प्रबंधन करें और गांव के सामूहिक विकास कोष का विस्तार करें।',
          bottomTabs: ['गृह (डैशबोर्ड)', 'मेरी सूचियां', 'अनुरोध', 'ऑर्डर्स', 'प्रोफ़ाइल'],
          keyFeatures: [
            'उचित मूल्य मार्गदर्शन के साथ उत्पाद जोड़ें व संपादित करें',
            'माध्यम तय करें: केवल विक्रय, वस्तु-विनिमय, अथवा दोनों (+ विनिमय आवश्यकताएं)',
            'आने वाले खरीदार अनुरोधों को स्वीकृत, अस्वीकृत अथवा जवाबी प्रस्ताव दें',
            'थोक सौदों के लिए बहु-ग्राम सामूहिक संकलन सूची में शामिल हों',
            'डिपो से वाहन प्रस्थान के समय "सुपुर्दगी पुष्टि" कार्यप्रवाह',
            'सूचीबद्ध करने से पूर्व क्षेत्रीय टीम द्वारा खाते का गहन सत्यापन',
          ],
          notAllowed: ['डिलीवरी कार्य स्वीकार नहीं कर सकते (केवल व्यक्तिगत वाहन स्वामी कर सकते हैं)'],
        },
        {
          title: 'भूस्वामी / ग्रामीण पोर्टल',
          subtitle: 'सीएफआर ग्राम का निवासी',
          badge: 'ग्राम सदस्य व चालक',
          description: 'स्थानीय ग्रामीणों के लिए तैयार किया गया ताकि वे अन्य ग्राम सभाओं से दुर्लभ संसाधनों का विनिमय कर सकें और अपने निजी वाहन से डिलीवरी करके स्वतंत्र आय प्राप्त कर सकें।',
          bottomTabs: ['गृह', 'खोजें', 'मेरे अनुरोध', 'ऑर्डर्स', 'प्रोफ़ाइल (+ अधिक)'],
          keyFeatures: [
            'दूरी और मूल्य के आधार पर सूचियों को खोजें व तुलना करें',
            'खरीद अनुरोध भेजें अथवा द्विपक्षीय वस्तु-विनिमय का प्रस्ताव दें',
            'ऑर्डर को स्वीकृति से लेकर ग्राम आपूर्ति तक कदम-दर-कदम ट्रैक करें',
            'प्राप्ति की पुष्टि करें एवं उपज गुणवत्ता व वाहन चालक को रेटिंग दें',
            'वाहन (पिकअप/टेम्पो/बाइक) पंजीकृत करने हेतु "डिलीवरी से कमाएं" कार्ड',
            'सत्यापन उपरांत एकीकृत "मेरी डिलीवरी" रोज़गार पोर्टल का स्वतः खुलना',
          ],
          notAllowed: ['ग्राम सभा के आधिकारिक अनुमोदन के बिना स्वतंत्र सूची पोस्ट नहीं कर सकते'],
        },
        {
          title: 'सामान्य खरीदार पोर्टल',
          subtitle: 'औषधीय संस्थान व शहरी उपभोक्ता',
          badge: 'व्यावसायिक खरीदार',
          description: 'आयुर्वेदिक फार्मेसियों, हर्बल ब्रांडों और जागरूक प्रसंस्करणकर्ताओं के लिए अनुकूलित जो प्रमाणित, नैतिक रूप से संकलित वन कच्चा माल थोक में चाहते हैं।',
          bottomTabs: ['गृह (थोक पहले)', 'खोजें', 'मेरे अनुरोध', 'ऑर्डर्स', 'प्रोफ़ाइल'],
          keyFeatures: [
            'मुख्य पृष्ठ पर थोक और सामूहिक संकलन सूचियों को प्राथमिकता',
            'एक ही ऑर्डर में कई उत्पादक गांवों से संयुक्त माल खरीदने की सुविधा',
            'संपूर्ण उत्पत्ति पारदर्शिता (वन कंपार्टमेंट व संकलन विधि)',
            'थोक ऑर्डरों (≥२५ इकाई) के लिए सतत उपयोग का कारण बताना अनिवार्य',
            'ऑर्डर ट्रैक करें और आधिकारिक संस्थागत समीक्षा प्रदान करें',
          ],
          notAllowed: [
            'वस्तु-विनिमय उपलब्ध नहीं (केवल मुद्रा द्वारा क्रय)',
            'डिलीवरी कार्य का विकल्प नहीं (परिवहन ग्रामीण नेटवर्क द्वारा अथवा स्वयं उठाव)',
          ],
        },
      ],
      comparisonRows: [
        { feature: 'प्राथमिक उद्देश्य', gs: 'वनोपज बेचना अथवा विनिमय करना', vil: 'माल प्राप्त करना या परिवहन से कमाना', buy: 'अस्सल थोक कच्चा माल खरीदना' },
        { feature: 'सूचीबद्ध करने का अधिकार', gs: true, vil: false, buy: false },
        { feature: 'वस्तु-विनिमय प्रस्ताव का अधिकार', gs: true, vil: true, buy: false },
        { feature: 'डिलीवरी रोज़गार का विकल्प', gs: false, vil: true, buy: false },
        { feature: 'सामूहिक संकलन / थोक प्राथमिकता', gs: true, vil: false, buy: true },
        { feature: 'बड़े ऑर्डर पर कारण की अनिवार्यता', gs: 'कारण की समीक्षा करता है', vil: 'कारण देता है (≥२५ इकाई)', buy: 'कारण देता है (≥२५ इकाई)' },
        { feature: 'निचले नेविगेशन बार के टैब', gs: '५ टैब (सूची केंद्रित)', vil: '५ टैब + सक्रिय होने पर डिलीवरी', buy: '५ टैब (थोक व खोज केंद्रित)' },
        { feature: 'सत्यापन की आवश्यकता', gs: 'पंजीकरण पर सीएफआर पट्टे की जांच', vil: 'ग्राम सभा से संबंद्धता की पुष्टि', buy: 'बुनियादी व्यावसायिक संपर्क सत्यापन' },
      ],
    },
    barterSection: {
      badge: 'न्यायसंगत व्यापार व पारंपरिक विनिमय',
      title: 'वस्तु-विनिमय संतुलन मीटर व निष्पक्ष मूल्य मार्गदर्शन',
      desc: 'विभिन्न ग्राम सभाओं के पास पूरक प्राकृतिक संपदा है—एक के पास जड़ी-बूटियां हैं, तो दूसरी के पास स्वच्छ पहाड़ी जल। वनमित्र पारदर्शी बाज़ार संदर्भ पर आधारित संतुलित विनिमय को संभव बनाता है।',
      simulatorTitle: 'इंटरैक्टिव वस्तु-विनिमय समानता सिम्युलेटर',
      liveTestBadge: 'सक्रिय परीक्षण',
      simulatorDesc: 'दोनों पक्षों की मात्रा को समायोजित करके परखें कि प्रस्तावित विनिमय संतुलित है या नहीं।',
      simToggleLabel: 'नए संसाधन का अनुकरण करें:',
      sparseDataTitle: '"क्षेत्रीय मूल्य का पर्याप्त डेटा उपलब्ध नहीं" स्थिति:',
      sparseDataDesc: 'जब कोई नया वन संसाधन बिना किसी पूर्व बिक्री इतिहास के पहली बार सूचीबद्ध होता है, तो वनमित्र "पर्याप्त डेटा उपलब्ध नहीं" दर्शाता है। दोनों ग्राम सभाएं बिना किसी अनिवार्य मूल्य दबाव के सीधे आपस में मात्रा तय करती हैं।',
      partyATitle: 'ग्राम सभा क (प्रस्तावित उत्पाद)',
      partyASub: 'विक्रेता ग्राम',
      partyBTitle: 'ग्राम सभा ख (मांगी गई वस्तु)',
      partyBSub: 'प्रतिपक्ष ग्राम',
      commodityLabel: 'वन संपदा:',
      qtyOfferedLabel: 'प्रस्तावित मात्रा:',
      qtyRequestedLabel: 'मांगी गई मात्रा:',
      totalBenchmarkVal: 'कुल मानक मूल्य:',
      exchangeRatioLabel: 'विनिमय अनुपात',
      equivalenceStatus: 'समानता स्थिति:',
      balancedVerdict: 'संतुलित न्यायसंगत विनिमय',
      favoursReceiverVerdict: 'प्रतिपक्ष के पक्ष में अनुकूल',
      favoursSenderVerdict: 'कम प्रस्तावित मात्रा',
      footnoteTitle: 'संवैधानिक नियम:',
      footnoteDesc: 'सुझाया गया मूल्य केवल मार्गदर्शन है। ग्राम सभाएं सदैव अपना मूल्य व विनिमय शर्तें तय करने के लिए पूर्णतः स्वतंत्र हैं। बाहरी खरीदार विनिमय नहीं कर सकते।',
    },
    groupSellingSection: {
      badge: 'सहकारी आपूर्ति',
      title: 'सामूहिक संकलन: साझा उपज सिम्युलेटर',
      desc: 'एकल जनजातीय पाड़ों में अक्सर सीमित मौसमी उपज होती है। वनमित्र पड़ोसी ग्राम सभाओं को अपनी उपज को एक ही संयुक्त सूची में जोड़ने की सुविधा देता है, जिससे थोक खरीदार मिलते हैं और हर गांव को उसका पूरा हिस्सा प्राप्त होता है।',
      contributingTitle: '३ भागीदार ग्राम सभाएं',
      totalPoolLabel: 'कुल सामूहिक पूल:',
      contributedPrefix: 'योगदान:',
      equalRuleNote: 'प्रत्येक गांव अपनी उपज का स्वयं प्रबंधन करता है और उसके योगदान अनुपात के अनुसार ही सीधे भुगतान पाता है।',
      pooledFunnelLabel: '१ संयुक्त सूची में एकत्रित',
      bulkBuyerPurchaseLabel: 'थोक खरीदार का ऑर्डर',
      simBuyerOrder: 'खरीदार ऑर्डर का अनुकरण:',
      minLabel: 'न्यूनतम: १० किग्रा',
      maxLabel: 'अधिकतम पूल: १०० किग्रा',
      totalOrderVal: 'कुल ऑर्डर मूल्य:',
      villagePayoutTitle: 'पारदर्शी ग्राम भुगतान विभाजन:',
    },
    deliverySection: {
      badge: 'आजीविका व स्थानीय परिवहन रोज़गार',
      title: 'डिलीवरी पार्टनर की यात्रा',
      desc: 'वन परिषदों के मध्य माल परिवहन पिकअप, टेम्पो अथवा मोटरसाइकिल रखने वाले ग्रामीणों के लिए सशुल्क कार्य उत्पन्न करता है। डिलीवरी कोई अलग ऐप नहीं है—यह ग्रामीण के सामान्य खाते में ही खुलती है।',
      journeySteps: [
        {
          step: '०१',
          title: 'ऐप के भीतर खोज',
          actor: 'ग्रामीण पोर्टल',
          desc: 'स्थानीय ग्रामीणों को अपनी होम स्क्रीन पर "डिलीवरी से कमाएं" कार्ड दिखाई देता है। कोई अलग ऐप नहीं—पूर्णतः एकीकृत।',
        },
        {
          step: '०२',
          title: 'जानकारी व वाहन पंजीकरण',
          actor: 'पंजीकरण प्रपत्र',
          desc: 'चालक वाहन का प्रकार (पिकअप, टेम्पो, बाइक), नंबर, माल वहन क्षमता (किग्रा) और ड्राइविंग लाइसेंस दर्ज करता है।',
        },
        {
          step: '०३',
          title: 'क्षेत्रीय टीम द्वारा सत्यापन',
          actor: 'वनमित्र क्षेत्रीय दल',
          desc: 'गांव के माल और सड़क सुरक्षा को सुनिश्चित करने के लिए स्थानीय समन्वयकों द्वारा दस्तावेजों का भौतिक सत्यापन।',
        },
        {
          step: '०४',
          title: '"मेरी डिलीवरी" टैब का अनावरण',
          actor: 'अधिकृत चालक',
          desc: 'स्वीकृत चालकों को सक्रिय कार्यों की सूची, यात्रा की दूरी, निश्चित पारिश्रमिक और उपलब्धता स्विच की सुविधा मिलती है।',
        },
      ],
      unlockedBadge: 'भूस्वामी / ग्रामीण ऐप के भीतर उपलब्ध',
      dashTitle: '"मेरी डिलीवरी" डैशबोर्ड के भीतर',
      dashDesc: 'स्वीकृति के उपरांत, ग्रामीण को सक्रिय परिवहन कार्यों की सूची मिलती है। जैसे ही ग्राम सभा किसी ऑर्डर को मंज़ूरी देती है, स्वचालित रूप से निश्चित दर पर डिलीवरी जॉब बन जाती है।',
      totalEarningsLabel: 'चालक की कुल संचित कमाई',
      completedHaulsLabel: 'सफल पूर्ण परिवहन यात्राएं',
      partnerRatingLabel: 'पार्टनर रेटिंग',
      ratedByLabel: 'ग्राम सभाओं व खरीदारों द्वारा मूल्यांकित',
      availabilityTitle: '"मैं डिलीवरी कार्य के लिए उपलब्ध हूँ"',
      availabilitySub: 'चालक अपनी सुविधानुसार समय तय करता है; चालू होने पर ही काम दिखता है।',
      activeText: 'सक्रिय',
      offlineText: 'ऑफ़लाइन',
      availableJobsTitle: 'उपलब्ध ग्रामीण परिवहन कार्य:',
      jobsOpenNearby: 'कार्य निकट उपलब्ध हैं',
      pickupLabel: 'उठाव:',
      dropLabel: 'गंतव्य:',
      routeLabel: 'मार्ग:',
      openJobBadge: 'खुला कार्य',
      fairnessRules: [
        {
          title: 'अपुष्ट उपयोगकर्ताओं से पूर्ण सुरक्षा',
          desc: 'जब तक कोई अधिकृत चालक "स्वीकार करें" पर क्लिक नहीं करता, तब तक फोन नंबर और सटीक पता गुप्त रहता है।',
        },
        {
          title: 'चालक की स्वतंत्रता व कभी भी अवकाश',
          desc: 'ग्रामीण कभी भी अपनी उपलब्धता बंद कर सकते हैं या सेवा छोड़ सकते हैं, इससे उनका सामान्य खाता प्रभावित नहीं होता।',
        },
        {
          title: 'मानवीय समीक्षा व निष्पक्ष व्यवहार',
          desc: 'कम रेटिंग वाले पार्टनरों को किसी अल्गोरिदम द्वारा हटाया नहीं जाता; उन्हें मानवीय दल द्वारा मार्गदर्शन दिया जाता है।',
        },
      ],
    },
    impactSection: {
      badge: 'सामुदायिक प्रभाव संकेतक',
      title: 'सामाजिक प्रभाव डैशबोर्ड',
      demoDataWarning: '★ सांकेतिक डेटा (प्रस्तुति व मूल्यांकन हेतु अनुकरण)',
      desc: 'सरकारी नवाचार सम्मेलनों, जनजातीय विकास विभागों और सहयोगी स्वयंसेवी संस्थाओं के लिए वास्तविक प्रमाण। राज्य स्तर पर लागू होने पर यहां वास्तविक आंकड़े दिखाई देंगे।',
      filterAll: 'सभी पायलट जिले',
      filterDistrictSuffix: 'जिला',
      earningsCardTitle: 'कुल प्रत्यक्ष भुगतान की गई आय',
      earningsCardSub: 'ग्राम सभा सामुदायिक कोष व उत्पादकों को सीधे प्रेषित',
      jobsCardTitle: 'सृजित डिलीवरी कार्य',
      jobsCardSub: 'ग्रामीण वाहन स्वामियों के लिए सशुल्क यात्राएं',
      familiesCardTitle: 'लाभान्वित जनजातीय परिवार',
      familiesCardSub: 'मान्यता प्राप्त सीएफआर वन क्षेत्र में',
      trendTitle: 'मासिक ग्रामीण आय रुझान (हज़ार ₹ में)',
      trendSub: 'पायलट क्लस्टरों में दर्ज विकास की ऐतिहासिक वक्र रेखा',
      trendBadge: '+२५२% तिमाही वृद्धि',
      volumeTitle: 'संसाधन श्रेणी अनुसार व्यापार हिस्सा',
      volumeSub: 'व्यापार किए गए वन उत्पादों का विभाजन',
      commissionNotice: '१००% आय सीधे ग्राम सभा खातों या वाहन चालकों को मिलती है। बिचौलियों का शून्य कमीशन।',
    },
    trustSection: {
      badge: 'पारिस्थितिकीय सत्यनिष्ठा',
      title: 'उत्पत्ति व विश्वास टैग का महत्व',
      desc: 'व्यावसायिक ई-कॉमर्स के विपरीत, वनमित्र वन अधिकार कानून पर आधारित है। हम प्रत्येक ग्राम सभा को सत्यापित करके और मौसमी सीमा का सम्मान करके विश्वास का निर्माण करते हैं।',
      tagTitle: 'सीएफआर उत्पत्ति प्रामाणिकता टैग',
      tagBadge: 'प्रत्येक उत्पाद पर',
      tagIntro: 'प्रत्येक उत्पाद कार्ड पर एक अपरिवर्तनीय डिजिटल हस्ताक्षर होता है जो खरीदार को जैविक शुद्धता का पूर्ण विश्वास दिलाता है:',
      tagPillars: [
        {
          title: 'पूर्व-सत्यापित ग्राम सभा प्राधिकार:',
          desc: 'सूचीबद्ध करने से पूर्व क्षेत्रीय समन्वयक जिला स्तरीय समिति (DLC) के आदेश से गांव के पट्टे का मिलान करते हैं।',
        },
        {
          title: 'वन कंपार्टमेंट व सूक्ष्म-पर्यावास:',
          desc: 'सटीक जलसंभर क्षेत्र अथवा देवराई (पवित्र उपवन) का दस्तावेजीकरण जहां से शुद्ध शहद या औषधीय जड़ें एकत्र की गईं।',
        },
        {
          title: 'अविनाशी संकलन की शपथ:',
          desc: 'सूची बनाने के लिए यह पुष्टि अनिवार्य है कि मधुमक्खी के छत्ते का केंद्र सुरक्षित रखा गया है और कंद की जड़ों को पुनः रोपा गया है।',
        },
      ],
      largeOrderTitle: 'थोक ऑर्डर पर कारण बताने का नियम',
      largeOrderBadge: 'सीमा ≥ २५ इकाई',
      largeOrderIntro: 'वनमित्र बड़ी मात्रा के खरीदारों से कारण पूछने पर बल क्यों देता है:',
      largeOrderRules: [
        {
          title: 'गांव के मौसमी संचय को समाप्त होने से बचाना:',
          desc: 'जंगल की प्राकृतिक उपज सीमित होती है। कोई एक बाहरी खरीदार पूरे गांव का कोटा अकेले समाप्त नहीं कर सकता।',
        },
        {
          title: 'ग्राम सभा का विचारपूर्वक निर्णय:',
          desc: 'ग्राम सभा समिति ऑर्डर को मंज़ूरी, जवाबी प्रस्ताव या अस्वीकार करने से पहले खरीदार का वास्तविक उद्देश्य पढ़ती है।',
        },
        {
          title: 'सट्टेबाज़ी व कालाबाज़ारी पर रोक:',
          desc: 'मंच को बाहरी सट्टेबाजों द्वारा असामान्य या हानिकारक संचय के प्रयासों की समय रहते पहचान करने में मदद मिलती है।',
        },
      ],
    },
    openDecisionsSection: {
      badge: 'पारदर्शी उत्पाद वास्तुकला',
      title: 'खुले उत्पाद निर्णय',
      desc: 'परियोजना विनिर्देश के अनुसार, हम बिना सरकारी सहमति के कोई काल्पनिक कमीशन नियम, भुगतान गेटवे या नीतियां लागू नहीं करते। ये ६ प्रमुख परिचालन निर्णय हितधारकों के विचार-विमर्श हेतु खुले रूप से प्रलेखित हैं।',
      statusLabel: 'स्थिति:',
      decisions: [
        {
          id: 'निर्णय-०१',
          title: 'भुगतान निपटान वास्तुकला',
          question: 'भुगतान कैसे होगा: ऑनलाइन गेटवे, कैश ऑन डिलीवरी (COD), अथवा वनमित्र टीम द्वारा प्रबंधित केंद्रीय एस्क्रो?',
          demoPlaceholder: '"भुगतान विधि: शीघ्र अंतिम रूप दिया जाएगा"',
          impact: 'जनजातीय बैंक खातों में ऑटो-डेबिट की अलग-अलग सीमाएं हैं। ग्रामीण हाटों में नकद प्रचलित है, किंतु बड़े सौदों में एस्क्रो सुरक्षित रहता है।',
        },
        {
          id: 'निर्णय-०२',
          title: 'डिलीवरी पारिश्रमिक सूत्र',
          question: 'क्या चालक का मेहनताना किलोमीटर अनुसार तय हो (उदा. ₹१२/किमी + आधार दर), या प्रत्येक यात्रा पर आपसी सहमति से?',
          demoPlaceholder: '"प्रति कार्य पारिश्रमिक प्रदर्शित (मॉडल अंतिम रूप देना बाकी)"',
          impact: 'सह्याद्री के दुर्गम घाट मार्गों पर दूरी के अलावा ढलान के कारण ईंधन व वाहन घिसाव अधिक होता है।',
        },
        {
          id: 'निर्णय-०३',
          title: 'ग्राम सभा पोर्टल में डिलीवरी विकल्प',
          question: 'क्या डिलीवरी कार्य का विकल्प केवल ग्रामीण पोर्टल में रहे, अथवा ग्राम सभा पोर्टल में भी दिखाई दे?',
          demoPlaceholder: 'वर्तमान वास्तुकला: केवल भूस्वामी/ग्रामीण पोर्टल में सक्रिय',
          impact: 'ग्राम सभा सामूहिक परिषद का प्रतिनिधित्व करती है, जबकि वाहन आमतौर पर व्यक्तिगत ग्रामीणों या महिला स्वयं सहायता समूहों (SHGs) के होते हैं।',
        },
        {
          id: 'निर्णय-०४',
          title: 'प्रारंभिक भाषाओं का दायरा',
          question: 'क्या अंग्रेजी, हिन्दी और मराठी पर्याप्त हैं, अथवा प्रथम दिवस से ही गोंडी, कोरकू, भीली जैसी जनजातीय बोलियों को शामिल किया जाए?',
          demoPlaceholder: 'प्रारंभिक चरण: अंग्रेज़ी / हिन्दी / मराठी प्रोटोटाइप में लाइव',
          impact: 'कातकरी और माडिया गोंड बुजुर्ग मुख्य रूप से अपनी बोली में मौखिक संवाद करते हैं और देवनागरी लिपि से कम परिचित हो सकते हैं।',
        },
        {
          id: 'निर्णय-०५',
          title: 'निम्न-नेटवर्क / ऑफ़लाइन सिंक व्यवहार',
          question: 'क्या शून्य-नेटवर्क वाले गहरे वन क्षेत्रों में मोबाइल ऐप ऑफ़लाइन कार्य करे और नेटवर्क में आने पर ऑर्डर सिंक करे?',
          demoPlaceholder: 'वास्तुकला स्थानीय IndexedDB / SQLite कैशिंग हेतु तैयार',
          impact: 'वनोपज संकलन प्रायः गहरी घाटियों में होता है जहां ४-८ घंटे मोबाइल नेटवर्क बिल्कुल उपलब्ध नहीं होता।',
        },
        {
          id: 'निर्णय-०६',
          title: 'नई संसाधन श्रेणी का अधिकार',
          question: 'नई उत्पाद श्रेणी जोड़ने का अधिकार किसके पास हो: केंद्रीय व्यवस्थापक दल, अथवा ग्राम सभाएं सीधे जोड़ सकती हैं?',
          demoPlaceholder: 'वर्तमान संस्करण में लचीला "अन्य" श्रेणी विकल्प उपलब्ध',
          impact: 'मानक वानस्पतिक वर्गीकरण और दुर्लभ स्थानीय औषधीय जड़ों के पारंपरिक जनजातीय नामों में सामंजस्य स्थापित करना।',
        },
      ],
    },
    footer: {
      subtitle: 'सामुदायिक वन संसाधन बाज़ार',
      summary: 'वनमित्र-AI वन अधिकारों की रक्षा करता है; वनमित्र उन्हें सतत ग्रामीण समृद्धि में बदलता है। पारदर्शी व्यापार और स्थानीय परिवहन रोज़गार के माध्यम से ग्राम सभाओं का सशक्तिकरण।',
      compliance: 'वन अधिकार अधिनियम (FRA 2006) के अनुरूप',
      ecosystemTitle: 'वनमित्र पारिस्थिकी तंत्र',
      backOfficeTitle: 'आंतरिक बैक-ऑफिस सूचना',
      backOfficeText: 'वनमित्र बैक-ऑफिस (जिसका उपयोग ग्राम सभा सीएफआर पट्टा दस्तावेजों के सत्यापन और वाहन चालकों के पंजीकरण की जांच हेतु होता है) विशुद्ध रूप से एक आंतरिक प्रशासनिक साधन है। यह कोई सार्वजनिक उपयोगकर्ता पोर्टल नहीं है।',
      helplineLabel: 'हेल्पलाइन:',
      helplineNumber: '१८००-२०९-६०६० (टोल-फ्री)',
      replayIntro: 'प्रस्तावना पुनः देखें',
      allRightsReserved: '© २०२६ वनमित्र · वनमित्र-AI पारिस्थितिकी तंत्र। सर्वाधिकार सुरक्षित।',
      fraLaw: 'वन अधिकार अधिनियम २००६',
      privacyPolicy: 'गोपनीयता नीति',
    },
    listingModal: {
      verifiedBadge: 'सत्यापित सीएफआर सामुदायिक वन संसाधन',
      verifiedReviews: 'सत्यापित समीक्षाएं',
      sourceAreaLabel: 'स्रोत वन क्षेत्र:',
      harvestMethodLabel: 'संकलन विधि:',
      sustainablePledge: 'जड़ों को नष्ट किए बिना और वन छत्र को नुकसान पहुंचाए बिना सतत रूप से संकलित।',
      listedPriceLabel: 'सूचीबद्ध दर',
      inStoreStock: 'ग्राम डिपो में उपलब्ध',
      fairPriceGuideTitle: 'सुझाया गया निष्पक्ष मूल्य मार्गदर्शन',
      fairPriceNotice: 'हाल के सीएफआर लेन-देन से परिकलित। ग्राम सभा अपना अंतिम मूल्य स्वायत्तता से तय करती है।',
      requestPurchaseTab: 'खरीद का अनुरोध करें',
      offerBarterTab: 'वस्तु विनिमय प्रस्ताव दें',
      barterDisabledNotice: 'बाहरी खरीदारों के लिए वस्तु विनिमय उपलब्ध नहीं',
      quantityDesiredLabel: 'वांछित मात्रा',
      sustainabilityTitle: 'सतत संकलन आवश्यकता: बड़ा ऑर्डर',
      sustainabilityNotice: 'बड़ा ऑर्डर गांव के मौसमी स्टॉक को समाप्त कर सकता है। कारण बताने से सतत कटाई सुरक्षित रहती है।',
      reasonInputLabel: 'अनुरोध का कारण / व्यावसायिक उपयोग',
      reasonPlaceholder: 'उदा. हर्बल दवा निर्माण अथवा सामुदायिक आरक्षित स्टॉक।',
      fulfillmentModeLabel: 'आपूर्ति का माध्यम',
      deliveryOptionTitle: 'ग्रामीण वाहन द्वारा डिलीवरी',
      deliveryOptionSub: 'सशुल्क स्थानीय चालक',
      pickupOptionTitle: 'गांव से स्वयं उठाव',
      pickupOptionSub: 'ग्राम सीएफआर डिपो से प्राप्त करें',
      estimatedAmountLabel: 'अनुमानित मूल्य:',
      paymentDecisionNotice: 'ऐप में भुगतान: यूपीआई या डिलीवरी पर नकद',
      grandTotalLabel: 'कुल योग:',
      barterWantsLabel: 'ग्राम सभा की आवश्यकता:',
      exchangeResourceLabel: 'विनिमय में आपकी प्रस्तावित वस्तु',
      exchangeQtyLabel: 'प्रस्तावित मात्रा (इकाई)',
      equityMeterTitle: 'वस्तु विनिमय संतुलन मीटर',
      offeredValLabel: 'प्रस्तावित मूल्य:',
      targetValLabel: 'वांछित मूल्य:',
      cancelBtn: 'रद्द करें',
      submitPurchaseBtn: 'खरीद अनुरोध भेजें',
      submitBarterBtn: 'विनिमय प्रस्ताव भेजें',
    },
  },
  mr: {
    tagline: 'वनसंपत्तीचा व्यापार। ग्रामीण उपजीविकेचा विस्तार।',
    motto: 'सामुदायिक वन हक्क (CFR) अंतर्गत वन संसाधनांचे रूपांतर शाश्वत ग्रामीण उत्पन्नात.',
    ecosystemSynergy: 'वनमित्र-AI वन हक्कांचे रक्षण करते; वनमित्र त्यांचे रूपांतर ग्रामीण उत्पन्नात करते.',
    nav: {
      overview: 'अवलोकन',
      ecosystem: 'परिसंस्था',
      howItWorks: 'कार्यपद्धती',
      portals: '३ मुख्य पोर्टल्स',
      marketplace: 'संसाधन बाजार',
      barter: 'विनिमय व योग्य दर',
      delivery: 'वितरण रोजगार',
      impact: 'सामाजिक प्रभाव',
      explore: 'अधिक विभाग',
      backToSite: 'माहिती पृष्ठावर जा',
      previousTab: 'मागील टॅब',
      nextTab: 'पुढील टॅब',
      activeWindow: 'विभागाचे स्वतंत्र दृश्य',
      openTab: 'टॅब उघडा',
      exploreSection: 'विभाग पहा',
      switchToDarkMode: 'डार्क मोडवर जा',
      switchToLightMode: 'लाइट मोडवर जा',
    },
    concepts: {
      communityCommerce: 'सामुदायिक व्यापार',
      sustainableLivelihoods: 'शाश्वत उपजीविका',
      employmentGeneration: 'स्थानिक रोजगार निर्मिती',
    },
    categories: {
      all: 'सर्व प्रकार',
      medicinal: 'औषधी वनस्पती व जडीबुटी',
      forest_produce: 'गौण वनोपज (मध, मोह, लाख)',
      handicrafts: 'हस्तकला व बांबू कलाकृती',
      water_land: 'जल व जमीन संसाधने',
      others: 'इतर नैसर्गिक संपत्ती',
    },
    portals: {
      gramSabha: {
        name: 'ग्रामसभा पोर्टल',
        desc: 'आम्ही सीएफआर वनक्षेत्राचे व्यवस्थापन करतो आणि नैसर्गिक वन संसाधनांची विक्री किंवा देवाणघेवाण करू इच्छितो.',
        badge: 'विक्रेता व वन संरक्षक',
      },
      villager: {
        name: 'जमीनधारक / ग्रामस्थ पोर्टल',
        desc: 'मी सीएफआर गावात राहतो, मला इतर गावांमधून संसाधने हवी आहेत किंवा वाहनाद्वारे वाहतूक करून रोजगार मिळवायचा आहे.',
        badge: 'ग्रामस्थ सदस्य',
      },
      buyer: {
        name: 'सर्वसाधारण खरेदीदार पोर्टल',
        desc: 'मी सीएफआर गावाबाहेरील व्यापारी किंवा आयुर्वेदिक कंपनी असून थेट जंगलातील अस्सल कच्चा माल घाऊक खरेदी करू इच्छितो.',
        badge: 'संस्थात्मक खरेदीदार',
      },
    },
    modes: {
      sell: 'फक्त विक्री',
      barter: 'वस्तुविनिमय',
      both: 'विक्री व विनिमय दोन्ही',
    },
    common: {
      searchPlaceholder: 'जडीबुटी, शुद्ध मध, बांबूच्या वस्तू शोधा...',
      distance: 'अंतर',
      quantity: 'उपलब्ध साठा',
      price: 'दर',
      suggestedFairPrice: 'सुचवलेला योग्य बाजारभाव',
      verifiedGramSabha: 'पडताळणीकृत ग्रामसभा',
      sustainableCollection: 'शाश्वत पद्धतीने गोळा केलेले',
      requestToBuy: 'खरेदीची विनंती करा',
      offerBarter: 'वस्तुविनिमयाची ऑफर द्या',
      largeOrderReason: 'मोठ्या खरेदीचे कारण (आवश्यक)',
      largeOrderReasonHelp: 'मोठ्या मागणीमुळे गावातील हंगामी साठा संपू नये व नैसर्गिक वनाचे नुकसान होऊ नये यासाठी कारणाची नोंद अनिवार्य आहे.',
      earnWithDelivery: 'वाहन आहे का? माल पोहोचवून पैसे कमवा.',
      deliveryPartnerDesc: 'गावातील अधिकृत डिलिव्हरी पार्टनर व्हा आणि प्रत्येक फेरीवर योग्य मोबदला मिळवा.',
      startRegistration: 'वाहन नोंदणी करा',
      viewDetails: 'सविस्तर माहिती',
      close: 'बंद करा',
      confirm: 'खात्री करा',
      submit: 'विनंती पाठवा',
      cancel: 'रद्द करा',
      status: 'स्थिती',
      openProductDecisions: 'अंतिम निर्णयाधीन मुद्दे',
    },
    hero: {
      badge: 'वनमित्र-AI परिसंस्था विभाग',
      cfrCommerce: '★ सीएफआर वन व्यापार',
      headlineBefore: 'जिथे नैसर्गिक वनसंपत्ती बनते',
      headlineHighlight: 'शाश्वत ग्रामीण रोजगार।',
      headlineAfter: '',
      description: 'वनमित्र वनसंरक्षक ग्रामसभा, आदिवासी उत्पादक आणि व्यावसायिक खरेदीदारांना एका पारदर्शक व्यासपीठावर आणते, तसेच स्थानिक वाहनधारकांसाठी सशुल्क वाहतूक रोजगार निर्माण करते.',
      howItWorks: 'कार्यपद्धती पहा',
      statsActiveGs: 'सक्रिय सीएफआर ग्रामसभा',
      statsRuralEarnings: 'थेट ग्रामीण उत्पन्न',
      statsDeliveries: 'यशस्वी वाहतूक फेऱ्या',
      driverEnRoute: 'ग्रामस्थ वाहन चालक प्रवासात आहे',
      routeMeta: 'MH-48 · २२ किमी (~₹३७०)',
    },
    featuredProducts: {
      badge: 'प्रमाणित सामुदायिक वन उत्पादने',
      title: 'वन उत्पादने पहा',
      desc: 'सामुदायिक वन हक्क (CFR) ग्रामसभांद्वारे शाश्वत पद्धतीने संकलित केलेली वनोपज, औषधी वनस्पती, हस्तकला आणि नैसर्गिक संसाधने.',
      allProducts: 'सर्व उत्पादने',
      viewDetails: 'तपशील पहा',
      exploreMarketplace: 'संपूर्ण बाजारपेठ पहा',
      showAll: 'सर्व पहा ({count})',
      showFewer: 'कमी पहा',
      showingCount: '{total} पैकी {count} उत्पादने',
      emptyTitle: 'या श्रेणीत कोणतीही उत्पादने नाहीत',
      emptyDesc: 'सध्या या श्रेणी फिल्टरशी जुळणारे कोणतेही उत्पादन उपलब्ध नाही.',
      resetFilter: 'सर्व उत्पादने पहा',
      verified: 'एफआरए प्रमाणित',
      groupPooled: 'सामूहिक संकलन',
      availableStock: 'उपलब्ध साठा:',
    },
    ecosystemSection: {
      badge: 'वनमित्र परिसंस्था रचना',
      title: 'वन हक्क मान्यतेतून आर्थिक सक्षमीकरण',
      desc: 'वनमित्र-AI वन हक्क कायद्यांतर्गत (FRA 2006) अधिकारांचे डिजिटल नकाशे व संरक्षण करते. वनमित्र हे त्या अधिकारांचे रूपांतर शाश्वत ग्रामीण उत्पन्नात करणारे अधिकृत व्यासपीठ आहे.',
      parentTitle: 'वनमित्र-AI (VanMitra-AI)',
      parentBadge: 'शासन व वन हक्क',
      parentDesc: 'वन हक्क मान्यतेच्या ५ प्रमुख स्तंभांचे डिजिटल व्यवस्थापन:',
      parentModules: [
        {
          title: 'डॅशबोर्ड',
          desc: 'गावाच्या सीएफआर दाव्यांची सद्यस्थिती, बैठका आणि वनक्षेत्र नोंदींचे नियंत्रण केंद्र.',
          status: 'सक्रिय शासन',
        },
        {
          title: 'दावे (फॉर्म B व C)',
          desc: 'सामुदायिक वन हक्कांचे डिजिटल अर्ज व नियम १३ पुरावे पडताळणी.',
          status: 'हक्क मान्यता',
        },
        {
          title: 'ग्रामसभा नोंदी',
          desc: 'कोरम उपस्थिती, अधिकृत ठराव आणि शाश्वत संकलन कोट्याची नोंद.',
          status: 'सामुदायिक अधिकार',
        },
        {
          title: 'ॲटलस नकाशा',
          desc: 'मान्यताप्राप्त वन कंपार्टमेंटचे डिजिटल जीआयएस सीमांकन.',
          status: 'भौगोलिक पडताळणी',
        },
        {
          title: 'प्रोफाइल व सेटिंग्ज',
          desc: 'ग्रामसभा पदाधिकाऱ्यांची ओळखपत्रे, बहुभाषिक पर्याय आणि सुरक्षित लॉगिन.',
          status: 'सत्यापित ओळख',
        },
      ],
      bridgeBadge: 'उपजीविका सेतू',
      bridgeDesc: 'मान्यताप्राप्त वनक्षेत्रांतून प्रमाणित नैसर्गिक संसाधनांचे उत्पादन',
      moduleTitle: 'वनमित्र (VanMitra)',
      moduleBadge: 'बाजार व रोजगार',
      moduleDesc: 'सामुदायिक वन हक्कांच्या अनुषंगाने तयार केलेले ॲमेझॉन-शैलीचे खरेदी-विक्री मॉडेल:',
      pillars: [
        {
          title: '१. थेट सामुदायिक व्यापार',
          desc: 'ग्रामसभा औषधी वनस्पती, मध, बांबू व इतर साधनसंपत्ती योग्य दराच्या मार्गदर्शनासह थेट विकतात.',
        },
        {
          title: '२. अस्सल उगम व संकलन संरक्षण',
          desc: 'फक्त पडताळणी झालेल्या ग्रामसभाच विक्री करू शकतात; वनाचे नुकसान टाळण्यासाठी मोठ्या खरेदीदारांना कारण देणे बंधनकारक.',
        },
        {
          title: '३. स्थानिक वाहतूक रोजगार',
          desc: 'पिकअप, टेम्पो व बाईक असणारे ग्रामस्थ मालाची वाहतूक करून दर फेरीवर हमखास उत्पन्न मिळवतात.',
        },
      ],
    },
    explorerSection: {
      badge: 'थेट सामुदायिक बाजारपेठ',
      title: 'संसाधन शोधक (Resource Explorer)',
      desc: 'वनरक्षक ग्रामसभांनी शाश्वत पद्धतीने गोळा केलेली अस्सल वनसंपत्ती शोधा, खात्रीशीर उगम दाखला आणि योग्य बाजारभावासह.',
      sortBy: 'क्रमवारी:',
      sortNearest: 'सर्वात जवळचे अंतर (किमी)',
      sortPriceAsc: 'कमी दर आधी',
      sortRatingDesc: 'उत्कृष्ट रेटिंग',
      modeLabel: 'प्रकार:',
      modeAll: 'सर्व',
      modeBuy: 'खरेदी',
      modeBarter: 'विनिमय',
      clear: 'साफ करा',
      groupPooled: 'सामूहिक संकलन',
      fairRange: 'योग्य दर:',
      offeredAt: 'उपलब्ध दर',
      noResultsTitle: 'कोणतीही संसाधने आढळली नाहीत',
      noResultsDesc: '"मध", "अश्वगंधा", "बांबू" शोधा किंवा सर्व प्रकार निवडा.',
      resetFilters: 'फिल्टर पूर्ववत करा',
    },
    howItWorksSection: {
      badge: 'संपूर्ण कार्यप्रणाली',
      title: 'वनमित्र कसे कार्य करते',
      desc: 'प्रत्येक टप्पा वन संवर्धन, ग्रामसभेचा निर्णय अधिकार आणि स्थानिक वाहनचालकांसाठी न्याय्य उत्पन्न सुरक्षित करतो.',
      stepPrefix: 'टप्पा',
      prevBtn: 'मागील टप्पा',
      nextBtn: 'पुढील टप्पा',
      liveStatusTitle: 'थेट कार्यप्रवाह स्थिती',
      steps: [
        {
          step: '०१',
          title: 'ग्रामसभा मालाची नोंदणी करते',
          actor: 'ग्रामसभा (विक्रेता)',
          summary: 'वन समित्या उपलब्ध वनोपज, फोटो, संकलन पद्धती आणि दरासह नोंदवतात.',
          details: [
            'मागील व्यवहारांवरून सुचवलेला वाजवी बाजारभाव दर.',
            'पर्याय: रोख विक्री, आवश्यक वस्तूसाठी विनिमय किंवा दोन्ही.',
            'नोंदणी सार्वजनिक होण्यापूर्वी क्षेत्रीय पथकाद्वारे ग्रामसभेची पडताळणी.',
          ],
          previewBadge: 'स्वायत्त किंमत व उगम',
        },
        {
          step: '०२',
          title: 'अंतर व दरानुसार शोध',
          actor: 'ग्रामस्थ किंवा खरेदीदार',
          summary: 'खरेदीदार जवळच्या ग्रामसभा अंतर, उपलब्ध साठा व रेटिंगनुसार शोधतात.',
          details: [
            'गावाच्या अक्षांश-रेखांशावरून मोजलेले अचूक अंतर.',
            'एका गावाचा साठा आणि अनेक गावांचे सामूहिक संकलन यातील स्पष्ट फरक.',
            'शाश्वत पद्धतीने गोळा केल्याची खात्री व वन कंपार्टमेंट माहिती.',
          ],
          previewBadge: 'स्थानिक शोध',
        },
        {
          step: '०३',
          title: 'खरेदी विनंती किंवा विनिमय ऑफर',
          actor: 'खरेदीदार किंवा ग्रामस्थ',
          summary: 'साठ्याची मागणी, वाहतूक पद्धत (स्वतः उचलणे किंवा गाडीने डिलिव्हरी) निवडून विनंती पाठवा.',
          details: [
            'वस्तुविनिमय फक्त ग्रामसभा व गावकऱ्यांमध्ये; बाहेरच्या व्यापाऱ्यांसाठी फक्त रोख खरेदी.',
            'डिजिटल मीटर दाखवतो की विनिमय दोघांसाठी योग्य आहे की नाही.',
            'मोठ्या मागणीसाठी (≥२५ युनिट) कारणाची नोंद अनिवार्य.',
          ],
          previewBadge: 'योग्य देवाणघेवाण',
        },
        {
          step: '०४',
          title: 'ग्रामसभेचा निर्णय व मंजुरी',
          actor: 'ग्रामसभा वन समिती',
          summary: 'वन समिती मागणीचे कारण, प्रमाण आणि विनिमय तपासून निर्णय घेते.',
          details: [
            'तीन पर्याय: मंजूर करा, नकार द्या किंवा दरात बदल सुचवा.',
            'बदल सुचवल्यास खरेदीदारास लगेच कळवले जाते.',
            'मंजुरी मिळताच साठा आरक्षित होतो आणि डिलिव्हरी काम उपलब्ध होते.',
          ],
          previewBadge: 'सामुदायिक निर्णय',
        },
        {
          step: '०५',
          title: 'स्थानिक वाहनचालकाची निवड',
          actor: 'स्थानिक डिलिव्हरी पार्टनर',
          summary: 'वाहन असणारे मंजूर स्थानिक ग्रामस्थ हे वाहतुकीचे काम स्वीकारतात.',
          details: [
            'पडताळणी झालेल्या चालकांनाच संपर्क व पत्ते दिसतात.',
            'डिलिव्हरी पूर्ण होताच चालकाला ठरलेला मोबदला मिळतो.',
            'गावातून निघण्यापूर्वी ग्रामसभा माल सुपूर्द केल्याची नोंद करते.',
          ],
          previewBadge: 'स्थानिक वाहतूक रोजगार',
        },
        {
          step: '०६',
          title: 'माल पोहोचला, रेटिंग व प्रभाव नोंद',
          actor: 'खरेदीदार व नेटवर्क',
          summary: 'खरेदीदार माल मिळाल्याची खात्री करतो आणि उत्पादनाला व चालकाला स्वतंत्र रेटिंग देतो.',
          details: [
            'रक्कम थेट ग्रामसभा निधी व चालकाच्या खात्यात जमा होते.',
            'प्रत्येक रेटिंग खऱ्या व्यवहाराशी जोडलेली असते.',
            'आकडेवारी थेट सामाजिक प्रभाव डॅशबोर्डवर दिसते.',
          ],
          previewBadge: 'पूर्ण पारदर्शकता',
        },
      ],
    },
    portalsSection: {
      badge: '३ स्वतंत्र अनुभव',
      title: 'नक्की ३ लॉगिन पोर्टल्स',
      desc: 'तिन्ही पोर्टल्स एकाच बाजारपेठेत काम करतात. फक्त मुख्य स्क्रीन, मेनू आणि परवानग्या गरजेनुसार बदलतात.',
      deliveryClarification: 'डिलिव्हरी हे चौथे पोर्टल नाही—ती ग्रामस्थ पोर्टलमध्ये दिलेली कमाईची संधी आहे.',
      activeSpecBadge: 'सक्रिय तपशील',
      bottomTabsLabel: 'तळातील मेनू पर्याय:',
      coreCapsLabel: 'मुख्य वैशिष्ट्ये:',
      restrictionsLabel: 'मर्यादा:',
      matrixTitle: 'पोर्टल अधिकार व तुलनात्मक तक्ता',
      matrixDesc: 'तिन्ही घटकांची समोरासमोर तुलना.',
      colFeature: 'वैशिष्ट्य / अधिकार',
      colGramSabha: 'ग्रामसभा',
      colVillager: 'जमीनधारक / ग्रामस्थ',
      colBuyer: 'खरेदीदार व्यापारी',
      portalSpecs: [
        {
          title: 'ग्रामसभा पोर्टल',
          subtitle: 'वनहक्क क्षेत्र व्यवस्थापन करणाऱ्या ग्रामसभा',
          badge: 'विक्रेता व वन संरक्षक',
          description: 'स्थानिक वनातील नैसर्गिक उत्पादनांची नोंदणी करणे, ऑर्डर्स तपासणे आणि गावाचा सामूहिक निधी वाढवण्यासाठी ग्रामसभा वन हक्क समित्यांसाठी.',
          bottomTabs: ['मुख्य पान', 'माझी उत्पादने', 'विनंत्या', 'ऑर्डर्स', 'प्रोफाइल'],
          keyFeatures: [
            'योग्य बाजारभाव मार्गदर्शनासह उत्पादने जोडा व बदला',
            'पर्याय निवडा: फक्त विक्री, वस्तुविनिमय किंवा दोन्ही',
            'खरेदीदारांच्या मागण्या मंजूर, नामंजूर किंवा बदल सुचवा',
            'मोठ्या व्यापाऱ्यांसाठी इतर गावांशी मिळून सामूहिक साठा विका',
            'गाडी सुटताना "माल सुपूर्द केला" अशी नोंद करा',
            'नोंदणीपूर्वी क्षेत्रीय समन्वयकांकडून कागदपत्रांची तपासणी',
          ],
          notAllowed: ['स्वतः डिलिव्हरी स्वीकारू शकत नाही (फक्त वैयक्तिक वाहनचालक करू शकतात)'],
        },
        {
          title: 'जमीनधारक / ग्रामस्थ पोर्टल',
          subtitle: 'वनहक्क गावातील रहिवासी',
          badge: 'ग्रामस्थ सदस्य व चालक',
          description: 'इतर गावांशी गरजेच्या वस्तूंची देवाणघेवाण करण्यासाठी आणि स्वतःच्या वाहनाने माल पोहोचवून स्वतंत्र उत्पन्न मिळवण्यासाठी.',
          bottomTabs: ['मुख्य पान', 'शोधा', 'माझ्या विनंत्या', 'ऑर्डर्स', 'प्रोफाइल (+ अधिक)'],
          keyFeatures: [
            'अंतर आणि दरानुसार उत्पादने शोधा',
            'खरेदी करा किंवा वस्तुविनिमयाचा प्रस्ताव पाठवा',
            'ऑर्डर पोहोचण्यापर्यंत प्रत्येक टप्पा ट्रॅक करा',
            'माल मिळाल्याची खात्री करा आणि रेटिंग द्या',
            'वाहन नोंदणीसाठी "डिलिव्हरी करून कमवा" कार्ड',
            'पडताळणीनंतर "माझ्या डिलिव्हरी" विभाग लगेच उपलब्ध',
          ],
          notAllowed: ['ग्रामसभेच्या परवानगीशिवाय स्वतंत्र विक्रीची नोंद करू शकत नाही'],
        },
        {
          title: 'सर्वसाधारण खरेदीदार पोर्टल',
          subtitle: 'कंपन्या व ग्राहक',
          badge: 'संस्थात्मक खरेदीदार',
          description: 'आयुर्वेदिक कंपन्या, कारखाने व ग्राहक ज्यांना थेट जंगलातील अस्सल कच्चा माल घाऊक प्रमाणात हवा आहे.',
          bottomTabs: ['मुख्य पान (घाऊक आधी)', 'शोधा', 'माझ्या विनंत्या', 'ऑर्डर्स', 'प्रोफाइल'],
          keyFeatures: [
            'घाऊक व अनेक गावांचा सामूहिक साठा मुख्य पानावर आधी दिसतो',
            'एकाच वेळी अनेक गावांचा साठा एकत्र ऑर्डर करता येतो',
            'माल नेमका कुठून व कसा काढला याचा स्पष्ट दाखला',
            'मोठ्या खरेदीसाठी (≥२५ युनिट) कारणाची नोंद अनिवार्य',
            'ऑर्डर ट्रॅक करा आणि अधिकृत प्रतिक्रिया नोंदवा',
          ],
          notAllowed: [
            'वस्तुविनिमयाची सोय नाही (फक्त पैशाने खरेदी)',
            'डिलिव्हरी स्वीकारू शकत नाही (स्थानिक चालक किंवा स्वतः उचलणे)',
          ],
        },
      ],
      comparisonRows: [
        { feature: 'मुख्य उद्देश', gs: 'वनोपज विकणे किंवा विनिमय', vil: 'माल घेणे किंवा वाहतुकीतून कमाई', buy: 'अस्सल कच्चा माल घाऊक खरेदी' },
        { feature: 'उत्पादने नोंदवण्याचा अधिकार', gs: true, vil: false, buy: false },
        { feature: 'वस्तुविनिमयाचा प्रस्ताव देणे', gs: true, vil: true, buy: false },
        { feature: 'डिलिव्हरी रोजगार मिळवणे', gs: false, vil: true, buy: false },
        { feature: 'सामूहिक संकलन / घाऊक प्राधान्य', gs: true, vil: false, buy: true },
        { feature: 'मोठ्या खरेदीसाठी कारण', gs: 'कारणाची तपासणी करते', vil: 'कारण देते (≥२५ युनिट)', buy: 'कारण देते (≥२५ युनिट)' },
        { feature: 'तळातील मेनू', gs: '५ पर्याय (विक्री केंद्रित)', vil: '५ पर्याय + डिलिव्हरी', buy: '५ पर्याय (घाऊक व शोध)' },
        { feature: 'पडताळणी', gs: 'वन हक्क पट्ट्याची तपासणी', vil: 'गावातील रहिवासी असल्याचे प्रमाणपत्र', buy: 'व्यावसायिक संपर्क पडताळणी' },
      ],
    },
    barterSection: {
      badge: 'न्याय्य व्यापार व पारंपारिक देवाणघेवाण',
      title: 'वस्तुविनिमय संतुलन मीटर व योग्य बाजारभाव मार्गदर्शन',
      desc: 'वेगवेगळ्या ग्रामसभांकडे निसर्गाची वेगवेगळी देणगी आहे—एका गावाकडे औषधी वनस्पती, तर दुसऱ्याकडे बारमाही स्वच्छ पाणी. वनमित्र दोघांनाही पारदर्शक विनिमय करण्यास मदत करते.',
      simulatorTitle: 'थेट वस्तुविनिमय संतुलन सिम्युलेटर',
      liveTestBadge: 'थेट चाचणी',
      simulatorDesc: 'दोन्ही बाजूंची संख्या बदलून पहा की हा विनिमय समतोल आहे की नाही.',
      simToggleLabel: 'नवीन उत्पादनाची चाचणी:',
      sparseDataTitle: '"बाजारातील दराची पुरेशी माहिती उपलब्ध नाही" स्थिती:',
      sparseDataDesc: 'जेव्हा एखादे नवीन वनउत्पादन पहिल्यांदाच नोंदवले जाते, तेव्हा पूर्वीचे दर उपलब्ध नसल्यामुळे "माहिती उपलब्ध नाही" असे दिसते. अशा वेळी दोन्ही गावे आपापसांत चर्चा करून प्रमाण ठरवतात.',
      partyATitle: 'ग्रामसभा अ (देत असलेला माल)',
      partyASub: 'विक्रेता गाव',
      partyBTitle: 'ग्रामसभा ब (मागत असलेला माल)',
      partyBSub: 'दुसरे गाव',
      commodityLabel: 'वनउत्पादन:',
      qtyOfferedLabel: 'देऊ केलेली संख्या:',
      qtyRequestedLabel: 'मागितलेली संख्या:',
      totalBenchmarkVal: 'एकूण बाजारमूल्य:',
      exchangeRatioLabel: 'विनिमय प्रमाण',
      equivalenceStatus: 'समतोल स्थिती:',
      balancedVerdict: 'समतोल व योग्य विनिमय',
      favoursReceiverVerdict: 'दुसऱ्या गावासाठी फायदेशीर',
      favoursSenderVerdict: 'देऊ केलेले प्रमाण कमी आहे',
      footnoteTitle: 'महत्त्वाचा नियम:',
      footnoteDesc: 'सुचवलेला दर फक्त मार्गदर्शनासाठी आहे. ग्रामसभा स्वतःचा दर किंवा विनिमय अटी ठरवण्यास पूर्णपणे स्वतंत्र आहेत. बाहेरील व्यापारी विनिमय करू शकत नाहीत.',
    },
    groupSellingSection: {
      badge: 'एकत्रित पुरवठा',
      title: 'सामूहिक विक्री: एकत्र साठा सिम्युलेटर',
      desc: 'एका छोट्या पाड्यामध्ये हंगामी साठा मर्यादित असू शकतो. वनमित्र शेजारील ग्रामसभांना एकत्र येऊन मोठा साठा विकण्याची संधी देते, ज्यामुळे मोठे व्यापारी मिळतात आणि प्रत्येकाला योग्य हिस्सा मिळतो.',
      contributingTitle: '३ सहभागी ग्रामसभा',
      totalPoolLabel: 'एकूण गोळा झालेला साठा:',
      contributedPrefix: 'हिस्सा:',
      equalRuleNote: 'प्रत्येक गाव आपल्या मालाची स्वतः काळजी घेते आणि दिलेल्या प्रमाणानुसारच थेट पैसे मिळवते.',
      pooledFunnelLabel: '१ सामायिक सूचीमध्ये एकत्र',
      bulkBuyerPurchaseLabel: 'मोठ्या व्यापाऱ्याची खरेदी',
      simBuyerOrder: 'खरेदीदाराच्या मागणीची चाचणी:',
      minLabel: 'किमान: १० किलो',
      maxLabel: 'कमाल साठा: १०० किलो',
      totalOrderVal: 'एकूण मागणी किंमत:',
      villagePayoutTitle: 'गावनिहाय वाटप तपशील:',
    },
    deliverySection: {
      badge: 'स्थानिक वाहतूक रोजगार निर्मिती',
      title: 'डिलिव्हरी पार्टनरचा प्रवास',
      desc: 'गावागावांत माल पोहोचवण्याचे काम स्थानिक पिकअप, टेम्पो किंवा मोटारसायकल असलेल्या गावकऱ्यांसाठी उत्पन्नाची संधी निर्माण करते. हे वेगळे ॲप नसून त्यांच्या नियमित ॲपमध्येच सुरू होते.',
      journeySteps: [
        {
          step: '०१',
          title: 'ॲपमध्ये माहिती',
          actor: 'ग्रामस्थ पोर्टल',
          desc: 'स्थानिक गावकऱ्यांना त्यांच्या ॲपमध्ये "डिलिव्हरी करून पैसे कमवा" असे कार्ड दिसते. पूर्णपणे एकत्रित व्यवस्था.',
        },
        {
          step: '०२',
          title: 'माहिती व वाहन नोंदणी',
          actor: 'नोंदणी अर्ज',
          desc: 'चालक वाहनाचा प्रकार (पिकअप, टेम्पो, बाईक), क्रमांक, वजन क्षमता (किलो) आणि परवाना भरतो.',
        },
        {
          step: '०३',
          title: 'क्षेत्रीय पथकाकडून पडताळणी',
          actor: 'वनमित्र टीम',
          desc: 'मालाची आणि रस्त्याची सुरक्षितता जपण्यासाठी स्थानिक समन्वयकांकडून कागदपत्रांची खात्री केली जाते.',
        },
        {
          step: '०४',
          title: '"माझ्या डिलिव्हरी" सुरू',
          actor: 'मान्यताप्राप्त चालक',
          desc: 'मंजुरी मिळालेल्या चालकांना वाहतुकीच्या फेऱ्यांची यादी, अंतर, हमखास मोबदला आणि कामाची वेळ निवडता येते.',
        },
      ],
      unlockedBadge: 'ग्रामस्थ ॲपमध्ये उपलब्ध',
      dashTitle: '"माझ्या डिलिव्हरी" डॅशबोर्ड',
      dashDesc: 'मंजुरी मिळाल्यावर चालकाला फेऱ्यांची यादी दिसते. ग्रामसभेने ऑर्डर मंजूर करताच ठरलेल्या मोबदल्यात काम लगेच उपलब्ध होते.',
      totalEarningsLabel: 'चालकाची एकूण कमाई',
      completedHaulsLabel: 'पूर्ण केलेल्या फेऱ्या',
      partnerRatingLabel: 'चालक रेटिंग',
      ratedByLabel: 'ग्रामसभा व ग्राहकांनी दिलेले गुण',
      availabilityTitle: '"मी डिलिव्हरी कामासाठी तयार आहे"',
      availabilitySub: 'चालक स्वतःची वेळ ठरवतो; चालू असेल तरच काम दिसते.',
      activeText: 'सक्रिय',
      offlineText: 'ऑफलाइन',
      availableJobsTitle: 'उपलब्ध वाहतूक फेऱ्या:',
      jobsOpenNearby: 'फेऱ्या जवळ उपलब्ध आहेत',
      pickupLabel: 'उचलणे:',
      dropLabel: 'पोहोचवणे:',
      routeLabel: 'रस्ता:',
      openJobBadge: 'उपलब्ध काम',
      fairnessRules: [
        {
          title: 'अनोळखी लोकांपासून पूर्ण सुरक्षा',
          desc: 'जोपर्यंत अधिकृत चालक काम स्वीकारत नाही, तोपर्यंत फोन नंबर आणि अचूक पत्ता गुप्त राहतो.',
        },
        {
          title: 'चालकाचे स्वातंत्र्य व कधीही सुट्टी',
          desc: 'ग्रामस्थ कधीही स्वतःचे काम बंद करू शकतात किंवा सुट्टी घेऊ शकतात, यामुळे त्यांचे मूळ खाते सुरक्षित राहते.',
        },
        {
          title: 'मानवी मार्गदर्शन व सन्मान',
          desc: 'कमी रेटिंग असलेल्या चालकांना परस्पर काढून टाकले जात नाही; त्यांना प्रत्यक्ष मार्गदर्शन दिले जाते.',
        },
      ],
    },
    impactSection: {
      badge: 'सामुदायिक प्रभाव',
      title: 'सामाजिक प्रभाव डॅशबोर्ड',
      demoDataWarning: '★ प्रात्यक्षिक डेटा (सादरीकरण व मूल्यमापनासाठी)',
      desc: 'शासकीय विभाग आणि सामाजिक संस्थांसाठी थेट पुरावा. शासकीय स्तरावर अंमलबजावणी झाल्यावर येथे थेट आकडे दिसतील.',
      filterAll: 'सर्व जिल्हे',
      filterDistrictSuffix: 'जिल्हा',
      earningsCardTitle: 'थेट दिलेले एकूण उत्पन्न',
      earningsCardSub: 'ग्रामसभा निधी व उत्पादकांना थेट वर्ग',
      jobsCardTitle: 'निर्माण झालेले वाहतूक रोजगार',
      jobsCardSub: 'स्थानिक वाहनचालकांना सशुल्क फेऱ्या',
      familiesCardTitle: 'लाभार्थी आदिवासी कुटुंबे',
      familiesCardSub: 'मान्यताप्राप्त वनक्षेत्रातून',
      trendTitle: 'मासिक ग्रामीण उत्पन्न वाढ (हजार ₹ मध्ये)',
      trendSub: 'पायलट भागातील ऐतिहासिक वाढीचा आलेख',
      trendBadge: '+२५२% तिमाही वाढ',
      volumeTitle: 'उत्पादन प्रकारानुसार वाटा',
      volumeSub: 'विक्री झालेल्या वनसंपत्तीचे प्रमाण',
      commissionNotice: '१००% रक्कम थेट ग्रामसभा किंवा वाहनचालकांना मिळते. दलालांचे शून्य कमिशन.',
    },
    trustSection: {
      badge: 'पर्यावरणीय सचोटी',
      title: 'उगम व विश्वास दाखल्याचे महत्त्व',
      desc: 'सामान्य ई-कॉमर्सपेक्षा वेगळे, वनमित्र वनहक्क कायद्यावर उभे आहे. आम्ही प्रत्येक ग्रामसभेची पडताळणी करून विश्वास निर्माण करतो.',
      tagTitle: 'सीएफआर उगम दाखला',
      tagBadge: 'प्रत्येक उत्पादनावर',
      tagIntro: 'प्रत्येक उत्पादनावर एक अधिकृत डिजिटल खूण असते, जी खरेदीदाराला शुद्धतेची खात्री देते:',
      tagPillars: [
        {
          title: 'पडताळणी झालेली ग्रामसभा:',
          desc: 'जिल्हास्तरीय समितीच्या (DLC) आदेशावरून गावाची कागदपत्रे तपासली जातात.',
        },
        {
          title: 'वन कंपार्टमेंट व उगमस्थान:',
          desc: 'ज्या पाणलोट क्षेत्रातून किंवा देवराईतून माल गोळा केला, त्याची अचूक नोंद.',
        },
        {
          title: 'अहिंसक संकलन प्रतिज्ञा:',
          desc: 'मध गोळा करताना पोळे सुरक्षित ठेवले आणि मुळ्या काढताना पुढील वाढीसाठी भाग रोवला याची खात्री.',
        },
      ],
      largeOrderTitle: 'मोठ्या खरेदीसाठी कारण विचारण्याचा नियम',
      largeOrderBadge: 'मर्यादा ≥ २५ युनिट',
      largeOrderIntro: 'वनमित्र मोठ्या व्यापाऱ्यांना कारण विचारणे का बंधनकारक करते:',
      largeOrderRules: [
        {
          title: 'गावातील साठा संपण्यापासून संरक्षण:',
          desc: 'जंगलातील साधनसंपत्ती मर्यादित असते. एकाच मोठ्या खरेदीदाराने संपूर्ण साठा संपवू नये.',
        },
        {
          title: 'ग्रामसभेचा विचारपूर्वक निर्णय:',
          desc: 'ग्रामसभा समिती खरेदीदाराचा हेतू वाचूनच मागणी मंजूर किंवा नामंजूर करते.',
        },
        {
          title: 'काळाबाजार रोखणे:',
          desc: 'व्यापाऱ्यांकडून होणारी नफेखोरी व साठेबाजी वेळीच रोखण्यास मदत होते.',
        },
      ],
    },
    openDecisionsSection: {
      badge: 'पारदर्शक उत्पादन रचना',
      title: 'अंतिम निर्णयाधीन मुद्दे',
      desc: 'आम्ही मनमानी नियम, पेमेंट गेटवे किंवा कमिशन ठरवत नाही. हे ६ महत्त्वाचे प्रशासकीय निर्णय अधिकृत मान्यतेसाठी खुले ठेवले आहेत.',
      statusLabel: 'स्थिती:',
      decisions: [
        {
          id: 'मुद्दा-०१',
          title: 'पेमेंट व व्यवहार रचना',
          question: 'पैसे कसे दिले जातील: ऑनलाइन पेमेंट, कॅश ऑन डिलिव्हरी (COD) की वनमित्रच्या मध्यस्थ खात्यातून?',
          demoPlaceholder: 'सद्यस्थिती: "पेमेंट पद्धत: निश्चित केली जाईल"',
          impact: 'आदिवासी भागात बँकिंग सुविधा वेगवेगळ्या आहेत. बाजारात रोख व्यवहार चालतो, पण मोठ्या व्यवहारात मध्यस्थ खाते सुरक्षित असते.',
        },
        {
          id: 'मुद्दा-०२',
          title: 'वाहतूक मोबदला सूत्र',
          question: 'चालकाचा दर किलोमीटरनुसार ठरवावा (उदा. ₹१२/किमी + मूळ दर) की प्रत्येक फेरीनुसार ठरवावा?',
          demoPlaceholder: 'सद्यस्थिती: "कामाप्रमाणे मोबदला दाखवला जातो (पद्धत ठरवणे बाकी)"',
          impact: 'घाटातील अवघड रस्त्यांवर किलोमीटरपेक्षा चढावामुळे इंधन आणि वाहनाचा खर्च जास्त होतो.',
        },
        {
          id: 'मुद्दा-०३',
          title: 'ग्रामसभा पोर्टलमध्ये डिलिव्हरी पर्याय',
          question: 'डिलिव्हरी पर्याय फक्त ग्रामस्थ पोर्टलमध्ये असावा की ग्रामसभा पोर्टलमध्येही दिसावा?',
          demoPlaceholder: 'सध्याची रचना: फक्त ग्रामस्थ पोर्टलमध्ये उपलब्ध',
          impact: 'ग्रामसभा संपूर्ण गावाचे प्रतिनिधित्व करते, तर वाहने वैयक्तिक गावकऱ्यांची किंवा बचत गटांची असतात.',
        },
        {
          id: 'मुद्दा-०४',
          title: 'सुरुवातीच्या भाषांची व्याप्ती',
          question: 'सुरुवातीला इंग्रजी, हिंदी, मराठी पुरेशा आहेत की पहिल्या दिवसापासून गोंडी, कोरकू, भिल्लोरी भाषा हव्यात?',
          demoPlaceholder: 'सुरुवातीचा टप्पा: इंग्रजी / हिंदी / मराठी थेट उपलब्ध',
          impact: 'कातकरी व माडिया गोंड समाजातील वृद्ध मंडळी मुख्यतः त्यांच्या बोलीभाषेत संवाद साधतात.',
        },
        {
          id: 'मुद्दा-०५',
          title: 'कमी नेटवर्क / ऑफलाइन कामकाज',
          question: 'नेटवर्क नसलेल्या घनदाट जंगलात मोबाईल ॲपने ऑफलाइन काम करावे का आणि रेंज आल्यावर माहिती पाठवावी का?',
          demoPlaceholder: 'रचना स्थानिक IndexedDB कॅशिंगसाठी सज्ज',
          impact: 'जंगलात अनेक ठिकाणी ४ ते ८ तास अजिबात मोबाईल रेंज नसते.',
        },
        {
          id: 'मुद्दा-०६',
          title: 'नवीन वनउत्पादनांची नोंदणी अधिकार',
          question: 'नवीन प्रकारची उत्पादने जोडण्याचा अधिकार कोणाकडे असावा: मुख्य व्यवस्थापन टीम की थेट ग्रामसभा?',
          demoPlaceholder: 'सध्याच्या आवृत्तीत "इतर" पर्याय उपलब्ध',
          impact: 'शास्त्रीय वनस्पतिशास्त्र आणि स्थानिक पारंपरिक बोलीतील औषधी वनस्पतींच्या नावांचा मेळ घालणे.',
        },
      ],
    },
    footer: {
      subtitle: 'सामुदायिक वन हक्क संसाधन बाजार',
      summary: 'वनमित्र-AI वन हक्कांचे रक्षण करते; वनमित्र त्याचे रूपांतर शाश्वत ग्रामीण उत्पन्नात करते. पारदर्शक व्यापार आणि स्थानिक वाहतूक रोजगारातून ग्रामसभेचे सक्षमीकरण.',
      compliance: 'वन हक्क कायदा (FRA 2006) च्या नियमांनुसार',
      ecosystemTitle: 'वनमित्र परिसंस्था',
      backOfficeTitle: 'अंतर्गत प्रशासकीय सूचना',
      backOfficeText: 'वनमित्र बॅक-ऑफिस (ज्याचा वापर ग्रामसभेची वनहक्क कागदपत्रे व चालकांची तपासणी करण्यासाठी होतो) हे अंतर्गत प्रशासकीय साधन आहे. हे सार्वजनिक लॉगिन पोर्टल नाही.',
      helplineLabel: 'हेल्पलाइन:',
      helplineNumber: '१८००-२०९-६०६० (टोल-फ्री)',
      replayIntro: 'प्रस्तावना पुन्हा पहा',
      allRightsReserved: '© २०२६ वनमित्र · वनमित्र-AI परिसंस्था. सर्व हक्क सुरक्षित.',
      fraLaw: 'वन हक्क कायदा २००६',
      privacyPolicy: 'गोपनीयता धोरण',
    },
    listingModal: {
      verifiedBadge: 'पडताळणीकृत सीएफआर वनउत्पादन',
      verifiedReviews: 'सत्यापित प्रतिक्रिया',
      sourceAreaLabel: 'उगम वनक्षेत्र:',
      harvestMethodLabel: 'संकलन पद्धती:',
      sustainablePledge: 'झाडांना व मुळ्यांना हानी न पोहोचवता शाश्वत पद्धतीने काढलेले.',
      listedPriceLabel: 'नोंदवलेला दर',
      inStoreStock: 'गावातील साठ्यात उपलब्ध',
      fairPriceGuideTitle: 'सुचवलेला योग्य बाजारभाव',
      fairPriceNotice: 'मागील सौद्यांवरून सुचवलेला दर. ग्रामसभा अंतिम दर ठरवण्यास पूर्ण स्वतंत्र आहे.',
      requestPurchaseTab: 'खरेदीची विनंती करा',
      offerBarterTab: 'वस्तुविनिमयाची ऑफर द्या',
      barterDisabledNotice: 'बाहेरील खरेदीदारांसाठी वस्तुविनिमय उपलब्ध नाही',
      quantityDesiredLabel: 'हवी असलेली संख्या',
      sustainabilityTitle: 'शाश्वतता नियम: मोठी खरेदी',
      sustainabilityNotice: 'मोठ्या खरेदीमुळे गावातील साठा संपू नये व नैसर्गिक वनाचे नुकसान होऊ नये यासाठी कारणाची नोंद आवश्यक आहे.',
      reasonInputLabel: 'खरेदीचे कारण व व्यावसायिक वापर',
      reasonPlaceholder: 'उदा. औषध निर्मितीसाठी किंवा साठ्यासाठी कच्चा माल.',
      fulfillmentModeLabel: 'वाहतूक पद्धती',
      deliveryOptionTitle: 'स्थानिक वाहनाने डिलिव्हरी',
      deliveryOptionSub: 'सशुल्क स्थानिक चालक',
      pickupOptionTitle: 'गावातून स्वतः उचलणे',
      pickupOptionSub: 'ग्राम डिपोमधून माल घ्या',
      estimatedAmountLabel: 'अंदाजे किंमत:',
      paymentDecisionNotice: 'अॅपमध्ये पेमेंट: यूपीआय किंवा डिलिव्हरीवर रोख',
      grandTotalLabel: 'एकूण:',
      barterWantsLabel: 'ग्रामसभेची गरज:',
      exchangeResourceLabel: 'विनिमयात तुम्ही देत असलेला माल',
      exchangeQtyLabel: 'देऊ केलेले प्रमाण (संख्या/किलो)',
      equityMeterTitle: 'वस्तुविनिमय समतोल मीटर',
      offeredValLabel: 'दिलेले मूल्य:',
      targetValLabel: 'अपेक्षित मूल्य:',
      cancelBtn: 'रद्द करा',
      submitPurchaseBtn: 'खरेदीची विनंती पाठवा',
      submitBarterBtn: 'विनिमयाची ऑफर पाठवा',
    },
  },
};
