import dns.resolver
import json
import os
import socket
import sys

BACKENDS = os.environ.get('BACKENDS', '').split(' ')
BACKENDS_PORT = os.environ.get('BACKENDS_PORT', '8080')

if sys.argv[1] == 'hosts':
    try:
        hosts = open("/etc/hosts")
    except:
        exit(0)

    localhost = socket.gethostbyname(socket.gethostname())
    backends = []

    for host in hosts:
        if "0.0.0.0" in host:
            continue
        if "127.0.0.1" in host:
            continue
        if localhost in host:
            continue
        if "::" in host:
            continue
        if host.startswith("#"):
            continue

        host_ip = host.split()[0]
        if host_ip in [backend["ip"] for backend in backends]:
            continue
        backends.append({"ip": host_ip,
                         "port": BACKENDS_PORT})
    hosts.close()
    print(json.dumps({"backends": backends}))

elif sys.argv[1] == 'dns':
    ips = {}
    backends = []
    for index, backend_server in enumerate(BACKENDS):
        server_port = backend_server.split(':')
        host = server_port[0]
        port = server_port[1] if len(server_port) > 1 else BACKENDS_PORT

        try:
            records = dns.resolver.query(host)
        except Exception as err:
            print(json.dumps({"backends": backends}))
            exit(0)
        else:
            for ip in records:
                ips[str(ip)] = host

    with open('/opt/dns.backends', 'w') as bfile:
        bfile.write(
            ' '.join(sorted(ips))
        )

    for ip, host in ips.items():
        backends.append({"ip": ip,
                         "port": BACKENDS_PORT})

    print(json.dumps({"backends": backends}))
