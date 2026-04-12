'use client';

import Image from 'next/image';
import { motion, useScroll, useTransform, useSpring } from 'framer-motion';
import Link from 'next/link';
import { useEffect, useState, useRef } from 'react';
import { FaPlay, FaShoppingCart, FaUsers, FaShieldAlt, FaFire, FaGem, FaTree, FaCrosshairs, FaCloudSun, FaCopy, FaCheck, FaMobileAlt, FaGamepad, FaArrowDown, FaChevronDown } from 'react-icons/fa';
import ServerStatusWidget from '@/components/ServerStatusWidget';
import StaffOnlineWidget from '@/components/StaffOnlineWidget';
import DiscordSupportWidget from '@/components/DiscordSupportWidget';
import CommunityDashboard from '@/components/CommunityDashboard';
import HeroPlayerBadge from '@/components/HeroPlayerBadge';
import AnimatedSection from '@/components/AnimatedSection';
import { Card, Button, Input, Textarea } from '@/components/ui';
import { t } from '@/lib/i18n';
import { useClientLang } from '@/lib/useClientLang';
import { toast } from 'react-toastify';

// Stagger container animation
const staggerContainer = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: {
      staggerChildren: 0.12,
      delayChildren: 0.1,
    },
  },
};

const staggerItem = {
  hidden: { opacity: 0, y: 30 },
  show: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.6,
      ease: [0.25, 0.46, 0.45, 0.94],
    },
  },
};

export default function HomePage() {
  const lang = useClientLang();
  const [staffForm, setStaffForm] = useState({ username: '', discord: '', about: '' });
  const [sendingStaff, setSendingStaff] = useState(false);
  const heroRef = useRef<HTMLDivElement>(null);

  const { scrollYProgress } = useScroll({
    target: heroRef,
    offset: ['start start', 'end start'],
  });

  const heroY = useTransform(scrollYProgress, [0, 1], [0, 150]);
  const heroOpacity = useTransform(scrollYProgress, [0, 0.5], [1, 0]);
  const heroScale = useTransform(scrollYProgress, [0, 0.5], [1, 0.95]);
  const bgY = useSpring(useTransform(scrollYProgress, [0, 1], [0, 80]), {
    stiffness: 100,
    damping: 30,
  });

  const serverHost = process.env.NEXT_PUBLIC_MINECRAFT_SERVER_IP || 'marketing-great.gl.joinmc.link';
  const serverPort = Number(process.env.NEXT_PUBLIC_MINECRAFT_SERVER_PORT || 25565);
  const serverAddress = `${serverHost}:${Number.isFinite(serverPort) ? serverPort : 25565}`;
  const serverDisplayAddress = serverHost;

  // Bedrock Edition
  const bedrockHost = 'waltz-compound.gl.at.ply.gg';
  const bedrockPort = 6920;
  const [bedrockCopied, setBedrockCopied] = useState(false);

  const handlePlayNow = async () => {
    try {
      await navigator.clipboard.writeText(serverDisplayAddress);
    } catch {
      // ignore (clipboard permissions)
    }

    const ua = typeof navigator !== 'undefined' ? navigator.userAgent : '';
    const isSafari = /^((?!chrome|chromium|android).)*safari/i.test(ua);

    if (isSafari) {
      toast.info(`IP copied: ${serverDisplayAddress}. Paste it in Multiplayer > Add server.`);
      return;
    }

    const javaUrl = `minecraft://connect?server=${encodeURIComponent(serverHost)}&port=${
      Number.isFinite(serverPort) ? serverPort : 25565
    }`;

    toast.info(`IP copied: ${serverDisplayAddress}. Trying to open Minecraft…`);
    window.location.href = javaUrl;
  };

  const handleBedrockPlay = async () => {
    try {
      await navigator.clipboard.writeText(`${bedrockHost}:${bedrockPort}`);
    } catch {
      // ignore
    }
    setBedrockCopied(true);
    setTimeout(() => setBedrockCopied(false), 2500);

    const bedrockUrl = `minecraft://?addExternalServer=VANAKAMSMPs|${bedrockHost}:${bedrockPort}`;
    toast.info(`Bedrock IP copied: ${bedrockHost}:${bedrockPort}. Opening Minecraft…`);
    window.location.href = bedrockUrl;
  };

  const [staffOpen, setStaffOpen] = useState(process.env.NEXT_PUBLIC_STAFF_APPLICATIONS_OPEN === 'true');

  useEffect(() => {
    const loadStaffOpen = async () => {
      try {
        const res = await fetch('/api/staff-applications/status', { cache: 'no-store' });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) return;
        setStaffOpen(Boolean((data as any).open));
      } catch {
        // ignore
      }
    };
    loadStaffOpen();
  }, []);

  const submitStaffApplication = async () => {
    if (!staffOpen) return;

    const username = staffForm.username.trim();
    const discord = staffForm.discord.trim();
    const about = staffForm.about.trim();

    if (!username || username.length < 2) {
      toast.error(t(lang, 'home.staffForm.usernameInvalid'));
      return;
    }
    if (!discord || discord.length < 2) {
      toast.error(t(lang, 'home.staffForm.discordInvalid'));
      return;
    }
    if (!about || about.length < 20) {
      toast.error(t(lang, 'home.staffForm.aboutInvalid'));
      return;
    }

    setSendingStaff(true);
    try {
      const res = await fetch('/api/staff-applications', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, discord, about }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error((data as any).error || 'Error');

      toast.success(t(lang, 'home.staffForm.sent'));
      setStaffForm({ username: '', discord: '', about: '' });
    } catch (e) {
      toast.error(e instanceof Error ? e.message : t(lang, 'home.staffForm.sendError'));
    } finally {
      setSendingStaff(false);
    }
  };

  const features = [
    {
      icon: <FaShieldAlt className="text-4xl text-minecraft-grass" />,
      title: t(lang, 'home.features.anticheat.title'),
      description: t(lang, 'home.features.anticheat.desc'),
    },
    {
      icon: <FaFire className="text-4xl text-minecraft-redstone" />,
      title: t(lang, 'home.features.events.title'),
      description: t(lang, 'home.features.events.desc'),
    },
    {
      icon: <FaUsers className="text-4xl text-minecraft-diamond" />,
      title: t(lang, 'home.features.community.title'),
      description: t(lang, 'home.features.community.desc'),
    },
    {
      icon: <FaGem className="text-4xl text-minecraft-gold" />,
      title: t(lang, 'home.features.economy.title'),
      description: t(lang, 'home.features.economy.desc'),
    },
  ];

  const gameModes = [
    {
      name: 'Survival',
      description: t(lang, 'home.modes.survivalDesc'),
      icon: <FaTree className="mx-auto text-minecraft-grass" />,
    },
    {
      name: 'PvP',
      description: t(lang, 'home.modes.pvpDesc'),
      icon: <FaCrosshairs className="mx-auto text-minecraft-redstone" />,
    },
    {
      name: 'SkyBlock',
      description: t(lang, 'home.modes.skyblockDesc'),
      icon: <FaCloudSun className="mx-auto text-minecraft-diamond" />,
    },
  ];

  const scrollToContent = () => {
    const el = document.getElementById('community-dashboard');
    if (el) {
      el.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <div className="min-h-screen overflow-x-clip">
      {/* Hero Section */}
      <section ref={heroRef} className="relative flex min-h-[100svh] items-center justify-center overflow-hidden">
        <div aria-hidden className="absolute inset-0 z-0 overflow-hidden">
          <motion.div
            style={{ y: bgY }}
            className="absolute inset-x-[-4%] -top-32 bottom-[-4%]"
          >
            <Image
              src="/fondo.png"
              alt=""
              fill
              priority
              sizes="100vw"
              className="object-cover object-top opacity-[0.48] scale-[1.08] saturate-[1.04] brightness-[0.84]"
            />
          </motion.div>
          <div className="absolute inset-0 bg-[linear-gradient(180deg,rgba(255,240,246,0.06),rgba(120,72,116,0.08)_18%,rgba(38,22,38,0.18)_48%,rgba(18,10,18,0.3)_76%,rgba(10,6,12,0.5)_100%)] dark:bg-[linear-gradient(180deg,rgba(255,240,246,0.08),rgba(120,72,116,0.12)_18%,rgba(38,22,38,0.22)_48%,rgba(18,10,18,0.36)_76%,rgba(10,6,12,0.56)_100%)]" />
          <div className="absolute inset-x-0 bottom-0 h-28 bg-gradient-to-b from-transparent to-[#020814] dark:to-[#02050f]" />
        </div>

        <motion.div
          style={{ y: heroY, opacity: heroOpacity, scale: heroScale }}
          className="relative z-10 mx-auto flex min-h-[100svh] w-full max-w-7xl items-center px-4 pb-14 pt-24 text-center sm:px-6 sm:pb-16 lg:px-8"
        >
          <div className="w-full">
            <motion.div
              initial={{ opacity: 0, y: -50 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, ease: [0.25, 0.46, 0.45, 0.94] }}
            >
              <HeroPlayerBadge host={serverHost} port={Number.isFinite(serverPort) ? serverPort : 25565} />
              <h1
                className="mb-5 bg-[linear-gradient(90deg,#fde7ee_0%,#f2b9cf_34%,#d58eaf_66%,#fff2f6_100%)] bg-[length:200%_200%] bg-clip-text text-3xl md:text-5xl lg:text-6xl font-bold text-transparent [text-shadow:0_0_24px_rgba(242,185,207,0.18)] font-[family-name:var(--font-press-start)]"
                style={{
                  animation: 'home-title-gradient 8s ease-in-out infinite',
                }}
              >
                VANAKAMSMPs
              </h1>
              <p className="mx-auto mb-8 max-w-3xl text-base leading-7 text-gray-700 dark:text-gray-300 sm:text-lg md:text-xl">
                {t(lang, 'home.hero.subtitle')}
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.8, delay: 0.6, ease: [0.25, 0.46, 0.45, 0.94] }}
              className="mx-auto max-w-2xl"
            >
              <div className="space-y-3">
                {/* Java Edition Server Status */}
                <ServerStatusWidget 
                  host={serverHost}
                  port={Number.isFinite(serverPort) ? serverPort : 25565}
                />

                {/* Bedrock Edition Card */}
                <motion.div
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.8 }}
                  className="relative overflow-hidden bg-gradient-to-br from-[#8B5CF6]/10 via-gray-900/50 to-[#06B6D4]/10 backdrop-blur-sm border border-[#8B5CF6]/20 rounded-lg p-4"
                >
                  {/* Decorative glow */}
                  <div className="absolute -top-8 -right-8 w-24 h-24 bg-[#8B5CF6]/15 rounded-full blur-2xl pointer-events-none" />
                  <div className="absolute -bottom-8 -left-8 w-24 h-24 bg-[#06B6D4]/15 rounded-full blur-2xl pointer-events-none" />
                  
                  <div className="relative flex items-center justify-between gap-3">
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="flex items-center justify-center w-10 h-10 rounded-lg bg-[#8B5CF6]/20 border border-[#8B5CF6]/30">
                        <FaGamepad className="text-[#8B5CF6] text-lg" />
                      </div>
                      <div className="min-w-0">
                        <div className="flex items-center gap-2">
                          <span className="text-xs font-bold uppercase tracking-wider text-[#8B5CF6]">Bedrock Edition</span>
                          <span className="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-bold bg-[#8B5CF6]/20 text-[#A78BFA] border border-[#8B5CF6]/30">Mobile/PC</span>
                        </div>
                        <div className="text-white font-mono text-sm mt-0.5 break-all">{bedrockHost}:{bedrockPort}</div>
                      </div>
                    </div>

                    <div className="flex items-center gap-2 shrink-0">
                      <button
                        type="button"
                        onClick={() => {
                          navigator.clipboard.writeText(`${bedrockHost}:${bedrockPort}`).catch(() => {});
                          setBedrockCopied(true);
                          setTimeout(() => setBedrockCopied(false), 2000);
                        }}
                        aria-label={bedrockCopied ? 'Copied' : 'Copy Bedrock IP'}
                        title={bedrockCopied ? 'Copied!' : 'Copy Bedrock IP'}
                        className="inline-flex items-center justify-center p-2 rounded-md bg-[#8B5CF6]/20 text-[#A78BFA] hover:bg-[#8B5CF6]/30 transition-colors"
                      >
                        {bedrockCopied ? <FaCheck className="text-green-400" /> : <FaCopy />}
                      </button>
                      <button
                        type="button"
                        onClick={handleBedrockPlay}
                        aria-label="Open Minecraft Bedrock"
                        title="Open Minecraft"
                        className="inline-flex items-center gap-2 px-3 py-2 rounded-md bg-[#8B5CF6]/30 text-white hover:bg-[#8B5CF6]/50 transition-colors font-semibold text-sm border border-[#8B5CF6]/30"
                      >
                        <FaMobileAlt />
                        <span className="hidden sm:inline">Open MC</span>
                      </button>
                    </div>
                  </div>
                </motion.div>

                <motion.div
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 1.0 }}
                  className="grid grid-cols-1 gap-3 sm:grid-cols-2"
                >
                  <StaffOnlineWidget host={serverHost} port={Number.isFinite(serverPort) ? serverPort : 25565} />
                  <DiscordSupportWidget />
                </motion.div>
              </div>
            </motion.div>
          </div>
        </motion.div>

        {/* Scroll indicator */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 2 }}
          className="absolute bottom-8 left-1/2 -translate-x-1/2 z-20"
        >
          <motion.button
            onClick={scrollToContent}
            animate={{ y: [0, 8, 0] }}
            transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut' }}
            className="flex flex-col items-center gap-2 text-gray-400 hover:text-white transition-colors"
          >
            <span className="text-xs font-semibold tracking-wider uppercase">Scroll</span>
            <FaChevronDown className="text-sm" />
          </motion.button>
        </motion.div>
      </section>

      {/* Community Dashboard (Leaderboards, Patch Notes, Ranks) */}
      <div id="community-dashboard">
        <AnimatedSection>
          <CommunityDashboard />
        </AnimatedSection>
      </div>

      {/* Features Section */}
      <AnimatedSection>
        <section className="mx-auto max-w-7xl px-4 py-16 sm:px-6 lg:px-8 lg:py-20">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="mb-12 text-center sm:mb-16"
          >
            <h2 className="mb-4 text-3xl font-bold text-gray-900 dark:text-white sm:text-4xl md:text-5xl">{t(lang, 'home.why.title')}</h2>
            <p className="text-base text-gray-600 dark:text-gray-400 sm:text-lg">{t(lang, 'home.why.subtitle')}</p>
          </motion.div>

          <motion.div
            variants={staggerContainer}
            initial="hidden"
            whileInView="show"
            viewport={{ once: true, margin: '-60px' }}
            className="grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-4 xl:gap-6"
          >
            {features.map((feature, index) => (
              <motion.div
                key={index}
                variants={staggerItem}
              >
                <Card hover className="h-full flex flex-col items-center rounded-[28px] text-center transform transition-all duration-300 hover:-translate-y-2 hover:border-minecraft-grass/50 hover:shadow-[0_8px_30px_rgba(81,200,98,0.15)]">
                  <div className="mb-4 flex justify-center">{feature.icon}</div>
                  <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">{feature.title}</h3>
                  <p className="text-sm leading-6 text-gray-600 dark:text-gray-400 sm:text-base">{feature.description}</p>
                </Card>
              </motion.div>
            ))}
          </motion.div>
        </section>
      </AnimatedSection>

      {/* Game Modes Section */}
      <AnimatedSection direction="left">
        <section className="mx-auto max-w-7xl px-4 py-14 sm:px-6 lg:px-8 lg:py-16">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="mb-10 text-center sm:mb-12"
          >
            <h2 className="mb-4 text-3xl font-bold text-gray-900 dark:text-white sm:text-4xl md:text-5xl">{t(lang, 'home.modes.title')}</h2>
            <p className="text-base text-gray-600 dark:text-gray-400 sm:text-lg">{t(lang, 'home.modes.subtitle')}</p>
          </motion.div>

          <motion.div
            variants={staggerContainer}
            initial="hidden"
            whileInView="show"
            viewport={{ once: true, margin: '-60px' }}
            className="grid grid-cols-1 gap-5 lg:grid-cols-3 lg:gap-6"
          >
            {gameModes.map((mode, index) => (
              <motion.div
                key={index}
                variants={staggerItem}
              >
                <Card hover className="h-full flex flex-col items-center rounded-[28px] text-center transform transition-all duration-300 hover:-translate-y-2 hover:shadow-xl">
                  <div className="text-6xl mb-4">{mode.icon}</div>
                  <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">{mode.name}</h3>
                  <p className="text-gray-600 dark:text-gray-400 mb-6 flex-1">{mode.description}</p>
                  <Button variant="secondary" className="w-full mt-auto" onClick={handlePlayNow}>
                    {`Play ${mode.name}`}
                  </Button>
                </Card>
              </motion.div>
            ))}
          </motion.div>
        </section>
      </AnimatedSection>

      {/* Screenshot Gallery Section */}
      <AnimatedSection direction="right">
        <section className="mx-auto max-w-7xl px-4 py-14 sm:px-6 lg:px-8 lg:py-16">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="mb-10 text-center sm:mb-12"
          >
            <h2 className="mb-4 text-3xl font-bold text-gray-900 dark:text-white sm:text-4xl md:text-5xl">In-Game Server Gallery</h2>
            <p className="text-base text-gray-600 dark:text-gray-400 sm:text-lg">
              Take a look at what awaits you inside the server.
            </p>
          </motion.div>

          <motion.div
            variants={staggerContainer}
            initial="hidden"
            whileInView="show"
            viewport={{ once: true, margin: '-40px' }}
            className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4"
          >
            <motion.div variants={staggerItem} className="relative h-64 overflow-hidden rounded-[24px] shadow-lg group">
              <Image src="/fondo.png" alt="Gallery 1" fill className="object-cover transition-transform duration-700 group-hover:scale-110" />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-end p-6">
                <div>
                  <span className="text-white font-bold text-lg tracking-wider">OneBlock</span>
                  <p className="text-gray-300 text-sm mt-1">Start on a single block</p>
                </div>
              </div>
            </motion.div>
            
            <motion.div variants={staggerItem} className="relative h-64 overflow-hidden rounded-[24px] shadow-lg group">
              <Image src="/fondo.png" alt="Gallery 2" fill className="object-cover object-bottom transition-transform duration-700 group-hover:scale-110" />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-end p-6">
                <div>
                  <span className="text-white font-bold text-lg tracking-wider">SkyBlock</span>
                  <p className="text-gray-300 text-sm mt-1">Your island awaits</p>
                </div>
              </div>
            </motion.div>
            
            <motion.div variants={staggerItem} className="relative h-64 overflow-hidden rounded-[24px] shadow-lg group md:col-span-2 lg:col-span-1">
              <Image src="/fondo.png" alt="Gallery 3" fill className="object-cover object-left transition-transform duration-700 group-hover:scale-110" />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-end p-6">
                <div>
                  <span className="text-white font-bold text-lg tracking-wider">PvP Events</span>
                  <p className="text-gray-300 text-sm mt-1">Weekly tournaments</p>
                </div>
              </div>
            </motion.div>
          </motion.div>
        </section>
      </AnimatedSection>

      {/* Staff Form */}
      <AnimatedSection>
        <section className="mx-auto max-w-4xl px-4 py-14 sm:px-6 lg:px-8 lg:py-16">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="mb-8 text-center sm:mb-10"
          >
            <h2 className="mb-3 text-3xl font-bold text-gray-900 dark:text-white sm:text-4xl md:text-5xl">{t(lang, 'home.staffForm.title')}</h2>
            <p className="text-gray-600 dark:text-gray-400 text-lg">
              {staffOpen ? t(lang, 'home.staffForm.openDesc') : t(lang, 'home.staffForm.subtitle')}
            </p>
          </motion.div>

          <Card hover={false} className="rounded-[30px] border-gray-200 dark:border-gray-800">
            <div className="mb-6">
              <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
                {staffOpen ? t(lang, 'home.staffForm.openTitle') : 'Applications currently closed'}
              </h3>
              <p className="text-gray-600 dark:text-gray-400">
                {staffOpen ? t(lang, 'home.staffForm.openDesc') : 'Our staff applications will open again in May. Stay tuned to our Discord for future openings!'}
              </p>
            </div>

            <div className="space-y-4">
              <Input
                disabled={!staffOpen}
                placeholder={t(lang, 'home.staffForm.username')}
                value={staffForm.username}
                onChange={(e) => setStaffForm((p) => ({ ...p, username: e.target.value }))}
              />
              <Input
                disabled={!staffOpen}
                placeholder={t(lang, 'home.staffForm.discord')}
                value={staffForm.discord}
                onChange={(e) => setStaffForm((p) => ({ ...p, discord: e.target.value }))}
              />
              <Textarea
                disabled={!staffOpen}
                rows={5}
                placeholder={t(lang, 'home.staffForm.aboutPlaceholder')}
                value={staffForm.about}
                onChange={(e) => setStaffForm((p) => ({ ...p, about: e.target.value }))}
              />
              <Button disabled={!staffOpen || sendingStaff} variant="secondary" onClick={submitStaffApplication} className="w-full sm:w-auto">
                <span>{t(lang, 'home.staffForm.send')}</span>
              </Button>
            </div>
          </Card>
        </section>
      </AnimatedSection>
    </div>
  );
}
