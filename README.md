# Usage

- отключить в `/etc/libvirt/qemu.conf` selinux `security_driver = "selinux"` меняем на `security_driver = "none"`
- перезапускаем сервис `systemctl restart libvirt-bin.service`

## Установка terraform-libvirt-provider
- качаем [бинарник](https://github.com/dmacvicar/terraform-provider-libvirt/releases)
- помещаем в директорию `~/.terraform.d/plugins/terraform-provider-libvirt`
## Cloud-init

- тулзы для поготовки образа `libguestfs-tools`

### ssh config
```
cat ~/.ssh/config
Host 10.10.1.*
    user user
    IdentityFile ~/kvm-lab/rsa/id_rsa
```

### qemu

для создания "тонкого" диска из образа:
```
$ sudo qemu-img create -b /kvm-pool/images/CentOS-7-x86_64-GenericCloud-1907.qcow2 -f qcow2 /kvm-pool/images/tmpl.qcow2
Formatting '/kvm-pool/images/tmpl.qcow2', fmt=qcow2 size=8589934592 backing_file=/kvm-pool/images/CentOS-7-x86_64-GenericCloud-1907.qcow2 cluster_size=65536 lazy_refcounts=off refcount_bits=16
$ qemu-img info /kvm-pool/images/tmpl.qcow2 
image: /kvm-pool/images/tmpl.qcow2
file format: qcow2
virtual size: 8.0G (8589934592 bytes)
disk size: 196K
cluster_size: 65536
backing file: /kvm-pool/images/CentOS-7-x86_64-GenericCloud-1907.qcow2
Format specific information:
    compat: 1.1
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
```

