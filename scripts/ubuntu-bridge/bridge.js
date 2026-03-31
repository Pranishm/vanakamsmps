const express = require('express');
const { spawn } = require('child_process');

const app = express();
const PORT = 4000;

// Extremely basic security token (optional but recommended!)
// Set it on your Ubuntu server like: export BRIDGE_TOKEN=my-secret-token
const SECRET_TOKEN = process.env.BRIDGE_TOKEN || 'vanakam-smp-secret';

app.use(express.json());

app.post('/api/bridge-start', (req, res) => {
    // 1. Verify token
    const token = req.headers['authorization'];
    if (token !== `Bearer ${SECRET_TOKEN}`) {
        res.status(401).send('Unauthorized connection attempt to Ubuntu Bridge.\n');
        return;
    }

    // 2. Setup streaming headers
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.setHeader('Transfer-Encoding', 'chunked');

    console.log("Incoming boot request from Vercel...");
    res.write('Connection to Ubuntu Laptop established...\n');
    res.write('Initializing boot script: /home/pranish/VanakamSMP/web_start.sh\n');

    // 3. Execute the script natively on the Ubuntu Laptop
    const child = spawn('/home/pranish/VanakamSMP/web_start.sh');

    child.stdout.on('data', (data) => {
        res.write(data.toString());
    });

    child.stderr.on('data', (data) => {
        res.write(data.toString());
    });

    child.on('close', (code) => {
        res.write(`\nUbuntu process exited with code ${code}\n`);
        res.end();
    });

    child.on('error', (err) => {
        res.write(`\nFailed to start subprocess on Ubuntu: ${err.message}\n`);
        res.end();
    });
});

app.listen(PORT, () => {
    console.log(`🛡️ Ubuntu Bridge listening on http://localhost:${PORT}`);
    console.log(`Waiting for signals from vanakam.me Vercel backend...`);
});
