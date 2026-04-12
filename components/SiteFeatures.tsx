'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { FaDiscord, FaGamepad, FaStore, FaQuestionCircle, FaHome, FaTimes, FaHeart } from 'react-icons/fa';

export default function SiteFeatures() {
  const [loading, setLoading] = useState(true);
  const [konamiUnlocked, setKonamiUnlocked] = useState(false);
  const [showPWA, setShowPWA] = useState(false);
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);
  const pathname = usePathname();

  // Konami Code sequence
  const konamiCode = [
    'ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown',
    'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight',
    'b', 'a'
  ];

  useEffect(() => {
    // Register Service Worker for PWA Add-To-Home-Screen Support
    if ('serviceWorker' in navigator) {
      window.addEventListener('load', () => {
        navigator.serviceWorker.register('/sw.js').catch((err) => {
          console.error('Service Worker registration failed:', err);
        });
      });
    }

    // Hide loading screen after 1.2s to simulate Minecraft loading
    const timer = setTimeout(() => setLoading(false), 1200);

    // Easter Egg: Konami Code
    let konamiPosition = 0;
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === konamiCode[konamiPosition]) {
        konamiPosition++;
        if (konamiPosition === konamiCode.length) {
          setKonamiUnlocked(true);
          // Play a level up sound
          try {
            const audio = new Audio('https://www.myinstants.com/media/sounds/minecraft_level_up.mp3');
            audio.volume = 0.5;
            audio.play();
          } catch (e) { }
          setTimeout(() => setKonamiUnlocked(false), 5000);
          konamiPosition = 0;
        }
      } else {
        konamiPosition = 0;
      }
    };
    window.addEventListener('keydown', handleKeyDown);

    // PWA Install Prompt
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault();
      setDeferredPrompt(e);
      setShowPWA(true);
    });

    return () => {
      clearTimeout(timer);
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, []);

  const handlePWAInstall = async () => {
    if (deferredPrompt) {
      deferredPrompt.prompt();
      const { outcome } = await deferredPrompt.userChoice;
      if (outcome === 'accepted') {
        setShowPWA(false);
      }
      setDeferredPrompt(null);
    }
  };

  return (
    <>
      {/* 1. Global Loading Screen */}
      {loading && (
        <div className="fixed inset-0 z-[9999] flex flex-col items-center justify-center bg-gray-900 transition-opacity duration-500">
          <div className="text-white font-bold text-3xl mb-8 animate-pulse font-[family-name:var(--font-press-start)] text-center tracking-widest drop-shadow-[0_4px_4px_rgba(0,0,0,0.5)] flex items-center justify-center">
            VANAKAMSMPs
            <span className="animate-bounce ml-2">_</span>
          </div>
          <div className="w-64 h-2 bg-gray-800 rounded-full overflow-hidden border border-gray-700 p-0.5">
            <div className="h-full bg-minecraft-grass rounded-full w-full origin-left animate-[loadBar_1.2s_ease-out_forwards]"></div>
          </div>
          <div className="mt-4 text-xs font-bold text-gray-500 tracking-widest uppercase animate-pulse">
            Generating terrain...
          </div>
          <style dangerouslySetInnerHTML={{
            __html: `
            @keyframes loadBar { 0% { transform: scaleX(0); } 30% { transform: scaleX(0.4); } 60% { transform: scaleX(0.7); } 100% { transform: scaleX(1); } }
          `}} />
        </div>
      )}

      {/* 2. Konami Easter Egg Overlay */}
      {konamiUnlocked && (
        <div className="fixed inset-0 z-[8000] pointer-events-none flex flex-col items-center justify-center bg-black/50 backdrop-blur-sm animate-in fade-in zoom-in duration-300">
          <div className="text-8xl animate-bounce drop-shadow-[0_0_30px_rgba(71,209,232,0.8)]">💎</div>
          <h2 className="mt-8 text-4xl font-bold bg-gradient-to-r from-minecraft-diamond to-minecraft-emerald text-transparent bg-clip-text text-center font-[family-name:var(--font-press-start)] drop-shadow-xl animate-pulse">SECRET UNLOCKED!</h2>
        </div>
      )}

      {/* 3. PWA Install Prompt */}
      {showPWA && (
        <div className="fixed top-20 left-1/2 -translate-x-1/2 z-[100] bg-gray-900 border border-minecraft-diamond/30 p-4 rounded-xl shadow-[0_10px_40px_rgba(0,0,0,0.5)] flex items-center gap-4 animate-in slide-in-from-top fade-in duration-500">
          <div className="bg-minecraft-diamond/20 p-2 rounded-lg text-minecraft-diamond"><FaHome size={24} /></div>
          <div>
            <div className="text-white font-bold text-sm">Install VANAKAMSMPs</div>
            <div className="text-gray-400 text-xs">Add to your home screen!</div>
          </div>
          <div className="flex items-center gap-2 ml-4">
            <button onClick={handlePWAInstall} className="text-xs bg-minecraft-diamond text-black font-bold px-3 py-1.5 rounded-lg hover:bg-cyan-400 transition-colors">Install</button>
            <button onClick={() => setShowPWA(false)} className="text-gray-500 hover:text-white"><FaTimes /></button>
          </div>
        </div>
      )}

      {/* 4. Floating Discord Button (Desktop primarily, hidden behind bottom nav on mobile if needed) */}
      <a
        href={process.env.NEXT_PUBLIC_DISCORD_URL || '#'}
        target="_blank"
        rel="noopener noreferrer"
        className="fixed bottom-6 right-6 md:bottom-8 md:right-8 z-50 bg-[#5865F2] text-white p-4 rounded-full shadow-[0_8px_30px_rgba(88,101,242,0.4)] hover:scale-110 hover:-translate-y-1 hover:shadow-[0_8px_40px_rgba(88,101,242,0.6)] transition-all duration-300 md:flex hidden items-center justify-center group"
      >
        <FaDiscord size={28} />
        <span className="absolute right-full mr-4 bg-gray-900 border border-gray-700 text-white text-sm font-bold px-3 py-1.5 rounded-lg opacity-0 group-hover:opacity-100 transition-all duration-300 translate-x-2 group-hover:translate-x-0 pointer-events-none whitespace-nowrap">
          Join our Discord!
        </span>
      </a>

      {/* 5. Mobile Bottom Navbar (App-like sticky bar) */}
      <div className="md:hidden fixed bottom-0 left-0 right-0 z-[100] bg-gray-950/95 backdrop-blur-xl border-t border-white/10 pb-safe pb-2 px-2 pt-2 pb-5">
        <div className="flex items-center justify-around">
          <Link href="/" className={`flex flex-col items-center gap-1 p-2 rounded-xl transition-colors ${pathname === '/' ? 'text-minecraft-diamond' : 'text-gray-500 hover:text-gray-300'}`}>
            <FaHome size={20} />
            <span className="text-[10px] font-bold">Home</span>
          </Link>
          <Link href="/shop" className={`flex flex-col items-center gap-1 p-2 rounded-xl transition-colors ${pathname === '/shop' ? 'text-minecraft-diamond' : 'text-gray-500 hover:text-gray-300'}`}>
            <FaStore size={20} />
            <span className="text-[10px] font-bold">Store</span>
          </Link>
          {/* Main Action Button - Play */}
          <div className="relative -top-5">
            <button
              onClick={() => {
                navigator.clipboard.writeText('vanakam.me');
                alert('IP: vanakam.me copied to clipboard!');
              }}
              className="flex items-center justify-center w-14 h-14 bg-gradient-to-tr from-minecraft-grass to-green-400 rounded-full shadow-[0_0_20px_rgba(71,209,232,0.4)] border-[3px] border-gray-950 text-white transform hover:scale-110 active:scale-95 transition-all duration-200"
            >
              <FaGamepad size={24} />
            </button>
          </div>
          <Link href="/support" className={`flex flex-col items-center gap-1 p-2 rounded-xl transition-colors ${pathname === '/support' ? 'text-minecraft-diamond' : 'text-gray-500 hover:text-gray-300'}`}>
            <FaQuestionCircle size={20} />
            <span className="text-[10px] font-bold">Support</span>
          </Link>
          <a href={process.env.NEXT_PUBLIC_DISCORD_URL || '#'} target="_blank" rel="noopener noreferrer" className="flex flex-col items-center gap-1 p-2 rounded-xl text-gray-500 hover:text-[#5865F2] transition-colors">
            <FaDiscord size={20} />
            <span className="text-[10px] font-bold">Discord</span>
          </a>
        </div>
      </div>
    </>
  );
}
