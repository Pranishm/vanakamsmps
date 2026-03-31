import type { Metadata } from 'next';
import { buildPageMetadata } from '@/lib/seo';

export const metadata: Metadata = buildPageMetadata({
  title: 'Vote',
  description:
    'Vote for VANAKAMSMPs, help the Minecraft server rank higher and earn rewards within the community.',
  path: '/vote',
  keywords: ['vote minecraft server', 'minecraft voting rewards', 'vanakamsmps vote'],
});

export default function VoteLayout({ children }: { children: React.ReactNode }) {
  return children;
}
