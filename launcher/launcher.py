#!/usr/bin/python
# launcher.py
# Jeremy Barnes, 16 October 2014
# HTTP server that will sanitize and launch docker containers
# Designed to avoid the Docker REST API needing to be exposed to
# the internet

import BaseHTTPServer, SimpleHTTPServer, SocketServer, ssl
import json
import argparse
import subprocess
import sys

parser = argparse.ArgumentParser(description='Simple REST docker launcher.')
parser.add_argument('--port', dest='port', default=7331,
                    help='Port to listen on')

args = parser.parse_args()

PORT = args.port

class RestHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_GET(self):

        try:
            split_path = self.path.split('/')

            if split_path[1] == 'v1' and split_path[2] == "version" and len(split_path) == 3:

                self.send_response(200)
                self.send_header('Content-type','application/json')
                self.end_headers()

                res = {}
                res['service'] = "DatacraticDB Launcher"
                res['version'] = "0.01"

                self.wfile.write(json.dumps(res));
                return
        except:
            print "Unexpected error:", sys.exc_info()[0]            
            print sys.exc_info()

            self.send_response(500)
            self.end_headers()
            self.wfile.write(sys.exc_info()[0])
            return
        
        self.send_response(404)
        self.end_headers()
        self.wfile.write("Unknown resource " + self.command + " " + self.path);
        return

    def do_POST(self):
        print self.client_address
        print self.command
        print self.path
        print self.request_version
        print self.headers

        try:
            split_path = self.path.split('/')

            print split_path

            if split_path[1] == 'v1' and split_path[2] == "services" and len(split_path) == 4:

                name = split_path[3]

                content_len = int(self.headers.getheader('content-length', 0))
                post_body = self.rfile.read(content_len)

                payload = json.loads(post_body)

                print payload

                options = [];
                options.extend(['--name', name])

                cmdline = [ "docker", "run", "-d" ]
                cmdline.extend(options)
                cmdline.append(payload['container'])

                if 'cmdline' in payload:
                    cmdline.extend(payload['cmdline'])

                print cmdline

                try:
                    output = subprocess.check_output(cmdline)
                except:
                    self.send_response(400)
                    self.end_headers()
                    self.wfile.write(sys.exc_info()[0])
                    return

                print output

                self.send_response(200)
                self.send_header('Content-type','application/json')
                self.end_headers()

                res = {}
                res['id'] = output

                self.wfile.write(json.dumps(res));
                return
        except:
            print "Unexpected error:", sys.exc_info()[0]            
            print sys.exc_info()

            self.send_response(500)
            self.end_headers()
            self.wfile.write(sys.exc_info()[0])
            return
        
        self.send_response(404)
        self.end_headers()
        self.wfile.write("Unknown resource " + self.command + " " + self.path);
        return


Handler = RestHandler

httpd = BaseHTTPServer.HTTPServer(('localhost', PORT), Handler)
#httpd.socket = ssl.wrap_socket (httpd.socket, certfile='path/to/localhost.pem', server_side=True)

print "serving at port", PORT
httpd.serve_forever()

