/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState } from 'react';
import { MarketplaceProvider, useMarketplace } from './context/MarketplaceContext';
import { Header } from './components/Header';
import { WindowTabBar } from './components/WindowTabBar';
import { TabWindowContainer } from './components/TabWindowContainer';
import { ToastContainer } from './components/ToastContainer';
import { ListingDetailModal } from './components/ListingDetailModal';
import { HeroSection } from './sections/HeroSection';
import { FeaturedProductsSection } from './sections/FeaturedProductsSection';
import { EcosystemSection } from './sections/EcosystemSection';
import { ResourceExplorerSection } from './sections/ResourceExplorerSection';
import { HowItWorksSection } from './sections/HowItWorksSection';
import { PortalsComparisonSection } from './sections/PortalsComparisonSection';
import { BarterAndFairPriceSection } from './sections/BarterAndFairPriceSection';
import { GroupSellingSection } from './sections/GroupSellingSection';
import { DeliveryJourneySection } from './sections/DeliveryJourneySection';
import { ImpactSection } from './sections/ImpactSection';
import { TrustSustainabilitySection } from './sections/TrustSustainabilitySection';
import { OpenDecisionsSection } from './sections/OpenDecisionsSection';
import { Footer } from './sections/Footer';
import { VanMitraPreloader } from './components/preloader/VanMitraPreloader';

function MainTabRouter() {
  const { activeTab } = useMarketplace();

  switch (activeTab) {
    case 'overview':
      return (
        <TabWindowContainer>
          <HeroSection />
          <FeaturedProductsSection />
        </TabWindowContainer>
      );

    case 'ecosystem':
      return (
        <TabWindowContainer>
          <EcosystemSection />
        </TabWindowContainer>
      );

    case 'how_it_works':
      return (
        <TabWindowContainer>
          <HowItWorksSection />
        </TabWindowContainer>
      );

    case 'portals':
      return (
        <TabWindowContainer>
          <PortalsComparisonSection />
        </TabWindowContainer>
      );

    case 'marketplace':
      return (
        <TabWindowContainer>
          <ResourceExplorerSection />
        </TabWindowContainer>
      );

    case 'barter':
      return (
        <TabWindowContainer>
          <BarterAndFairPriceSection />
          <GroupSellingSection />
        </TabWindowContainer>
      );

    case 'delivery':
      return (
        <TabWindowContainer>
          <DeliveryJourneySection />
        </TabWindowContainer>
      );

    case 'impact':
      return (
        <TabWindowContainer>
          <ImpactSection />
          <TrustSustainabilitySection />
          <OpenDecisionsSection />
        </TabWindowContainer>
      );

    default:
      return (
        <TabWindowContainer>
          <HeroSection />
          <FeaturedProductsSection />
        </TabWindowContainer>
      );
  }
}

function AppContent({ onReplayIntro }: { onReplayIntro: () => void }) {
  return (
    <div className="min-h-screen bg-[#F4F7F5] dark:bg-[#10261B] text-[#13202B] dark:text-[#F4F7F5] transition-colors duration-200 flex flex-col pt-[var(--header-h)] font-['Manrope','Noto_Sans_Devanagari',sans-serif] w-full max-w-full overflow-x-hidden">
      {/* Navigation Header (Fixed) */}
      <Header />

      {/* Main Content: Respective Separate Window Tab Section */}
      <main className="flex-grow flex flex-col">
        <MainTabRouter />
      </main>

      {/* Global Footer */}
      <Footer onReplayIntro={onReplayIntro} />

      {/* Interactive Overlays */}
      <ListingDetailModal />
      <ToastContainer />
    </div>
  );
}

export default function App() {
  const [replayKey, setReplayKey] = useState(0);

  // Synchronous initialization so preloader is visible on very first paint
  const [showPreloader, setShowPreloader] = useState<boolean>(() => {
    try {
      return !sessionStorage.getItem('vanmitra_intro_played');
    } catch {
      return true;
    }
  });

  const handleReplayIntro = () => {
    setReplayKey((k) => k + 1);
    setShowPreloader(true);
  };

  return (
    <MarketplaceProvider>
      {/* Cinematic VanMitra Preloader overlay */}
      {showPreloader && (
        <VanMitraPreloader
          key={replayKey}
          onComplete={() => setShowPreloader(false)}
        />
      )}

      <div aria-hidden={showPreloader ? 'true' : undefined}>
        <AppContent onReplayIntro={handleReplayIntro} />
      </div>
    </MarketplaceProvider>
  );
}
