import type { Metadata } from 'next';
import { buildPageMetadata } from '@/lib/seo';

export const metadata: Metadata = buildPageMetadata({
  title: 'News',
  description:
    'News, events, guides and updates from VANAKAMSMPs to stay up to date with the Minecraft server.',
  path: '/noticias',
  keywords: ['minecraft news', 'minecraft updates', 'server news', 'vanakamsmps news'],
});

export default function NoticiasLayout({ children }: { children: React.ReactNode }) {
  return children;
}
