import React, { useState, useEffect } from 'react';
import { useMarketplace } from '../context/MarketplaceContext';
import { translations } from '../i18n/translations';
import { PortalType, Language, Listing, VehicleType } from '../types';
import { ResourceIcon } from '../components/ResourceIcon';
import { calculateFairPriceRange, checkIsLargeOrder } from '../utils/marketplace';
import {
  X,
  Maximize2,
  Minimize2,
  Home,
  Layers,
  Search,
  Scale,
  ShoppingBag,
  Truck,
  User,
  ShieldCheck,
  Plus,
  Star,
  MapPin,
  CheckCircle,
  XCircle,
  AlertCircle,
  ArrowRight,
  Sparkles,
  Phone,
  Lock,
  ChevronRight,
  TrendingUp,
  LogOut,
  RefreshCw,
  Clock,
  Car,
  ToggleLeft,
  ToggleRight,
  FileText,
} from 'lucide-react';

type PreLoginScreen = 'splash' | 'login' | 'choose_portal' | 'register' | 'language' | 'app';

export const DemoAppModal: React.FC = () => {
  const {
    isDemoOpen,
    setIsDemoOpen,
    activePortal,
    setActivePortal,
    language,
    setLanguage,
    listings,
    addListing,
    toggleListingStatus,
    requests,
    approveRequest,
    rejectRequest,
    sendCounterOffer,
    acceptCounterOffer,
    orders,
    confirmHandover,
    confirmReceived,
    deliveryPartner,
    registerDeliveryPartner,
    simulateTeamApproval,
    toggleDriverAvailability,
    deliveryJobs,
    acceptDeliveryJob,
    updateJobProgress,
    setSelectedListing,
  } = useMarketplace();

  const t = translations[language];

  // Screen state
  const [screen, setScreen] = useState<PreLoginScreen>('splash');
  const [activeTab, setActiveTab] = useState<string>('home');
  const [isFullScreen, setIsFullScreen] = useState(false);

  // Pre-login state
  const [selectedSignupPortal, setSelectedSignupPortal] = useState<PortalType>('villager');
  const [loginPhone, setLoginPhone] = useState('9822100000');
  const [loginPassword, setLoginPassword] = useState('password123');

  // Registration Form States
  const [regName, setRegName] = useState('');
  const [regVillage, setRegVillage] = useState('Jawhar');
  const [regDistrict, setRegDistrict] = useState('Palghar');
  const [regPhone, setRegPhone] = useState('9822100000');
  const [regContactPerson, setRegContactPerson] = useState('Suresh Mukne (Secretary)');
  const [regCfrDetails, setRegCfrDetails] = useState('DLC Order #442/2014, Area 420 Ha');
  const [regBusinessName, setRegBusinessName] = useState('BioVeda Herbals Pvt Ltd');

  // Delivery Partner registration modal in Villager portal
  const [showDriverRegModal, setShowDriverRegModal] = useState(false);
  const [driverVehicleType, setDriverVehicleType] = useState<VehicleType>('pickup_truck');
  const [driverVehicleNumber, setDriverVehicleNumber] = useState('MH-48-AB-9921');
  const [driverCapacity, setDriverCapacity] = useState<number>(650);
  const [driverLicence, setDriverLicence] = useState('MH48 20190012480');
  const [driverAreas, setDriverAreas] = useState('Jawhar, Mokhada, Vikramgad');

  // Add Listing Modal state in Gram Sabha portal
  const [showAddListingModal, setShowAddListingModal] = useState(false);
  const [newTitle, setNewTitle] = useState('');
  const [newCategory, setNewCategory] = useState<any>('forest_produce');
  const [newQty, setNewQty] = useState(30);
  const [newUnit, setNewUnit] = useState('kg');
  const [newPrice, setNewPrice] = useState(400);
  const [newMode, setNewMode] = useState<'sell' | 'barter' | 'both'>('both');
  const [newBarterWants, setNewBarterWants] = useState('Bamboo baskets or wild herbs');
  const [newSourceArea, setNewSourceArea] = useState('Jawhar CFR Northern Ridge');
  const [newCollectionMethod, setNewCollectionMethod] = useState('Selective sustainable wild harvest');
  const [newHarvestSeason, setNewHarvestSeason] = useState('October - January');

  // Counter Offer dialog state
  const [counterTargetReq, setCounterTargetReq] = useState<string | null>(null);
  const [counterQty, setCounterQty] = useState<number>(20);
  const [counterPrice, setCounterPrice] = useState<number>(450);
  const [counterNote, setCounterNote] = useState<string>('Can supply from next week harvest batch');

  // Rate order dialog state
  const [ratingOrderTarget, setRatingOrderTarget] = useState<string | null>(null);
  const [ratingStars, setRatingStars] = useState<number>(5);
  const [reviewNote, setReviewNote] = useState<string>('Authentic forest quality, swift delivery!');
  const [driverRating, setDriverRating] = useState<number>(5);

  // Auto-advance splash after 3.5 seconds
  useEffect(() => {
    if (screen === 'splash' && isDemoOpen) {
      const timer = setTimeout(() => {
        setScreen('login');
      }, 3500);
      return () => clearTimeout(timer);
    }
  }, [screen, isDemoOpen]);

  // Set active tab default when switching portal
  useEffect(() => {
    setActiveTab('home');
  }, [activePortal]);

  if (!isDemoOpen) return null;

  const handleClose = () => {
    setIsDemoOpen(false);
    window.location.hash = '#/';
  };

  const handleLoginSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setScreen('choose_portal');
  };

  const handlePortalSelected = (portal: PortalType) => {
    setSelectedSignupPortal(portal);
    setScreen('register');
  };

  const handleRegisterSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setActivePortal(selectedSignupPortal);
    setScreen('language');
  };

  const handleLanguageChoice = (lang: Language) => {
    setLanguage(lang);
    setScreen('app');
  };

  const handleCreateListingSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim()) return;

    addListing({
      title: newTitle,
      category: newCategory,
      quantity: newQty,
      unit: newUnit,
      pricePerUnit: newPrice,
      mode: newMode,
      barterWants: newMode !== 'sell' ? newBarterWants : undefined,
      gramSabhaId: 'gs-jawhar',
      gramSabhaName: 'Gram Sabha Jawhar',
      village: 'Jawhar',
      district: 'Palghar',
      distanceKm: 0,
      sourceArea: newSourceArea,
      collectionMethod: newCollectionMethod,
      isSustainable: true,
      isGroupListing: false,
      iconType: newCategory === 'medicinal' ? 'herbs' : newCategory === 'handicrafts' ? 'bamboo' : 'seeds',
      description: `High quality ${newTitle} harvested sustainably under Jawhar CFR rights.`,
      harvestSeason: newHarvestSeason,
      status: 'active',
    });

    setShowAddListingModal(false);
    setNewTitle('');
  };

  const handleDriverRegSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    registerDeliveryPartner({
      name: regName || 'Kailash Mukne',
      phone: regPhone || '+91 98221 44091',
      village: regVillage || 'Jawhar Rural',
      vehicleType: driverVehicleType,
      vehicleNumber: driverVehicleNumber,
      carryingCapacityKg: driverCapacity,
      licenceDetail: driverLicence,
      coveredAreas: driverAreas,
    });
    setShowDriverRegModal(false);
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto bg-black/80 backdrop-blur-md flex items-center justify-center p-0 sm:p-4">
      {/* Container - Centered Phone Frame or Fullscreen */}
      <div
        className={`relative bg-[#0C1B14] text-white overflow-hidden shadow-2xl transition-all flex flex-col ${
          isFullScreen
            ? 'w-full h-full rounded-none'
            : 'w-full sm:max-w-md h-full sm:h-[840px] sm:rounded-[40px] border-0 sm:border-[8px] sm:border-[#2B5A46]'
        }`}
      >
        {/* Top Control Bar (Demo Helper) */}
        <div className="bg-[#10261B] border-b border-[#2B5A46] px-4 py-2 flex items-center justify-between text-xs shrink-0 z-20">
          <div className="flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-[#5FAE3B] animate-pulse" />
            <span className="font-extrabold text-[#FF8D20] uppercase text-[10px] tracking-wider">
              VanRozgar Interactive App
            </span>
          </div>

          <div className="flex items-center gap-2">
            {screen === 'app' && (
              <div className="flex items-center gap-1 bg-[#1A4331] px-2 py-0.5 rounded-lg border border-[#2B5A46]">
                <span className="text-[10px] text-[#AAB8B2]">Role:</span>
                <select
                  value={activePortal}
                  onChange={(e) => setActivePortal(e.target.value as PortalType)}
                  aria-label="Switch demo portal persona"
                  className="bg-transparent text-[10px] font-bold text-white outline-none"
                >
                  <option value="gram_sabha" className="bg-[#1A4331] text-white">Gram Sabha (Seller)</option>
                  <option value="villager" className="bg-[#1A4331] text-white">Landowner / Villager</option>
                  <option value="buyer" className="bg-[#1A4331] text-white">General Buyer (Bulk)</option>
                </select>
              </div>
            )}

            <button
              onClick={() => setIsFullScreen(!isFullScreen)}
              aria-label={isFullScreen ? 'Exit fullscreen' : 'Enter fullscreen'}
              className="p-1 rounded-md text-white/80 hover:text-white"
            >
              {isFullScreen ? <Minimize2 className="w-3.5 h-3.5" /> : <Maximize2 className="w-3.5 h-3.5" />}
            </button>

            <button
              onClick={handleClose}
              aria-label="Close demo"
              className="p-1 rounded-md text-white/80 hover:text-white"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Mobile App Viewport Body */}
        <div className="flex-1 overflow-y-auto relative flex flex-col bg-[#F4F7F5] dark:bg-[#10261B] text-[#13202B] dark:text-[#F4F7F5]">
          
          {/* ================= SCREEN 1: PROMO SPLASH ================= */}
          {screen === 'splash' && (
            <div className="flex-1 flex flex-col items-center justify-between p-8 bg-gradient-to-b from-[#1A4331] via-[#10261B] to-[#0C1B14] text-white text-center">
              <div className="w-full flex justify-end">
                <span className="text-[10px] text-[#AAB8B2] px-2 py-1 rounded bg-white/5 border border-white/10">
                  Auto-advancing...
                </span>
              </div>

              <div className="space-y-6 max-w-xs">
                {/* Logo in center */}
                <div className="w-28 h-28 mx-auto rounded-full overflow-hidden border-4 border-[#FF8D20] shadow-2xl bg-white p-1">
                  <img
                    src="/assets/aistudio/IMG-20261006-WA0009_1_.jpg_91f800c1.jpeg"
                    alt="VanRozgar Tribal Mandala Logo"
                    className="w-full h-full object-cover rounded-full"
                  />
                </div>

                <div className="space-y-2">
                  <h1 className="text-3xl font-extrabold font-['Manrope'] tracking-tight">
                    VanRozgar
                  </h1>
                  <p className="text-xs font-semibold text-[#FF8D20] uppercase tracking-wider">
                    Community Resource Marketplace
                  </p>
                </div>

                <p className="text-sm text-[#F4F7F5]/85 italic">
                  "{t.tagline}"
                </p>
                <p className="text-[11px] text-[#AAB8B2] leading-relaxed">
                  A module of VanMitra-AI protecting CFR rights and generating rural transport livelihoods.
                </p>
              </div>

              <div className="w-full max-w-xs space-y-3">
                <button
                  onClick={() => setScreen('login')}
                  className="w-full py-3.5 rounded-2xl bg-[#FF8D20] hover:bg-[#D96B00] text-white font-bold text-sm shadow-xl flex items-center justify-center gap-2"
                >
                  <span>Get Started</span>
                  <ArrowRight className="w-4 h-4" />
                </button>
                <div className="text-[10px] text-[#AAB8B2]">
                  No menus · No search · Direct entrance
                </div>
              </div>
            </div>
          )}

          {/* ================= SCREEN 2: LOGIN / REGISTER ================= */}
          {screen === 'login' && (
            <div className="flex-1 p-6 flex flex-col justify-between bg-gradient-to-b from-[#1A4331] via-[#10261B] to-[#0C1B14] text-white">
              <div className="space-y-6 pt-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full overflow-hidden border-2 border-[#FF8D20] bg-white shrink-0">
                    <img
                      src="/assets/aistudio/IMG-20261006-WA0009_1_.jpg_91f800c1.jpeg"
                      alt="Logo"
                      className="w-full h-full object-cover"
                    />
                  </div>
                  <div>
                    <h2 className="text-xl font-bold font-['Manrope']">Welcome to VanRozgar</h2>
                    <p className="text-xs text-[#AAB8B2]">Sign in to access your forest council portal</p>
                  </div>
                </div>

                <form onSubmit={handleLoginSubmit} className="space-y-4 pt-2">
                  <div>
                    <label className="block text-xs font-bold text-[#F4F7F5] mb-1">
                      Phone Number or Email
                    </label>
                    <input
                      type="text"
                      value={loginPhone}
                      onChange={(e) => setLoginPhone(e.target.value)}
                      placeholder="e.g. 98221 00000"
                      className="w-full p-3 rounded-xl bg-white/10 border border-white/20 text-white placeholder:text-gray-400 text-xs focus:ring-2 focus:ring-[#FF8D20] outline-none"
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-bold text-[#F4F7F5] mb-1">
                      Password or SMS One-Time Code
                    </label>
                    <input
                      type="password"
                      value={loginPassword}
                      onChange={(e) => setLoginPassword(e.target.value)}
                      placeholder="••••••••"
                      className="w-full p-3 rounded-xl bg-white/10 border border-white/20 text-white placeholder:text-gray-400 text-xs focus:ring-2 focus:ring-[#FF8D20] outline-none"
                      required
                    />
                  </div>

                  <div className="flex items-center justify-between text-xs">
                    <label className="flex items-center gap-1.5 text-[#AAB8B2]">
                      <input type="checkbox" defaultChecked className="rounded accent-[#FF8D20]" />
                      <span>Remember credentials</span>
                    </label>
                    <a href="#forgot" onClick={(e) => { e.preventDefault(); alert('In the live pilot, SMS OTP is sent to registered village mobile number.'); }} className="text-[#FF8D20] hover:underline">
                      Forgot password?
                    </a>
                  </div>

                  <button
                    type="submit"
                    className="w-full py-3 rounded-xl bg-[#FF8D20] hover:bg-[#D96B00] text-white font-bold text-xs shadow-md mt-2 flex items-center justify-center gap-2"
                  >
                    <span>Sign In</span>
                    <ArrowRight className="w-4 h-4" />
                  </button>
                </form>
              </div>

              <div className="pt-6 border-t border-white/10 text-center space-y-2">
                <span className="text-xs text-[#AAB8B2]">New to VanRozgar?</span>
                <button
                  type="button"
                  onClick={() => setScreen('choose_portal')}
                  className="w-full py-2.5 rounded-xl bg-white/10 hover:bg-white/20 text-white text-xs font-bold border border-white/20"
                >
                  Create New Account (Sign Up)
                </button>
              </div>
            </div>
          )}

          {/* ================= SCREEN 3: CHOOSE PORTAL ================= */}
          {screen === 'choose_portal' && (
            <div className="flex-1 p-6 flex flex-col justify-between bg-[#F4F7F5] dark:bg-[#10261B] text-[#13202B] dark:text-[#F4F7F5]">
              <div className="space-y-4 pt-2">
                <div className="space-y-1">
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#FF8D20]/20 text-[#FF8D20]">
                    Screen 3: Registration Choice
                  </span>
                  <h2 className="text-xl font-bold font-['Manrope']">
                    Choose Your Portal
                  </h2>
                  <p className="text-xs text-[#66737C] dark:text-[#AAB8B2]">
                    Select the role matching your community status. (Delivery is not a 4th card—it unlocks inside the Villager portal).
                  </p>
                </div>

                <div className="space-y-3 pt-2">
                  {/* Card 1: Gram Sabha */}
                  <button
                    onClick={() => handlePortalSelected('gram_sabha')}
                    className="w-full p-4 rounded-2xl bg-white dark:bg-[#173425] border-2 border-transparent hover:border-[#FF8D20] shadow-md text-left transition-all group"
                  >
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-xs font-bold px-2 py-0.5 rounded bg-emerald-100 dark:bg-emerald-950/60 text-[#1A4331] dark:text-[#5FAE3B]">
                        The Seller
                      </span>
                      <ArrowRight className="w-4 h-4 text-[#FF8D20] group-hover:translate-x-1 transition-transform" />
                    </div>
                    <h3 className="text-sm font-bold text-[#13202B] dark:text-white">
                      Gram Sabha Portal
                    </h3>
                    <p className="text-xs text-[#66737C] dark:text-[#AAB8B2] mt-1 leading-relaxed">
                      "We manage a CFR village and want to sell or exchange resources."
                    </p>
                  </button>

                  {/* Card 2: Landowner / Villager */}
                  <button
                    onClick={() => handlePortalSelected('villager')}
                    className="w-full p-4 rounded-2xl bg-white dark:bg-[#173425] border-2 border-transparent hover:border-[#FF8D20] shadow-md text-left transition-all group"
                  >
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-xs font-bold px-2 py-0.5 rounded bg-amber-100 dark:bg-amber-950/60 text-amber-800 dark:text-[#FF8D20]">
                        Community & Driver
                      </span>
                      <ArrowRight className="w-4 h-4 text-[#FF8D20] group-hover:translate-x-1 transition-transform" />
                    </div>
                    <h3 className="text-sm font-bold text-[#13202B] dark:text-white">
                      Landowner / Villager Portal
                    </h3>
                    <p className="text-xs text-[#66737C] dark:text-[#AAB8B2] mt-1 leading-relaxed">
                      "I live in or own land in a CFR village and want to buy resources or earn with delivery."
                    </p>
                  </button>

                  {/* Card 3: General Buyer */}
                  <button
                    onClick={() => handlePortalSelected('buyer')}
                    className="w-full p-4 rounded-2xl bg-white dark:bg-[#173425] border-2 border-transparent hover:border-[#FF8D20] shadow-md text-left transition-all group"
                  >
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-xs font-bold px-2 py-0.5 rounded bg-blue-100 dark:bg-blue-950/60 text-blue-800 dark:text-blue-300">
                        Outside Buyer
                      </span>
                      <ArrowRight className="w-4 h-4 text-[#FF8D20] group-hover:translate-x-1 transition-transform" />
                    </div>
                    <h3 className="text-sm font-bold text-[#13202B] dark:text-white">
                      General Buyer Portal
                    </h3>
                    <p className="text-xs text-[#66737C] dark:text-[#AAB8B2] mt-1 leading-relaxed">
                      "I am a person or business outside CFR villages and want to buy authentic bulk raw materials."
                    </p>
                  </button>
                </div>
              </div>

              <div className="pt-4 text-center">
                <button
                  type="button"
                  onClick={() => setScreen('login')}
                  className="text-xs text-[#66737C] dark:text-[#AAB8B2] hover:underline"
                >
                  ← Back to Sign In
                </button>
              </div>
            </div>
          )}

          {/* ================= SCREEN 4: REGISTER FORM ================= */}
          {screen === 'register' && (
            <div className="flex-1 p-6 flex flex-col justify-between bg-[#F4F7F5] dark:bg-[#10261B] text-[#13202B] dark:text-[#F4F7F5]">
              <div className="space-y-4 pt-1">
                <div className="space-y-1">
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#1A4331]/20 dark:bg-[#2D765C]/30 text-[#1A4331] dark:text-[#5FAE3B]">
                    Portal Register: {selectedSignupPortal.replace('_', ' ').toUpperCase()}
                  </span>
                  <h2 className="text-lg font-bold font-['Manrope']">
                    Sign Up Details
                  </h2>
                </div>

                <form onSubmit={handleRegisterSubmit} className="space-y-3">
                  <div>
                    <label className="block text-[11px] font-bold text-[#13202B] dark:text-white mb-1">
                      Full Name
                    </label>
                    <input
                      type="text"
                      value={regName}
                      onChange={(e) => setRegName(e.target.value)}
                      placeholder="e.g. Kailash Mukne"
                      className="w-full p-2.5 text-xs rounded-xl border border-gray-200 dark:border-[#2B5A46] bg-white dark:bg-[#173425] text-[#13202B] dark:text-white outline-none focus:ring-2 focus:ring-[#FF8D20]"
                      required
                    />
                  </div>

                  {selectedSignupPortal === 'gram_sabha' && (
                    <>
                      <div className="grid grid-cols-2 gap-2">
                        <div>
                          <label className="block text-[11px] font-bold text-[#13202B] dark:text-white mb-1">
                            Gram Sabha Village
                          </label>
                          <input
                            type="text"
                            value={regVillage}
                            onChange={(e) => setRegVillage(e.target.value)}
                            className="w-full p-2.5 text-xs rounded-xl border border-gray-200 dark:border-[#2B5A46] bg-white dark:bg-[#173425] text-[#13202B] dark:text-white"
                            required
                          />
                        </div>
                        <div>
                          <label className="block text-[11px] font-bold text-[#13202B] dark:text-white mb-1">
                            District
                          </label>
                          <input
                            type="text"
                            value={regDistrict}
                            onChange={(e) => setRegDistrict(e.target.value)}
                            className="w-full p-2.5 text-xs rounded-xl border border-gray-200 dark:border-[#2B5A46] bg-white dark:bg-[#173425] text-[#13202B] dark:text-white"
                            required
                          />
                        </div>
                      </div>

                      <div>
                        <label className="block text-[11px] font-bold text-[#13202B] dark:text-white mb-1">
                          Contact Person & Title
                        </label>
                        <input
                          type="text"
                          value={regContactPerson}
                          onChange={(e) => setRegContactPerson(e.target.value)}
                          className="w-full p-2.5 text-xs rounded-xl border border-gray-200 dark:border-[#2B5A46] bg-white dark:bg-[#173425] text-[#13202B] dark:text-white"
                          required
                        />
                      </div>

                      <div>
                        <label className="block text-[11px] font-bold text-[#13202B] dark:text-white mb-1">
                          CFR Recognition Title Detail
                        </label>
                        <input
                          type="text"
                          value={regCfrDetails}
                          onChange={(e) => setRegCfrDetails(e.target.value)}
                          className="w-full p-2.5 text-xs rounded-xl border border-gray-200 dark:border-[#2B5A46] bg-white dark:bg-[#173425] text-[#13202B] dark:text-white"
                          required
                        />
                      </div>
                    </>
                  )}

                  {selectedSignupPortal === 'villager' && (
                    <div className="grid grid-cols-2 gap-2">
                      <div>
                        <label className="block text-[11px] font-bold text-[#13202B] dark:text-white mb-1">
                          Village
                        </label>
                        <input
                          type="text"
                          value={regVillage}
                          onChange={(e) => setRegVillage(e.target.value)}
                          className="w-full p-2.5 text-xs rounded-xl border border-gray-200 dark:border-[#2B5A46] bg-white dark:bg-[#173425] text-[#13202B] dark:text-white"
                          required
                        />
                      </div>
                      <div>
                        <label className="block text-[11px] font-bold text-[#13202B] dark:text-white mb-1">
                          Gram Sabha Affiliation
                        </label>
                        <input
                          type="text"
                          defaultValue="Gram Sabha Jawhar"
                          className="w-full p-2.5 text-xs rounded-xl border border-gray-200 dark:border-[#2B5A46] bg-white dark:bg-[#173425] text-[#13202B] dark:text-white"
                          required
                        />
                      </div>
                    </div>
                  )}

                  {selectedSignupPortal === 'buyer' && (
                    <div>
                      <label className="block text-[11px] font-bold text-[#13202B] dark:text-white mb-1">
                        Enterprise Name (Optional)
                      </label>
                      <input
                        type="text"
                        value={regBusinessName}
                        onChange={(e) => setRegBusinessName(e.target.value)}
                        className="w-full p-2.5 text-xs rounded-xl border border-gray-200 dark:border-[#2B5A46] bg-white dark:bg-[#173425] text-[#13202B] dark:text-white"
                      />
                    </div>
                  )}

                  <div>
                    <label className="block text-[11px] font-bold text-[#13202B] dark:text-white mb-1">
                      Phone Number
                    </label>
                    <input
                      type="text"
                      value={regPhone}
                      onChange={(e) => setRegPhone(e.target.value)}
                      className="w-full p-2.5 text-xs rounded-xl border border-gray-200 dark:border-[#2B5A46] bg-white dark:bg-[#173425] text-[#13202B] dark:text-white"
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-[11px] font-bold text-[#13202B] dark:text-white mb-1">
                      Set Secure Password
                    </label>
                    <input
                      type="password"
                      defaultValue="secret123"
                      className="w-full p-2.5 text-xs rounded-xl border border-gray-200 dark:border-[#2B5A46] bg-white dark:bg-[#173425] text-[#13202B] dark:text-white"
                      required
                    />
                  </div>

                  {selectedSignupPortal === 'gram_sabha' && (
                    <div className="p-3 bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-900 rounded-xl text-[11px] text-amber-800 dark:text-amber-200 flex items-start gap-2">
                      <ShieldCheck className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
                      <span>
                        <strong>Verification Note:</strong> Gram Sabha accounts are verified by the VanRozgar team before listings go live to protect buyers and keep the trust tag honest.
                      </span>
                    </div>
                  )}

                  <button
                    type="submit"
                    className="w-full py-3 rounded-xl bg-[#FF8D20] hover:bg-[#D96B00] text-white font-bold text-xs shadow-md mt-2 flex items-center justify-center gap-2"
                  >
                    <span>Proceed to Language Setup</span>
                    <ArrowRight className="w-4 h-4" />
                  </button>
                </form>
              </div>

              <div className="pt-2 text-center">
                <button
                  type="button"
                  onClick={() => setScreen('choose_portal')}
                  className="text-xs text-[#66737C] dark:text-[#AAB8B2]"
                >
                  ← Back to Portal Selection
                </button>
              </div>
            </div>
          )}

          {/* ================= SCREEN 5: LANGUAGE CHOICE ================= */}
          {screen === 'language' && (
            <div className="flex-1 p-6 flex flex-col justify-between bg-gradient-to-b from-[#1A4331] via-[#10261B] to-[#0C1B14] text-white">
              <div className="space-y-6 pt-6">
                <div className="text-center space-y-2">
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#FF8D20]/20 text-[#FF8D20]">
                    Screen 5: Language Selection
                  </span>
                  <h2 className="text-2xl font-bold font-['Manrope']">
                    Choose Your Language
                  </h2>
                  <p className="text-xs text-[#AAB8B2]">
                    Asked once on first open. Villagers should never need to read English to use the app.
                  </p>
                </div>

                <div className="space-y-3 pt-2">
                  <button
                    onClick={() => handleLanguageChoice('mr')}
                    className="w-full p-4 rounded-2xl bg-white/10 hover:bg-white/20 border-2 border-transparent hover:border-[#FF8D20] text-left transition-all flex items-center justify-between"
                  >
                    <div>
                      <div className="text-base font-bold text-white">मराठी</div>
                      <div className="text-xs text-[#AAB8B2]">महाराष्ट्र वनक्षेत्र व स्थानिक ग्रामसभांसाठी</div>
                    </div>
                    <span className="text-xs font-bold px-2 py-1 rounded bg-[#FF8D20] text-white">
                      निवडा
                    </span>
                  </button>

                  <button
                    onClick={() => handleLanguageChoice('hi')}
                    className="w-full p-4 rounded-2xl bg-white/10 hover:bg-white/20 border-2 border-transparent hover:border-[#FF8D20] text-left transition-all flex items-center justify-between"
                  >
                    <div>
                      <div className="text-base font-bold text-white">हिन्दी</div>
                      <div className="text-xs text-[#AAB8B2]">मध्य व उत्तर भारतीय वनक्षेत्रों हेतु</div>
                    </div>
                    <span className="text-xs font-bold px-2 py-1 rounded bg-[#FF8D20] text-white">
                      चुनें
                    </span>
                  </button>

                  <button
                    onClick={() => handleLanguageChoice('en')}
                    className="w-full p-4 rounded-2xl bg-white/10 hover:bg-white/20 border-2 border-transparent hover:border-[#FF8D20] text-left transition-all flex items-center justify-between"
                  >
                    <div>
                      <div className="text-base font-bold text-white">English</div>
                      <div className="text-xs text-[#AAB8B2]">Commercial buyers & institutional partners</div>
                    </div>
                    <span className="text-xs font-bold px-2 py-1 rounded bg-[#FF8D20] text-white">
                      Select
                    </span>
                  </button>
                </div>
              </div>

              <div className="text-center text-[11px] text-[#AAB8B2]">
                Can be updated anytime in Profile / Settings.
              </div>
            </div>
          )}

          {/* ================= SCREEN 6: MAIN APP PORTAL ================= */}
          {screen === 'app' && (
            <div className="flex-1 flex flex-col justify-between overflow-hidden">
              
              {/* Portal In-App Header */}
              <div className="p-3.5 bg-[#1A4331] text-white flex items-center justify-between shadow-md shrink-0">
                <div className="flex items-center gap-2.5">
                  <div className="w-8 h-8 rounded-full bg-[#FF8D20] text-white font-extrabold flex items-center justify-center text-xs shadow-sm">
                    {activePortal === 'gram_sabha' ? 'GS' : activePortal === 'villager' ? 'VI' : 'BY'}
                  </div>
                  <div>
                    <h3 className="text-xs font-bold leading-tight">
                      {activePortal === 'gram_sabha'
                        ? 'Gram Sabha Jawhar'
                        : activePortal === 'villager'
                        ? 'Kailash Mukne (Villager)'
                        : 'EcoVeda Herbal Labs (Buyer)'}
                    </h3>
                    <div className="text-[10px] text-[#AAB8B2] flex items-center gap-1">
                      <MapPin className="w-3 h-3 text-[#FF8D20]" />
                      <span>{activePortal === 'buyer' ? 'Mumbai HQ' : 'Jawhar, Palghar'}</span>
                      <span>•</span>
                      <span className="text-[#5FAE3B] font-semibold">CFR Active</span>
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-1.5">
                  <button
                    onClick={() => setScreen('choose_portal')}
                    title="Switch Portal Persona"
                    className="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white text-[10px] font-semibold flex items-center gap-1"
                  >
                    <RefreshCw className="w-3 h-3 text-[#FF8D20]" />
                    <span className="hidden sm:inline">Role</span>
                  </button>
                </div>
              </div>

              {/* Main Content Area (Scrollable) */}
              <div className="flex-1 overflow-y-auto p-4 space-y-4">
                
                {/* ----------------- GRAM SABHA PORTAL ----------------- */}
                {activePortal === 'gram_sabha' && (
                  <>
                    {/* GS Tab: Home (Dashboard) */}
                    {activeTab === 'home' && (
                      <div className="space-y-4">
                        {/* Summary Cards */}
                        <div className="grid grid-cols-2 gap-2.5">
                          <div className="p-3 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs">
                            <span className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">Active Listings</span>
                            <div className="text-xl font-bold text-[#1A4331] dark:text-white mt-0.5">
                              {listings.filter((l) => l.gramSabhaId === 'gs-jawhar').length} items
                            </div>
                          </div>

                          <div className="p-3 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs">
                            <span className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">Requests Waiting</span>
                            <div className="text-xl font-bold text-[#FF8D20] mt-0.5">
                              {requests.filter((r) => r.status === 'pending').length} pending
                            </div>
                          </div>

                          <div className="p-3 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs">
                            <span className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">Orders In Progress</span>
                            <div className="text-xl font-bold text-blue-500 mt-0.5">
                              {orders.filter((o) => o.status !== 'closed').length} active
                            </div>
                          </div>

                          <div className="p-3 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs">
                            <span className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">Total Earnings</span>
                            <div className="text-xl font-bold text-[#5FAE3B] mt-0.5">
                              ₹42,800
                            </div>
                          </div>
                        </div>

                        {/* Quick Button: Add new resource */}
                        <button
                          onClick={() => setShowAddListingModal(true)}
                          className="w-full py-3 rounded-2xl bg-[#FF8D20] hover:bg-[#D96B00] text-white font-bold text-xs shadow-md flex items-center justify-center gap-2"
                        >
                          <Plus className="w-4 h-4" />
                          <span>Add New Forest Resource</span>
                        </button>

                        {/* Latest Requests Preview */}
                        <div className="space-y-2">
                          <div className="flex items-center justify-between text-xs font-bold text-[#13202B] dark:text-white px-1">
                            <span>Latest Incoming Requests</span>
                            <button onClick={() => setActiveTab('requests')} className="text-[#FF8D20] text-[11px]">
                              View All ({requests.length})
                            </button>
                          </div>

                          {requests.slice(0, 2).map((req) => (
                            <div
                              key={req.id}
                              className="p-3 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs space-y-2"
                            >
                              <div className="flex items-start justify-between">
                                <div>
                                  <div className="text-xs font-bold text-[#13202B] dark:text-white">
                                    {req.resourceTitle}
                                  </div>
                                  <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                                    From: {req.buyerName} ({req.buyerPortal})
                                  </div>
                                </div>
                                <span className={`text-[9px] font-bold px-2 py-0.5 rounded-full ${req.status === 'pending' ? 'bg-amber-100 text-amber-800' : 'bg-emerald-100 text-[#1A4331]'}`}>
                                  {req.status}
                                </span>
                              </div>

                              <div className="flex items-center justify-between text-xs pt-1">
                                <span className="font-semibold text-[#1A4331] dark:text-[#5FAE3B]">
                                  Wanted: {req.requestedQuantity} {req.unit}
                                </span>
                                {req.status === 'pending' && (
                                  <button
                                    onClick={() => approveRequest(req.id)}
                                    className="px-3 py-1 bg-[#5FAE3B] text-white text-[10px] font-bold rounded-lg shadow-xs"
                                  >
                                    Approve
                                  </button>
                                )}
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}

                    {/* GS Tab: My Listings */}
                    {activeTab === 'listings' && (
                      <div className="space-y-3">
                        <div className="flex items-center justify-between">
                          <h4 className="text-xs font-bold text-[#13202B] dark:text-white uppercase tracking-wider">
                            Gram Sabha Catalog
                          </h4>
                          <button
                            onClick={() => setShowAddListingModal(true)}
                            className="px-2.5 py-1 rounded-lg bg-[#FF8D20] text-white text-[11px] font-bold flex items-center gap-1"
                          >
                            <Plus className="w-3.5 h-3.5" />
                            <span>Add</span>
                          </button>
                        </div>

                        {listings.map((l) => (
                          <div
                            key={l.id}
                            className="p-3.5 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs flex items-center justify-between gap-3"
                          >
                            <div className="flex items-center gap-3">
                              <div className="w-10 h-10 rounded-xl bg-[#1A4331]/10 p-1.5 flex items-center justify-center shrink-0">
                                <ResourceIcon type={l.iconType} className="w-6 h-6" />
                              </div>
                              <div>
                                <div className="text-xs font-bold text-[#13202B] dark:text-white line-clamp-1">
                                  {l.title}
                                </div>
                                <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                                  {l.quantity} {l.unit} available · ₹{l.pricePerUnit}/{l.unit}
                                </div>
                                <div className="text-[9px] text-[#5FAE3B] font-semibold mt-0.5">
                                  Mode: {l.mode}
                                </div>
                              </div>
                            </div>

                            <div className="text-right shrink-0">
                              <button
                                onClick={() => toggleListingStatus(l.id)}
                                className={`px-2.5 py-1 rounded-lg text-[10px] font-bold ${
                                  l.status === 'active'
                                    ? 'bg-emerald-100 dark:bg-emerald-950/60 text-[#1A4331] dark:text-[#5FAE3B]'
                                    : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300'
                                }`}
                              >
                                {l.status === 'active' ? 'Active' : 'Paused'}
                              </button>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}

                    {/* GS Tab: Requests (Approve / Reject / Counter) */}
                    {activeTab === 'requests' && (
                      <div className="space-y-3">
                        <h4 className="text-xs font-bold text-[#13202B] dark:text-white uppercase tracking-wider">
                          Purchase & Barter Requests
                        </h4>

                        {requests.map((r) => (
                          <div
                            key={r.id}
                            className="p-3.5 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs space-y-2.5"
                          >
                            <div className="flex items-start justify-between">
                              <div>
                                <span className="text-[9px] font-bold px-2 py-0.5 rounded-full bg-blue-100 dark:bg-blue-950 text-blue-700 dark:text-blue-300">
                                  {r.isBarter ? 'Barter Swap Proposal' : 'Purchase Order'}
                                </span>
                                <h5 className="text-xs font-bold text-[#13202B] dark:text-white mt-1">
                                  {r.resourceTitle}
                                </h5>
                                <p className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                                  Buyer: {r.buyerName} ({r.buyerVillage || 'Outside Buyer'})
                                </p>
                              </div>
                              <span className="text-[10px] font-bold px-2 py-0.5 rounded-md bg-gray-100 dark:bg-gray-800 text-[#13202B] dark:text-white">
                                {r.requestedQuantity} {r.unit}
                              </span>
                            </div>

                            {r.isLargeOrder && r.reason && (
                              <div className="p-2 rounded-xl bg-amber-50 dark:bg-amber-950/30 text-[10px] text-amber-900 dark:text-amber-200 border border-amber-200 dark:border-amber-900">
                                <strong>Stated Reason: </strong>"{r.reason}"
                              </div>
                            )}

                            {r.isBarter && r.offeredResource && (
                              <div className="p-2 rounded-xl bg-emerald-50 dark:bg-emerald-950/30 text-[10px] text-emerald-900 dark:text-emerald-200">
                                <strong>Offered in Exchange: </strong>{r.offeredQuantity} {r.offeredResource}
                              </div>
                            )}

                            {r.status === 'pending' && (
                              <div className="flex items-center gap-2 pt-1">
                                <button
                                  onClick={() => approveRequest(r.id)}
                                  className="flex-1 py-1.5 rounded-lg bg-[#5FAE3B] text-white text-xs font-bold shadow-xs hover:bg-emerald-600"
                                >
                                  Approve
                                </button>
                                <button
                                  onClick={() => {
                                    setCounterTargetReq(r.id);
                                    setCounterQty(r.requestedQuantity);
                                  }}
                                  className="flex-1 py-1.5 rounded-lg bg-[#FF8D20] text-white text-xs font-bold shadow-xs hover:bg-[#D96B00]"
                                >
                                  Counter
                                </button>
                                <button
                                  onClick={() => rejectRequest(r.id)}
                                  className="px-3 py-1.5 rounded-lg bg-red-100 text-red-700 dark:bg-red-950 dark:text-red-300 text-xs font-bold"
                                >
                                  Reject
                                </button>
                              </div>
                            )}

                            {r.status !== 'pending' && (
                              <div className="text-[10px] font-bold text-[#5FAE3B]">
                                Status: {r.status.toUpperCase()}
                              </div>
                            )}
                          </div>
                        ))}
                      </div>
                    )}

                    {/* GS Tab: Orders (Handover workflow) */}
                    {activeTab === 'orders' && (
                      <div className="space-y-3">
                        <h4 className="text-xs font-bold text-[#13202B] dark:text-white uppercase tracking-wider">
                          Orders & Driver Handover
                        </h4>

                        {orders.map((ord) => (
                          <div
                            key={ord.id}
                            className="p-3.5 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs space-y-2.5"
                          >
                            <div className="flex items-start justify-between">
                              <div>
                                <span className="text-[9px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 dark:bg-emerald-950/60 text-[#1A4331] dark:text-[#5FAE3B]">
                                  {ord.id.toUpperCase()}
                                </span>
                                <h5 className="text-xs font-bold text-[#13202B] dark:text-white mt-1">
                                  {ord.resourceTitle} ({ord.quantity} {ord.unit})
                                </h5>
                                <p className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                                  Buyer: {ord.buyerName} · Total: ₹{ord.totalAmount}
                                </p>
                              </div>
                              <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-blue-50 dark:bg-blue-950 text-blue-600 dark:text-blue-300">
                                {ord.status.replace('_', ' ')}
                              </span>
                            </div>

                            {/* Handover action */}
                            {!ord.handoverConfirmed ? (
                              <button
                                onClick={() => confirmHandover(ord.id)}
                                className="w-full py-2 rounded-xl bg-[#1A4331] hover:bg-[#2D765C] text-white text-xs font-bold shadow-xs flex items-center justify-center gap-1.5"
                              >
                                <CheckCircle className="w-3.5 h-3.5 text-[#5FAE3B]" />
                                <span>Confirm Handover to Driver</span>
                              </button>
                            ) : (
                              <div className="p-2 rounded-xl bg-emerald-50 dark:bg-emerald-950/40 text-[10px] text-[#5FAE3B] font-bold flex items-center gap-1.5">
                                <CheckCircle className="w-3.5 h-3.5" />
                                <span>Goods handed over to delivery driver</span>
                              </div>
                            )}
                          </div>
                        ))}
                      </div>
                    )}

                    {/* GS Tab: Profile */}
                    {activeTab === 'profile' && (
                      <div className="space-y-4">
                        <div className="p-4 rounded-3xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs space-y-3">
                          <div className="flex items-center gap-3">
                            <div className="w-12 h-12 rounded-full bg-[#1A4331] text-white flex items-center justify-center font-bold text-lg">
                              GS
                            </div>
                            <div>
                              <h4 className="text-sm font-bold text-[#13202B] dark:text-white">
                                Gram Sabha Jawhar
                              </h4>
                              <p className="text-xs text-[#5FAE3B] font-semibold flex items-center gap-1">
                                <ShieldCheck className="w-3.5 h-3.5" />
                                <span>CFR Verified Council #442/2014</span>
                              </p>
                            </div>
                          </div>

                          <div className="text-xs text-[#66737C] dark:text-[#AAB8B2] space-y-1 pt-1 border-t border-gray-100 dark:border-[#2B5A46]">
                            <div>District: Palghar, Maharashtra</div>
                            <div>Recognized CFR Forest Area: 420 Hectares</div>
                            <div>Secretary: Suresh Mukne (+91 98221 00000)</div>
                          </div>
                        </div>

                        {/* Language setting toggle */}
                        <div className="p-3.5 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] flex items-center justify-between text-xs">
                          <span>Language</span>
                          <div className="flex gap-1">
                            {(['mr', 'hi', 'en'] as const).map((l) => (
                              <button
                                key={l}
                                onClick={() => setLanguage(l)}
                                className={`px-2 py-1 rounded text-[10px] font-bold ${
                                  language === l ? 'bg-[#FF8D20] text-white' : 'bg-gray-100 dark:bg-gray-800'
                                }`}
                              >
                                {l.toUpperCase()}
                              </button>
                            ))}
                          </div>
                        </div>

                        <button
                          onClick={() => setScreen('login')}
                          className="w-full py-2.5 rounded-xl border border-red-300 dark:border-red-900 text-red-600 dark:text-red-400 text-xs font-bold flex items-center justify-center gap-2"
                        >
                          <LogOut className="w-4 h-4" />
                          <span>Sign Out</span>
                        </button>
                      </div>
                    )}
                  </>
                )}

                {/* ----------------- VILLAGER PORTAL ----------------- */}
                {activePortal === 'villager' && (
                  <>
                    {/* Villager Tab: Home */}
                    {activeTab === 'home' && (
                      <div className="space-y-4">
                        {/* Search bar at top */}
                        <div
                          onClick={() => setActiveTab('search')}
                          className="p-3 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs flex items-center gap-2.5 text-xs text-[#66737C] dark:text-[#AAB8B2] cursor-pointer"
                        >
                          <Search className="w-4 h-4 text-[#FF8D20]" />
                          <span>{t.common.searchPlaceholder}</span>
                        </div>

                        {/* "Earn with delivery" hero card */}
                        <div className="p-4 rounded-3xl bg-gradient-to-r from-[#1A4331] to-[#2D765C] text-white shadow-lg space-y-2.5">
                          <div className="flex items-center justify-between">
                            <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#FF8D20] text-white uppercase tracking-wider">
                              Livelihood Gig
                            </span>
                            <Truck className="w-5 h-5 text-amber-300" />
                          </div>
                          <h4 className="text-sm font-bold font-['Manrope']">
                            {t.common.earnWithDelivery}
                          </h4>
                          <p className="text-xs text-[#AAB8B2] leading-relaxed">
                            Deliver forest produce between nearby Gram Sabhas. Earn per-trip pay with your tempo, pickup truck, or motorcycle.
                          </p>

                          {deliveryPartner.status === 'not_registered' && (
                            <button
                              onClick={() => setShowDriverRegModal(true)}
                              className="px-4 py-2 rounded-xl bg-[#FF8D20] hover:bg-[#D96B00] text-white text-xs font-bold shadow-md"
                            >
                              Register Your Vehicle
                            </button>
                          )}

                          {deliveryPartner.status === 'pending_review' && (
                            <div className="flex items-center justify-between pt-1">
                              <span className="text-xs text-amber-300 font-bold flex items-center gap-1">
                                <Clock className="w-3.5 h-3.5" />
                                <span>Under Team Review</span>
                              </span>
                              <button
                                onClick={simulateTeamApproval}
                                className="px-2.5 py-1 rounded-lg bg-white/20 text-white text-[10px] font-bold hover:bg-white/30"
                              >
                                Simulate Team Approval
                              </button>
                            </div>
                          )}

                          {deliveryPartner.status === 'approved' && (
                            <div className="flex items-center justify-between pt-1">
                              <span className="text-xs text-[#5FAE3B] font-bold flex items-center gap-1">
                                <CheckCircle className="w-3.5 h-3.5" />
                                <span>Approved Partner</span>
                              </span>
                              <button
                                onClick={() => setActiveTab('deliveries')}
                                className="px-3 py-1 rounded-lg bg-[#FF8D20] text-white text-[11px] font-bold"
                              >
                                Open My Deliveries
                              </button>
                            </div>
                          )}
                        </div>

                        {/* "Near you" row */}
                        <div className="space-y-2">
                          <div className="flex items-center justify-between text-xs font-bold text-[#13202B] dark:text-white px-1">
                            <span>Near You (Closest Gram Sabhas)</span>
                            <button onClick={() => setActiveTab('search')} className="text-[#FF8D20] text-[11px]">
                              Browse All
                            </button>
                          </div>

                          <div className="space-y-2">
                            {listings.slice(0, 3).map((item) => (
                              <div
                                key={item.id}
                                onClick={() => setSelectedListing(item)}
                                className="p-3 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs flex items-center justify-between gap-3 cursor-pointer hover:border-[#FF8D20]"
                              >
                                <div className="flex items-center gap-2.5 min-w-0">
                                  <div className="w-8 h-8 rounded-xl bg-gray-100 dark:bg-black/20 p-1 flex items-center justify-center shrink-0">
                                    <ResourceIcon type={item.iconType} className="w-5 h-5" />
                                  </div>
                                  <div className="min-w-0">
                                    <div className="text-xs font-bold text-[#13202B] dark:text-white truncate">
                                      {item.title}
                                    </div>
                                    <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                                      {item.gramSabhaName} · <strong className="text-[#5FAE3B]">{item.distanceKm} km</strong>
                                    </div>
                                  </div>
                                </div>
                                <div className="text-right shrink-0">
                                  <div className="text-xs font-extrabold text-[#1A4331] dark:text-[#5FAE3B]">
                                    ₹{item.pricePerUnit}
                                  </div>
                                  <span className="text-[9px] text-[#FF8D20] font-bold">
                                    {item.mode}
                                  </span>
                                </div>
                              </div>
                            ))}
                          </div>
                        </div>
                      </div>
                    )}

                    {/* Villager Tab: Search */}
                    {activeTab === 'search' && (
                      <div className="space-y-3">
                        <h4 className="text-xs font-bold text-[#13202B] dark:text-white uppercase tracking-wider">
                          Marketplace Search
                        </h4>

                        <div className="space-y-2.5">
                          {listings.map((item) => (
                            <div
                              key={item.id}
                              onClick={() => setSelectedListing(item)}
                              className="p-3.5 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs flex items-center justify-between gap-3 cursor-pointer hover:border-[#FF8D20]"
                            >
                              <div className="flex items-center gap-3 min-w-0">
                                <div className="w-9 h-9 rounded-xl bg-gray-100 dark:bg-black/20 p-1.5 flex items-center justify-center shrink-0">
                                  <ResourceIcon type={item.iconType} className="w-6 h-6" />
                                </div>
                                <div className="min-w-0">
                                  <div className="text-xs font-bold text-[#13202B] dark:text-white truncate">
                                    {item.title}
                                  </div>
                                  <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                                    {item.gramSabhaName} · {item.distanceKm} km
                                  </div>
                                </div>
                              </div>
                              <div className="text-right shrink-0">
                                <div className="text-xs font-extrabold text-[#1A4331] dark:text-[#5FAE3B]">
                                  ₹{item.pricePerUnit}/{item.unit}
                                </div>
                                <span className="text-[9px] px-1.5 py-0.5 rounded bg-[#FF8D20]/15 text-[#FF8D20] font-bold">
                                  {item.mode}
                                </span>
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}

                    {/* Villager Tab: My Requests */}
                    {activeTab === 'requests' && (
                      <div className="space-y-3">
                        <h4 className="text-xs font-bold text-[#13202B] dark:text-white uppercase tracking-wider">
                          My Purchase & Barter Requests
                        </h4>

                        {requests.filter((r) => r.buyerPortal === 'villager').map((r) => (
                          <div
                            key={r.id}
                            className="p-3.5 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs space-y-2"
                          >
                            <div className="flex items-start justify-between">
                              <div>
                                <h5 className="text-xs font-bold text-[#13202B] dark:text-white">
                                  {r.resourceTitle}
                                </h5>
                                <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                                  To: {r.sellerGramSabhaName} · {r.requestedQuantity} {r.unit}
                                </div>
                              </div>
                              <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${
                                r.status === 'approved'
                                  ? 'bg-emerald-100 text-[#1A4331]'
                                  : r.status === 'countered'
                                  ? 'bg-orange-100 text-[#FF8D20]'
                                  : 'bg-amber-100 text-amber-800'
                              }`}>
                                {r.status}
                              </span>
                            </div>

                            {/* Counter offer accept/decline buttons */}
                            {r.status === 'countered' && r.counterOffer && (
                              <div className="p-2.5 rounded-xl bg-orange-50 dark:bg-orange-950/30 border border-orange-200 dark:border-orange-900 space-y-2">
                                <div className="text-[10px] text-amber-900 dark:text-amber-200">
                                  <strong>Counter Offer from Seller: </strong>
                                  {r.counterOffer.quantity} units @ ₹{r.counterOffer.pricePerUnit} ("{r.counterOffer.note}")
                                </div>
                                <div className="flex gap-2">
                                  <button
                                    onClick={() => acceptCounterOffer(r.id)}
                                    className="flex-1 py-1 bg-[#5FAE3B] text-white text-[10px] font-bold rounded-lg"
                                  >
                                    Accept Counter Offer
                                  </button>
                                  <button
                                    onClick={() => rejectRequest(r.id)}
                                    className="px-2 py-1 bg-gray-200 dark:bg-gray-700 text-xs text-gray-700 dark:text-white rounded-lg"
                                  >
                                    Decline
                                  </button>
                                </div>
                              </div>
                            )}
                          </div>
                        ))}
                      </div>
                    )}

                    {/* Villager Tab: Orders */}
                    {activeTab === 'orders' && (
                      <div className="space-y-3">
                        <h4 className="text-xs font-bold text-[#13202B] dark:text-white uppercase tracking-wider">
                          My Orders
                        </h4>

                        {orders.map((ord) => (
                          <div
                            key={ord.id}
                            className="p-3.5 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs space-y-2"
                          >
                            <div className="flex items-start justify-between">
                              <div>
                                <h5 className="text-xs font-bold text-[#13202B] dark:text-white">
                                  {ord.resourceTitle}
                                </h5>
                                <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                                  From {ord.sellerName} · Total: ₹{ord.totalAmount}
                                </div>
                              </div>
                              <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-blue-100 text-blue-700">
                                {ord.status.replace('_', ' ')}
                              </span>
                            </div>

                            {/* Confirm Received action */}
                            {ord.status === 'delivered' && !ord.receivedConfirmed && (
                              <button
                                onClick={() => setRatingOrderTarget(ord.id)}
                                className="w-full py-2 rounded-xl bg-[#5FAE3B] hover:bg-emerald-600 text-white text-xs font-bold flex items-center justify-center gap-1.5 shadow-xs"
                              >
                                <CheckCircle className="w-4 h-4" />
                                <span>Confirm Received & Rate Seller</span>
                              </button>
                            )}

                            {ord.receivedConfirmed && (
                              <div className="text-[10px] text-[#5FAE3B] font-bold flex items-center gap-1">
                                <CheckCircle className="w-3.5 h-3.5" />
                                <span>Order completed & rated ★★★★★</span>
                              </div>
                            )}
                          </div>
                        ))}
                      </div>
                    )}

                    {/* Villager Tab: Deliveries (if approved) */}
                    {activeTab === 'deliveries' && (
                      <div className="space-y-4">
                        {/* Status bar */}
                        <div className="p-3.5 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] flex items-center justify-between text-xs">
                          <div>
                            <div className="font-bold text-[#13202B] dark:text-white">
                              Driver: {deliveryPartner.name}
                            </div>
                            <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                              {deliveryPartner.vehicleNumber} ({deliveryPartner.vehicleType})
                            </div>
                          </div>

                          <button
                            onClick={toggleDriverAvailability}
                            className="flex items-center gap-1 text-[11px] font-bold text-[#5FAE3B]"
                          >
                            <span>{deliveryPartner.isAvailable ? 'Online' : 'Offline'}</span>
                            {deliveryPartner.isAvailable ? <ToggleRight className="w-6 h-6" /> : <ToggleLeft className="w-6 h-6 text-gray-400" />}
                          </button>
                        </div>

                        {/* Available Jobs list */}
                        <div className="space-y-2">
                          <h5 className="text-xs font-bold text-[#13202B] dark:text-white uppercase tracking-wider">
                            Available Village Jobs
                          </h5>

                          {deliveryJobs.filter((j) => j.status === 'available').map((j) => (
                            <div
                              key={j.id}
                              className="p-3.5 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs space-y-2"
                            >
                              <div className="flex justify-between items-start">
                                <div>
                                  <div className="text-xs font-bold text-[#13202B] dark:text-white">
                                    {j.resourceTitle}
                                  </div>
                                  <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                                    Route: {j.pickupVillage} → {j.dropVillage}
                                  </div>
                                </div>
                                <span className="text-sm font-extrabold text-[#5FAE3B]">
                                  ₹{j.estimatedPay}
                                </span>
                              </div>

                              <button
                                onClick={() => acceptDeliveryJob(j.id)}
                                className="w-full py-2 rounded-xl bg-[#FF8D20] text-white text-xs font-bold shadow-xs hover:bg-[#D96B00]"
                              >
                                Accept Job
                              </button>
                            </div>
                          ))}
                        </div>

                        {/* Active Job Stepper */}
                        {deliveryJobs.filter((j) => j.assignedPartnerId === deliveryPartner.id && j.status !== 'delivered').map((activeJ) => (
                          <div
                            key={activeJ.id}
                            className="p-3.5 rounded-2xl bg-amber-50 dark:bg-amber-950/40 border border-amber-300 dark:border-amber-700/60 space-y-2.5"
                          >
                            <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#FF8D20] text-white">
                              Active Job: {activeJ.id}
                            </span>
                            <div className="text-xs font-bold text-[#13202B] dark:text-white">
                              {activeJ.resourceTitle}
                            </div>
                            <div className="text-[11px] text-[#66737C] dark:text-[#AAB8B2]">
                              Status: <strong className="text-[#FF8D20] uppercase">{activeJ.status.replace('_', ' ')}</strong>
                            </div>

                            <div className="grid grid-cols-2 gap-2 pt-1">
                              {activeJ.status === 'accepted' && (
                                <button
                                  onClick={() => updateJobProgress(activeJ.id, 'picked_up')}
                                  className="w-full py-1.5 rounded-lg bg-[#1A4331] text-white text-[11px] font-bold"
                                >
                                  Mark Picked Up
                                </button>
                              )}
                              {activeJ.status === 'picked_up' && (
                                <button
                                  onClick={() => updateJobProgress(activeJ.id, 'in_transit')}
                                  className="w-full py-1.5 rounded-lg bg-blue-600 text-white text-[11px] font-bold"
                                >
                                  Mark In Transit
                                </button>
                              )}
                              {activeJ.status === 'in_transit' && (
                                <button
                                  onClick={() => updateJobProgress(activeJ.id, 'delivered')}
                                  className="w-full py-1.5 rounded-lg bg-[#5FAE3B] text-white text-[11px] font-bold"
                                >
                                  Mark Delivered
                                </button>
                              )}
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </>
                )}

                {/* ----------------- GENERAL BUYER PORTAL ----------------- */}
                {activePortal === 'buyer' && (
                  <div className="space-y-4">
                    {/* Buyer Home: Bulk & Group Listings Shown First */}
                    <div className="p-3 rounded-2xl bg-blue-50 dark:bg-blue-950/40 border border-blue-200 dark:border-blue-900 text-xs text-blue-900 dark:text-blue-200">
                      <strong>Enterprise Portal: </strong>
                      Showing bulk group listings first. Barter is disabled for commercial accounts. Large orders (≥25 units) require a verified sustainability harvest reason.
                    </div>

                    <div className="space-y-2.5">
                      {listings.filter((l) => l.isGroupListing).map((groupL) => (
                        <div
                          key={groupL.id}
                          onClick={() => setSelectedListing(groupL)}
                          className="p-4 rounded-3xl bg-white dark:bg-[#173425] border-2 border-emerald-300 dark:border-emerald-700 shadow-md cursor-pointer space-y-2 hover:border-[#FF8D20]"
                        >
                          <div className="flex items-center justify-between">
                            <span className="text-[10px] font-extrabold px-2 py-0.5 rounded-full bg-emerald-100 dark:bg-emerald-950 text-[#1A4331] dark:text-[#5FAE3B]">
                              Bulk Multi-Producer Pool
                            </span>
                            <span className="text-xs font-bold text-[#FF8D20]">
                              {groupL.quantity} {groupL.unit} in stock
                            </span>
                          </div>
                          <h4 className="text-sm font-bold text-[#13202B] dark:text-white">
                            {groupL.title}
                          </h4>
                          <p className="text-xs text-[#66737C] dark:text-[#AAB8B2]">
                            Pooled across Jawhar, Mokhada & Vikramgad. Single bulk procurement contract.
                          </p>
                          <div className="text-xs font-extrabold text-[#1A4331] dark:text-[#5FAE3B]">
                            ₹{groupL.pricePerUnit}/{groupL.unit}
                          </div>
                        </div>
                      ))}

                      {/* General Catalog */}
                      {listings.filter((l) => !l.isGroupListing).slice(0, 4).map((item) => (
                        <div
                          key={item.id}
                          onClick={() => setSelectedListing(item)}
                          className="p-3.5 rounded-2xl bg-white dark:bg-[#173425] border border-gray-200 dark:border-[#2B5A46] shadow-xs flex items-center justify-between gap-3 cursor-pointer hover:border-[#FF8D20]"
                        >
                          <div>
                            <div className="text-xs font-bold text-[#13202B] dark:text-white">
                              {item.title}
                            </div>
                            <div className="text-[10px] text-[#66737C] dark:text-[#AAB8B2]">
                              {item.gramSabhaName} · {item.quantity} {item.unit} available
                            </div>
                          </div>
                          <div className="text-right">
                            <div className="text-xs font-extrabold text-[#1A4331] dark:text-[#5FAE3B]">
                              ₹{item.pricePerUnit}
                            </div>
                            <span className="text-[9px] text-[#5FAE3B] font-bold">Purchase Only</span>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

              </div>

              {/* Mobile App Bottom Navigation Bar */}
              <div className="bg-white dark:bg-[#0C1B14] border-t border-gray-200 dark:border-[#2B5A46] py-2 px-3 flex items-center justify-around shrink-0 z-20">
                {activePortal === 'gram_sabha' && (
                  <>
                    <button
                      onClick={() => setActiveTab('home')}
                      className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'home' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                    >
                      <Home className="w-4 h-4" />
                      <span>Home</span>
                    </button>
                    <button
                      onClick={() => setActiveTab('listings')}
                      className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'listings' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                    >
                      <Layers className="w-4 h-4" />
                      <span>My Listings</span>
                    </button>
                    <button
                      onClick={() => setActiveTab('requests')}
                      className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'requests' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                    >
                      <Scale className="w-4 h-4" />
                      <span>Requests</span>
                    </button>
                    <button
                      onClick={() => setActiveTab('orders')}
                      className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'orders' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                    >
                      <ShoppingBag className="w-4 h-4" />
                      <span>Orders</span>
                    </button>
                    <button
                      onClick={() => setActiveTab('profile')}
                      className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'profile' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                    >
                      <User className="w-4 h-4" />
                      <span>Profile</span>
                    </button>
                  </>
                )}

                {activePortal === 'villager' && (
                  <>
                    <button
                      onClick={() => setActiveTab('home')}
                      className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'home' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                    >
                      <Home className="w-4 h-4" />
                      <span>Home</span>
                    </button>
                    <button
                      onClick={() => setActiveTab('search')}
                      className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'search' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                    >
                      <Search className="w-4 h-4" />
                      <span>Search</span>
                    </button>
                    <button
                      onClick={() => setActiveTab('requests')}
                      className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'requests' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                    >
                      <Scale className="w-4 h-4" />
                      <span>Requests</span>
                    </button>
                    <button
                      onClick={() => setActiveTab('orders')}
                      className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'orders' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                    >
                      <ShoppingBag className="w-4 h-4" />
                      <span>Orders</span>
                    </button>
                    {deliveryPartner.status === 'approved' && (
                      <button
                        onClick={() => setActiveTab('deliveries')}
                        className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'deliveries' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                      >
                        <Truck className="w-4 h-4" />
                        <span>Deliveries</span>
                      </button>
                    )}
                  </>
                )}

                {activePortal === 'buyer' && (
                  <>
                    <button
                      onClick={() => setActiveTab('home')}
                      className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'home' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                    >
                      <Home className="w-4 h-4" />
                      <span>Bulk Home</span>
                    </button>
                    <button
                      onClick={() => setActiveTab('search')}
                      className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'search' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                    >
                      <Search className="w-4 h-4" />
                      <span>Catalog</span>
                    </button>
                    <button
                      onClick={() => setActiveTab('orders')}
                      className={`flex flex-col items-center gap-1 text-[10px] font-bold ${activeTab === 'orders' ? 'text-[#FF8D20]' : 'text-[#66737C] dark:text-[#AAB8B2]'}`}
                    >
                      <ShoppingBag className="w-4 h-4" />
                      <span>Orders</span>
                    </button>
                  </>
                )}
              </div>

            </div>
          )}

        </div>

        {/* ================= MODAL: ADD LISTING (GRAM SABHA) ================= */}
        {showAddListingModal && (
          <div className="absolute inset-0 z-50 bg-black/70 backdrop-blur-xs flex items-center justify-center p-3">
            <div className="bg-white dark:bg-[#173425] rounded-3xl p-5 max-w-sm w-full border border-gray-200 dark:border-[#2B5A46] shadow-2xl space-y-3 max-h-[90%] overflow-y-auto">
              <div className="flex items-center justify-between pb-2 border-b border-gray-200 dark:border-[#2B5A46]">
                <h4 className="text-sm font-bold text-[#13202B] dark:text-white">
                  Add Forest Resource Listing
                </h4>
                <button onClick={() => setShowAddListingModal(false)}>
                  <X className="w-4 h-4" />
                </button>
              </div>

              <form onSubmit={handleCreateListingSubmit} className="space-y-2.5 text-xs">
                <div>
                  <label className="block font-bold mb-1">Resource Name</label>
                  <input
                    type="text"
                    value={newTitle}
                    onChange={(e) => setNewTitle(e.target.value)}
                    placeholder="e.g. Deseeded Wild Tamarind"
                    className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                    required
                  />
                </div>

                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="block font-bold mb-1">Category</label>
                    <select
                      value={newCategory}
                      onChange={(e) => setNewCategory(e.target.value)}
                      className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                    >
                      <option value="forest_produce">Forest Produce</option>
                      <option value="medicinal">Medicinal Plants</option>
                      <option value="handicrafts">Handicrafts</option>
                      <option value="water_land">Water & Land</option>
                      <option value="others">Others</option>
                    </select>
                  </div>
                  <div>
                    <label className="block font-bold mb-1">Mode</label>
                    <select
                      value={newMode}
                      onChange={(e) => setNewMode(e.target.value as any)}
                      className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                    >
                      <option value="both">Sell & Barter</option>
                      <option value="sell">Sell Only</option>
                      <option value="barter">Barter Only</option>
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="block font-bold mb-1">Quantity</label>
                    <input
                      type="number"
                      min="1"
                      value={newQty}
                      onChange={(e) => setNewQty(Number(e.target.value))}
                      className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                    />
                  </div>
                  <div>
                    <label className="block font-bold mb-1">Unit</label>
                    <input
                      type="text"
                      value={newUnit}
                      onChange={(e) => setNewUnit(e.target.value)}
                      className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                    />
                  </div>
                </div>

                <div>
                  <div className="flex justify-between items-center mb-1">
                    <label className="font-bold">Price per Unit (₹)</label>
                    <span className="text-[10px] text-[#5FAE3B]">
                      Fair Guide: ₹{Math.round(newPrice * 0.9)} - ₹{Math.round(newPrice * 1.15)}
                    </span>
                  </div>
                  <input
                    type="number"
                    min="1"
                    value={newPrice}
                    onChange={(e) => setNewPrice(Number(e.target.value))}
                    className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                  />
                </div>

                <div>
                  <label className="block font-bold mb-1">Forest Source Area</label>
                  <input
                    type="text"
                    value={newSourceArea}
                    onChange={(e) => setNewSourceArea(e.target.value)}
                    className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                  />
                </div>

                <button
                  type="submit"
                  className="w-full py-2.5 rounded-xl bg-[#FF8D20] text-white font-bold shadow-md hover:bg-[#D96B00] mt-1"
                >
                  Publish Listing
                </button>
              </form>
            </div>
          </div>
        )}

        {/* ================= MODAL: DRIVER REGISTRATION (VILLAGER) ================= */}
        {showDriverRegModal && (
          <div className="absolute inset-0 z-50 bg-black/70 backdrop-blur-xs flex items-center justify-center p-3">
            <div className="bg-white dark:bg-[#173425] rounded-3xl p-5 max-w-sm w-full border border-gray-200 dark:border-[#2B5A46] shadow-2xl space-y-3 max-h-[90%] overflow-y-auto">
              <div className="flex items-center justify-between pb-2 border-b border-gray-200 dark:border-[#2B5A46]">
                <h4 className="text-sm font-bold text-[#13202B] dark:text-white">
                  Become a Delivery Partner
                </h4>
                <button onClick={() => setShowDriverRegModal(false)}>
                  <X className="w-4 h-4" />
                </button>
              </div>

              <form onSubmit={handleDriverRegSubmit} className="space-y-2.5 text-xs">
                <div>
                  <label className="block font-bold mb-1">Vehicle Type</label>
                  <select
                    value={driverVehicleType}
                    onChange={(e) => setDriverVehicleType(e.target.value as any)}
                    className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                  >
                    <option value="pickup_truck">Pickup Truck (e.g. Bolero/Tata Ace)</option>
                    <option value="tempo">Tempo / 3-Wheeler Commercial</option>
                    <option value="bike">Motorcycle with Carrier Rack</option>
                    <option value="tractor">Village Tractor Trolley</option>
                  </select>
                </div>

                <div>
                  <label className="block font-bold mb-1">Vehicle Registration Plate Number</label>
                  <input
                    type="text"
                    value={driverVehicleNumber}
                    onChange={(e) => setDriverVehicleNumber(e.target.value)}
                    className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                    required
                  />
                </div>

                <div>
                  <label className="block font-bold mb-1">Carrying Capacity (kg)</label>
                  <input
                    type="number"
                    value={driverCapacity}
                    onChange={(e) => setDriverCapacity(Number(e.target.value))}
                    className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                    required
                  />
                </div>

                <div>
                  <label className="block font-bold mb-1">Driving Licence Number</label>
                  <input
                    type="text"
                    value={driverLicence}
                    onChange={(e) => setDriverLicence(e.target.value)}
                    className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                    required
                  />
                </div>

                <div>
                  <label className="block font-bold mb-1">Covered Village Routes</label>
                  <input
                    type="text"
                    value={driverAreas}
                    onChange={(e) => setDriverAreas(e.target.value)}
                    className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                  />
                </div>

                <button
                  type="submit"
                  className="w-full py-2.5 rounded-xl bg-[#FF8D20] text-white font-bold shadow-md hover:bg-[#D96B00] mt-1"
                >
                  Submit Application for Review
                </button>
              </form>
            </div>
          </div>
        )}

        {/* ================= MODAL: COUNTER OFFER DIALOG ================= */}
        {counterTargetReq && (
          <div className="absolute inset-0 z-50 bg-black/70 backdrop-blur-xs flex items-center justify-center p-3">
            <div className="bg-white dark:bg-[#173425] rounded-3xl p-5 max-w-sm w-full border border-gray-200 dark:border-[#2B5A46] shadow-2xl space-y-3">
              <h4 className="text-sm font-bold text-[#13202B] dark:text-white">
                Propose Counter-Offer
              </h4>
              <div className="space-y-2 text-xs">
                <div>
                  <label className="block font-bold mb-1">Adjusted Quantity</label>
                  <input
                    type="number"
                    value={counterQty}
                    onChange={(e) => setCounterQty(Number(e.target.value))}
                    className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                  />
                </div>
                <div>
                  <label className="block font-bold mb-1">Adjusted Price per Unit (₹)</label>
                  <input
                    type="number"
                    value={counterPrice}
                    onChange={(e) => setCounterPrice(Number(e.target.value))}
                    className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                  />
                </div>
                <div>
                  <label className="block font-bold mb-1">Note to Buyer</label>
                  <textarea
                    rows={2}
                    value={counterNote}
                    onChange={(e) => setCounterNote(e.target.value)}
                    className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                  />
                </div>
              </div>

              <div className="flex gap-2 pt-2">
                <button
                  onClick={() => setCounterTargetReq(null)}
                  className="flex-1 py-2 rounded-xl text-xs font-semibold bg-gray-100 dark:bg-gray-800 text-[#66737C]"
                >
                  Cancel
                </button>
                <button
                  onClick={() => {
                    sendCounterOffer(counterTargetReq, {
                      quantity: counterQty,
                      pricePerUnit: counterPrice,
                      note: counterNote,
                    });
                    setCounterTargetReq(null);
                  }}
                  className="flex-1 py-2 rounded-xl text-xs font-bold bg-[#FF8D20] text-white"
                >
                  Send Counter
                </button>
              </div>
            </div>
          </div>
        )}

        {/* ================= MODAL: RATING DIALOG ================= */}
        {ratingOrderTarget && (
          <div className="absolute inset-0 z-50 bg-black/70 backdrop-blur-xs flex items-center justify-center p-3">
            <div className="bg-white dark:bg-[#173425] rounded-3xl p-5 max-w-sm w-full border border-gray-200 dark:border-[#2B5A46] shadow-2xl space-y-3">
              <h4 className="text-sm font-bold text-[#13202B] dark:text-white">
                Confirm Receipt & Rate Experience
              </h4>
              <p className="text-[11px] text-[#66737C] dark:text-[#AAB8B2]">
                Ratings are only possible on confirmed orders. Sellers and delivery partners are rated separately.
              </p>

              <div className="space-y-3 text-xs">
                <div>
                  <label className="block font-bold mb-1">Gram Sabha Produce Quality (1–5 Stars)</label>
                  <div className="flex gap-1">
                    {[1, 2, 3, 4, 5].map((num) => (
                      <button
                        key={num}
                        type="button"
                        onClick={() => setRatingStars(num)}
                        className={`p-1.5 rounded-lg ${num <= ratingStars ? 'text-[#FF8D20]' : 'text-gray-300'}`}
                      >
                        <Star className="w-5 h-5 fill-current" />
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="block font-bold mb-1">Delivery Driver Service (1–5 Stars)</label>
                  <div className="flex gap-1">
                    {[1, 2, 3, 4, 5].map((num) => (
                      <button
                        key={num}
                        type="button"
                        onClick={() => setDriverRating(num)}
                        className={`p-1.5 rounded-lg ${num <= driverRating ? 'text-[#5FAE3B]' : 'text-gray-300'}`}
                      >
                        <Star className="w-5 h-5 fill-current" />
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="block font-bold mb-1">Review Note</label>
                  <textarea
                    rows={2}
                    value={reviewNote}
                    onChange={(e) => setReviewNote(e.target.value)}
                    className="w-full p-2 rounded-lg border border-gray-200 dark:border-[#2B5A46] bg-gray-50 dark:bg-[#10261B]"
                  />
                </div>
              </div>

              <div className="flex gap-2 pt-2">
                <button
                  onClick={() => setRatingOrderTarget(null)}
                  className="flex-1 py-2 rounded-xl text-xs font-semibold bg-gray-100 dark:bg-gray-800 text-[#66737C]"
                >
                  Cancel
                </button>
                <button
                  onClick={() => {
                    confirmReceived(ratingOrderTarget, ratingStars, reviewNote, driverRating);
                    setRatingOrderTarget(null);
                  }}
                  className="flex-1 py-2 rounded-xl text-xs font-bold bg-[#5FAE3B] text-white"
                >
                  Confirm & Submit
                </button>
              </div>
            </div>
          </div>
        )}

      </div>
    </div>
  );
};
