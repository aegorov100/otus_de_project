## Run dbt in project Docker compose
```
docker compose --file ..\docker-compose-all.yaml up -d
docker compose --file ..\docker-compose-all.yaml exec dbt bash
```

In local browser DBT Docs UI in localhost:8081

or you can connect to separate dbt container via SSH:
```
ssh -i ../ssh_keys/dbt_client_id_rsa -p 2222 root@localhost
```
where dbt_client_id_rsa is a private key in ssh_keys projects directory


## Run DBT in separate container

```
docker run -it --rm --name dbt `
--add-host host.docker.internal:host-gateway `
--entrypoint /bin/bash `
-p 8081:8080 `
-v .\dbt_dwh:/usr/app/dbt `
-v .\dbt_dwh\profiles.yml:/root/.dbt/profiles.ym `
-e DBT_DB_HOST=host.docker.internal `
-e DBT_DB_PORT=5432 `
-e DBT_DB_NAME=dwh `
-e DBT_DB_SCHEMA=stage `
-e DBT_DB_USER=dwh `
-e DBT_DB_PASS=dwh `
ghcr.io/dbt-labs/dbt-postgres:1.9.0 
```

## DBT commaands

Check profile, config 
```
dbt debug
```

Generate docs
```
dbt docs generate
dbt docs serve --host "0.0.0.0" --port 8080 --no-browser
```

