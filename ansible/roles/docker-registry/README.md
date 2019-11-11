# Docker Registry

# Requirements
- Генерируем сертификаты: 
```
cd files
openssl req -newkey rsa:4096 -nodes -sha256 -keyout domain.key -x509 -days 365 -out domain.crt
```
- Генерируем логин/пароль: 
```
docker run --rm --entrypoint htpasswd registry:2 -Bbn user q1q1q1 > htpasswd
```
- Сертификат надо применить на клиентах:
```
cp files/domain.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
systemctl restart docker.service
```


# Example Playbook
```
- hosts: server
  roles:
    - docker-registry
```
```
curl -X GET https://user:password@1.2.3.4:5000/v2/_catalog
```

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
