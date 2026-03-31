'use client';

import { useEffect, useState } from 'react';
import { useSession } from 'next-auth/react';
import { motion } from 'framer-motion';
import { toast } from 'react-toastify';
import { FaMap, FaPlus, FaSyncAlt, FaTrash, FaPen } from 'react-icons/fa';

import { Card, Input, Badge, Button, Textarea } from '@/components/ui';

interface VoteMap {
  _id: string;
  title: string;
  description: string;
  image: string;
  isActive: boolean;
  votesCount: number;
}

export default function AdminVoteMapPage() {
  const { data: session } = useSession();
  const [maps, setMaps] = useState<VoteMap[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [editingMap, setEditingMap] = useState<VoteMap | null>(null);
  
  const [form, setForm] = useState({ title: '', description: '', image: '', isActive: true });
  const [submitting, setSubmitting] = useState(false);

  const fetchMaps = async () => {
    setRefreshing(true);
    try {
      const response = await fetch('/api/admin/votemap', { cache: 'no-store' });
      if (!response.ok) throw new Error('Error loading maps');
      const data = await response.json();
      setMaps(Array.isArray(data) ? data : []);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Error loading maps');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchMaps();
  }, []);

  const resetForm = () => {
    setForm({ title: '', description: '', image: '', isActive: true });
    setEditingMap(null);
    setShowCreateModal(false);
  };

  const handleSubmit = async () => {
    if (!form.title) {
      toast.error('Title is required');
      return;
    }

    setSubmitting(true);
    try {
      const url = editingMap ? `/api/admin/votemap/${editingMap._id}` : '/api/admin/votemap';
      const method = editingMap ? 'PUT' : 'POST';
      
      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      
      const data = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(data.error || 'Request failed');
      
      toast.success(editingMap ? 'Map updated!' : 'Map created!');
      resetForm();
      fetchMaps();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Error saving map');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this map? All votes for it will also be lost.')) return;
    
    try {
      const response = await fetch(`/api/admin/votemap/${id}`, { method: 'DELETE' });
      if (!response.ok) throw new Error('Failed to delete');
      toast.success('Map deleted');
      fetchMaps();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Error deleting map');
    }
  };

  const openEdit = (map: VoteMap) => {
    setEditingMap(map);
    setForm({ title: map.title, description: map.description || '', image: map.image || '', isActive: map.isActive });
    setShowCreateModal(true);
  };

  return (
    <div className="space-y-6">
      <Card className="rounded-[30px] border border-gray-200 bg-white dark:border-white/10 dark:bg-gray-950/25" hover={false}>
        <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
          <div className="flex items-center gap-3 min-w-0">
            <div className="grid h-12 w-12 place-items-center rounded-[18px] border border-slate-200 bg-slate-950 text-white shadow-[0_28px_70px_-48px_rgba(15,23,42,0.6)] dark:border-white/10 dark:bg-white dark:text-slate-950">
              <FaMap />
            </div>
            <div className="min-w-0">
              <h1 className="truncate text-2xl font-bold tracking-[-0.04em] text-gray-900 dark:text-white md:text-3xl">Map Voting</h1>
              <p className="text-sm text-gray-600 dark:text-gray-400 md:text-base">Manage maps available for player voting</p>
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-2 justify-start lg:justify-end">
            <Button type="button" variant="secondary" onClick={fetchMaps} disabled={refreshing} className="h-10">
              <FaSyncAlt />
              <span>{refreshing ? 'Loading...' : 'Refresh'}</span>
            </Button>

            <Button type="button" onClick={() => { resetForm(); setShowCreateModal(true); }} className="h-10">
              <FaPlus />
              <span>Add Map</span>
            </Button>
          </div>
        </div>
      </Card>

      {/* Modal inside page */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black/80 z-50 flex items-center justify-center p-4 overflow-y-auto">
          <motion.div
            initial={{ opacity: 0, scale: 0.97, y: 10 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            className="bg-gray-950/95 border border-white/10 rounded-2xl p-6 md:p-8 max-w-2xl w-full my-8 max-h-[calc(100vh-4rem)] overflow-y-auto"
          >
            <div className="flex items-start justify-between gap-4 mb-6">
              <div>
                <div className="text-white text-xl font-bold">{editingMap ? 'Edit Map' : 'Add New Map'}</div>
                <div className="text-xs text-gray-400">Add a map option for players to vote on.</div>
              </div>
            </div>

            <div className="grid grid-cols-1 gap-4">
              <div>
                <label className="block text-xs font-medium text-gray-400 mb-2">Map Title *</label>
                <Input
                  value={form.title}
                  onChange={(e) => setForm((p) => ({ ...p, title: e.target.value }))}
                  placeholder="E.g. Survival Vanilla"
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-gray-400 mb-2">Image URL</label>
                <Input
                  value={form.image}
                  onChange={(e) => setForm((p) => ({ ...p, image: e.target.value }))}
                  placeholder="https://example.com/image.png"
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-gray-400 mb-2">Description</label>
                <Textarea
                  value={form.description}
                  onChange={(e) => setForm((p) => ({ ...p, description: e.target.value }))}
                  placeholder="Describe the map..."
                  rows={3}
                />
              </div>
              
              <div className="flex items-center gap-2 mt-2">
                <input 
                  type="checkbox" 
                  id="isActive"
                  checked={form.isActive}
                  onChange={(e) => setForm((p) => ({ ...p, isActive: e.target.checked }))}
                  className="w-4 h-4 rounded bg-gray-900 border-gray-700"
                />
                <label htmlFor="isActive" className="text-sm font-medium text-gray-300">Active (Visible to users)</label>
              </div>
            </div>

            <div className="mt-8 flex flex-col sm:flex-row gap-3">
              <Button onClick={handleSubmit} disabled={submitting} className="flex-1 justify-center">
                <span>{submitting ? 'Saving...' : 'Save Map'}</span>
              </Button>
              <Button
                type="button"
                variant="secondary"
                disabled={submitting}
                onClick={resetForm}
                className="flex-1 justify-center"
              >
                <span>Cancel</span>
              </Button>
            </div>
          </motion.div>
        </div>
      )}

      {loading ? (
        <Card className="rounded-[30px] border border-gray-200 bg-white dark:border-white/10 dark:bg-gray-950/25 p-8 text-center" hover={false}>
          <div className="text-gray-500">Loading maps...</div>
        </Card>
      ) : maps.length === 0 ? (
        <Card className="rounded-[30px] border border-gray-200 bg-white dark:border-white/10 dark:bg-gray-950/25 p-12 text-center" hover={false}>
          <FaMap className="mx-auto text-4xl mb-4 text-gray-400 dark:text-gray-600" />
          <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-2">No maps found</h3>
          <p className="text-gray-500 mb-6">Create your first map to start the voting process.</p>
          <Button onClick={() => setShowCreateModal(true)}>Add Map</Button>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {maps.map((map) => (
            <Card key={map._id} className="rounded-[30px] border border-gray-200 bg-white overflow-hidden p-0 dark:border-white/10 dark:bg-gray-950/25 transition-all" hover>
              {map.image && (
                <div className="w-full h-40 bg-gray-200 dark:bg-gray-800 relative">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={map.image} alt={map.title} className="w-full h-full object-cover" />
                  {!map.isActive && (
                    <div className="absolute inset-0 bg-black/60 flex items-center justify-center">
                      <Badge variant="warning">INACTIVE</Badge>
                    </div>
                  )}
                </div>
              )}
              <div className="p-5">
                <div className="flex justify-between items-start mb-2">
                  <h3 className="text-xl font-bold text-gray-900 dark:text-white truncate">{map.title}</h3>
                  <Badge variant="info" className="ml-2 whitespace-nowrap">{map.votesCount} Votes</Badge>
                </div>
                {map.description && (
                  <p className="text-sm text-gray-600 dark:text-gray-400 line-clamp-2 mb-4">{map.description}</p>
                )}
                
                <div className="flex items-center gap-2 mt-4 pt-4 border-t border-gray-100 dark:border-gray-800">
                  <Button variant="secondary" onClick={() => openEdit(map)} className="flex-1 py-2 h-auto text-xs">
                    <FaPen /> Edit
                  </Button>
                  <Button variant="secondary" onClick={() => handleDelete(map._id)} className="flex-1 py-2 h-auto text-xs !bg-red-500/10 !text-red-500 hover:!bg-red-500/20 !border-red-500/20">
                    <FaTrash /> Delete
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
