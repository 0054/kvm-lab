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
    user centos
    IdentityFile ~/kvm-lab/rsa/id_rsa
```

> ### статьи на почитать:

> - https://stafwag.github.io/blog/blog/2019/03/03/howto-use-centos-cloud-images-with-cloud-init/
> - https://scottlinux.com/2017/05/08/set-password-or-ssh-key-for-centos-cloud-images/


