# Smart Nutrition Tool APIs

This repository provides the APIs for the Smart Nutrition Tool, including a backend service that connects to a PostgreSQL database.

## Prerequisites

- Docker: [Install Docker](https://docs.docker.com/get-docker/)
- Docker Compose: [Install Docker Compose](https://docs.docker.com/compose/install/)

## Getting Started

1. **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/smart-nutrition-tool.git
    cd smart-nutrition-tool
    ```

2. **Pull the Docker image**:
    ```bash
    docker pull mdsoln/smart-nutrition-tool-apis:latest
    ```

3. **Start the services**:
    ```bash
    cd api
    docker-compose up
    ```

    This will start:
    - **Backend API**: `http://localhost:8080`
    - **PostgreSQL**: `localhost:5432`

4. **Verify running services**:
    ```bash
    docker ps
    ```

5. **Stop the services**:
    ```bash
    docker-compose down
    ```

## Checking the Database

To check the database and see the data:

1. **Access PostgreSQL from a container**:
    You can connect to the PostgreSQL container using the `psql` command-line tool. First, get the container ID or name:
    ```bash
    docker ps
    ```

    Then, use the following command to access the PostgreSQL database:
    ```bash
    docker exec -it postgres psql -U postgres -d nutrition
    ```

2. **Query data in the database**:
    After accessing the database, you can run SQL queries to check the data:
    ```sql
    SELECT * FROM your_table_name;
    ```

    Replace `your_table_name` with the actual table you want to check.

## Configuration

- **Database credentials**:
  - `POSTGRES_USER`: `postgres`
  - `POSTGRES_PASSWORD`: `mdsoln`
  - `POSTGRES_DB`: `nutrition`

## License

[MIT License](LICENSE)
