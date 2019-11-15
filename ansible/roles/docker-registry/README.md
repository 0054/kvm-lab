# Docker Registry

# Requirements
- Генерируем сертификаты: 
```
vim /etc/ssl/openssl.cnf # добавляем в раздел v3_ca
subjectAltName = IP:10.10.1.11
```
```
cd files
openssl req -newkey rsa:4096 -nodes -sha256 -keyout domain.key -x509 -days 365 -out domain.crt
```
- Генерируем логин/пароль: 
```
docker run --rm --entrypoint htpasswd registry:2 -Bbn user password > htpasswd
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

