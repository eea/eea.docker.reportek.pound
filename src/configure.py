import socket
import json

try:
    hosts = open("/etc/hosts")
except:
    exit(0)

localhost = socket.gethostbyname(socket.gethostname())
backends = []

for host in hosts:
    if "0.0.0.0" in host or "127.0.0.1" in host or localhost in host or "::" in host or host.startswith("#"):
        continue
    host_ip = host.split()[0]
    if host_ip in [backend["ip"] for backend in backends]:
        continue
    backends.append({"ip": host_ip,
                     "port": "80"})
hosts.close()
print json.dumps({"backends": backends})
exit(0)
