# Wordpress installation and configuration on Pterodactyl Guide

## Summary

This guide covers the following topics:

-   Configuring NGINX for a Website
-   Configuring NGINX for a PHP Website
-   Configuring NGINX for a Website With SSL (same for PHP)

## ⚠️ Prerequisites

-   A functional Linux Debian Server With NGINX installed on.
-   All commands are run as **root user**

## Table of Contents

- [Technical choice: NGINX](#technical-choice-nginx)  
1. [Install Dependencies](#1-install-dependencies)
    - [1. Update your system](#1-update-your-system)
    - [2. Install NGINX](#2-install-nginx)
    - [3. Install PHP](#3-install-php)
    - [4. Install certbot](#4-install-certbot)  
2. [Nginx for a simple Website](#2-nginx-for-a-simple-website)
    - [1. Create a New NGINX Configuration File](#1-create-a-new-nginx-configuration-file)
    - [2. Define the Server Block](#2-define-the-server-block)
    - [3. Create the Website Root Directory](#3-create-the-website-root-directory)
    - [4. Enable the Configuration](#4-enable-the-configuration)
    - [5. Test the Configuration](#5-test-the-configuration)
    - [6. Reload NGINX](#6-reload-nginx)
    - [7. Access Your Website](#7-access-your-website)
3. [Nginx for a PHP Website](#3-nginx-for-a-php-website)
    - [1. Enable PHP Support in the Server Block](#1-enable-php-support-in-the-server-block)
    - [2. Create a PHP Test File](#2-create-a-php-test-file)
    - [3. Enable the configuration](#3-enable-the-configuration)
    - [4. Test the Configuration](#4-test-the-configuration)
    - [5. Reload NGINX](#5-reload-nginx)
    - [6. Verify PHP is Working](#6-verify-php-is-working)
4. [Nginx for a Website with SSL](#4-nginx-for-a-website-with-ssl)
    - [1. Generate an SSL Certificate](#1-generate-an-ssl-certificate)
    - [2. Add SSL Configuration](#2-add-ssl-configuration)
    - [3. Optional SSL Instructions](#3-optional-ssl-instructions)
    - [4. Redirect HTTP to HTTPS](#4-redirect-http-to-https)
    - [5. Apply the configuration](#5-apply-the-configuration)
    - [6. Test the Configuration](#6-test-the-configuration)
    - [7. Reload NGINX](#7-reload-nginx)
    - [8. Verify SSL is Working](#8-verify-ssl-is-working)


## Technical choice: NGINX

NGINX is a powerful and efficient web server, reverse proxy, loadbalancer, and mail proxy that offers several advantages:

-   **Performance**: NGINX is designed to handle a large number of concurrent connections with low resource usage, making it ideal for high-traffic websites.
-   **Scalability**: It supports load balancing, allowing you to distribute traffic across multiple servers for better performance and reliability.
-   **Flexibility**: NGINX can serve static/dynamic content, act as a reverse proxy for dynamic content, and support various protocols like HTTP, HTTPS, and even HTTP/2.
-   **Security**: It provides robust features like SSL/TLS termination, rate limiting, and protection against common web attacks.
-   **Ease of Configuration**: NGINX uses a straightforward configuration syntax, making it easy to set up and customize for different use cases.
-   **Community and Documentation**: NGINX has a large community and extensive documentation, making it easier to find solutions and best practices.

These features make NGINX a popular choice for hosting websites, handling APIs, and acting as a reverse proxy for applications like WordPress.

---

## 1. Install Dependencies

#### 1. **Update your system**

-   Before starting We will have to ensure the system is up to date, to make that, run the following command
    ```
    apt update; apt upgrade -y
    ```

#### 2. **Install NGINX**

-   Since, in this documentation, we use NGINX as a Reverse Proxy and a web server, this documentation depends on NGINX. To install it, run the following command:
    ```
    apt install -y nginx
    ```

#### 3. **Install PHP**

-   Now if you want to run a PHP website, you will need PHP and PHP-FPM, but on Debian, PHP is not by default in the `apt` sources list, to enable it, please follow the documentation to add [repository](./Pterodactyl.md#2-add-repositories) and add the PHP repositorie.
-   Now update your system again (just `apt update`)
-   You can finally install PHP and FPM, use the following command for this:
    ```
    apt install -y php8.3 php8.3-fpm
    ```
-   This will install PHP version 8.3 and PHP-FPM for the same version of PHP.
-   You can change the `8.3` by any PHP version that exist!

#### 4. **Install certbot**

-   Certbot is a great tool to generate free let's encrypt certificate. It's also integrating a automated renewal system.
-   To install certbot, use the following command:
    ```
    apt install certbot python3-certbot-nginx
    ```

## 2. **Nginx for a simple Website**

This section provides a step-by-step guide to setting up a basic NGINX configuration

### 1. **Create a New NGINX Configuration File**

-   Navigate to the NGINX configuration directory:
    ```
    cd /etc/nginx/sites-available
    ```
-   Create a new configuration file for your website (e.g., `example.com`):
    ```
    nano example.com
    ```

### 2. **Define the Server Block**

-   Add the following configuration to the file:

    ```conf
    server {
          listen 80; # Port to listen on
          server_name example.com; # www.example.com; # you can add multiple server_name # Replace with your domain name

          access_log /var/log/nginx/example.com.access.log; # Path to access log file, it will print in the file all connection date, scheme, IP, path, and some other data
          error_log /var/log/nginx/example.com.error.log; # Path to error log file, it will print in the file all error that occurs within the website on server side

          root /var/www/example.com; # Path to your website's root directory
          index index.html index.htm; # Default files to serve, seperated by a space

          location / {
               try_files $uri $uri/ =404; # Serve files or return 404 if not found
          }
    }
    ```

### 3. **Create the Website Root Directory**

-   Create the directory specified in the `root` directive:
    ```
    mkdir -p /var/www/example.com
    ```
-   Add an `index.html` file to test the configuration (or your code):
    ```
    echo "<h1>Welcome to example.com</h1>" > /var/www/example.com/index.html
    ```

### 4. **Enable the Configuration**

-   Create a symbolic link to enable the site:
    ```
    ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/
    ```

5. **Test the Configuration**

    - Test the NGINX configuration for syntax errors:
        ```
        nginx -t
        ```

6. **Reload NGINX**

    - Apply the changes by reloading NGINX:
        ```
        systemctl reload nginx
        ```

7. **Access Your Website**
    - Open a web browser and navigate to `http://example.com` or `http://<your-server-ip>` to verify the setup.

Your simple website is now configured and accessible! For additional customization, refer to the [NGINX documentation](https://nginx.org/en/docs/).

## 3. **Nginx for a PHP Website**

This section provides a step-by-step guide to setting up a NGINX for a basic website running on PHP. It will be based on the previous configuration [block](#2-define-the-server-block) provided in the section [before](#2-nginx-for-a-simple-website)

### 1. **Enable PHP Support in the Server Block**

-   To configure NGINX to handle PHP files, update the `server` block in your NGINX configuration file. Add the following snippet at the end of the `server` block:
    ```conf
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock; # Adjust this to match your installed PHP version
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    ```
-   This configuration ensures that requests for `.php` files are forwarded to the PHP-FPM service. It includes the necessary parameters to correctly process PHP scripts and pass them to the PHP-FPM instance for execution.
-   Change the PHP version `8.3` if you want to use a different version

### 2. **Create a PHP Test File**

-   Create a test PHP file in your website's root directory:
    `      echo "<?php phpinfo(); ?>" > /var/www/example.com/index.php
     `

### 3. **Enable the configuration**

-   To apply the configuration, refer to the documentation wrote [before](#4-enable-the-configuration) if you didn't already did this

### 4. **Test the Configuration**

-   Test the NGINX configuration for syntax errors:
    `      nginx -t
     `

### 5. **Reload NGINX**

-   Apply the changes by reloading NGINX:
    `      systemctl reload nginx
     `

### 6. **Verify PHP is Working**

-   Open a web browser and navigate to `http://example.com` or `http://<your-server-ip>`. You should see the PHP info page, confirming that PHP is working correctly.

Your PHP website is now configured and ready to use! For additional customization, refer to the [NGINX documentation](https://nginx.org/en/docs/) and [PHP documentation](https://www.php.net/docs.php).

## 4. **Nginx for a Website with SSL**

This section provides a step-by-step guide to setting up a SSL in a basic NGINX configuration. Before following this guide, ensure you got a [basic](#2-nginx-for-a-simple-website) configuration or a [PHP configuration](#3-nginx-for-a-php-website)

### 1. **Generate an SSL Certificate**

-   Use Certbot to generate an SSL certificate for your domain:
    ```
    certbot --nginx -d example.com
    ```
-   Replace `example.com` with your actual domain names.
-   Certbot automatically renew certificate

### 2. **Add SSL Configuration**

-   Certbot only generate the certificate.
-   So you need to update your NGINX configuration to tell NGINX to use the certificate.
-   To make it, open your configuration file with your favorite editor like nano
    ```
    nano /etc/nginx/sites-available/example.com
    ```
-   Add the following snippet into the `server` block between `index` and `location` instructions:
    ```conf
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem; # Path to SSL certificate
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem; # Path to SSL certificate key
    ```
-   Now replace the `listen` instructions values. The configuration done before use port `80` wich stand for HTTP, not HTTPS (s for secure). You will need to set it to `443` wich stand for HTTPS protocol.

### 3. **Optional SSL Instructions**

-   For enhanced security, you can add the following SSL options to your configuration file:
    ```conf
    ssl_protocols TLSv1.2 TLSv1.3; # Enable only secure TLS protocols
    ssl_prefer_server_ciphers on; # Prefer server ciphers over client ciphers
    ssl_ciphers HIGH:!aNULL:!MD5; # Use strong ciphers
    ssl_session_cache shared:SSL:10m; # Cache SSL sessions for better performance
    ssl_session_timeout 1d; # Set session timeout to 1 day
    ssl_stapling on; # Enable OCSP stapling
    ssl_stapling_verify on; # Verify OCSP responses
    resolver 8.8.8.8 8.8.4.4 valid=300s; # Use Google's public DNS for OCSP
    resolver_timeout 5s; # Set resolver timeout
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always; # Enforce HTTPS
    ```
-   These options improve the security of your SSL configuration by enabling modern protocols, strong ciphers, and additional security headers.
-   This options is optionnal and not required. You can add it if you need it.
-   Make sure to test your configuration after adding these options to ensure compatibility with your server and clients.
-   For more details on SSL configuration, refer to the [NGINX SSL documentation](https://nginx.org/en/docs/http/configuring_https_servers.html).

### 4. **Redirect HTTP to HTTPS**

-   To enforce HTTPS for all traffic, include a redirection rule at the top of your configuration file to force use of HTTPS:
    ```conf
    server {
        listen 80;
        server_name example.com;
        return 301 https://$host$request_uri;
    }
    ```
-   Replace `example.com` by your domain.

### 5. **Apply the configuration**

-   To apply the configuration, if you haven't follow the [first part](#2-nginx-for-a-simple-website) of the documentation, please refer to the [Enable configuration](#4-enable-the-configuration) section.

### 6. **Test the Configuration**

-   Test the NGINX configuration for syntax errors:
    ```
    nginx -t
    ```

### 7. **Reload NGINX**

-   Apply the changes by reloading NGINX:
    ```
    systemctl reload nginx
    ```

### 8. **Verify SSL is Working**

-   Open a web browser and navigate to `https://example.com`. You should see your website served over HTTPS with a valid SSL certificate.

Your website is now secured with SSL! For additional SSL configuration options, refer to the [Certbot documentation](https://certbot.eff.org/) and [NGINX SSL documentation](https://nginx.org/en/docs/http/configuring_https_servers.html).
