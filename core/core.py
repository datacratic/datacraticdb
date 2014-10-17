#!/usr/bin/python
# launcher.py
# Jeremy Barnes, 16 October 2014
# HTTP server that will sanitize and launch docker containers
# Designed to avoid the Docker REST API needing to be exposed to
# the internet

import BaseHTTPServer, SimpleHTTPServer, SocketServer, ssl
from os import chdir

import argparse

parser = argparse.ArgumentParser(description='Simple REST docker launcher.')
parser.add_argument('--port', dest='port', default=8000,
                    help='Port to listen on')

args = parser.parse_args()

PORT = args.port

chdir("./static")

Handler = SimpleHTTPServer.SimpleHTTPRequestHandler

httpd = BaseHTTPServer.HTTPServer(('0.0.0.0', PORT), Handler)
#httpd.socket = ssl.wrap_socket (httpd.socket, certfile='path/to/localhost.pem', server_side=True)

print "serving at port", PORT
httpd.serve_forever()
