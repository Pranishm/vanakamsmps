import type { MetadataRoute } from 'next';
import { getSiteName } from '@/lib/seo';

export default function manifest() {
  const baseConfig = {
    name: getSiteName(),
    short_name: 'VANAKAMSMPs',
    description: 'Minecraft server and community with store, forum, news and support.',
    start_url: '/',
    display: 'standalone',
    background_color: '#020814',
    theme_color: '#d4af37',
    categories: ['games', 'entertainment', 'social'],
    icons: [
      {
        src: '/icon-192.png',
        sizes: '192x192',
        type: 'image/png',
      },
      {
        src: '/icon-512.png',
        sizes: '512x512',
        type: 'image/png',
      },
    ],
  };

  return {
    ...baseConfig,
    widgets: [
      {
        name: "Vanakam Status (Small)",
        short_name: "Status Small",
        description: "Live player count (2x2)",
        tag: "vanakam-widget-small",
        template_url: "/widget-template.html?size=small",
        ms_ac_template: "/widget-template.html?size=small",
        data: "https://vanakam.me/api/status",
        type: "application/json",
        update: 900
      },
      {
        name: "Vanakam Status (Medium)",
        short_name: "Status Medium",
        description: "Live stats and events (4x2)",
        tag: "vanakam-widget-medium",
        template_url: "/widget-template.html?size=medium",
        ms_ac_template: "/widget-template.html?size=medium",
        data: "https://vanakam.me/api/status",
        type: "application/json",
        update: 900
      }
    ]
  } as any;
}