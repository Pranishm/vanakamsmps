import { NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import VoteMap from '@/models/VoteMap';
import VoteMapLog from '@/models/VoteMapLog';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';

export async function GET() {
  try {
    await dbConnect();
    
    const maps = await VoteMap.find({ isActive: true }).sort({ votesCount: -1 });
    
    const session = await getServerSession(authOptions);
    let userVote = null;
    
    if (session?.user?.id) {
      const log = await VoteMapLog.findOne({ userId: session.user.id || "" || "" });
      if (log) {
        userVote = log.mapId;
      }
    }
    
    return NextResponse.json({
      maps,
      userVote,
    });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
