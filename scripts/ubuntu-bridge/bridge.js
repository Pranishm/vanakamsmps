const express = require('express');
const { spawn } = require('child_process');

const app = express();
const PORT = 4000;
const SECRET_TOKEN = process.env.BRIDGE_TOKEN || 'vanakam-smp-secret';

app.use(express.json());

// Reference to keep the process alive
let activeProcess = null;

// Endpoint to send commands to the running process
app.post('/api/bridge-input', (req, res) => {
    const token = req.headers['authorization'];
    if (token !== `Bearer ${SECRET_TOKEN}`) {
        return res.status(401).send('Unauthorized\n');
    }

    const { command } = req.body;
    if (!activeProcess) {
        return res.status(400).send('No active server process to receive commands.\n');
    }

    console.log(`Writing command to stdin: ${command}`);
    activeProcess.stdin.write(command + '\n');
    res.status(200).send('Command sent to Ubuntu process.\n');
});

app.post('/api/bridge-start', (req, res) => {
    const token = req.headers['authorization'];
    if (token !== `Bearer ${SECRET_TOKEN}`) {
        return res.status(401).send('Unauthorized\n');
    }

    if (activeProcess) {
        return res.status(200).send('Process already running.\n');
    }

    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.setHeader('Transfer-Encoding', 'chunked');

    console.log("Initializing boot script: /home/pranish/VanakamSMP/web_start.sh");
    
    // Spawn the script
    activeProcess = spawn('bash', ['/home/pranish/VanakamSMP/web_start.sh']);

    activeProcess.stdout.on('data', (data) => {
        res.write(data.toString());
    });

    activeProcess.stderr.on('data', (data) => {
        res.write(data.toString());
    });

    activeProcess.on('close', (code) => {
        console.log(`Process closed with code ${code}`);
        activeProcess = null;
        res.write(`\nUbuntu process exited with code ${code}\n`);
        res.end();
    });

    activeProcess.on('error', (err) => {
        console.error(`Process error: ${err.message}`);
        activeProcess = null;
        res.write(`\nFailed to start subprocess: ${err.message}\n`);
        res.end();
    });
});

app.listen(PORT, () => {
    console.log(`🛡️ Ubuntu Bridge listening on http://localhost:${PORT}`);
    console.log(`Ready for interactive commands from vanakam.me`);
});

