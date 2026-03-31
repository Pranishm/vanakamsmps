import { NextResponse } from 'next/server';
import { getServerStatus } from '@/lib/minecraft';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const host = searchParams.get('host') || process.env.MINECRAFT_SERVER_IP || 'vanakam.me';
    const port = parseInt(searchParams.get('port') || process.env.MINECRAFT_SERVER_PORT || '25565');
    
    // Fetch base server status globally using your existing working lib
    const status = await getServerStatus(host, port);
    
    // Attempt internal fetch for admins
    let adminsCount = 0;
    try {
      const staffRes = await fetch(`https://vanakam.me/api/server/staff-online?host=${host}&port=${port}`, { next: { revalidate: 0 }});
      if (staffRes.ok) {
        const staffData = await staffRes.json();
        adminsCount = staffData.count || 0;
      }
    } catch(e) { /* ignore internal fetch err */ }

    const widgetData = {
      server: status?.online ? 'online' : 'offline',
      admins_online: adminsCount,
      players: status?.players?.online || 0,
      max_players: status?.players?.max || 100
    };
    
    return NextResponse.json(widgetData);
  } catch (error) {
    console.error('Android Widget Server status error:', error);
    return NextResponse.json(
      { server: "offline", admins_online: 0, players: 0, max_players: 0 },
      { status: 200 } // Send 200 with offline data so widget doesn't crash
    );
  }
}

// Disable caching for real-time widget status updating
export const revalidate = 0;
