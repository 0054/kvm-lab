# NIFI

## мониторинг праймори ноды 


работает на питоне 2, но должно и на 3 (не тестил)
```
#!/usr/bin/env python

import sys
import json
import urllib2
import platform

hostname = platform.node().split('.')[0]
addr = "http://{}:8888/nifi-api/controller/cluster".format(hostname)

def getData(url):
    return json.loads(urllib2.urlopen(addr).read())

def isPrimary(data):
    for node in data['cluster']['nodes']:
        if node['address'] == hostname:
            if node['roles'] and 'Primary Node' in node['roles']:
                print hostname + ' is Primary Node'
                sys.exit(0)
            else:
                print hostname + ' is Slave Node'
                sys.exit(1)

if __name__ == '__main__':
    isPrimary(getData(addr))
```
## конфиг для keepalived например

```
vrrp_script chk_nifi {
  script        "/path/to/script/check_primary_nifi_node.py"
  interval 2   # check every 2 seconds
  fall 2       # require 2 failures for KO
  rise 2       # require 2 successes for OK
}

vrrp_instance VRRP2 {
    interface ens192
    virtual_router_id 43
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 7vynr349qy
    }
    virtual_ipaddress {
        1.2.3.4/24
    }
    track_script {
        chk_nifi
    }
}

```
