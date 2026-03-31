import { spawn } from 'child_process';
import { NextResponse } from 'next/server';

export async function POST(req: Request) {
    const encoder = new TextEncoder();

    const customReadable = new ReadableStream({
        start(controller) {
            controller.enqueue(encoder.encode('Initializing boot script natively on Ubuntu host...\n'));

            // Use spawn to execute and stream data 
            const child = spawn('/home/pranish/VanakamSMP/web_start.sh');

            child.stdout.on('data', (data) => {
                controller.enqueue(encoder.encode(data.toString()));
            });

            child.stderr.on('data', (data) => {
                controller.enqueue(encoder.encode(data.toString()));
            });

            child.on('close', (code) => {
                controller.enqueue(encoder.encode(`\nProcess exited with code ${code}\n`));
                controller.close();
            });

            child.on('error', (err) => {
                controller.enqueue(encoder.encode(`\nFailed to start subprocess: ${err.message}\n`));
                // Add troubleshooting message dynamically about Windows line endings
                if (err.message.includes('ENOENT')) {
                    controller.enqueue(encoder.encode(`\n[System] ENOENT detected. If the file exists, it might have Windows line endings (\\r\\n). Run: dos2unix /home/pranish/VanakamSMP/web_start.sh\n`));
                }
                controller.close();
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
