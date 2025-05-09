# Monitoring Installation and Configuration Documentation

## Summary

This document provides a step-by-step guide to set up a monitoring stack using Grafana, Prometheus, and Node Exporter. These tools work together to collect, store, and visualize system metrics. 

## ⚠️ Prerequisites

All commands are run as **root user**.  
The system is based on **Debian**.


## Table of Contents

1. [Grafana Installation & Configuration](#1-grafana-installation--configuration)
2. [Prometheus Installation & Configuration](#2-prometheus-installation--configuration)
3. [Node Exporter Installation](#3-node-exporter-installation)
4. [Notes](#notes)

---

## 1. Grafana Installation & Configuration

### Purpose

Grafana is used to visualize metrics collected by different sources (Prometheus is used here) in customizable dashboards.

### Installation Steps

1. **Run Grafana**:

    1. **Using Pterodactyl**

        1. **Import Grafana on Pterodactyl**:

            - Download the fixed Prometheus egg from the provided link: [Grafana Egg](https://github.com/pelican-eggs/software/blob/main/grafana/egg-pterodactyl-grafana.json).
            - Log in to the Pterodactyl admin panel.
            - Navigate to **Nests > Import Egg**.
            - Upload the downloaded JSON file.
            - Assign the egg to an existing nest or create a new one. (refer to Pterodactyl [usage documentation](../Web/Pterodactyl.md) for more details about creating a new Nest.)
            - Save the changes and ensure the egg is available for use.

        2. **Create a Server on Pterodactyl**

            - Log in to the Pterodactyl admin panel.
            - Navigate to **Servers > Create New**.
            - Fill in the required details:
            - **Name**: Enter a name for the server (e.g., `Grafana`).
            - **Nest**: Select the nest where the Grafana egg was imported.
            - **Egg**: Choose the Grafana egg.
            - **Docker Image**: Use the default debian image provided by the egg.
            - **Resources**: Allocate CPU, memory, and disk space as needed. (we set: 50% CPU, 512MB mem, and 800Mb of disk space.)
            - Save the server configuration.

        3. **Start it**
            - Start the server and wait for it to initialize. Ensure there are no errors in the console logs.

    2. **Using docker**:
        1. **Storage**
            - To ensure you will not need to remake the grafana configuration every time you restart, we create a docker volume to store them.
            ```
            docker volumes create grafana-storage
            ```
        2. **Picking a version**
            - There is two docker image for it, OSS (open source), and enterprise. The two are free, but enterprise image allow to upgrade to enterprise feature.
            -   - OSS Image: `grafana/grafana-oss`
                - Enterprise Image: `grafana/grafana-enterprise`
            - Since grafana recommend to use the enterprise version, all the command will use the recommended one.
        3. **Create and start a container**
            - Create and start the container with storage and publishing the port to the host.
            ```
            docker run --name grafana --restart=always -d -p 3000:3000 --volume grafana-storage:/var/lib/grafana grafana-enterprise
            ```
            - You can customize the first port number, this will be the exposed port on the host wich will proxy to the 3000 port inside of the container.
            - This container will be called `grafana` and will be restarted whenever it was not stopped by the user.

2. **Access Grafana**:

    - Open your browser and navigate to `http://<node-ip>:<port>`.
    - Log in with the default credentials (`admin`/`admin`) and change the password.

3. **Add Prometheus as a Data Source**:

    - Navigate to **Configuration > Data Sources** in Grafana.
    - Add a new data source and select **Prometheus**.
    - Enter the Prometheus server URL (e.g., `http://<prometheus-server-ip>:9090`) and save.

4. **Import Dashboards**:
    - Navigate to **Dashboard** in Grafana.
    - Click **New** button and select **Import** if you want to import a prebuilt dashboards from the [Grafana Dashboard Library](https://grafana.com/grafana/dashboards/).
    - Or select **New dashboard** for creating it your seulf

---

## 2. Prometheus Installation & Configuration

### Purpose

Prometheus is a temporal database used to scrape and store metrics from Node Exporter and other targets. It is designed to handle time-series data efficiently, making it ideal for monitoring and alerting systems.

### Installation Steps

1. **Run Prometheus**

    1. **Using Pterodactyl**

        1. **Fix Prometheus egg for Pterodactyl**:

            - The Prometheus egg was updated to work with Pelican, and don't work anymore with pterodactyl.
            - We have fixed it, you can now get the valid one for pterodactyl [here](./pterodactyl-prometheus-egg.json)

        2. **Import Prometheus Egg on Pterodactyl**:

            - Download the fixed Prometheus egg from the provided link: [Prometheus Egg](./pterodactyl-prometheus-egg.json).
            - Log in to the Pterodactyl admin panel.
            - Navigate to **Nests > Import Egg**.
            - Upload the downloaded JSON file.
            - Assign the egg to an existing nest or create a new one.
            - Save the changes and ensure the egg is available for use.

        3. **Create a Server on Pterodactyl**

            - Log in to the Pterodactyl admin panel.
            - Navigate to **Servers > Create New**.
            - Fill in the required details:
            - **Name**: Enter a name for the server (e.g., `Prometheus`).
            - **Nest**: Select the nest where the Prometheus egg was imported.
            - **Egg**: Choose the Prometheus egg.
            - **Docker Image**: Use the default debian image provided by the egg.
            - **Resources**: Allocate CPU, memory, and disk space as needed. (we set: 50% CPU, 768Mb mem, and 5Gb of disk space.)
            - Save the server configuration.

        4. **Start it**
            - Start the server and wait for it to initialize. Ensure there are no errors in the console logs.

    2. **Using docker**:
        1. **Storage**
            - To ensure you will not need to remake the prometheus configuration at all restart using some hard process, create a file on the server to store the prometheus configuration
            ```
                mkdir -p /etc/prometheus
                touch /etc/prometheus/prometheus.yml
            ```
        2. **Create and start a container**
            - Create and start the container with configuration file and publishing the port to the host.
            ```
            docker run \
                --name prometheus \
                --restart=always \
                -d -p 9090:9090 \
                -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
                prom/prometheus
            ```
            - You can customize the first port number, this will be the exposed port on the host wich will proxy to the 9090 port inside of the container.
            - This container will be called `prometheus` and will automatically restart whenever it was not stopped by the user.

2. **Configure Prometheus**:

    - Edit the `prometheus.yml` file to include scrape targets:
        ```yaml
        scrape_configs:
            - job_name: "node_exporter"
              static_configs:
                  - targets:
                        [
                            "<node-exporter-ip>:9100",
                            "<other_node-exporter-ip>:9100",
                        ]
        ```
    - This configuration use default node_exporter port, don't forget change it if you use custom port.

3. **Restart Prometheus**:

    - To reload the configuration, restart prometheus.

    1. **On Pterodactyl**
        - Navigate to the Pterodactyl web interface and log in with your credentials.
        - Go to **Servers** and select the server running Prometheus.
        - Click the **Restart** button to restart it.
        - Check the server console logs to ensure Prometheus starts without errors.
    2. **On Docker**
        - You supposed to have a container called `prometheus` like it was created before.
        - Else you can replace the name by the id of the container. You can find it using command:
        ```
        docker ps -a
        ```
        - You will now need to find your prometheus container in the list and copy his id.
        - Restart the container:
        ```
        docker restart prometheus # replace 'prometheus' by the id if it's needed.
        ```

4. **Verify Prometheus**:
    - Access Prometheus at `http://<prometheus-node-ip>:9090`.

---

## 3. Node Exporter Installation

### Purpose

Node Exporter is designed to expose system-level metrics such as CPU, memory, disk usage, and network statistics.
So it should be installed directly on the system rather than in a Docker container to ensure that it has direct access to the host's resources and metrics without any abstraction or limitations introduced by containerization.

### Installation Steps

1.  **Update the system packages**:

    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

2.  **Download the Node Exporter binary**:

    -   Visit the [official Prometheus download page](https://prometheus.io/download/#node_exporter) and copy the link for the latest Node Exporter binary compatible with Linux.
        -   Use `wget` to download the binary:
        ```shell
        wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz # replace this link by the link of the last version
        ```

    3. **Extract the downloaded archive**:

        ```bash
        tar -xvf node_exporter-1.9.1.linux-amd64.tar.gz
        cd node_exporter-1.9.1.linux-amd64
        ```

    4. **Move the binary to a system-wide location**:

        ```bash
        mv node_exporter /usr/local/bin/
        ```

    5. **Create a dedicated user for Node Exporter**:

        ```bash
        useradd --no-create-home --shell /bin/false node_exporter
        ```

    6. **Create a systemd service file**:

        - Open a new file using your preferred text editor:
            ```bash
            sudo nano /etc/systemd/system/node_exporter.service
            ```
        - Add the following content:

            ```ini
            [Unit]
            Description=Node Exporter
            After=network.target

            [Service]
            User=node_exporter
            Group=node_exporter
            ExecStart=/usr/local/bin/node_exporter
            Restart=always

            [Install]
            WantedBy=multi-user.target
            ```

    7. **Reload systemd and start the service**:

        ```bash
        sudo systemctl daemon-reload
        sudo systemctl start node_exporter
        sudo systemctl enable node_exporter
        ```

    8. **Verify that Node Exporter is running**:

        - Ensure Node Exporter is accessible on port `9100` by default:
            ```bash
            curl http://localhost:9100/metrics
            ```

    9. **Allow traffic on port 9100 (if using a firewall)**:

        - If `ufw` is enabled, allow traffic on port `9100`:
            ```bash
            sudo ufw allow 9100
            sudo ufw reload
            ```

---

### Notes

-   **Accessing Prometheus from a Private Network**:  
     If your server does not have a public IP address, Grafana may not be able to access the host IP directly because the Docker container operates on a virtual network managed by Docker. To resolve this, you can use the gateway IP of the Docker network, which represents the host machine. Run the following command to find all information on the ip configuration (ip, network, gateway, etc...)

    ```bash
    docker exec -it <container_name_or_id> ip a
    ```

    This Gateway address will be useful when linking Prometheus to Grafana as a data source.
    - 172.18.0.1 is the gateway of the Pterodactyl Docker network, representing the host machine (also referred to as the intranet machine). This address is used to link Prometheus to Grafana as a data source or to scrape metrics from Node Exporter running on the host.
        
    ### Configuration Details

    #### Grafana

    -   **Prometheus Data Source URL**: `http://172.18.0.1:50002`
    -   **Imported Dashboard ID**: `1860`

    #### Prometheus

    -   **Scrape Configuration**:
        ```yaml
        scrape_configs:
            - job_name: "node_exporter"
            static_configs:
                - targets: ["172.18.0.1:9100","10.0.0.3:9100"]
                  labels:
                    app: "node_exporter"
        ```

    #### Configuration File Links

    -   **Prometheus Egg**: [Download Prometheus Egg](./Web-prometheus-egg.json)
    -   **Grafana Egg**: [Download Grafana Egg](https://github.com/pelican-eggs/software/blob/main/grafana/egg-pterodactyl-grafana.json)

---
