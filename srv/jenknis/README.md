
## api
чуть чуть почитать про АПИ можно по ссылке
```
http://10.10.1.12/crumbIssuer/api/
```

для работы по api так же нужен api token делается в личных настройках

далее схема такая:
```
curl --user 'admin:apitoken' -d "Jenkins-Crumb=3a3b9fa488d35bee6a108fd7c354d33e9d323bdda52a01f905a698070a1461fe" --data-urlencode "script=$(<./script.groovy)" http://10.10.1.12/scriptText
``` 
CSRF можно передавать как хэдер 
```
curl ... -H "Jenkins-Crumb:3a3b9fa488d35bee6a108fd7c354d33e9d323bdda52a01f905a698070a1461fe" ...
```

### run_script.sh
```
./run_script.sh /path/to/script.groovy
```


## CSRF
Cross site request forgery - эта хрень для большей секурности
проверка включен ли CSRF
```
curl --user 'admin:q1q1q1' -s http://10.10.1.12/api/json?pretty=true 2> /dev/null | python -c 'import sys,json;exec "try:\n  j=json.load(sys.stdin)\n  print str(j[\"useCrumbs\"]).lower()\nexcept:\n  pass"'
``` 
как обойти?
 - выключить
 - использовать специальный токен

получить токен:
 ```
curl http://admin:q1q1q1@10.10.1.12/crumbIssuer/api/json?pretty=true
or
wget -q --auth-no-challenge --user admin --password q1q1q1 --output-document - 'http://10.10.1.12/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'
 ```
это возвращает токен который надо  добавлять в хедер в виде:
```
Jenkins-Crumb:df39b70c5284af27cafbfef037306c9ff4f2974ae8770a4081784a5ea3ac212e
```


