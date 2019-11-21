
```while true; do curl http://10.10.1.15:8080  --output /dev/null -s  --write-out '%{http_code}-'; done```
