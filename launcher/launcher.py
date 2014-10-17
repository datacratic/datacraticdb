#!/usr/bin/python
# launcher.py
# Jeremy Barnes, 16 October 2014
# HTTP server that will sanitize and launch docker containers
# Designed to avoid the Docker REST API needing to be exposed to
# the internet

import BaseHTTPServer, SimpleHTTPServer, SocketServer, ssl

import argparse

parser = argparse.ArgumentParser(description='Simple REST docker launcher.')
parser.add_argument('--port', dest='port', default=7331,
                    help='Port to listen on')

args = parser.parse_args()

PORT = args.port

class RestHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_GET(self):
        print self.client_address
        print self.command
        print self.path
        print self.request_version
        print self.headers

        self.send_response(200)
        self.send_header('Content-type','application/json')
        self.end_headers()
        # Send the html message
        self.wfile.write("{ \"hello\": \"world\" }");
        return

    def do_POST(self):
        print self.client_address
        print self.command
        print self.path
        print self.request_version
        print self.headers

        self.send_response(200)
        self.send_header('Content-type','application/json')
        self.end_headers()
        # Send the html message
        self.wfile.write("{ \"hello\": \"world\" }");
        return


Handler = RestHandler

httpd = BaseHTTPServer.HTTPServer(('localhost', PORT), Handler)
#httpd.socket = ssl.wrap_socket (httpd.socket, certfile='path/to/localhost.pem', server_side=True)

print "serving at port", PORT
httpd.serve_forever()

