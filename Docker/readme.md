# Linux Scripts

A collection of scripts I use to manage my personal servers.

## Repository Structure

```plaintext
linux-scripts/
├── Docker/
│   ├── calibreweb/
│   │   ├── docker-compose.yml
│   │   └── README.md
│   ├── komga/
│   │   ├── docker-compose.yml
│   │   └── README.md
│   └── portainer/
│       ├── docker-compose.yml
│       └── README.md
└── README.md
```

Each subdirectory under `Docker/` contains the necessary `docker-compose.yml` files and individual `README.md` files for setting up specific services.

## Services

### Calibre Web
- **Directory**: `Docker/calibreweb/`
- **Description**: Provides a web-based interface for browsing, reading, and managing your eBook collection.
- **Setup**:
  1. Navigate to the `calibreweb` directory:
     ```bash
     cd Docker/calibreweb
     ```
  2. Review the `docker-compose.yml` file to ensure volume paths and environment variables are correctly set.
  3. Start the service:
     ```bash
     docker-compose up -d
     ```
  4. Access the web UI at `http://<your-server-ip>:8083`.

### Komga
- **Directory**: `Docker/komga/`
- **Description**: A media server for your comics, mangas, and digital books.
- **Setup**:
  1. Navigate to the `komga` directory:
     ```bash
     cd Docker/komga
     ```
  2. Review the `docker-compose.yml` file to ensure volume paths and environment variables are correctly set.
  3. Start the service:
     ```bash
     docker-compose up -d
     ```
  4. Access the web UI at `http://<your-server-ip>:25600`.

### Portainer
- **Directory**: `Docker/portainer/`
- **Description**: A lightweight management UI which allows you to easily manage your Docker environments.
- **Setup**:
  1. Navigate to the `portainer` directory:
     ```bash
     cd Docker/portainer
     ```
  2. Review the `docker-compose.yml` file to ensure volume paths and environment variables are correctly set.
  3. Start the service:
     ```bash
     docker-compose up -d
     ```
  4. Access the web UI at `http://<your-server-ip>:9000`.

## Environment Variables

Each service utilizes environment variables for configuration. It's recommended to create a `.env` file in each service's directory with the necessary variables. For example:

```env
PUID=1000
PGID=1000
TZ=America/New_York
CALIBRE_CONFIG=/path/to/calibre/config
CALIBRE_DATA=/path/to/calibre/data
KOMGA_CONFIG=/path/to/komga/config
KOMGA_DATA=/path/to/komga/data
PORTAINER_DATA=/path/to/portainer/data
```

Ensure that the paths and values are adjusted to match your system's configuration.

## Prerequisites

- **Docker**: Ensure Docker is installed on your system. You can install Docker using the official installation script:

  ```bash
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  ```

- **Docker Compose**: Verify that Docker Compose is installed. If not, follow the official installation guide.

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/lynchhj1/linux-scripts.git
   ```

2. Navigate to the desired service directory, e.g., for Calibre Web:

   ```bash
   cd linux-scripts/Docker/calibreweb
   ```

3. Create and configure the `.env` file with the necessary environment variables.

4. Start the service using Docker Compose:

   ```bash
   docker-compose up -d
   ```

5. Access the service's web interface using the URLs provided in the Services section.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes. Ensure that your contributions align with the repository's structure and guidelines.

## License

This project is licensed under the MIT License. See the [LICENSE](../LICENSE) file for details.
