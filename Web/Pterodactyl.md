# Pterodactyl Panel and Wings Documentation Guide

## Summary

This guide provides detailed instructions for setting up and managing the Pterodactyl panel alongside the Wings service. Pterodactyl is a fully open-source platform, giving users the freedom to customize and adapt it to their needs. While it is primarily designed for managing game servers, its flexibility allows it to be used for a variety of other purposes, all through an intuitive graphical interface that simplifies Docker container management.

## ⚠️ Prerequisites

All commands are run as **root user**.  
The system is based on **Debian**.  
The **apt** package manager.

> **⚠️ Warning**  
> It is crucial to follow the documentation step-by-step without skipping any part unless explicitly mentioned. Skipping steps may lead to unexpected issues or incomplete configurations. Always ensure you understand each step before proceeding.

## Table of Contents
- [Pterodactyl Panel and Wings Documentation Guide](#pterodactyl-panel-and-wings-documentation-guide)
    - [Summary](#summary)
    - [⚠️ Prerequisites](#️-prerequisites)
    - [Table of Contents](#table-of-contents)
    - [1. Pterodactyl Installation](#1-pterodactyl-installation)
        - [1. Connect to the server](#1-connect-to-the-server)
        - [2. Install dependencies](#2-install-dependencies)
            - [1. First package](#1-first-package)
            - [2. Add Repositories](#2-add-repositories)
            - [3. Install dependencies](#3-install-dependencies)
            - [4. Composer](#4-composer)
        - [3. Install panel files](#3-install-panel-files)
            - [1. Make folder](#1-make-folder)
            - [2. Download files](#2-download-files)
        - [4. Install & Configure the Panel](#4-install--configure-the-panel)
            - [1. Create MYSQL user and database](#1-create-mysql-user-and-database)
            - [2. Configure Pterodactyl](#2-configure-pterodactyl)
                - [1. Copy environment file](#1-copy-environment-file)
                - [2. Install composer dependencies](#2-install-composer-dependencies)
                - [3. Generate key](#3-generate-key)
                - [4. Environment setup](#4-environment-setup)
                - [5. Database setup](#5-database-setup)
                - [6. Create user](#6-create-user)
        - [5. Finalising Pterodactyl installation](#5-finalising-pterodactyl-installation)
        - [6. Webserver configuration](#6-webserver-configuration)  
        - [7. Database Host](#7-database-host)
            - [Step 1: Create a MySQL User](#step-1-create-a-mysql-user)
            - [Step 2: Add a New Database Host](#step-2-add-a-new-database-host)
            - [Step 3: Verify the Database Host](#step-3-verify-the-database-host)
    - [2. Wings Installation](#2-wings-installation)
        - [1. Install Docker](#1-install-docker)
        - [2. Install Wings](#2-install-wings)
        - [3. Create a Configuration Directory](#3-create-a-configuration-directory)
        - [4. Generate a Configuration File](#4-generate-a-configuration-file)
        - [5. Run Wings](#5-run-wings)
        - [6. Daemonizing wings](#6-daemonizing-wings)
        - [7. Verify Connection](#7-verify-connection)
        - [8. Node Allocations](#8-node-allocations)
            - [1. Add Allocations in the Panel](#1-add-allocations-in-the-panel)
    - [3. Pterodactyl Usage](#3-pterodactyl-usage)
        - [1. Create a New Location](#1-create-a-new-location)
        - [2. Create a New Node](#2-create-a-new-node)
        - [3. Create a New Nest](#3-create-a-new-nest)
        - [4. Create a New Egg](#4-create-a-new-egg)
        - [5. Create a New Server](#5-create-a-new-server)
    - [Notes](#notes)

---

## 1. Pterodactyl Installation

### 1. **Connect to the server**

-   The first step is to connect to the server, for that, we use ssh command. This is the only command that don't have to be run as `root`.
    ```
    ssh root@<ip>
    ```
-   Replace '\<ip>' by the IP of your server.

### 2. **Install dependencies**

-   Pterodactyl requires a bunch of packet, so we starting by installing them.

    #### 1. **First package**

    -   To install pterodactyl, we need some packages, such as curl and other. To install them, use the following command

        ```
        apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
        ```

    #### 2. **Add Repositories**

    -   All repositories that contains package used by pterodactyl are not by default on apt source list, so we need to add them.
        1. **MariaDB**
            - To setup the mariaDB repo, you can use the script provided by mariaDB.
            ```
            curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash
            ```
        2. **PHP** (useless on Debian 12 and higher)
            - Pterodactyl panel is running on Laravel, so we need to install PHP. Here is the command to add PHP repo on debian.
            ```
            curl -sSL https://packages.sury.org/php/README.txt | bash -x
            ```
    -   To end the repositories step, we will update package list on system using
        ```
        apt update
        ```

    #### 3. **Install dependencies**

    -   Now that we have all packages needed available, we need to install them. To do that, use the following command
        ```
        apt -y install php8.3 php8.3-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git
        ```
    -   This command will install php 8.3 and all php module required for pterodactyl with mariaDB server, nginx and some other usefull package for installation process

    #### 4. **Composer**

    -   Composer is a dependency manager for PHP that allows us to ship everything you'll need code wise to operate the Panel. You'll need composer installed before continuing in this process.
    -   You can install it using the official installer:
        ```
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
        ```

### 3. **Install panel files**

-   The first step for installing Pterodactyl is to set up his files.
    #### 1. **Make folder**
    -   We will create the folder used by pterodactyl in their doc. This will also help for simplify usage of support.
    -   They set their panel file at `/var/www/pterodactyl`
    -   So to create the folder we will use the following command:
        ````
        mkdir -p /var/www/pterodactyl
        ```bash
        - `-p` option for `--parent` create folder recursively, if `www` dont exist for example, it will be created as same as `www/pterodactyl`
        ````
    -   To ensure we download files at the rigth place, we will go to the new created folder using the next command
        ```bash
        cd /var/www/pterodactyl
        ```
    #### 2. **Download files**
    -   We will now download pterodactyl files from their Github.
        ```bash
        curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/download/v1.11.10/panel.tar.gz
        ```
    -   To extract the files we will use `tar` command
        ```bash
        tar -xzvf panel.tar.gz
        ```
    -   Now we want to ensure that all user/group on the system will be able to access `storage` and `cache` folder.
        ```
        chmod -R 755 storage/* bootstrap/cache/
        ```

### 4. **Install & Configure the Panel**

-   Pterodactyl installation process is much longer that what we just do. We need to create a user and a database with all permissions give to the user, install PHP dependencies (composer), and to finish, the pterodactyl setup step.

    #### 1. **Create MYSQL user and database**

    1.  **Fix MariaDB bind adress**
        -   MariaDB default only bind on loopback interface. But we want the database server to be accessible on all the network, so we need to change the bind address in the configuration files.
        -   The bind address is configured inside the folder `/etc/mysql/mariadb.conf.d/` and the file that contains the configuration attributes is the one who is called `50-server.cnf`
        -   Open it with your favorite editor, and search for a line where is write `bind-address = 127.0.0.1`.
        -   Replace the `127.0.0.1` by `0.0.0.0` to make the server binding on all IP address available on the host.
    2.  **Connect to MariaDB**
        -   To connect to MariaDB, you only need to run the following command
            ```
            mariadb -u root -p
            ```
        -   This will connect to the root database user without password. If you got a password for the root user, add your password after the `-p` option.
    3.  **Create user**
        -   Now with the kind of SQL shell you got, you should enter the following command to create a pterodactyl user.
            ```
            CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY 'yourPassword';
            ```
        -   Replace `yourPassword` by your password. You can generate a random one easily using [LastPass](https://www.lastpass.com/fr/features/password-generator)
        -   **Save your password, you will need it after**
    4.  **Create database**
        -   The user is now created, the next step is to create a database called `panel` (default name used by pterodactyl)
        -   To make it, use the following command
            ```
            CREATE DATABASE panel;
            ```
    5.  **Grant permission**
        -   Pterodactyl user need all permissions on this database, so we will grant him all privileges with GRANT OPTION (like super-admin permission).
        -   To make it, we use the following command:
            ```
            GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION;
            ```
        -   This command will grant all privileges on all tables in `panel` database to the user we created before, and give him grant option on the database.
        -   To ensure the permission is set, you can flush privileges using the following command:
            ```
            FLUSH PRIVILEGES
            ```

    -   You can now exit mariaDB using the `exit` command.

    #### 2. **Configure Pterodactyl**

    -   To configure pterodactyl, we will need to copy the example environment configuration files, install all PHP dependencies using `composer`, generate a key, and follow Pterodactyl set-up script.

        ##### 1. **Copy environment file**
        - To copy the environment file serving as an example, you will need to run the command
            ```
            cp .env.example .env
            ```
        ##### 2. **Install composer dependencies**
        - Because we use root user, composer will not run due to security mesure. To fix it, we will add `COMPOSER_ALLOW_SUPERUSER=1` before the command.
        - The command to install dependencies is:
            ```
            COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
            ```
        ##### 3. **Generate key**
        - Pterodactyl encrypt some data, so to encrypt it, you need to generate a key.
        - **Be aware**, this command will automatically replace the one in the `.env` file, so if you already have a key generated with data on your Pterodactyl, don't run the next command.
        - The command to generate the key is:
            ```
            php artisan key:generate --force
            ```
        - **Back up your encryption key** (APP_KEY in the .env file). It is used as an encryption key for all data that needs to be stored securely (e.g. api keys). Store it somewhere safe, not just on your server. If you lose it all encrypted data is irrecoverable, even if you have backups unless they contains the APP_KEY.

        ##### 4. **Environment setup**

        - Pterodactyl provides multiples script to easily configure the panel.
        - To start the first setup, use the next command:
            ```
            php artisan p:environment:setup
            ```
        - The first step is to setup Pterodactyl environment, you will set-up the following data
            |            **Name**             |    **Default value**     | **Type** | **Description**                                                                                                                                                                                                                                |
            | :-----------------------------: | :----------------------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
            |        Egg author email         |   unknown@unknown.com    |  E-mail  | This is the email assigned as the 'creator' of nest and egg created directly on the panel (not imported)                                                                                                                                       |
            |             App URL             | http://panel.example.com |   URL    | This is the URL of the APP, if you use Pterodactyl on IP, just put `http://<ip>`, else but your domain. (**DON'T** forgot the http/s before)                                                                                                   |
            |          App Timezone           |           UTC            | Timezone | No need to explain...                                                                                                                                                                                                                          |
            |          Cache driver           |          redis           | Selector | This is a selector to choose how you will store cache. (using redis/memcached/file system) (we use file system)                                                                                                                                |
            |         Session driver          |          redis           | Selector | This is a selector to choose how you will store session data. (using redis/database/file system) (we use database)                                                                                                                             |
            |          Queue driver           |          redis           | Selector | This is a selector to choose how you will handle queues. (using redis/database/sync) (we use database)                                                                                                                                         |
            | Enable UI based settings editor |          false           | Boolean  | This option allows enabling or disabling the settings editor directly within the Pterodactyl panel's user interface. When set to `true`, administrators can modify configuration settings through the panel instead of editing files manually. |

           
            - You also can set mail setting, but it don't required, so we will not document it.
            - Anyway if you want to do it, use the following command:
                ```bash
                php artisan p:environment:mail
                ```

        ##### 5. **Database setup**
         - The second step, is used to configure the database. Run the setup using the command:
                ```bash
                php artisan p:environment:database
                ```
            - Here is what will be asked:

            |     **Name**      | **Default value** |  **Type**   | **Description**                                                                                               |
            | :---------------: | :---------------: | :---------: | :------------------------------------------------------------------------------------------------------------ |
            |   Database host   |     127.0.0.1     | IP/Hostname | This is the IP or hostname of your database server.                                                           |
            |   Database port   |       3306        |    Port     | The port used to connect to your database server.                                                             |
            |   Database name   |       panel       |   String    | The name of the database created for Pterodactyl.                                                             |
            | Database username |    pterodactyl    |   String    | The username created for accessing the database.                                                              |
            | Database password |        N/a        |   String    | The password of the pterodactyl user, you have set it in this [step](#1-create-mysql-user-and-database) user. |

        - Pterodactyl provides a script to prepare the database. It will create all tables and fill them with default values such as some eggs.
        - To do it, use the following command:
            ```bash
            php artisan migrate --seed --force
            ```
        ##### 6. **Create user**

        - Since Pterodactyl is a web application, we need to authenticate before acceding. But if no user exist, we can't authenticate.
        - So we need to create the first user using the command:
            ```bash
            php artisan p:user:make
            ```
        - You will be asked the following data:

            |     **Name**      | **Default Value** | **Type** | **Description**                                                          |
            | :---------------: | :---------------: | :------: | :----------------------------------------------------------------------- |
            |       Email       |        N/a        |  String  | The email address of the user being created.                             |
            |     Username      |        N/a        |  String  | The username for the user.                                               |
            |    First Name     |        N/a        |  String  | The first name of the user.                                              |
            |     Last Name     |        N/a        |  String  | The last name of the user.                                               |
            |     Password      |        N/a        |  String  | The password for the user.                                               |
            | Is Admin (yes/no) |        no         | Boolean  | Determines if the user will have administrative privileges on the panel. |

### 5. **Finalising Pterodactyl installation**

-   Now that Pterodactyl is fully install and configured, we need to create a new service for Pterodactyl Queue. This is responsible of mail sending and many other Pterodactyl background tasks.
-   To do that, create a new file called `pteroq.service` in `/etc/systemd/system/` folder.
-   Then open it with your favorite text editor and paste the following content in it:

    ```ini
    # Pterodactyl Queue Worker File
    # ----------------------------------

    [Unit]
    Description=Pterodactyl Queue Worker
    After=redis-server.service

    [Service]
    # On some systems the user and group might be different.
    # Some systems use `apache` or `nginx` as the user and group.
    User=www-data
    Group=www-data
    Restart=always
    ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
    StartLimitInterval=180
    StartLimitBurst=30
    RestartSec=5s

    [Install]
    WantedBy=multi-user.target
    ```

-   Now enable and start the service with this:
    ```
    systemctl enable --now pteroq.service
    ```

### 6. **Webserver configuration**
-   For this installation, we used NGINX as webServer.
-   On Debian, NGINX use the `www-data` user and group, so we will change owner of Pterodactyl folder to this one using this command:
    ```
    chown -R www-data:www-data /var/www/pterodactyl/*
    ```
-   The first step is to remove the default configuration from the enabled one. To do this, we will remove the link in `/etc/nginx/sites-enabled` called `default`. To do this, use this command:
    ```
    rm /etc/nginx/sites-enabled/default
    ```
-   Since we run Pterodactyl on intra-net and that we haven't set any custom DNS, we use the IP of the host to expose the panel. (the IP is the `10.0.0.2`)
-   So we haven't any certificate for the panel since it will mostly pertube user due to browser showing an alert error saying that certificate is not valid because it's self-signed.
-   To configure NGINX so for exposing Pterodactyl on IP, we need to add the following configuration in a file called `pterodactyl.conf` located in `/etc/nginx/sites-available` folder. (please notice that you can name the file like you want), but remember to replace it with your file name in the documentation).
    ```nginx
    server { 
        listen 80; # Listen on port 80 (default since there is no certificate)
        server_name <Host_IP>; # If you use a domain, you should replace this by your domain name (without http(s)).

        root /var/www/pterodactyl/public;
        index index.html index.htm index.php;
        charset utf-8;

        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }

        location = /favicon.ico { access_log off; log_not_found off; }
        location = /robots.txt  { access_log off; log_not_found off; }

        access_log off;
        error_log  /var/log/nginx/pterodactyl.app-error.log error;

        # allow larger file uploads and longer script runtimes
        client_max_body_size 100m;
        client_body_timeout 120s;

        sendfile off;

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/run/php/php8.3-fpm.sock;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param HTTP_PROXY "";
            fastcgi_intercept_errors off;
            fastcgi_buffer_size 16k;
            fastcgi_buffers 4 16k;
            fastcgi_connect_timeout 300;
            fastcgi_send_timeout 300;
            fastcgi_read_timeout 300;
        }

        location ~ /\.ht {
            deny all;
        }

    }
    ```
- This configuration will listen on port 80 and on host IP address. It use Pterodactyl folder as website root folder and redirect all request with path ending by `.php` to PHP-fpm socket.
- Now we need to link the configuration to the `sites-enabled` folder. To make it, use the command
    ```bash
    ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
    ```
- It will create a symbolic link (also known as soft link)
- To apply configuration, we will reload nginx. But before, we need to check if no error was made. To check the configuration use the following command:
    ```
    nginx -t
    ```
    This is a sample output:
    ```
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful
    ```
- If no error occurs, reload nginx using the following command:
    ```
    nginx -s reload
    ```
- Pterodactyl should now be accessible! Congratulations!
- For futher explanation about NGINX configuratio, please refer to this [user guide](./WebServer.md).

### 7. **Database Host**

This section explains how to create a new database host in the Pterodactyl admin panel. A database host allows servers to create and utilize the database for their operations.

#### Step 1: Create a MySQL User
Before creating a database host, ensure you have a MySQL user with the appropriate permissions to manage the database. If you haven't already created a MySQL user, follow these steps:
1. **Connect to MariaDB**:
    - Use the following command to access the MariaDB shell:
      ```bash
      mariadb -u root -p
      ```
    - Enter the root password when prompted.
2. **Create a New User**:
    - Run the following SQL command to create a new MySQL user:
      ```sql
      CREATE USER 'pterodactyl_db'@'%' IDENTIFIED BY 'yourPassword';
      ```
    - Replace `yourPassword` with a secure password. Save this password for later use.
3. **Grant Permissions**:
    - Assign the necessary permissions to the user:
      ```sql
      GRANT ALL PRIVILEGES ON *.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION;
      ```
    - This grants the user full access to manage databases.
4. **Flush Privileges**:
    - Apply the changes by running:
      ```sql
      FLUSH PRIVILEGES;
      ```
5. **Exit MariaDB**:
    - Type `exit` to leave the MariaDB shell.

#### Step 2: Add a New Database Host
Once the MySQL user is created, proceed to add a new database host in the Pterodactyl admin panel:
1. Navigate to the **Databases** section in the admin panel.
3. Click the **Create New Host** button.
4. Fill in the following details:
    - **Name**: Provide a descriptive name for the database host.
    - **Host Address**: Enter the IP address or hostname of the database server. (for us, is 10.0.0.2)
    - **Port**: Specify the port used by the database server (default is usually `3306` for MySQL).
    - **Username**: Enter the MySQL username you created earlier (e.g., `pterodactyl_db`).
    - **Password**: Enter the password for the MySQL user.
    - **Linked Node**: This setting allow to create database on different host basing on the selected node. If a server is on the selected node, then this databse host will be use.
5. Click **Create** to save the new database host.

#### Step 3: Verify the Database Host
After creating the database host:
1. If you don't see any red background, it means the database host is correctly set
2. If you see any red background, make sure the database host IP is reachable by the Panel host machine. Also make sure that the user password is correct and that the user have all permissions.

By following these steps, you can successfully create and configure a new database host in the Pterodactyl admin panel.
-   Use secure credentials and restrict access to the database server to authorized users only.
-   Refer to the [Create User](#6-create-user) section for managing database access credentials.

## 2. Wings Installation 


This section provides a step-by-step guide to installing the Wings service and connecting it to the Pterodactyl panel. Wings is the server-side daemon responsible for managing Docker containers and ensuring seamless communication with the panel.

### 1. **Install Docker**

- Wings requires Docker to manage containers. Install Docker using the following command:
    ```bash
    curl -sSL https://get.docker.com/ | CHANNEL=stable bash
    ```
-   Verify the installation by checking the Docker version:
    ```bash
    docker --version
    ```
-   Ensure Docker is running and will start at system boot:
    ```bash
    systemctl start docker
    systemctl enable docker
    ```

### 2. **Install Wings**

-   Begin by downloading the Wings binary from the official Pterodactyl repository.
    ```bash
    curl -Lo /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings
    ```
-   Make the binary executable:
    ```bash
    chmod +x /usr/local/bin/wings
    ```

### 3. **Create a Configuration Directory**

-   Create a directory to store the Wings configuration file:
    ```bash
    mkdir -p /etc/pterodactyl
    ```

### 4. **Generate a Configuration File**

-   Log in to your Pterodactyl panel as an administrator.
-   Navigate to the **Nodes** section and create a new node or select an existing one.
-   Under the **Configuration** tab, copy the provided Wings configuration file.
-   Save the configuration file to `/etc/pterodactyl/config.yml` on your server.
- **Alternatively**, click on the Generate Token button under the **Configuration** tab, copy the shell command and paste it into the terminal.

### 5. **Run Wings**

-   Start Wings using the following command:
    ```bash
    wings
    ```
- You may optionally add the `--debug` flag to run Wings in debug mode.
-   To ensure Wings runs in the background, you can set it up as a systemd service ([daemonize](#6-daemonizing-wings) it).

### 6. **Daemonizing wings**

-   Create a new service file for Wings:
    ```bash
    nano /etc/systemd/system/wings.service
    ```
-   Add the following content:
    ```ini
    [Unit]
    Description=Pterodactyl Wings Daemon
    After=docker.service
    Requires=docker.service
    PartOf=docker.service

    [Service]
    User=root
    WorkingDirectory=/etc/pterodactyl
    LimitNOFILE=4096
    PIDFile=/var/run/wings/daemon.pid
    ExecStart=/usr/local/bin/wings
    Restart=on-failure
    StartLimitInterval=180
    StartLimitBurst=30
    RestartSec=5s

    [Install]
    WantedBy=multi-user.target
    ```
-   Save and close the file, then enable and start the service:
    ```bash
    systemctl enable --now wings
    ```

### 7. **Verify Connection**

-   Return to the Pterodactyl panel and check the status of the node. If everything is set up correctly, the node should appear as online.
### 8. **Node Allocations**

-   Node allocations are used to define the IP addresses and ports that the Wings daemon can use to host servers. This step is crucial for ensuring that servers are accessible and properly configured.

    #### 1. **Add Allocations in the Panel** 
    1. Log in to your Pterodactyl panel as an administrator.
    2. Navigate to the **Nodes** section and select the node you want to configure.
    3. Go to the **Allocations** tab and click on **Create Allocation**.
    4. Fill in the required fields:
        - **IP Address**: The IP address of the node.
        - **Ports**: Specify the port range or individual ports to allocate (e.g., `25565-25570` for Minecraft servers).
    5. Click **Submit** to save the allocation.

## 3. Pterodactyl Usage
### 1. **Create a New Location**

- Locations in Pterodactyl are used to group nodes geographically or logically. This helps in organizing nodes and making it easier to manage them.

#### How to Create a Location:
1. Access your Pterodactyl panel as an administrator.
2. In the admin panel, go to the **Locations** section from the sidebar.
3. Click on the **Create Location** button.
4. Fill in the Required Fields:
    - **Short Code**: Enter a short, unique identifier for the location (e.g., `nyc`, `paris`).
    - **Description**: Provide a descriptive name for the location (e.g., `New York City`, `Paris Data Center`).
5. Click the **Create** button to save the new location.  

- Locations are purely organizational and do not affect the functionality of nodes or servers.
- Ensure the short code is unique and descriptive for easier identification.

By following these steps, you can successfully create and manage locations in the Pterodactyl panel.
### 2. **Create a New Node**

- Nodes are the physical or virtual machines where servers are hosted. Creating a node in the Pterodactyl panel is essential for managing server resources and allocations.

#### How to Create a Node:
1. Log in to your Pterodactyl panel as an administrator.
2. Navigate to the **Nodes** section from the sidebar.
3. In the Nodes section, click the **Create New Node** button.
3. Fill in the Required Fields:
    - **Name**: Enter a descriptive name for the node (e.g., `Node-1`, `Node-intra`).
    - **Location**: Select the location where this node belongs. You can learn how to create location in [this section](#1-create-a-new-location)
    - **FQDN**: Enter the Fully Qualified Domain Name (FQDN) or IP address of the node (e.g., `node1.example.com` or `10.0.0.3`).
    - **Communicate Over SSL**: Select `Yes` if the node uses SSL for secure communication. Otherwise, select `No`.
    - **Daemon Port**: Specify the port used by the Wings daemon (default is `8080`).

4. Set Resource Limits:
    - **Total Memory**: Define the total memory available for servers on this node (e.g., `16 GB`).
    - **Total Disk Space**: Specify the total disk space available for servers (e.g., `500 GB`).
    - **Memory Over-Allocation**: Enter a percentage value (e.g., `150` for 150%). This allows the node to allocate up to 150% of its physical memory.
    - **Disk Over-Allocation**: Enter a percentage value (e.g., `200` for 200%). This allows the node to allocate up to 200% of its physical disk space.
    
    ##### Notes:
    - Use over-allocation cautiously to avoid resource contention or performance issues.
    - Monitor the node's resource usage regularly to ensure stability.
    - By configuring over-allocation, you can maximize resource utilization while maintaining flexibility in server management.

5. Configure Network Settings:
    - **Public**: Enable this option except if you want a full private admin node.
    - **Behind Proxy**: Enable this option if the node is behind a proxy.
6. Click the **Create Node** button to save the new node.

7. Generate Wings Configuration:
    - After creating the node, go to the **Configuration** tab.
    - Copy the provided Wings configuration file or use the **Generate Token** button to get a shell command.
    - Follow the instructions in the [Wings Installation](#2-wings-installation) section to set up the Wings daemon on the node.

By following these steps, you can successfully create and configure a new node in the Pterodactyl panel.
### 3. **Create a New Nest**
- A Nest is a collection of Eggs that define the configuration and behavior of server instances. Follow the steps below to set up a new Nest.

#### How to Create a New Nest
1. Access the Pterodactyl Panel using your administrator credentials.
2. From the sidebar, click on `Nests` under the `Server Management` category.
3. Click the `Create New` button located at the top-right corner of the Nests page.
4. Fill in Nest Details:
      - **Name**: Enter a descriptive name for the Nest.
      - **Description**: Add a brief description of the Nest's purpose or contents.
5. Once all required fields are filled, click the `Create Nest` button to save the new Nest.
6. After creating the Nest, you can add Eggs to it by importing it (a json file) from the `Nests` tab on the side bar, or create a new one from scratch while in the Nest details view page.
### 4. **Create a New Egg**
- Eggs are templates that define the configuration and behavior of individual server instances. Follow these steps to create a new Egg:
- Creating a egg from scratch is a very long and hard task. We recommand to search online for an existing egg that already doing what you want. But if you really want/need to create it yourself, please refer to the [Pterodactyl community documentation](https://pterodactyl.io/community/config/eggs/creating_a_custom_egg.html)
#### How to Create a New Egg:
1. Log in to the Pterodactyl panel as an administrator.
2. Navigate to the **Nests** section and select the Nest where you want to add the Egg.
3. Click the **New Egg** button.
4. Refer to the [community documentation](https://pterodactyl.io/community/config/eggs/creating_a_custom_egg.html) for going further
#### How to Import a New Egg:
1. Download the JSON file corresponding to the Egg you want to import. You can find a community repo containing many different egg [here](https://github.com/Ptero-Eggs)
2. Log in to the Pterodactyl panel as an administrator.
3. Navigate to the **Nests** section
4. Click the **Import Egg** button.
5. Browse to the json file you saved earlier
6. Select the Nest you want to put the egg in.

#### Notes:
- Ensure the Docker image and startup command are compatible with the server type.
- Use descriptive names and clear descriptions to make Eggs easier to identify.
- Test the Egg configuration on a test server before deploying it to production.

By following these steps, you can successfully create and manage Eggs in the Pterodactyl panel.
### 5. **Create a New Server**
- Servers in Pterodactyl are the actual instances that run applications or services. 
- Before creating a server, ensure you have a valid node, (refer to [this](#2-create-a-new-node))
- Also make sure you have imported the egg of the application/service you want to run. Refer to [this](#4-create-a-new-egg)
- Now follow the steps below to create a new server.

#### How to Create a New Server:
1. Log in to the Pterodactyl panel as an administrator.
2. Navigate to the **Servers** section from the sidebar.
3. Click the **Create New Server** button.
4. Fill in the Required Fields:
    - **Name**: Enter a descriptive name for the server (e.g., `Wordpress server`, `Grafana`).
    - **Description**: Provide a brief description of the server's purpose or details.
    - **User**: Select the user who will own this server. You can create a new user in the `User` tab if needed.
    - **Node**: Select an currently available node (online) to host the server
    - **Default Allocation**: Select a free allocation on the node you selected
    - **Nest**: Choose the Nest that contains the Egg for this server.
    - **Egg**: Select the Egg that defines the server's configuration and behavior.
    - **Docker Image**: The Docker image will be pre-filled based on the selected Egg. Modify it only if necessary.
    - **Startup Command**: This will also be pre-filled based on the Egg. Modify it only if required.

5. Configure Resource Limits:
    - **CPU Limit**: Define the maximum CPU usage for the server (e.g., `200%` for 2 cores).
    - **Memory**: Specify the amount of RAM allocated to the server (e.g., `4 GB`).
    - **Disk Space**: Set the amount of disk space available for the server (e.g., `20 GB`).
    - **Swap**: Define the swap memory allocation (set to `0` to disable swap).
    - **IO Weight**: Set the I/O priority for the server (default is `500`).

6. Configure Feature Limits:
    - **Databases**: Specify the maximum number of databases the server can create.
    - **Allocations**: Define the number of ports the server can use.
    - **Backups**: Set the maximum number of backups the server can create.

8. Configure Environment Variables:
    - Modify any environment variables required by the Egg. These will be pre-filled based on the Egg's configuration.

9. Finalize and Create:
    - Review the server details to ensure everything is correct.
    - Click the **Create Server** button to finalize the setup.

#### Notes:
- Resource limits should be set based on the server's requirements and the node's available resources.
- Test the server after creation to verify that it is functioning as expected.

By following these steps, you can successfully create and manage servers in the Pterodactyl panel.


--- 
This guide provides a comprehensive overview of setting up Pterodactyl and Wings. Ensure you follow each step carefully to avoid configuration issues. For further assistance, refer to the [official Pterodactyl documentation](https://pterodactyl.io/).

Happy hosting!
