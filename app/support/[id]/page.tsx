'use client';

import { use } from 'react';
import TicketChatView from '@/components/support/TicketChatView';

export default function SoporteTicketPage({ params }: { params: Promise<{ id: string }> }) {
  const { id: ticketId } = use(params);
  return <TicketChatView ticketId={ticketId} backHref="/support" callbackUrl={`/soporte/${ticketId}`} />;
}
