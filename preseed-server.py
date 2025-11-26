#!/usr/bin/env python3
"""
HTTP server to serve preseed.cfg with detailed logging
"""

import http.server
import socketserver
import sys
import os
from datetime import datetime
from pathlib import Path

class LoggingHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP request handler with detailed logging"""

    def log_message(self, format, *args):
        """Override to add timestamp and colors"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Format the message
        message = format % args

        # Add colors for better visibility
        if "GET" in message and "preseed" in message:
            # Highlight preseed requests
            print(f"\n✓ [{timestamp}] PRESEED REQUEST: {message}")
        elif "GET" in message and "200" in message:
            # Successful requests
            print(f"  [{timestamp}] ✓ {message}")
        elif "404" in message:
            # 404 errors
            print(f"  [{timestamp}] ✗ {message}")
        else:
            # Other messages
            print(f"  [{timestamp}] {message}")

    def do_GET(self):
        """Handle GET requests"""
        # Log the request
        if "preseed" in self.path.lower():
            print(f"\n{'='*70}")
            print(f"PRESEED REQUESTED at {datetime.now().strftime('%H:%M:%S')}")
            print(f"Path: {self.path}")
            print(f"Client: {self.client_address[0]}:{self.client_address[1]}")
            print(f"{'='*70}")

        # Call parent implementation
        super().do_GET()

    def end_headers(self):
        """Add custom headers"""
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000

    # Change to the directory containing preseed.cfg
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    print(f"""
╔══════════════════════════════════════════════════════════════════════╗
║           PRESEED HTTP SERVER WITH LOGGING                          ║
╚══════════════════════════════════════════════════════════════════════╝

Server Details:
  • Listening on: 0.0.0.0:{port}
  • Working directory: {script_dir}
  • Serving: preseed.cfg

Access URLs:
  • Local: http://localhost:{port}/preseed.cfg
  • From VM (NAT): http://10.0.2.2:{port}/preseed.cfg

Instructions:
  1. Boot the VM
  2. Select "Automated install" from boot menu
  3. When prompted for preseed location, enter:
     http://10.0.2.2:{port}/preseed.cfg
  4. Watch the logs below as installation proceeds

Press Ctrl+C to stop the server
{'─'*70}

""")

    Handler = LoggingHTTPRequestHandler
    with socketserver.TCPServer(("", port), Handler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n\n✓ Server stopped")
            sys.exit(0)

if __name__ == '__main__':
    main()
