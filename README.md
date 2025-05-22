# Otus Data Engineer Project "Organization of DWH for the analysis of the danger of Internet resources"

## Running project

Generate ssh keys for running dbt models in Airflow via SSH operator
```
mkdir -p ssh_keys && ssh-keygen -t rsa -b 4096 -f ssh_keys/dbt_client_id_rsa
```

Run Docker Compose
```
docker compose --file .\docker-compose-all.yaml up -d 
```

## Project structure

```
    .
    ├── airflow                  # Airflow DAGs source code
    ├── dbt                      # DBT project source code
    ├── docs                     # Extra files for documentation
    ├── dwh                      # DWH DB object scripts
    ├── docker-compose-all.yaml  # Docker Compose file for running all requiered services
    └── README.md                # You are reading this
```

## Architecture


## DWH ERD


## TODO

- Build Docker image for DBT with SSH
- Add MinIO instead of Managed S3 


