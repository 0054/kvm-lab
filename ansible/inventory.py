#!/usr/bin/env python3

import libvirt
import json

# def getLeases():
#     with open('/var/lib/libvirt/dnsmasq/terraform_network.hostsfile', 'r') as f:
#         leases = dict()
#         for line in f.read().split():
#             d = line.split(',')
#             hostname = d[2]
#             mac = d[0]
#             ip = d[1]
#             leases[hostname] = { 'mac': mac, 'ip': ip }
#     return leases

# def getLeases():
#     with libvirt.open() as conn:
#         leases = conn.networkLookupByName("terraform_network").DHCPLeases()
#     return leases

def updateInventory(data):
    inventory = {}
    inventory['_meta'] = {'hostvars': {}} 
    for vmData in data:
        hostname = vmData['hostname']
        ip = vmData['ip']
        group = vmData['group']
        
        if not inventory.get(group):
            inventory[group] = {'hosts': [],}
        inventory[group]['hosts'].append(hostname)
        inventory['_meta']['hostvars'][hostname] = {
                'ansible_host': ip,
                'ansible_user': 'user',
                'ansible_connection': 'ssh',
                }
    return inventory

def makeInventory():
    dataList = list()
    with libvirt.open() as conn:
        for vm in conn.listAllDomains():
            if vm.isActive():
                i = 0 
                ip = int()
                while True:
                    interface = vm.interfaceAddresses(i).get('eth0')
                    if interface:
                        ip = interface['addrs'][0]['addr']
                        break
                    i +=1
                if '-' in vm.name():
                    group = vm.name().split('-')[0]
                else:
                    group = 'ungrouped'

                vmData = { 
                        'hostname': vm.name(),
                        'group': group,
                        'ip': ip
                        }
                dataList.append(vmData)
    inventory = updateInventory(dataList)
    return json.dumps(inventory, indent=4)


if __name__ == "__main__":
    print(makeInventory())
