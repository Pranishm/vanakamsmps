import type { Metadata } from 'next';
import { buildPageMetadata } from '@/lib/seo';

export const metadata: Metadata = buildPageMetadata({
  title: 'Staff',
  description:
    'Meet the VANAKAMSMPs team: administration, moderation and support for the Minecraft server.',
  path: '/staff',
  keywords: ['minecraft staff', 'server moderators', 'vanakamsmps staff'],
});

export default function StaffLayout({ children }: { children: React.ReactNode }) {
  return children;
}
