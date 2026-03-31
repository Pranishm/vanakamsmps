import type { Metadata } from 'next';
import { buildPageMetadata } from '@/lib/seo';

export const metadata: Metadata = buildPageMetadata({
  title: 'Partners',
  description:
    'VANAKAMSMPs partner program for collaborations, promotions and visibility among Minecraft communities and servers.',
  path: '/partner',
  keywords: ['minecraft partner program', 'partner minecraft server', 'vanakamsmps partners'],
});

export default function PartnerLayout({ children }: { children: React.ReactNode }) {
  return children;
}
