import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import ForumReply from '@/models/ForumReply';
import ForumPost from '@/models/ForumPost';
import { requireAdmin, requireAuth } from '@/lib/session';
import Notification from '@/models/Notification';
import User from '@/models/User';
import { buildForumReputation, getForumReputationMap } from '@/lib/forumReputation';

function escapeRegex(text: string) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export async function GET(_request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    await dbConnect();

    const { id } = await params;
    const [threadReplies, legacyReplies] = await Promise.all([
      ForumPost.find({
        $or: [
          { rootId: id, parentId: { $ne: null } },
          // compat: replies viejos que no guardaban rootId
          { rootId: null, parentId: id },
        ],
      })
        .select('-likedBy')
        .sort({ createdAt: 1 })
        .limit(500)
        .lean(),
      ForumReply.find({ postId: id }).sort({ createdAt: 1 }).limit(500).lean(),
    ]);

    const normalized = [
      ...threadReplies.map((r: any) => ({
        _id: String(r._id),
        postId: id,
        rootId: typeof r.rootId === 'string' ? r.rootId : null,
        parentId: typeof r.parentId === 'string' ? r.parentId : id,
        userId: String(r.authorId || ''),
        username: String(r.authorUsername || ''),
        content: String(r.content || ''),
        createdAt: r.createdAt,
        likesCount: Number(r.likesCount || 0),
        views: Number(r.views || 0),
        media: Array.isArray(r.media) ? r.media : [],
        isLegacy: false,
      })),
      ...legacyReplies.map((r: any) => ({
        _id: String(r._id),
        postId: id,
        rootId: null,
        parentId: id,
        userId: String(r.userId || ''),
        username: String(r.username || ''),
        content: String(r.content || ''),
        createdAt: r.createdAt,
        likesCount: 0,
        views: 0,
        media: [],
        isLegacy: true,
      })),
    ].sort((a: any, b: any) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime());

    const usernames = Array.from(
      new Set(
        normalized
          .map((r: any) => (typeof r?.username === 'string' ? r.username.trim() : ''))
          .filter(Boolean)
      )
    );

    const userQueries = usernames.map((u) => ({ username: { $regex: new RegExp(`^${escapeRegex(u)}$`, 'i') } }));
    const users = userQueries.length
      ? await User.find({ $or: userQueries }).select('username avatar verified').lean()
      : [];

    const userByUsernameLower = new Map<string, { avatar: string | null; verified: boolean }>();
    for (const u of users as any[]) {
      const uname = typeof u?.username === 'string' ? u.username : '';
      if (!uname) continue;
      userByUsernameLower.set(uname.toLowerCase(), {
        avatar: typeof u?.avatar === 'string' ? u.avatar : null,
        verified: Boolean(u?.verified),
      });
    }

    const reputationMap = await getForumReputationMap(
      normalized.map((r: any) => ({
        id: String(r?.userId || ''),
        username: String(r?.username || ''),
      }))
    );

    const enriched = normalized.map((r: any) => {
      const uname = typeof r?.username === 'string' ? r.username : '';
      const meta = uname ? userByUsernameLower.get(uname.toLowerCase()) : undefined;
      return {
        ...r,
        userAvatar: meta?.avatar || null,
        userVerified: Boolean(meta?.verified),
        userReputation:
          reputationMap.get(String(r?.userId || '')) ||
          reputationMap.get(`u:${String(r?.username || '').trim().toLowerCase()}`) ||
          buildForumReputation(),
      };
    });

    return NextResponse.json(enriched);
  } catch (error) {
    console.error('Error fetching forum replies:', error);
    return NextResponse.json({ error: 'Error al obtener respuestas' }, { status: 500 });
  }
}

export async function POST(request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const user = await requireAuth();
    const body = await request.json().catch(() => ({}));

    const { id } = await params;
    const content = typeof body.content === 'string' ? body.content.trim() : '';
    const parentIdRaw = typeof (body as any).parentId === 'string' ? ((body as any).parentId as string).trim() : '';
    const parentId = parentIdRaw || id;
    const mediaRaw = Array.isArray((body as any).media) ? (body as any).media : [];
    const media = mediaRaw
      .filter((u: any) => typeof u === 'string')
      .map((u: string) => u.trim())
      .filter((u: string) => u.length > 0)
      .slice(0, 4);

    if (!content || content.length < 1 || content.length > 280) {
      return NextResponse.json({ error: 'Respuesta inválida' }, { status: 400 });
    }

    await dbConnect();

    const post = await ForumPost.findById(id).select('_id authorId title').lean();
    if (!post) {
      return NextResponse.json({ error: 'Publicación no encontrada' }, { status: 404 });
    }

    if (parentId !== id) {
      const parent = await ForumPost.findById(parentId).select('_id rootId parentId').lean();
      if (!parent) {
        return NextResponse.json({ error: 'Comentario no encontrado' }, { status: 404 });
      }

      const belongsToThread =
        String((parent as any).rootId || '') === id ||
        (String((parent as any).rootId || '') === '' && String((parent as any).parentId || '') === id);

      if (!belongsToThread) {
        return NextResponse.json({ error: 'Comentario inválido' }, { status: 400 });
      }
    }

    // Reply como post (hilo estilo Twitter)
    const title = content.length > 80 ? `${content.slice(0, 77)}...` : content;
    const created = await ForumPost.create({
      title: title.length >= 3 ? title : 'Respuesta',
      content,
      category: 'GENERAL',
      authorId: user.id,
      authorUsername: user.name,
      rootId: id,
      parentId,
      repostOf: null,
      media,
      repliesCount: 0,
    });

    await ForumPost.updateOne({ _id: id }, { $inc: { repliesCount: 1 } });

    // Notify post author (if different user)
    try {
      const authorId = String((post as any).authorId || '');
      if (authorId && authorId !== user.id) {
        await Notification.create({
          userId: authorId,
          title: 'Nueva respuesta en tu publicación',
          message: `${user.name} respondió: ${content.slice(0, 120)}${content.length > 120 ? '…' : ''}`,
          href: `/foro/${id}`,
          type: 'INFO',
        });
      }
    } catch {
      // ignore notification failures
    }

    return NextResponse.json(created, { status: 201 });
  } catch (error: any) {
    if (error.message === 'Unauthorized') {
      return NextResponse.json({ error: 'No autorizado' }, { status: 401 });
    }

    console.error('Error creating forum reply:', error);
    return NextResponse.json({ error: 'Error al crear respuesta' }, { status: 500 });
  }
}

export async function DELETE(request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    await requireAdmin();
    const body = await request.json().catch(() => ({}));
    const replyId = typeof body.replyId === 'string' ? body.replyId : '';

    if (!replyId) {
      return NextResponse.json({ error: 'replyId requerido' }, { status: 400 });
    }

    await dbConnect();
    const { id } = await params;

    // Intentar borrar reply tipo hilo (ForumPost)
    const reply = await ForumPost.findById(replyId).select('_id rootId parentId').lean();
    if (reply) {
      const isThreadReply =
        String((reply as any).rootId || '') === id ||
        (String((reply as any).rootId || '') === '' && String((reply as any).parentId || '') === id);

      if (isThreadReply) {
        // Reenganchar hijos al root (evita orfandad)
        await ForumPost.updateMany({ rootId: id, parentId: replyId }, { $set: { parentId: id } });
        await ForumPost.deleteOne({ _id: replyId });
        await ForumPost.updateOne({ _id: id }, { $inc: { repliesCount: -1 } });
        return NextResponse.json({ ok: true });
      }
    }

    // Fallback: reply legacy
    const deletedLegacy = await ForumReply.findOneAndDelete({ _id: replyId, postId: id }).select('_id');
    if (!deletedLegacy) {
      return NextResponse.json({ error: 'Respuesta no encontrada' }, { status: 404 });
    }

    await ForumPost.updateOne({ _id: id }, { $inc: { repliesCount: -1 } });

    return NextResponse.json({ ok: true });
  } catch (error: any) {
    if (error.message === 'Unauthorized' || error.message === 'Forbidden: Admin access required') {
      return NextResponse.json({ error: 'No autorizado' }, { status: 403 });
    }

    console.error('Error deleting forum reply:', error);
    return NextResponse.json({ error: 'Error al eliminar respuesta' }, { status: 500 });
  }
}
