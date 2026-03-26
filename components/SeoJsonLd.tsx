import React from 'react';

export default function SeoJsonLd({ data, nonce }: { data: any; nonce?: string }) {
  if (!data) return null;
  return (
    <script
      type="application/ld+json"
      // JSON-LD must be a raw string.
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
