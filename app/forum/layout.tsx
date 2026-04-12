import type { Metadata } from 'next';
import { buildPageMetadata } from '@/lib/seo';

export const metadata: Metadata = buildPageMetadata({
  title: 'Forum',
  description:
    'VANAKAMSMPs forum for questions, guides, trading, reports and community discussion for the Minecraft server.',
  path: '/foro',
  keywords: ['minecraft forum', 'minecraft community', 'server forum', 'vanakamsmps forum'],
});

export default function ForoLayout({ children }: { children: React.ReactNode }) {
  return children;
}
