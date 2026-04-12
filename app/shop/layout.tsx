import type { Metadata } from 'next';
import { buildPageMetadata } from '@/lib/seo';

export const metadata: Metadata = buildPageMetadata({
  title: 'Store',
  description:
    'Official VANAKAMSMPs store with ranks, bundles, keys, coins and limited offers for the Minecraft server.',
  path: '/tienda',
  keywords: ['minecraft store', 'minecraft ranks', 'minecraft bundles', 'vanakamsmps store'],
});

export default function TiendaLayout({ children }: { children: React.ReactNode }) {
  return children;
}
