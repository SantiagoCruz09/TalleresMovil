/*
Simple CORS proxy server for local development.
Usage:
  1. npm install
  2. node server.js

Then, in the Flutter web app (or any client), set the proxy URL to:
  http://localhost:8080/
and the client should concatenate the target URL after the proxy base. Example:
  http://localhost:8080/https://parking.visiontic.com.co/api/users

This server will forward the request to the target URL and return the response, adding permissive CORS headers.

Notes:
- This is for development/testing only. Do NOT use in production.
- Requires Node 14+ (recommended Node 18+ for native fetch). If Node <18, install node-fetch and adapt the code.
*/

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors());
app.use(bodyParser.raw({ type: '*/*', limit: '10mb' }));

// Proxy endpoint: the target URL is appended to the proxy base, for example:
// http://localhost:8080/https://api.example.com/path
app.all('/*', async (req, res) => {
  try {
    const original = req.originalUrl; // starts with '/https://...'
    const target = original.substring(1); // remove leading '/'
    if (!target.startsWith('http')) {
      return res.status(400).json({ error: 'Invalid target URL. Request should be /https://target...' });
    }

    // Build fetch options
    const fetch = global.fetch || (await import('node-fetch')).default;

    const headers = { ...req.headers };
    // Remove host header to avoid issues
    delete headers.host;

    const fetchOptions = {
      method: req.method,
      headers: headers,
      body: req.method === 'GET' || req.method === 'HEAD' ? undefined : req.body,
      redirect: 'follow'
    };

    const response = await fetch(target, fetchOptions);

    // forward status
    res.status(response.status);
    // copy headers
    response.headers.forEach((value, name) => {
      res.setHeader(name, value);
    });
    // ensure permissive CORS for dev
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    const buffer = await response.arrayBuffer();
    res.send(Buffer.from(buffer));
  } catch (err) {
    console.error('Proxy error:', err);
    res.status(500).json({ error: err.toString() });
  }
});

app.listen(PORT, () => {
  console.log(`CORS proxy listening on http://localhost:${PORT}/`);
});
