# Wordpress installation and configuration on Pterodactyl Guide

## Summary

This guide provide a fully detailed instructions for installing and hosting a WordPress website inside a docker container and managed via Pterodactyl Panel.
## ⚠️ Prerequisites

- A functional Pterodactyl panel must be available. Refer to [Pterodactyl documentation](./Pterodactyl.md) for setup
- At least one connected and online node. Refer to [Wings documentation](./Pterodactyl.md#2-wings-installation) for setup and [wings connection](./Pterodactyl.md#2-create-a-new-node) for connecting and creating the new node on the panel.
- Allocations must be configured and available on the connected node.
- All commands are run as **root user**

## Table of Contents
1. [WordPress Installation on Pterodactyl](#1-wordpress-installation-on-pterodactyl)
    - [Download the WordPress Egg](#1-download-the-wordpress-egg)
    - [Create a New Server](#2-create-a-new-server)
    - [Configure the Server](#3-configure-the-server)
    - [Access WordPress](#4-access-wordpress)
    - [Notes](#5-notes)
2. [Reverse Proxy](#2-reverse-proxy)
    - [Install a Web Server](#1-install-a-web-server)
    - [Configuration for the Reverse Proxy](#2-configuration-for-the-reverse-proxy)
    - [Enable the Configuration](#3-enable-the-configuration)
    - [Test the Reverse Proxy](#4-test-the-reverse-proxy)  
    - [Secure the Connection](#5-secure-the-connection)  
        - [Install Certbot](#1-install-certbot)
        - [Obtain an SSL Certificate](#2-obtain-an-ssl-certificate)
        - [Add the Certificate](#3-add-the-certificate)
        - [Reload NGINX](#4-reload-nginx)
        - [Test the Secure Connection](#5-test-the-secure-connection)
        - [Setup automatica Renewal](#6-set-up-automatic-renewal)


---
## 1. WordPress Installation on Pterodactyl

This section provides a step-by-step guide to installing WordPress on Pterodactyl using the [egg](nginx-egg-pterodactyl.json) created by `info@finniedj.nl`.

### 1. **Import the WordPress Egg**

1. Log in to your Pterodactyl panel as an administrator.
2. Navigate to the **Nests** section and select the nest where you want to add the WordPress egg (e.g., "Applications").
3. Click on **Import Egg** and upload the WordPress egg JSON file provided by `info@finniedj.nl`.  
    - You can download the egg [here](./nginx-egg-pterodactyl.json)

### 2. **Create a New Server**
- *This part retake the same process that the one explained [here](./Web.md#5-create-a-new-server) but with more specific details*

1. Go to the **Servers** section and click **Create New**.
2. Fill in the required details:
    - **Name**: Enter a name for your WordPress server.
        - **User**: Assign the server to a user.
        - **Nest**: Select the nest where you imported the WordPress egg.
        - **Egg**: Choose the WordPress egg.
        - **Database Limit**: Set the database limit to `1` since WordPress requires a single database.
        - **CPU**: Allocate sufficient CPU resources (e.g., 100% or more depending on your server's requirements) (100% = 1 core).
        - **Memory**: Allocate sufficient memory (e.g., 512 MB or more).
        - **Disk**: Allocate enough disk space (e.g., 1 GB or more).
        - **WordPress Installation**: Set the `wordpress` variable to `true` to enable WordPress installation. If set to `false`, WordPress will not be installed.
3. Click **Create Server** to finalize the setup.

### 3. **Configure the Server**
1. Go under the `database` tab, and create a new one with allowing connection from anywhere.
2. Start the server from the panel.
3. Access the **Console** tab to monitor the installation process.
4. Once the server is running, note the **IP address** and **port** assigned to it.

### 4. **Access WordPress**

1. Open a web browser and navigate to `http://<server-ip>:<port>`.
2. Follow the WordPress setup wizard to configure your site:
    - Choose a language.
    - Enter database details (You will find them in `database` tab, after opening database details modal ).
    - Set up an admin account and site details.
---

Your WordPress site is now ready to use! For further customization, refer to the [official WordPress documentation](https://wordpress.org/support/).

### 5. **Notes**
- This egg is automatically installing wordpress. But the process to install it is pretty simple. Here is the step to follow:

    1. Download latest version of Wordpress on official [website](https://wordpress.org)
    2. Extract the archive
    3. Move the content of `wordpress` folder to your webroot folder
    4. Remove archive files and empty `wordpress` folder.
    5. Configure a web server to serve the wordpress file. 
        - For wordpress, you can re-use the [web server configuration](./Web.md#6-webserver-configuration) from Pterodactyl panel. Don't forget you can customize it/adding SSL, for more detailed instructions about adding a SSL, you can refer to the [SSL obtention guide](#2-obtain-an-ssl-certificate) and to the [Reverse Proxy SSL Configuration](#3-add-the-certificate) to configure NGINX. The configuration for a website and for a Reverse Proxy is the same in this case.
- Here is the script to make that (from 1 to 4 only):
    ```
    cd /mnt/server/webroot # move to the webroot folder
    curl -LO http://wordpress.org/latest.tar.gz # Step 1
    tar -xzf latest.tar.gz # Step 2
    mv wordpress/* . # Step 3
    rm -rf wordpress latest.tar.gz # Step 4
    ```

## 2. **Reverse Proxy**

This section provides a step-by-step guide to setting up a reverse proxy for your WordPress installation.

### 1. **Install a Web Server**

- Ensure you have a web server installed on your reverse proxy machine (e.g., Nginx or Apache) (if you have followed the [documentation for installing Pterodactyl](./Web.md), you already have NGINX installed).

- If not installed, use the following commands to install Nginx or Apache:
- For Nginx:
    ```bash
    sudo apt update
    sudo apt install nginx
    ```
- For Apache:
    ```bash
    sudo apt update
    sudo apt install apache2
    ```

#### **WARNING**, in this guide, we will use NGINX, if you want to use apache, please refer to online tutorial (or the [official documentation](https://httpd.apache.org/docs/2.4/howto/reverse_proxy.html))

### 2. **Configuration for the Reverse Proxy**


#### 1. **Nginx configuration**
- Open the configuration file with your favorite text editor.
    ```bash
    nano /etc/nginx/sites-available/wordpress.conf
    ```
- Add the following configuration to proxy traffic to your WordPress server:
    ```nginx
    server {
        listen 80;
        server_name yourdomain.com;   

        location / {
            proxy_pass http://<server-ip>:<port>;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
      }
    ```
- Replace `yourdomain.com` by your domain name or sub-domain you want to use.
- Replace `<server-ip>` and `<port>` with the IP address and port of your WordPress server.


### 3. **Enable the Configuration**
- To enable the configuration, we should link the configuration from the availables folder to the enabled one and reload nginx.
- To create the link use the following command:
    ```bash
    sudo ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/
    ```
- Now check the configuration, if there is no error and reload NGINX. You can refer to [Pterodactyl guide](./Web.md#6-webserver-configuration) for more details
    ```
    sudo nginx -t
    sudo systemctl reload nginx
    ```

### 4. **Test the Reverse Proxy**

1. Open a web browser and navigate to your domain.
2. Verify that the WordPress site is accessible through the reverse proxy.

### 5. **Secure the Connection**

#### 1. **Install Certbot**  
- Certbot is a tool to obtain and manage SSL/TLS certificates. Install it using the following commands:
    ```bash
    apt update
    apt install certbot python3-certbot-nginx
    ```

#### 2. **Obtain an SSL Certificate**  
- Run the following command to obtain a certificate for your domain:
    ```bash
    sudo certbot certonly --nginx -d yourdomain.com
    ```
- Replace `yourdomain.com` with your actual domain name.
- `--nginx` tell to certbot to use nginx as web server to handle challenge files that CA uses to certify the certificate
- This command will only generate a certificate
- `-d` say that the next arguments is the domain for wich we generate a certificate.

#### 3. **Add the Certificate**  
- Now that the certificate is generated, we need to update our configuration.
- To do that, open your nginx configuration with your favorite text editor, or using nano:
   ```bash
    nano /etc/nginx/sites-available/wordpress.conf
    ```
- An add the following lines between `server_name` and `location`:
    ```
    ssl_certificate /etc/letsencrypt/live/<domain>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<domain>/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    ssl_prefer_server_ciphers on;
    ```
- Don't forget to replace `<domain>` by your domain (the one used when generating the certificate)

#### 4. **Reload Nginx**  
- Test and apply the changes by reloading Nginx:
    ```bash
    nginx -t
    nginx -s reload
    ```

#### 5. **Test the Secure Connection**  
- Open a web browser and navigate to your domain. Verify that the connection is secure and the SSL certificate is active.

#### 6. **Set Up Automatic Renewal**  
- Certbot automatically renews certificates, but you can test the renewal process with:
    ```bash
    certbot renew --dry-run
    ```  
<br>
Your connection is now secured with SSL/TLS! For more details, refer to the [Certbot documentation](https://certbot.eff.org/).

---

Your reverse proxy is now set up! For further customization, refer to the official documentation for [Nginx](https://nginx.org/en/docs/).
