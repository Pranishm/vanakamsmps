import { NextResponse } from 'next/server';
import { Client } from 'ssh2';

export async function POST(req: Request) {
    const encoder = new TextEncoder();
    
    // Direct SSH / Port Forwarding Method
    const sshHost = process.env.SSH_HOST || '182.65.189.222'; // Router Public IP
    const sshUser = process.env.SSH_USER || 'pranish';
    const sshPass = process.env.SSH_PASS || '200813'; // Laptop Password

    if (!sshHost || !sshPass) {
        const customReadable = new ReadableStream({
            start(controller) {
                controller.enqueue(encoder.encode('[Vercel Cloud] ERROR: Missing SSH Credentials.\n'));
                controller.enqueue(encoder.encode('Please configure SSH_HOST and SSH_PASS environment variables.\n'));
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

    const customReadable = new ReadableStream({
        start(controller) {
            controller.enqueue(encoder.encode('--- SECURE SSH TERMINAL UPLINK ---\n'));
            controller.enqueue(encoder.encode(`Connecting directly to Public IP: ${sshHost}...\n`));

            const conn = new Client();

            conn.on('ready', () => {
                controller.enqueue(encoder.encode('✅ SSH Authentication Successful!\n'));
                controller.enqueue(encoder.encode('Executing Minecraft Boot Script directly on Ubuntu Laptop...\n'));
                
                conn.exec('bash /home/pranish/VanakamSMP/web_start.sh', (err, stream) => {
                    if (err) {
                        controller.enqueue(encoder.encode(`\n[SSH Exec Error] Failed to run command: ${err.message}\n`));
                        conn.end();
                        controller.close();
                        return;
                    }
                    
                    stream.on('data', (data: any) => {
                        controller.enqueue(encoder.encode(data.toString()));
                    }).stderr.on('data', (data: any) => {
                        controller.enqueue(encoder.encode(data.toString()));
                    }).on('close', (code: any, signal: any) => {
                        controller.enqueue(encoder.encode(`\n[SSH Session Closed - Exit Code: ${code}]\n`));
                        conn.end();
                        controller.close();
                    });
                });
            }).on('error', (err) => {
                controller.enqueue(encoder.encode(`\n❌ [SSH Connection Error]: ${err.message}\n`));
                controller.enqueue(encoder.encode('Ensure your Wi-Fi router is Port Forwarding Port 22 to your laptop IP!\n'));
                controller.close();
            }).connect({
                host: sshHost,
                port: 22,
                username: sshUser,
                password: sshPass,
                readyTimeout: 10000 // Fails fast if port 22 is closed
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
