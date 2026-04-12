import { NextResponse } from 'next/server';
import dbConnect from '@/lib/mongodb';
import User from '@/models/User';

export async function GET() {
  try {
    await dbConnect();
    
    // Top 10 by loyalty points
    const topUsers = await User.find({ isBanned: false })
      .sort({ loyaltyLifetimePoints: -1 })
      .limit(10)
      .select('username minecraftUsername loyaltyLifetimePoints avatar')
      .lean();

    return NextResponse.json(topUsers);
  } catch (error) {
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
