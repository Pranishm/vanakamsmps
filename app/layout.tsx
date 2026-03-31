import type { Metadata } from 'next';
import { Rajdhani, Press_Start_2P } from 'next/font/google';
import { cookies } from 'next/headers';
import './globals.css';
import CookieConsent from '@/components/CookieConsent';
import ChatbotWidget from '@/components/ChatbotWidget';
import RootShell from '@/components/RootShell';
import { Providers } from './providers';
import 'react-toastify/dist/ReactToastify.css';
import { normalizeLang } from '@/lib/i18n';
import ConsentAnalytics from '@/components/ConsentAnalytics';
import { buildPageMetadata, getAlternateLanguages, getDefaultKeywords, getSiteName, getSiteUrl } from '@/lib/seo';
import SeoJsonLd from '@/components/SeoJsonLd';
import SiteFeatures from '@/components/SiteFeatures';

const rajdhani = Rajdhani({ 
  subsets: ['latin'],
  weight: ['400', '500', '600', '700'],
});

const pressStart2P = Press_Start_2P({
  subsets: ['latin'],
  weight: ['400'],
  variable: '--font-press-start',
});

const siteUrl = getSiteUrl();

const googleVerification = process.env.GOOGLE_SITE_VERIFICATION || process.env.NEXT_PUBLIC_GOOGLE_SITE_VERIFICATION;
const bingVerification = process.env.BING_SITE_VERIFICATION || process.env.NEXT_PUBLIC_BING_SITE_VERIFICATION;

const verification: Metadata['verification'] = {
  ...(googleVerification ? { google: googleVerification } : {}),
  ...(bingVerification ? { other: { bing: bingVerification } } : {}),
};

export const metadata: Metadata = {
  ...buildPageMetadata({
    title: '- Minecraft Server',
    description:
      'Minecraft server and community with official store, forum, news, support and events. Built for players, search engines and AI assistants.',
    path: '/',
    keywords: getDefaultKeywords(),
  }),
  metadataBase: new URL(siteUrl),
  title: {
    default: 'VANAKAMSMPs - Minecraft Server',
    template: '%s | VANAKAMSMPs',
  },
  applicationName: getSiteName(),
  authors: [{ name: getSiteName() }],
  creator: getSiteName(),
  publisher: getSiteName(),
  category: 'games',
  classification: 'Minecraft community website',
  manifest: '/manifest.webmanifest',
  alternates: {
    canonical: '/',
    languages: getAlternateLanguages('/'),
  },
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  icons: {
    icon: [{ url: '/favicon.png' }],
    shortcut: [{ url: '/favicon.png' }],
    apple: [{ url: '/apple-touch-icon.png', sizes: '180x180' }],
  },
  appleWebApp: {
    capable: true,
    title: getSiteName(),
    statusBarStyle: 'default',
  },
  verification,
};

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const cookieStore = await cookies();
  const lang = normalizeLang(cookieStore.get('lang')?.value);

  const orgJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: process.env.SITE_NAME || 'VANAKAMSMPs',
    url: siteUrl,
    logo: `${siteUrl}/icon.png`,
    sameAs: [
      process.env.DISCORD_URL,
      process.env.TIKTOK_URL,
      process.env.YOUTUBE_URL,
    ].filter(Boolean),
  };

  const websiteJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: getSiteName(),
    url: siteUrl,
    inLanguage: ['en', 'es'],
  };

  return (
    <html lang={lang} className="dark" suppressHydrationWarning>
      <head>
        <link rel="icon" href="/favicon.png" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
        <SeoJsonLd data={orgJsonLd} />
        <SeoJsonLd data={websiteJsonLd} />
        <script
          suppressHydrationWarning
          dangerouslySetInnerHTML={{
            __html:
              "(() => {\n" +
              "  try {\n" +
              "    const saved = localStorage.getItem('theme');\n" +
              "    const theme = (saved === 'dark' || saved === 'light') ? saved : 'dark';\n" +
              "    if (theme === 'dark') document.documentElement.classList.add('dark');\n" +
              "    else document.documentElement.classList.remove('dark');\n" +
              "  } catch {}\n" +
              "})();",
          }}
        />
      </head>
      <body className={`${rajdhani.className} ${pressStart2P.variable}`}>
        <Providers initialLang={lang}>
          <RootShell>{children}</RootShell>
          <SiteFeatures />
          <CookieConsent />
          <ChatbotWidget />
        </Providers>
        <ConsentAnalytics />
      </body>
    </html>
  );
}
