import { NextResponse } from 'next/server';
import { requireAdmin } from '@/lib/session';
import dbConnect from '@/lib/mongodb';
import VoteMap from '@/models/VoteMap';

export async function GET() {
  try {
    await requireAdmin();
    await dbConnect();
    
    const maps = await VoteMap.find().sort({ createdAt: -1 });
    
    return NextResponse.json(maps);
  } catch (error: any) {
    if (error.message === 'Unauthorized' || error.message === 'Forbidden: Admin access required') {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 403 });
    }
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    await requireAdmin();
    await dbConnect();
    
    const body = await req.json();
    const { title, description, image, isActive } = body;
    
    if (!title) {
      return NextResponse.json({ error: 'Title is required' }, { status: 400 });
    }
    
    const newMap = await VoteMap.create({ title, description, image, isActive });
    
    return NextResponse.json(newMap);
  } catch (error: any) {
    if (error.message === 'Unauthorized' || error.message === 'Forbidden: Admin access required') {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 403 });
    }
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
