import React, { createContext, useContext, useState, useEffect } from 'react';
import {
  Listing,
  RequestItem,
  Order,
  DeliveryPartner,
  DeliveryJob,
  PortalType,
  Language,
  TabId,
  JobStatus,
  CounterOffer,
} from '../types';
import {
  initialListings,
  initialRequests,
  initialOrders,
  initialDeliveryPartner,
  initialDeliveryJobs,
} from '../data/mockData';
import { calculateDeliveryPay, checkIsLargeOrder } from '../utils/marketplace';
import { sampleItemCode } from '../utils/itemCode';
import { fetchLiveListings } from '../data/liveListings';
import { API_URL } from '../config';

export interface ToastMessage {
  id: string;
  type: 'success' | 'warning' | 'info' | 'error';
  title: string;
  message: string;
}

interface MarketplaceContextType {
  // Theme & Language
  isDark: boolean;
  toggleTheme: () => void;
  language: Language;
  setLanguage: (lang: Language) => void;

  // Active portal & navigation
  activePortal: PortalType;
  setActivePortal: (portal: PortalType) => void;
  activeTab: TabId;
  setActiveTab: (tab: TabId) => void;

  // Data states
  listings: Listing[];
  /** `live` when the listings came from the marketplace server, `sample` when they are the labelled demo data. */
  dataSource: 'sample' | 'live';
  requests: RequestItem[];
  orders: Order[];
  deliveryPartner: DeliveryPartner;
  deliveryJobs: DeliveryJob[];

  // User Actions
  addListing: (listingData: Omit<Listing, 'id' | 'itemCode' | 'source' | 'rating' | 'reviewCount' | 'isVerified' | 'fairPriceRange'>) => void;
  toggleListingStatus: (id: string) => void;
  submitRequest: (params: {
    listingId: string;
    quantity: number;
    isBarter: boolean;
    offeredResource?: string;
    offeredQuantity?: number;
    reason?: string;
  }) => { success: boolean; error?: string };
  approveRequest: (requestId: string) => void;
  rejectRequest: (requestId: string) => void;
  sendCounterOffer: (requestId: string, offer: CounterOffer) => void;
  acceptCounterOffer: (requestId: string) => void;
  confirmHandover: (orderId: string) => void;
  confirmReceived: (orderId: string, rating: number, review?: string, partnerRating?: number) => void;

  // Delivery Actions
  registerDeliveryPartner: (data: Omit<DeliveryPartner, 'id' | 'status' | 'isAvailable' | 'totalEarnings' | 'completedJobs' | 'rating'>) => void;
  simulateTeamApproval: () => void;
  toggleDriverAvailability: () => void;
  acceptDeliveryJob: (jobId: string) => void;
  updateJobProgress: (jobId: string, newStatus: JobStatus) => void;

  // Toast notifications
  toasts: ToastMessage[];
  addToast: (toast: Omit<ToastMessage, 'id'>) => void;
  dismissToast: (id: string) => void;

  // Detail Modal helper
  selectedListing: Listing | null;
  setSelectedListing: (listing: Listing | null) => void;

  // "Buy in the app" page (the website takes no payment: the app does)
  downloadListing: Listing | null;
  setDownloadListing: (listing: Listing | null) => void;
}

const MarketplaceContext = createContext<MarketplaceContextType | undefined>(undefined);

export const MarketplaceProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // Theme state with local persistence
  const [isDark, setIsDark] = useState<boolean>(() => {
    try {
      const saved = localStorage.getItem('vanrozgar_theme');
      return saved ? saved === 'dark' : false;
    } catch {
      return false;
    }
  });

  // Language state with local persistence
  const [language, setLanguageState] = useState<Language>(() => {
    try {
      const saved = localStorage.getItem('vanrozgar_lang') as Language;
      return saved && ['en', 'hi', 'mr'].includes(saved) ? saved : 'en';
    } catch {
      return 'en';
    }
  });

  // Active portal persona
  const [activePortal, setActivePortal] = useState<PortalType>('villager');

  const getTabFromHash = (hash: string): TabId => {
    const clean = hash.replace(/^#\/?/, '').toLowerCase();
    if (clean === 'ecosystem') return 'ecosystem';
    if (clean === 'how-it-works' || clean === 'howitworks') return 'how_it_works';
    if (clean === 'portals' || clean === '3-portals') return 'portals';
    if (clean === 'marketplace' || clean === 'catalog') return 'marketplace';
    if (clean === 'barter' || clean === 'fair-price' || clean === 'barter-and-fair-price') return 'barter';
    if (clean === 'delivery' || clean === 'delivery-jobs' || clean === 'jobs') return 'delivery';
    if (clean === 'impact' || clean === 'metrics') return 'impact';
    return 'overview';
  };

  const [activeTab, setActiveTabState] = useState<TabId>(() => {
    return getTabFromHash(window.location.hash);
  });

  const setActiveTab = (tab: TabId) => {
    setActiveTabState(tab);
    const hashMap: Record<TabId, string> = {
      overview: '#overview',
      ecosystem: '#ecosystem',
      how_it_works: '#how-it-works',
      portals: '#portals',
      marketplace: '#marketplace',
      barter: '#barter',
      delivery: '#delivery',
      impact: '#impact',
    };
    if (window.location.hash !== hashMap[tab]) {
      try {
        window.history.pushState(null, '', hashMap[tab]);
      } catch {}
    }
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Core reactive data
  const [listings, setListings] = useState<Listing[]>(initialListings);
  const [requests, setRequests] = useState<RequestItem[]>(initialRequests);
  const [orders, setOrders] = useState<Order[]>(initialOrders);
  const [deliveryPartner, setDeliveryPartner] = useState<DeliveryPartner>(initialDeliveryPartner);
  const [deliveryJobs, setDeliveryJobs] = useState<DeliveryJob[]>(initialDeliveryJobs);
  const [toasts, setToasts] = useState<ToastMessage[]>([]);
  const [selectedListing, setSelectedListing] = useState<Listing | null>(null);
  const [downloadListing, setDownloadListing] = useState<Listing | null>(null);
  const [dataSource, setDataSource] = useState<'sample' | 'live'>('sample');

  // Live listings from the marketplace server replace the sample ones when there are any; otherwise keep Sample
  useEffect(() => {
    let cancelled = false;
    fetchLiveListings(API_URL).then((live) => {
      if (cancelled || !live || live.length === 0) return;
      setListings(live);
      setDataSource('live');
    });
    return () => {
      cancelled = true;
    };
  }, []);

  // Apply dark class to document body
  useEffect(() => {
    const root = document.documentElement;
    if (isDark) {
      root.classList.add('dark');
      try {
        localStorage.setItem('vanrozgar_theme', 'dark');
      } catch {}
    } else {
      root.classList.remove('dark');
      try {
        localStorage.setItem('vanrozgar_theme', 'light');
      } catch {}
    }
  }, [isDark]);

  // Keep document html lang in sync
  useEffect(() => {
    document.documentElement.lang = language;
  }, [language]);

  // Listen for hash changes
  useEffect(() => {
    const handleHash = () => {
      const hash = window.location.hash;
      const matched = getTabFromHash(hash);
      setActiveTabState(matched);
    };
    window.addEventListener('hashchange', handleHash);
    return () => window.removeEventListener('hashchange', handleHash);
  }, []);

  const toggleTheme = () => setIsDark((prev) => !prev);

  const setLanguage = (lang: Language) => {
    setLanguageState(lang);
    try {
      localStorage.setItem('vanrozgar_lang', lang);
    } catch {}
  };

  const addToast = (toast: Omit<ToastMessage, 'id'>) => {
    const id = `toast-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`;
    setToasts((prev) => [...prev, { ...toast, id }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 4500);
  };

  const dismissToast = (id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  // Add Listing
  const addListing = (
    listingData: Omit<Listing, 'id' | 'itemCode' | 'source' | 'rating' | 'reviewCount' | 'isVerified' | 'fairPriceRange'>
  ) => {
    const minFair = Math.round(listingData.pricePerUnit * 0.88);
    const maxFair = Math.round(listingData.pricePerUnit * 1.14);
    const id = `list-${Date.now()}`;
    const newListing: Listing = {
      ...listingData,
      id,
      itemCode: sampleItemCode(id),
      source: 'sample',
      rating: 5.0,
      reviewCount: 1,
      isVerified: true,
      fairPriceRange: [minFair, maxFair],
    };
    setListings((prev) => [newListing, ...prev]);
    addToast({
      type: 'success',
      title: 'Resource Listed Successfully',
      message: `${newListing.title} is now visible to verified buyers across the network.`,
    });
  };

  // Toggle Pause/Active Listing
  const toggleListingStatus = (id: string) => {
    setListings((prev) =>
      prev.map((item) => {
        if (item.id === id) {
          const newStatus = item.status === 'active' ? 'paused' : 'active';
          addToast({
            type: 'info',
            title: `Listing ${newStatus === 'active' ? 'Resumed' : 'Paused'}`,
            message: `${item.title} status updated to ${newStatus}.`,
          });
          return { ...item, status: newStatus };
        }
        return item;
      })
    );
  };

  // Submit Request
  const submitRequest = (params: {
    listingId: string;
    quantity: number;
    isBarter: boolean;
    offeredResource?: string;
    offeredQuantity?: number;
    reason?: string;
  }) => {
    const listing = listings.find((l) => l.id === params.listingId);
    if (!listing) return { success: false, error: 'Listing not found' };

    const isLarge = checkIsLargeOrder(params.quantity);
    if (isLarge && !params.reason?.trim()) {
      return { success: false, error: 'A sustainability reason is strictly mandatory for large bulk orders.' };
    }

    const buyerName =
      activePortal === 'buyer'
        ? 'EcoVeda Natural Enterprises'
        : activePortal === 'villager'
        ? 'Kailash Mukne (Landowner)'
        : 'Gram Sabha Jawhar';

    const newReq: RequestItem = {
      id: `req-${Date.now()}`,
      listingId: listing.id,
      resourceTitle: listing.title,
      buyerId: `user-${activePortal}`,
      buyerName,
      buyerPortal: activePortal,
      buyerVillage: activePortal === 'villager' ? 'Jawhar' : undefined,
      sellerGramSabhaId: listing.gramSabhaId,
      sellerGramSabhaName: listing.gramSabhaName,
      requestedQuantity: params.quantity,
      unit: listing.unit,
      isBarter: params.isBarter,
      offeredResource: params.offeredResource,
      offeredQuantity: params.offeredQuantity,
      reason: params.reason,
      isLargeOrder: isLarge,
      status: 'pending',
      createdAt: 'Just now',
    };

    setRequests((prev) => [newReq, ...prev]);

    addToast({
      type: 'success',
      title: params.isBarter ? 'Barter Proposal Sent' : 'Purchase Request Sent',
      message: `Your request for ${params.quantity} ${listing.unit} sent to ${listing.gramSabhaName}.`,
    });

    return { success: true };
  };

  // Approve Request -> generates Order + auto-generates delivery job
  const approveRequest = (requestId: string) => {
    const req = requests.find((r) => r.id === requestId);
    if (!req) return;

    const listing = listings.find((l) => l.id === req.listingId);
    const unitPrice = listing ? listing.pricePerUnit : 100;
    const totalAmount = req.isBarter ? 0 : req.requestedQuantity * unitPrice;

    // Update request status
    setRequests((prev) =>
      prev.map((r) => (r.id === requestId ? { ...r, status: 'approved' as const } : r))
    );

    // Deduct stock
    if (listing) {
      setListings((prev) =>
        prev.map((l) =>
          l.id === listing.id
            ? { ...l, quantity: Math.max(0, l.quantity - req.requestedQuantity) }
            : l
        )
      );
    }

    const newOrderId = `ord-${Date.now()}`;
    const newOrder: Order = {
      id: newOrderId,
      requestId: req.id,
      listingId: req.listingId,
      resourceTitle: req.resourceTitle,
      buyerName: req.buyerName,
      sellerName: req.sellerGramSabhaName,
      sellerGramSabhaId: req.sellerGramSabhaId,
      quantity: req.requestedQuantity,
      unit: req.unit,
      totalAmount,
      isBarter: req.isBarter,
      barterDetails: req.isBarter ? `Exchanging for ${req.offeredQuantity} ${req.offeredResource}` : undefined,
      deliveryType: 'delivery',
      status: 'approved',
      deliveryFee: calculateDeliveryPay(15, req.requestedQuantity),
      createdAt: 'Just now',
      handoverConfirmed: false,
      receivedConfirmed: false,
    };

    setOrders((prev) => [newOrder, ...prev]);

    // Create a delivery job
    const newJob: DeliveryJob = {
      id: `job-${Date.now()}`,
      orderId: newOrderId,
      pickupVillage: req.sellerGramSabhaName,
      dropVillage: req.buyerVillage ? `${req.buyerVillage} Village` : 'Buyer Depot Point',
      resourceTitle: `${req.resourceTitle} (${req.requestedQuantity} ${req.unit})`,
      weightKg: req.requestedQuantity,
      distanceKm: 16,
      estimatedPay: calculateDeliveryPay(16, req.requestedQuantity),
      status: 'available',
    };

    setDeliveryJobs((prev) => [newJob, ...prev]);

    addToast({
      type: 'success',
      title: 'Request Approved & Order Created',
      message: `Stock reserved. Delivery job posted to village vehicle partners.`,
    });
  };

  // Reject Request
  const rejectRequest = (requestId: string) => {
    setRequests((prev) =>
      prev.map((r) => (r.id === requestId ? { ...r, status: 'rejected' as const } : r))
    );
    addToast({
      type: 'warning',
      title: 'Request Declined',
      message: 'Buyer has been informed that request could not be fulfilled at this time.',
    });
  };

  // Counter Offer
  const sendCounterOffer = (requestId: string, offer: CounterOffer) => {
    setRequests((prev) =>
      prev.map((r) =>
        r.id === requestId ? { ...r, status: 'countered' as const, counterOffer: offer } : r
      )
    );
    addToast({
      type: 'info',
      title: 'Counter-Offer Dispatched',
      message: `Offered: ${offer.quantity} units @ ₹${offer.pricePerUnit}. Awaiting buyer response.`,
    });
  };

  // Accept Counter Offer
  const acceptCounterOffer = (requestId: string) => {
    const req = requests.find((r) => r.id === requestId);
    if (!req || !req.counterOffer) return;

    const acceptedQty = req.counterOffer.quantity;
    const acceptedPrice = req.counterOffer.pricePerUnit;

    setRequests((prev) =>
      prev.map((r) => (r.id === requestId ? { ...r, status: 'approved' as const } : r))
    );

    const newOrderId = `ord-${Date.now()}`;
    const newOrder: Order = {
      id: newOrderId,
      requestId: req.id,
      listingId: req.listingId,
      resourceTitle: req.resourceTitle,
      buyerName: req.buyerName,
      sellerName: req.sellerGramSabhaName,
      sellerGramSabhaId: req.sellerGramSabhaId,
      quantity: acceptedQty,
      unit: req.unit,
      totalAmount: acceptedQty * acceptedPrice,
      isBarter: req.isBarter,
      deliveryType: 'delivery',
      status: 'approved',
      deliveryFee: calculateDeliveryPay(14, acceptedQty),
      createdAt: 'Just now',
    };

    setOrders((prev) => [newOrder, ...prev]);
    addToast({
      type: 'success',
      title: 'Counter-Offer Accepted',
      message: 'Order created with counter-offered terms.',
    });
  };

  // Confirm Handover (Gram Sabha seller action)
  const confirmHandover = (orderId: string) => {
    setOrders((prev) =>
      prev.map((ord) => {
        if (ord.id === orderId) {
          return {
            ...ord,
            handoverConfirmed: true,
            status: ord.deliveryPartnerId ? 'in_transit' : 'approved',
          };
        }
        return ord;
      })
    );
    addToast({
      type: 'success',
      title: 'Handover Confirmed',
      message: 'Goods officially handed over to designated delivery partner.',
    });
  };

  // Confirm Received (Buyer / Villager action)
  const confirmReceived = (orderId: string, rating: number, review?: string, partnerRating?: number) => {
    setOrders((prev) =>
      prev.map((ord) => {
        if (ord.id === orderId) {
          return {
            ...ord,
            receivedConfirmed: true,
            status: 'closed' as const,
            ratingGiven: rating,
            reviewGiven: review,
            partnerRatingGiven: partnerRating,
          };
        }
        return ord;
      })
    );

    addToast({
      type: 'success',
      title: 'Order Confirmed & Completed',
      message: 'Feedback recorded! Earnings credited to Gram Sabha & Delivery Partner.',
    });
  };

  // Delivery Partner: Register
  const registerDeliveryPartner = (
    data: Omit<DeliveryPartner, 'id' | 'status' | 'isAvailable' | 'totalEarnings' | 'completedJobs' | 'rating'>
  ) => {
    setDeliveryPartner({
      ...data,
      id: `driver-${Date.now()}`,
      status: 'pending_review',
      isAvailable: false,
      totalEarnings: 0,
      completedJobs: 0,
      rating: 5.0,
    });
    addToast({
      type: 'info',
      title: 'Application Submitted',
      message: 'Your vehicle details are under review by the VanMitra field team.',
    });
  };

  // Simulate Team Approval
  const simulateTeamApproval = () => {
    setDeliveryPartner((prev) => ({
      ...prev,
      status: 'approved',
      isAvailable: true,
    }));
    addToast({
      type: 'success',
      title: 'Application Approved by Team',
      message: 'You are now an authorized delivery partner. "My Deliveries" tab unlocked!',
    });
  };

  // Toggle Driver Availability
  const toggleDriverAvailability = () => {
    setDeliveryPartner((prev) => {
      const next = !prev.isAvailable;
      addToast({
        type: 'info',
        title: next ? 'You are Available' : 'Duty Paused',
        message: next ? 'You can now accept nearby village haul requests.' : 'New jobs temporarily hidden.',
      });
      return { ...prev, isAvailable: next };
    });
  };

  // Accept Delivery Job
  const acceptDeliveryJob = (jobId: string) => {
    const job = deliveryJobs.find((j) => j.id === jobId);
    if (!job) return;

    setDeliveryJobs((prev) =>
      prev.map((j) =>
        j.id === jobId
          ? { ...j, status: 'accepted' as const, assignedPartnerId: deliveryPartner.id }
          : j
      )
    );

    // Link into order
    setOrders((prev) =>
      prev.map((ord) =>
        ord.id === job.orderId
          ? {
              ...ord,
              status: 'delivery_assigned',
              deliveryPartnerId: deliveryPartner.id,
              deliveryPartnerName: `${deliveryPartner.name} (${deliveryPartner.vehicleNumber})`,
              deliveryPartnerPhone: deliveryPartner.phone,
            }
          : ord
      )
    );

    addToast({
      type: 'success',
      title: 'Job Accepted!',
      message: `Pickup: ${job.pickupVillage}. Route locked for you.`,
    });
  };

  // Update Job Progress (Picked up -> In Transit -> Delivered)
  const updateJobProgress = (jobId: string, newStatus: JobStatus) => {
    const job = deliveryJobs.find((j) => j.id === jobId);
    if (!job) return;

    setDeliveryJobs((prev) =>
      prev.map((j) => (j.id === jobId ? { ...j, status: newStatus } : j))
    );

    // Sync to order
    setOrders((prev) =>
      prev.map((ord) => {
        if (ord.id === job.orderId) {
          const mappedOrderStatus =
            newStatus === 'picked_up' || newStatus === 'in_transit'
              ? 'in_transit'
              : newStatus === 'delivered'
              ? 'delivered'
              : ord.status;
          return { ...ord, status: mappedOrderStatus };
        }
        return ord;
      })
    );

    if (newStatus === 'delivered') {
      setDeliveryPartner((prev) => ({
        ...prev,
        totalEarnings: prev.totalEarnings + job.estimatedPay,
        completedJobs: prev.completedJobs + 1,
      }));
    }

    addToast({
      type: 'info',
      title: 'Delivery Status Updated',
      message: `Job ${jobId.slice(0, 7)} is now marked as ${newStatus.replace('_', ' ')}.`,
    });
  };

  return (
    <MarketplaceContext.Provider
      value={{
        isDark,
        toggleTheme,
        language,
        setLanguage,
        activePortal,
        setActivePortal,
        activeTab,
        setActiveTab,
        listings,
        dataSource,
        requests,
        orders,
        deliveryPartner,
        deliveryJobs,
        addListing,
        toggleListingStatus,
        submitRequest,
        approveRequest,
        rejectRequest,
        sendCounterOffer,
        acceptCounterOffer,
        confirmHandover,
        confirmReceived,
        registerDeliveryPartner,
        simulateTeamApproval,
        toggleDriverAvailability,
        acceptDeliveryJob,
        updateJobProgress,
        toasts,
        addToast,
        dismissToast,
        selectedListing,
        setSelectedListing,
        downloadListing,
        setDownloadListing,
      }}
    >
      {children}
    </MarketplaceContext.Provider>
  );
};

export const useMarketplace = () => {
  const context = useContext(MarketplaceContext);
  if (!context) throw new Error('useMarketplace must be used within a MarketplaceProvider');
  return context;
};
