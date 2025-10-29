CORS proxy (development only)

This small proxy forwards requests to a target URL and adds permissive CORS headers so you can test requests from the browser while developing.

IMPORTANT: Use only for development. Do NOT expose this proxy in production.

Quick start

1. Install dependencies

```bash
cd tools/cors-proxy
npm install
```

2. Run the proxy

```bash
node server.js
# or
npm start
```

3. In the app's registration screen (web), enable "Usar proxy CORS" and set the proxy URL to:

```
http://localhost:8080/
```

Then the client will request:

```
http://localhost:8080/https://parking.visiontic.com.co/api/users
```

and the proxy will forward the request to the parking API and return the response with CORS headers.

If you prefer, you can use a public proxy (not recommended) like https://cors-anywhere.herokuapp.com/ but those services often require activation.

Troubleshooting

- If you see errors from the proxy about the target URL, ensure you include the full target (including https://) after the proxy base.
- For large requests, you may need to increase the bodyParser limit in server.js.
