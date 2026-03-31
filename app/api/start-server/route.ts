import { NextResponse } from 'next/server';

export async function POST(req: Request) {
    const encoder = new TextEncoder();

    // The tunnel URL pointing to the Ubuntu laptop (e.g. https://my-laptop-tunnel.ngrok.io/api/bridge-start)
    const bridgeUrl = process.env.UBUNTU_BRIDGE_URL || 'https://weak-rings-smoke.loca.lt/api/bridge-start';
    const bridgeToken = process.env.UBUNTU_BRIDGE_TOKEN || 'vanakam-smp-secret';

    if (!bridgeUrl) {
        const customReadable = new ReadableStream({
            start(controller) {
                controller.enqueue(encoder.encode('[Vercel Cloud] ERROR: Cannot reach Ubuntu Laptop.\n'));
                controller.enqueue(encoder.encode('[Vercel Cloud] Missing Environment Variable: UBUNTU_BRIDGE_URL\n'));
                controller.enqueue(encoder.encode('Please configure this variable in Vercel to point to your Ubuntu Bridge server (e.g., https://yourip/api/bridge-start).\n'));
                controller.close();
            }
        });
        return new NextResponse(customReadable, {
            headers: {
                'Content-Type': 'text/plain; charset=utf-8',
                'Transfer-Encoding': 'chunked'
            }
        });
    }

    try {
        const response = await fetch(bridgeUrl, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${bridgeToken}`,
                'Content-Type': 'application/json',
                'Bypass-Tunnel-Reminder': 'true',
                'User-Agent': 'VanakamSMP-Vercel-Bot'
            }
        });

        if (!response.body) {
            throw new Error("No readable stream received from the Bridge.");
        }

        return new NextResponse(response.body, {
            headers: {
                'Content-Type': 'text/plain; charset=utf-8',
                'Transfer-Encoding': 'chunked'
            }
        });

    } catch (error: any) {
        const customReadable = new ReadableStream({
            start(controller) {
                controller.enqueue(encoder.encode('[Vercel Cloud] CRITICAL ERROR connecting to Ubuntu bridge!\n'));
                controller.enqueue(encoder.encode(`Details: ${error.message}\n`));
                controller.enqueue(encoder.encode(`Attempted to fetch: ${bridgeUrl}\n`));
                controller.enqueue(encoder.encode(`Are you sure the Ubuntu bridge is running and exposed to the internet?`));
                controller.close();
            }
        });
        return new NextResponse(customReadable, {
            headers: {
                'Content-Type': 'text/plain; charset=utf-8',
                'Transfer-Encoding': 'chunked'
            }
        });
    }
}
