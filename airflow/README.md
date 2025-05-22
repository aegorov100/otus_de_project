## Run Airflow in project Docker compose
```
docker compose --file ..\docker-compose-all.yaml up -d
```

In local browser Airflow Web UI in localhost:8080


## Airflow Variables

- abuse_ip_db_api_ip_version: 4
- abuse_ip_db_api_key: <abuseipdb_apikey>
- abuse_ip_db_api_url: https://api.abuseipdb.com/api/v2/blacklist

## Airflow Connections

- dbt_ssh:
    - conn_type: ssh
    - description: ''
    - extra: '{"key_file": "/opt/ssh-keys/dbt_client_id_rsa"}' # SSH keys must be pre-generated. 
    - host: dbt-ssh
    - login: root
    - password: null
    - port: null
    - schema: ''
- dwh_db:
    - conn_type: postgres
    - description: ''
    - extra: ''
    - host: < from docker-compose-all.yaml >
    - login: < from docker-compose-all.yaml >
    - password: < from docker-compose-all.yaml >
    - port: < from docker-compose-all.yaml >
    - schema: < from docker-compose-all.yaml >
- s3_input:
    - conn_type: aws
    - description: ''
    - extra: '{"endpoint_url": "https://storage.yandexcloud.net", "region_name": "us-east-1"}'
    - host: ''
    - login: <S3 Access Key>
    - password: <S3 Access Secret Key>
    - port: null
    - schema: ''
