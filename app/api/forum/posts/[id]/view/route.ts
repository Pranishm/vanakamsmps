import { NextRequest, NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import ForumPost from '@/models/ForumPost';

export async function POST(_request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    await dbConnect();

    const { id } = await params;
    const updated = await ForumPost.findByIdAndUpdate(
      id,
      { $inc: { views: 1 } },
      { returnDocument: 'after' }
    ).select('views');

    if (!updated) {
      return NextResponse.json({ error: 'Publicación no encontrada' }, { status: 404 });
    }

    return NextResponse.json({ views: updated.views });
  } catch (error) {
    console.error('Error incrementing forum post views:', error);
    return NextResponse.json({ error: 'Error al actualizar vistas' }, { status: 500 });
  }
}
