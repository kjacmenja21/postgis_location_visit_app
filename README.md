# GeoApp Docker Compose Setup

This repository contains a Docker Compose setup for running a geospatial application with the following services:

- **Postgres** with PostGIS extension for geospatial data storage
- **Backend** service for handling application logic and connecting to the database

## Prerequisites

Before you begin, ensure you have the following installed on your machine:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)

## Project Structure

```
.
├── docker-compose.yml
├── backend/
│   ├── Dockerfile
│   └── [Application Code]
├── postgres/
│   ├── Dockerfile
│   └── init/
│       └── [SQL or Shell Scripts for Initialization]
```

### Services

1. **Postgres**:

   - Image: `postgis/postgis:latest`
   - Exposes port `5432`
   - Initializes using scripts in `postgres/init`

2. **Backend**:
   - Custom application image built from `backend/Dockerfile`
   - Exposes port `8000`
   - Connects to the Postgres database

## Getting Started

Follow these steps to get the application up and running:

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <repository-folder>
```

### 2. Build and Start the Services

Run the following command to build the images and start the containers:

```bash
docker-compose up --build
```

This will:

- Build the custom `backend` and `postgres` images.
- Start the containers for the `postgres` and `backend` services.

### 3. Access the Application

- **Postgres Database**:

  - Host: `localhost`
  - Port: `5432`
  - Credentials:
    - User: `user`
    - Password: `password`
    - Database: `geoapp`

- **Backend API**:
  - URL: `http://localhost:8000`

## Data Persistence

The Postgres database data is stored in a Docker volume named `postgres_data`. This ensures that data persists even if the container is stopped or removed.

## Managing the Services

### Stop the Services

To stop the running containers:

```bash
docker-compose down
```

### Restart the Services

To restart the services:

```bash
docker-compose up
```

### Clean Up

To remove the containers, networks, and volumes:

```bash
docker-compose down -v
```

> **Note**: Removing volumes will delete all data stored in the database.

## Customization

### Environment Variables

You can customize the environment variables for each service by modifying the `docker-compose.yml` file.

### Initialization Scripts

To initialize the database with custom data or schemas, place SQL or shell scripts in the `postgres/init` directory. These scripts will run automatically during the Postgres container's first startup.

## Troubleshooting

- **Check Logs**:
  Use the following command to view container logs:

  ```bash
  docker-compose logs -f
  ```

- **Rebuild Images**:
  If you make changes to the Dockerfiles or the application code, rebuild the images:
  ```bash
  docker-compose up --build
  ```

## License

This project is licensed under the GPL-v3.0 License. See the LICENSE file for details.
