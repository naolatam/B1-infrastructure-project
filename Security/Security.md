# Security Documentation

## Table of Contents

1. [Firewall Documentation](#1-firewall-documentation)
2. [Regular Update Documentation](#2-regular-updates)
3. [SSH Security](#3-ssh-security)

## 1. Firewall Documentation

The documentation for configure the firewall using UFW and IPTABLES is [here](./ufw_tech_doc.md)

## 2. Regular Updates

To ensure the system remains secure and up-to-date, you can automate updates using `cron`. Follow these steps:

1. **Create a Script for Updates**  
    Write a script to handle updates. Save it as `/usr/local/bin/update-packages.sh`:

    ```bash
    #!/bin/bash
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    ```
    Make the script executable:
    
    ```bash
    chmod +x /usr/local/bin/update-packages.sh
    ```

2. **Schedule the Script with Cron**  
    Open the `cron` editor:
    ```bash
    crontab -e
    ```

    Add the following line to schedule the script to run daily at 2 AM:
    ```bash
    0 2 * * * /usr/local/bin/update-packages.sh
    ```

3. **Verify Cron Job**  
    Ensure the cron job is listed:
    ```bash
    crontab -l
    ```

4. **Monitor Logs**  
    Check the cron logs to confirm the updates are running as scheduled:
    ```bash
    grep CRON /var/log/syslog
    ```

    Automating updates with `cron` ensures your system stays secure without manual intervention.

## 3. SSH Security
The documentation on how the SSH was secured can be found [here](./SSH-Security-Guide.md)
