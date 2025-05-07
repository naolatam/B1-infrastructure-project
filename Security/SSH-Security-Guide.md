# Security Documentation – UFW Configuration

## ⚠️ Prerequisites

All commands are run as **root user**.  
The system is based on **Debian**.

---

## Table of Contents

1. [⚠️ Prerequisites](#⚠️-prerequisites)
2. [Introduction](#introduction)
3. [Installation](#installation)
    - [1. Update the system](#1-update-the-system)
    - [2. Install it](#2-install-it)
4. [Configuration](#configuration)
    - [1. Change default port](#1-change-default-port)
    - [2. Disable Password root login](#2-disable-password-root-login)
    - [3. Enable key authentication](#3-enable-key-authentication)
    - [4. SSH Limits](#4-ssh-limits)
        - [1. Set Login Grace Time](#1-set-login-grace-time)
        - [2. Enable Strict Modes](#2-enable-strict-modes)
        - [3. Limit Authentication Attempts](#3-limit-authentication-attempts)
        - [4. Limit Concurrent Sessions](#4-limit-concurrent-sessions)
    - [5. Configure Fail2Ban](#5-configure-fail2ban)
        - [1. Edit the Fail2Ban Configuration File](#1-edit-the-fail2ban-configuration-file)
        - [2. Enable SSH Protection](#2-enable-ssh-protection)
        - [3. Enable Fail2Ban](#3-enable-fail2ban)
        - [4. Restart Fail2Ban](#4-restart-fail2ban)
5. [Restart SSH](#4-restart-ssh)

## Introduction

This documentation explains how to secure SSH connection on a Linux server (Debian based). It will disable root login and ban IP that will try to connect to much times.

---

## Installation

-   For this Guide, we will use `Fail2Ban`, so we need to install it

### 1. **Update the system**

```bash
apt update && apt upgrade -y
```

### 2. **Install it**

```bash
apt install -y fail2ban
```

## Configuration

The `sshd_config` file is the main configuration file for the SSH server. It is located in the `/etc/ssh` directory. Modifying this file allows you to customize the behavior of the SSH server, including enhancing its security.

To edit the file, use a text editor like `nano`:

```bash
nano /etc/ssh/sshd_config
```

### 1. **Change default port**

-   The port used for SSH is one of the first things set in the conifguration file.
-   In this project, we will use the port 1501. But you can use the port you want at least if it not used by any other service
-   You can check if a port is used by anyservice using this website: https://www.speedguide.net/port.php?port=\<PORT>
-   And replace '\<PORT>' by your port number.
-   So, to edit the configuration, run the following command:

```bash
sed -i 's/^#Port 22/Port 1501/' /etc/ssh/sshd_config
```

-   It will replace the line with `Port 22` by `Port 1501`.
-   If you want to make this change manually, you can edit the file with your favorite editor, search for the line starting with `Port` and replace the port number by the one you want to use.
-   After making this change, save the file, we will restart later.
-   If you change your SSH port, don't forget to update your firewall!

After making these changes, save the file and restart the SSH service to apply the new configuration:

```bash
systemctl restart sshd
```

These modifications significantly enhance the security of your SSH server by reducing attack vectors and enforcing stricter access controls.

### 2. **Disable Password root login**
-   Disabling Password root login is a critical step to enhance the security of your SSH server.
-   To disable password root login, edit the SSH configuration file:

```bash
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication prohibit-password/' /etc/ssh/sshd_config
```

-   This command will replace the line with `PermitRootLogin yes` by `PermitRootLogin prohibit-password`.
-   If you prefer to make this change manually, open the file with your favorite editor, search for the line starting with `PermitRootLogin`, and set its value to `prohibit-password`.
-   After making this change, save the file, we will restart later.

Disabling password root login ensures that attackers cannot directly target the root account, significantly reducing the risk of unauthorized access.

### 3. **Enable Key authentication**
- Ensure the SSH server is configured to allow public key authentication.
- open the file and verify the following settings:  
    ```
    PubkeyAuthentication yes
    AuthorizedKeysFile .ssh/authorized_keys
    ```
- Or you can do it automatically with this commands:
    ```bash
    sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^#AuthorizedKeysFile .ssh\/authorized_keys/AuthorizedKeysFile .ssh\/authorized_keys/' /etc/ssh/sshd_config
    ```
By following these steps, you can enable and use public key authentication for secure and 
password-less access to your server.
"""
### 4. **SSH Limits**

To further enhance the security of your SSH server, you can configure additional limits in the `sshd_config` file. These settings help control login behavior and reduce the risk of brute-force attacks.

#### **1. Set Login Grace Time**

-   The `LoginGraceTime` option specifies the time allowed for a user to successfully authenticate before the server disconnects.
-   To set it to 1 minutes, run the following command:

```bash
sed -i 's/^#LoginGraceTime 2m/LoginGraceTime 1m/' /etc/ssh/sshd_config
```

-   Alternatively, open the file manually in your favorite text editor and ensure the line is not commented, also change the value to 1m:

```bash
LoginGraceTime 1m
```

#### **2. Enable Strict Modes**

-   The `StrictModes` option ensures that SSH checks file permissions and ownership of the user's files and directories before allowing login.
-   To enable it, run:

```bash
sed -i 's/^#StrictModes yes/StrictModes yes/' /etc/ssh/sshd_config
```

-   Or manually ensure that the line is not commented and the value is set to `yes`:

```bash
StrictModes yes
```

#### **3. Limit Authentication Attempts**

-   The `MaxAuthTries` option limits the number of authentication attempts per connection.
-   To set it to 3 attempts, run:

```bash
sed -i 's/^#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
```

-   This will uncomment the line and update his values.
-   Or manually uncomment and set the value to `3`:

```bash
MaxAuthTries 3
```

#### **4. Limit Concurrent Sessions**

-   The `MaxSessions` option limits the number of open sessions per connection.
-   To uncomment the line and set it to 5 sessions, run:

```bash
sed -i 's/^#MaxSessions 10/MaxSessions 5/' /etc/ssh/sshd_config
```

-   Or do it manually, the line should be like this one:

```bash
MaxSessions 5
```

**Don't forget to save the file if you edit manually the configuration**

These settings help enforce stricter login policies, reducing the risk of unauthorized access and resource abuse.

### 5. **Configure Fail2Ban**

Fail2Ban is a tool that helps protect your server by banning IP addresses that show malicious signs, such as too many failed login attempts.

#### 1. Edit the Fail2Ban Configuration File

-   The main configuration file for Fail2Ban is located at `/etc/fail2ban/jail.local`. If the file does not exist, create it by copying the default configuration file:

```bash
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

-   Open the `jail.local` file with your preferred text editor:

```bash
nano /etc/fail2ban/jail.local
```

#### 2. Enable SSH Protection

-   Locate the `[sshd]` section in the file. If it does not exist, add the following configuration:

```ini
[sshd]
enabled = true
port = 1501
filter = sshd
logpath = %(sshd_log)s
maxretry = 5
bantime = 3600
```

-   Replace `1501` with the custom SSH port you configured before.
-   The `maxretry` option specifies the number of failed attempts before banning an IP.
-   The `bantime` option defines how long (in seconds) an IP will be banned.

#### 3. Enable Fail2Ban

-   Since we have just install it, it's not already enable on systemd, so to enable it we will enter the following command:

```bash
systemctl enable --now fail2ban
```

#### 4. Restart Fail2Ban

-   Normally, after enabling it for the first time, it should start, but for not taking any risk, we will restart it anyways

```bash
systemctl restart fail2ban
```

### 4. **Restart SSH**

-   To ensure the configuration is running, use the following command to restart sshd:

```
systemctl restart sshd
```
