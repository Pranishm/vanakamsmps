'use client';

import { useEffect, useMemo, useState } from 'react';
import Image from 'next/image';
import { motion } from 'framer-motion';
import { FaUsers } from 'react-icons/fa';
import { useClientLang } from '@/lib/useClientLang';

type StaffOnlineItem = {
  username: string;
  role: string;
  minecraftUsername: string;
  minecraftUuid: string;
};

type StaffOnlineResponse = {
  online: boolean;
  count: number;
  staff: StaffOnlineItem[];
  note?: string;
};

interface StaffOnlineWidgetProps {
  host: string;
  port?: number;
}

export default function StaffOnlineWidget({ host, port = 25565 }: StaffOnlineWidgetProps) {
  const lang = useClientLang();
  const [data, setData] = useState<StaffOnlineResponse | null>(null);
  const [loading, setLoading] = useState(true);

  const portNumber = Number.isFinite(Number(port)) ? Number(port) : 25565;
  const endpoint = useMemo(
    () => `/api/server/staff-online?host=${encodeURIComponent(host)}&port=${portNumber}`,
    [host, portNumber]
  );

  useEffect(() => {
    let alive = true;

    const fetchStaff = async () => {
      setLoading(true);
      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 6000);
        const res = await fetch(endpoint, { cache: 'no-store', signal: controller.signal });
        clearTimeout(timeoutId);
        
        const json = (await res.json().catch(() => null)) as StaffOnlineResponse | null;
        if (!alive) return;
        if (res.ok && json) setData(json);
        else setData({ online: false, count: 0, staff: [] });
      } catch {
        if (!alive) return;
        setData({ online: false, count: 0, staff: [] });
      }
      if (alive) setLoading(false);
    };

    fetchStaff();
    const interval = setInterval(fetchStaff, 30000);
    return () => {
      alive = false;
      clearInterval(interval);
    };
  }, [endpoint]);

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-gray-900/50 backdrop-blur-sm border border-gray-800 rounded-lg p-4"
    >
      <div className="flex items-center justify-between gap-3 mb-3">
        <div className="flex items-center gap-2 text-white font-medium">
          <FaUsers className="text-minecraft-grass" />
          <span>{'Admins online'}</span>
        </div>

        <div className="text-xs text-gray-400">
          {loading ? ('Loading…') : `${data?.count ?? 0}`}
        </div>
      </div>

      {!loading && (data?.staff?.length || 0) > 0 ? (
        <div className="flex flex-wrap gap-2">
          {data!.staff.slice(0, 12).map((u) => {
            const mc = String(u.minecraftUsername || '').trim();
            const displayName = mc || u.username;
            return (
              <div
                key={`${u.minecraftUsername}-${u.username}`}
                className="flex items-center gap-2 rounded-full border border-gray-800 bg-gray-950/50 pr-3 p-1 transition-colors hover:bg-gray-800/50"
                title={displayName}
              >
                <div className="relative h-6 w-6 shrink-0 overflow-hidden rounded-full bg-black">
                  <Image
                    src={`https://minotar.net/helm/${encodeURIComponent(mc || 'Steve')}/24.png`}
                    alt={displayName}
                    fill
                    sizes="24px"
                    className="object-cover"
                  />
                </div>
                <span className="text-sm font-medium text-gray-200">
                  {displayName}
                </span>
              </div>
            );
          })}
        </div>
      ) : (
        <div className="text-sm text-gray-400">
          {data?.note
            ? data.note
            : 'No admins online right now.'}
        </div>
      )}
    </motion.div>
  );
}
