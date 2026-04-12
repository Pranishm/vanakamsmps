import { NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import VoteMap from '@/models/VoteMap';
import VoteMapLog from '@/models/VoteMapLog';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';

export async function POST(req: Request) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { mapId } = await req.json();
    if (!mapId) return NextResponse.json({ error: 'Map ID required' }, { status: 400 });

    await dbConnect();
    
    // Check if map exists and is active
    const voteMap = await VoteMap.findOne({ _id: mapId, isActive: true });
    if (!voteMap) return NextResponse.json({ error: 'Map not found or inactive' }, { status: 404 });
    
    // Check if user already voted
    const existingLog = await VoteMapLog.findOne({ userId: session.user.id || "" || "" });
    
    if (existingLog) {
      if (existingLog.mapId.toString() === mapId) {
        return NextResponse.json({ message: 'Already voted for this map' });
      }
      
      // Decrease old map count
      await VoteMap.updateOne(
        { _id: existingLog.mapId },
        { $inc: { votesCount: -1 } }
      );
      
      // Update log
      existingLog.mapId = mapId;
      await existingLog.save();
      
      // Increase new map count
      await VoteMap.updateOne(
        { _id: mapId },
        { $inc: { votesCount: 1 } }
      );
      
      return NextResponse.json({ success: true, message: 'Vote changed' });
    }
    
    // New vote
    await VoteMapLog.create({ userId: session.user.id || "" || "", mapId });
    await VoteMap.updateOne(
      { _id: mapId },
      { $inc: { votesCount: 1 } }
    );
    
    return NextResponse.json({ success: true, message: 'Vote cast' });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
