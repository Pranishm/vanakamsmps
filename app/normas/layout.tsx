import type { Metadata } from 'next';
import { buildPageMetadata } from '@/lib/seo';

export const metadata: Metadata = buildPageMetadata({
  title: 'Rules',
  description:
    'Server and Discord rules for VANAKAMSMPs to maintain a healthy, safe and competitive community.',
  path: '/normas',
  keywords: ['minecraft server rules', 'server rules', 'discord server rules'],
});

export default function NormasLayout({ children }: { children: React.ReactNode }) {
  return children;
}
