import json
import shutil
import time
from pathlib import Path

cpu = [int(value) for value in Path('/proc/stat').read_text().splitlines()[0].split()[1:9]]
mem = {}
for line in Path('/proc/meminfo').read_text().splitlines():
    key, value = line.split(':', 1)
    mem[key] = int(value.split()[0])
disk = shutil.disk_usage('/')
network = {}
for line in Path('/proc/net/dev').read_text().splitlines()[2:]:
    name, values = line.split(':', 1)
    name = name.strip()
    # Physical interfaces only: avoid double-counting VPNs, bridges and loopback.
    if not (Path('/sys/class/net') / name / 'device').exists():
        continue
    counters = values.split()
    network[name] = {'rx': int(counters[0]), 'tx': int(counters[8])}
print(json.dumps({'time': time.monotonic(), 'network': network, 'cpuTotal': sum(cpu), 'cpuIdle': cpu[3] + cpu[4],
                  'ramUsed': (mem['MemTotal'] - mem['MemAvailable']) / 1048576,
                  'ramTotal': mem['MemTotal'] / 1048576,
                  'diskUsed': disk.used / 1073741824, 'diskTotal': disk.total / 1073741824}))
