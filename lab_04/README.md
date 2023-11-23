# Установка расширения `plpython3`

1. Заходим в контейнер из-под рута
```
docker exec -it *имя контейнера* bash
```

2. Узнаём установленную версию постгреса
```
psql --version
```

3. Если в контейнере у вас стоит `Linux Alpine`
```
apk add postgresql15-plpython3
```

если стоит `Debian`-подобная ось, то, наверное
```
apt-get install postgresql-plpython3-15
```
(не проверял, откройте `Issue`/`PR`, кто проверил)

4. В СУБД прописываем
```
CREATE EXTENSION IF NOT EXISTS plpython3u;
```
