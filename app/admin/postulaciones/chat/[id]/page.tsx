'use client';

import { use } from 'react';
import TicketChatView from '@/components/support/TicketChatView';

export default function AdminPostulacionesChatPage({ params }: { params: Promise<{ id: string }> }) {
  const { id: ticketId } = use(params);
  return (
    <TicketChatView
      ticketId={ticketId}
      backHref="/admin/postulaciones"
      callbackUrl={`/admin/postulaciones/chat/${ticketId}`}
      embedded
    />
  );
}
