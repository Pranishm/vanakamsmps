import type { Metadata } from 'next';
import { buildPageMetadata } from '@/lib/seo';

export const metadata: Metadata = buildPageMetadata({
  title: 'Support',
  description:
    'Technical and account support for VANAKAMSMPs: tickets, payments, store, incidents and team help.',
  path: '/soporte',
  keywords: ['minecraft support', 'minecraft help desk', 'help desk minecraft'],
});

export default function SoporteLayout({ children }: { children: React.ReactNode }) {
  return children;
}
