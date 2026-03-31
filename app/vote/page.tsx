'use client';

import { useEffect, useState } from 'react';
import { useSession } from 'next-auth/react';
import { FaMap, FaCheckCircle, FaVoteYea } from 'react-icons/fa';
import PageHeader from '@/components/PageHeader';
import AnimatedSection from '@/components/AnimatedSection';
import { Badge, Card, Button } from '@/components/ui';
import { toast } from 'react-toastify';

interface VoteMap {
  _id: string;
  title: string;
  description: string;
  image: string;
  isActive: boolean;
  votesCount: number;
}

export default function MapVotePage() {
  const { status } = useSession();
  const [maps, setMaps] = useState<VoteMap[]>([]);
  const [userVote, setUserVote] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [voting, setVoting] = useState<string | null>(null);

  const fetchMaps = async () => {
    try {
      setLoading(true);
      const res = await fetch('/api/votemap', { cache: 'no-store' });
      if (!res.ok) throw new Error('Failed to load maps');
      const data = await res.json();
      setMaps(Array.isArray(data.maps) ? data.maps : []);
      if (data.userVote) {
        setUserVote(data.userVote);
      }
    } catch (e) {
      toast.error('Could not load voting options');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMaps();
  }, [status]);

  const handleVote = async (mapId: string) => {
    if (status !== 'authenticated') {
      toast.error('You must be logged in to vote');
      return;
    }

    setVoting(mapId);
    try {
      const res = await fetch('/api/votemap/vote', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ mapId })
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to vote');
      
      toast.success(data.message || 'Vote successfully cast!');
      fetchMaps();
    } catch (e: any) {
      toast.error(e.message);
    } finally {
      setVoting(null);
    }
  };

  return (
    <div className="mx-auto max-w-7xl px-4 py-16 sm:px-6 lg:px-8 lg:py-20">
      <PageHeader
        title="Map Voting"
        description="Vote for your favorite map to play next! You can cast one vote."
        icon={<FaMap className="text-6xl text-minecraft-gold" />}
      />

      <AnimatedSection>
        {loading ? (
          <div className="flex justify-center py-20">
            <div className="text-gray-500">Loading maps...</div>
          </div>
        ) : maps.length === 0 ? (
          <Card className="rounded-[30px] border-gray-200 dark:border-white/10 text-center py-20" hover={false}>
            <div className="text-6xl mb-4 text-gray-400 flex justify-center"><FaMap /></div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">No active maps</h2>
            <p className="text-gray-500">There is currently no ongoing map voting.</p>
          </Card>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {maps.map((map) => (
              <Card key={map._id} className={`rounded-[30px] overflow-hidden p-0 transition-all ${userVote === map._id ? 'border-2 border-minecraft-grass ring-4 ring-minecraft-grass/20' : 'border border-gray-200 dark:border-white/10'}`} hover>
                {map.image && (
                  <div className="w-full h-48 bg-gray-200 dark:bg-gray-800 relative group">
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img src={map.image} alt={map.title} className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110" />
                    {userVote === map._id && (
                      <div className="absolute top-3 right-3 bg-minecraft-grass text-white rounded-full p-1.5 shadow-lg">
                        <FaCheckCircle className="text-xl" />
                      </div>
                    )}
                  </div>
                )}
                
                <div className="p-6">
                  <div className="flex justify-between items-start mb-3">
                    <h3 className="text-xl font-bold text-gray-900 dark:text-white truncate pr-2">{map.title}</h3>
                    <Badge variant="info" className="shrink-0">{map.votesCount} {map.votesCount === 1 ? 'Vote' : 'Votes'}</Badge>
                  </div>
                  
                  {map.description && (
                    <p className="text-gray-600 dark:text-gray-400 text-sm mb-6 line-clamp-3">{map.description}</p>
                  )}
                  
                  <Button 
                    variant={userVote === map._id ? 'secondary' : 'primary'}
                    className="w-full justify-center"
                    onClick={() => handleVote(map._id)}
                    disabled={voting === map._id || userVote === map._id}
                  >
                    {voting === map._id ? 'Voting...' : userVote === map._id ? 'Voted' : (
                      <>
                        <FaVoteYea className="mr-2" />
                        Vote
                      </>
                    )}
                  </Button>
                </div>
              </Card>
            ))}
          </div>
        )}
      </AnimatedSection>

      <AnimatedSection>
        <div className="mt-20">
          <div className="mb-10 text-center">
            <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-3">Vote Rewards</h2>
            <p className="text-gray-600 dark:text-gray-400 max-w-2xl mx-auto">
              Participating in server votes helps our community grow! As a token of our appreciation, you will receive these rewards instantly in-game every time you participate.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            <Card hover className="rounded-[24px] text-center p-6 border border-gray-200 dark:border-white/10 dark:bg-white/[0.02]">
              <div className="text-4xl mb-4 flex justify-center drop-shadow-md">💎</div>
              <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">Diamonds</h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">Receive 5x Diamonds instantly dropped into your inventory.</p>
            </Card>

            <Card hover className="rounded-[24px] text-center p-6 border border-gray-200 dark:border-white/10 dark:bg-white/[0.02]">
              <div className="text-4xl mb-4 flex justify-center drop-shadow-md">🔑</div>
              <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">Vote Keys</h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">Get 1x Vote Crate Key to unlock rare cosmetics and gear.</p>
            </Card>

            <Card hover className="rounded-[24px] text-center p-6 border border-gray-200 dark:border-white/10 dark:bg-white/[0.02]">
              <div className="text-4xl mb-4 flex justify-center drop-shadow-md">💰</div>
              <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">Economy Cash</h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">Earn $500 in-game currency to spend at the server shop.</p>
            </Card>

            <Card hover className="rounded-[24px] text-center p-6 border border-gray-200 dark:border-white/10 dark:bg-white/[0.02]">
              <div className="text-4xl mb-4 flex justify-center drop-shadow-md">✨</div>
              <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">Loyalty XP</h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">Gain +50 Experience points to level up your Mcmmo skills.</p>
            </Card>
          </div>
        </div>
      </AnimatedSection>
    </div>
  );
}
