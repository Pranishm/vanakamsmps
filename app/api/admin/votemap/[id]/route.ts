import { NextResponse } from 'next/server';
import { requireAdmin } from '@/lib/session';
import dbConnect from '@/lib/mongodb';
import VoteMap from '@/models/VoteMap';
import VoteMapLog from '@/models/VoteMapLog';

export async function PUT(req: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    await requireAdmin();
    const { id } = await params;
    
    await dbConnect();
    
    const body = await req.json();
    const { title, description, image, isActive } = body;
    
    const map = await VoteMap.findByIdAndUpdate(
      id,
      { title, description, image, isActive },
      { new: true }
    );
    
    if (!map) return NextResponse.json({ error: 'Map not found' }, { status: 404 });
    
    return NextResponse.json(map);
  } catch (error: any) {
    if (error.message === 'Unauthorized' || error.message === 'Forbidden: Admin access required') {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 403 });
    }
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function DELETE(req: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    await requireAdmin();
    const { id } = await params;
    
    await dbConnect();
    
    const map = await VoteMap.findByIdAndDelete(id);
    if (!map) return NextResponse.json({ error: 'Map not found' }, { status: 404 });
    
    // Also delete associated votes logs
    await VoteMapLog.deleteMany({ mapId: id });
    
    return NextResponse.json({ success: true });
  } catch (error: any) {
    if (error.message === 'Unauthorized' || error.message === 'Forbidden: Admin access required') {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 403 });
    }
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
