#!/usr/bin/env python3
"""Minimal HTTP backend for reverse-proxy practice."""

from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os


PORT = int(os.environ.get("PORT", "3000"))


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = json.dumps(
            {
                "status": "ok",
                "service": "backend",
                "path": self.path,
                "message": "Hello from the backend container",
            }
        ).encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        # Keep container logs readable.
        print("%s - %s" % (self.address_string(), fmt % args), flush=True)


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Backend listening on 0.0.0.0:{PORT}", flush=True)
    server.serve_forever()
