import { exec } from 'child_process';
import { NextResponse } from 'next/server';

export async function POST(req: Request) {
    console.log("Starting the Minecraft network...");

    return new Promise<NextResponse>((resolve) => {
        // This executes the hidden bash script on your Ubuntu laptop
        exec('/home/pranish/VanakamSMP/web_start.sh', (error, stdout, stderr) => {
            if (error) {
                console.error(`Start failed: ${error.message}`);
                resolve(NextResponse.json({ success: false, message: 'Failed to boot server.' }, { status: 500 }));
                return;
            }
            
            console.log("Server booted successfully!");
            resolve(NextResponse.json({ success: true, message: 'VanakamSMP is booting up in the background!' }));
        });
    });
}
