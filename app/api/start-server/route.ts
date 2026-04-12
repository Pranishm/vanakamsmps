import { NextResponse } from 'next/server';
import { Client } from 'ssh2';

export async function POST(req: Request) {
    const encoder = new TextEncoder();
    
    const body = await req.json().catch(() => ({}));
    
    const sshHost = body.sshHost || process.env.SSH_HOST;
    const sshUser = body.sshUser || process.env.SSH_USER;
    const sshPass = body.sshPass || process.env.SSH_PASS || process.env.SSH_PASSWORD;
    const sshPort = parseInt(body.sshPort || process.env.SSH_PORT || '22', 10);

    if (!sshHost) {
        return new NextResponse('Error: SSH Host not configured. Please set it in the mobile app.', { status: 400 });
    }
    const bridgeUrl = process.env.BRIDGE_URL;
    const bridgeToken = process.env.BRIDGE_TOKEN || 'vanakam-smp-secret';

    const customReadable = new ReadableStream({
        async start(controller) {
            if (body.sshHost) {
                controller.enqueue(encoder.encode(`ℹ️ Using custom configuration: ${sshUser}@${sshHost}\n`));
            }
            // Priority 1: Ubuntu Bridge (Reliable, Vercel-friendly)
            if (bridgeUrl) {
                controller.enqueue(encoder.encode('--- UBUNTU BRIDGE UPLINK ---\n'));
                controller.enqueue(encoder.encode(`Connecting to bridge at: ${bridgeUrl}...\n`));
                
                try {
                    const response = await fetch(`${bridgeUrl}/api/bridge-start`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'Authorization': `Bearer ${bridgeToken}`
                        }
                    });

                    if (!response.ok) {
                        const errorText = await response.text();
                        controller.enqueue(encoder.encode(`❌ Bridge Error (${response.status}): ${errorText}\n`));
                        controller.close();
                        return;
                    }

                    const reader = response.body?.getReader();
                    if (reader) {
                        let done = false;
                        while (!done) {
                            const { value, done: readerDone } = await reader.read();
                            done = readerDone;
                            if (value) controller.enqueue(value);
                        }
                    }
                    controller.enqueue(encoder.encode('\n✅ Bridge sequence completed.\n'));
                } catch (err: any) {
                    controller.enqueue(encoder.encode(`❌ Failed to reach Ubuntu Bridge: ${err.message}\n`));
                    controller.enqueue(encoder.encode('Make sure the bridge is running on your Ubuntu laptop and the tunnel/URL is correct.\n'));
                }
                controller.close();
                return;
            }

            // Priority 2: Direct SSH (Great for Local Dev)
            controller.enqueue(encoder.encode(`--- DIRECT SSH TERMINAL (Local Dev Mode: ${sshHost}) ---\n`));
            controller.enqueue(encoder.encode(`Connecting to ${sshUser}@${sshHost}...\n`));

            const conn = new Client();
            const timeoutMs = 30000;
            const handshakeTimeout = setTimeout(() => {
                controller.enqueue(encoder.encode(`\n⚠️ Handshake taking too long (> ${timeoutMs/1000}s)...\n`));
                controller.enqueue(encoder.encode('Suggestions:\n 1. Is your Ubuntu laptop ASLEEP?\n 2. Are both devices on the SAME WiFi?\n 3. Can you "ping ${sshHost}" from your terminal?\n'));
            }, 10000);

            conn.on('ready', () => {
                clearTimeout(handshakeTimeout);
                controller.enqueue(encoder.encode('✅ SSH Connected successfully!\n'));
                controller.enqueue(encoder.encode('Command: bash /home/pranish/VanakamSMP/web_start.sh\n\n'));
                
                conn.exec('bash /home/pranish/VanakamSMP/web_start.sh', (err, stream) => {
                    if (err) {
                        controller.enqueue(encoder.encode(`\n[SSH Exec Error] Failed: ${err.message}\n`));
                        conn.end();
                        controller.close();
                        return;
                    }
                    
                    stream.on('data', (data: any) => {
                        controller.enqueue(encoder.encode(data.toString()));
                    }).stderr.on('data', (data: any) => {
                        controller.enqueue(encoder.encode(data.toString()));
                    }).on('close', (code: any) => {
                        controller.enqueue(encoder.encode(`\n[SSH Session Closed - Exit Code: ${code ?? 0}]\n`));
                        conn.end();
                        controller.close();
                    });
                });
            }).on('error', (err) => {
                clearTimeout(handshakeTimeout);
                controller.enqueue(encoder.encode(`\n❌ [SSH Error]: ${err.message || 'Unknown Error'}\n`));
                if (err.message.includes('handshake')) {
                    controller.enqueue(encoder.encode('\nPossible causes:\n - Laptop is shutting down or sleeping.\n - Network congestion.\n - Incorrect password or user.\n'));
                } else if (err.message.includes('ETIMEDOUT')) {
                    controller.enqueue(encoder.encode('\nPossible causes:\n - Devices are not on the same network.\n - Firewall is blocking Port 22.\n'));
                }
                controller.enqueue(encoder.encode(`\nTry this in your Mac terminal to test: "ssh ${sshUser}@${sshHost}"\n`));
                controller.close();
            }).connect({
                host: sshHost,
                port: sshPort,
                username: sshUser,
                password: sshPass,
                readyTimeout: timeoutMs,
                keepaliveInterval: 1000,
                keepaliveCountMax: 3
            });

        }
    });


    return new NextResponse(customReadable, {
        headers: {
            'Content-Type': 'text/plain; charset=utf-8',
            'Transfer-Encoding': 'chunked'
        }
    });
}
