import { NextResponse } from 'next/server';

export async function POST(req: Request) {
    try {
        const body = await req.json();
        const { command } = body;
        const bridgeUrl = process.env.BRIDGE_URL;
        const bridgeToken = process.env.BRIDGE_TOKEN || 'vanakam-smp-secret';

        // Method 1: Ubuntu Bridge (Recommended)
        if (bridgeUrl) {
            console.log(`Forwarding command to Ubuntu Bridge: ${command}`);
            const response = await fetch(`${bridgeUrl}/api/bridge-input`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${bridgeToken}`
                },
                body: JSON.stringify({ command })
            });

            if (!response.ok) {
                const err = await response.text();
                return new NextResponse(`Bridge Error: ${err}`, { status: response.status });
            }
            return new NextResponse('Command sent via Bridge', { status: 200 });
        }

        // Method 2: Direct SSH Fallback (Local Dev)
        const sshHost = body.sshHost || process.env.SSH_HOST;
        const sshUser = body.sshUser || process.env.SSH_USER;
        const sshPass = body.sshPass || process.env.SSH_PASSWORD || process.env.SSH_PASS;
        const sshPort = parseInt(body.sshPort || process.env.SSH_PORT || '22', 10);

        if (!sshHost) {
            return new NextResponse('Error: SSH Host not configured', { status: 400 });
        }

        return new Promise<Response>((resolve) => {
            const { Client } = require('ssh2');
            const conn = new Client();
            
            conn.on('ready', () => {
                // Try to send to screen/tmux or just execute as bash
                // We'll target a screen session named 'minecraft' if it exists, otherwise just execute
                const finalCommand = `screen -ls | grep -q "minecraft" && screen -S minecraft -p 0 -X stuff "${command}\\n" || eval "${command}"`;
                
                conn.exec(finalCommand, (err: any) => {
                    conn.end();
                    if (err) {
                        resolve(new NextResponse(`SSH Error: ${err.message}`, { status: 500 }));
                    } else {
                        resolve(new NextResponse('Command sent via SSH', { status: 200 }));
                    }
                });
            }).on('error', (err: any) => {
                resolve(new NextResponse(`SSH Connection Error: ${err.message}`, { status: 500 }));
            }).connect({
                host: sshHost,
                port: sshPort,
                username: sshUser,
                password: sshPass,
                readyTimeout: 10000
            });
        });


    } catch (error: any) {
        console.error('Error in send-command route:', error);
        return new NextResponse(`Internal Server Error: ${error.message}`, { status: 500 });
    }
}
