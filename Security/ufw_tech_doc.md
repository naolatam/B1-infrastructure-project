# Security Documentation – UFW Configuration

## ⚠️ Prerequisites

All commands are run as **root user**.  
The system is based on **Debian**.

---

## Table of Contents

1. [⚠️ Prerequisites](#️-prerequisites)
2. [Introduction](#introduction)
3. [Installation](#installation)
    - [1. Update the system](#1-update-the-system)
    - [2. Install UFW](#2-install-ufw)
4. [Configuration](#configuration)
    - [1. Set default policy](#1-set-default-policy)
    - [2. Set Custom Rules](#2-set-custom-rules)
      - [VPS](#vps)
      - [VM Intra](#vm-intra)
      - [VM Extra](#vm-extra)
    - [3. Disable ping](#3-disable-ping)
    - [4. Enable UFW](#enable-ufw)
      - [Enable UFW](#enable-ufw-1)
      - [Check UFW Status](#check-ufw-status)
      - [Sample Output](#sample-output)
5. [Configuration Completed](#configuration-completed)
6. [Useful UFW Commands](#useful-ufw-commands)
    - [1. Check UFW Status](#1-check-ufw-status)
    - [2. Enable/Disable UFW](#2-enabledisable-ufw)
    - [3. Allow/Deny Specific Ports](#3-allowdeny-specific-ports)
    - [4. Delete a Rule](#4-delete-a-rule)
    - [5. Reset UFW](#5-reset-ufw)
    - [6. Enable Logging](#6-enable-logging)
    - [7. Reload UFW](#7-reload-ufw)

## Introduction

This documentation explains how to install, enable, and configure a basic firewall using **UFW** (Uncomplicated Firewall) on a Linux server (Debian based).

---

## Installation

### 1. **Update the system**

```bash
apt update && apt upgrade -y
```

### 2. **Install UFW**

```bash
apt install ufw -y
```

## Configuration
### 1. **Set default policy**

The default policy in UFW (Uncomplicated Firewall) determines how the firewall handles traffic that does not explicitly match any rules. By setting these policies, you define the baseline behavior for incoming, outgoing, and routed traffic.

The following commands configure the default policy:

```bash
ufw default deny incoming
ufw default allow outgoing
ufw default deny routed
```

- `ufw default deny incoming`: Blocks all incoming connections by default. This ensures that no unauthorized external traffic can access your system unless explicitly allowed by a rule.
- `ufw default allow outgoing`: Allows all outgoing connections by default. This permits your system to initiate connections to external servers or services without restrictions.
- `ufw default deny routed`: Blocks all forwarded traffic by default. This is useful if your system is acting as a router or gateway and you want to prevent traffic from being forwarded between networks.

These settings provide a secure starting point by minimizing exposure to external threats while allowing your system to function normally for outgoing connections.

### 2. **Set Custom Rules**

To allow incoming traffic for specific services, you need to define custom rules for the corresponding ports. Below is the list of services and their respective ports for each virtual machine:

#### **VPS**
The following services should be enabled on this VM:
- **SSH**: Port `22`
- **HTTP**: Port `80`
- **HTTPS**: Port `443`
- **Node Exporter**: Port `9100`
- **Wireguard**: Port `51820`

#### **VM Intra**
The following services should be enabled on this VM:
- **HTTP**: Port `80`
- **SSH**: Port `1501`
- **SFTP**: Port `2022`
- **MariaDB**: Port `3306`
- **Wings**: Port `8080` (pseudo-HTTP)
- **Node Exporter**: Port `9100`
- **Custom Ports**: Ports `50000` and `50002`

#### **VM Extra**
The following services should be enabled on this VM:
- **SSH**: Port `1501`
- **SFTP**: Port `2022`
- **Wings**: Port `8080` (pseudo-HTTP)
- **Custom Port**: Port `8081`
- **Node Exporter**: Port `9100`

All these services require only the **TCP** protocol. To create a custom rule, use the following command:

```bash
ufw allow <port>/tcp
```

Replace `<port>` with the port number corresponding to the service you want to enable. For example, to allow SSH traffic, you would run:

```bash
ufw allow 22/tcp
```

Repeat this command for each port listed above to configure the firewall for your specific requirements.

### 3. **Disable ping**

To ensure the server doesn't reply his alive
### 3. **Enable UFW**
#### **Enable UFW**

Run the following command to enable UFW:

```bash
ufw enable
```

You will be prompted to confirm the action. Type `y` and press `Enter` to proceed. This will activate the firewall with the rules you have configured.

#### **Check UFW Status**

To ensure UFW is enabled and configured correctly, use the following command:

```bash
ufw status verbose
```

This will display the current status of UFW, including the default policies, logging level, and the list of allowed ports.

#### **Sample Output**

```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
3306/tcp                   ALLOW       Anywhere
2022/tcp                   ALLOW       Anywhere
8080/tcp                   ALLOW       Anywhere
9100/tcp                   ALLOW       Anywhere
50000/tcp                  ALLOW       Anywhere
50002/tcp                  ALLOW       Anywhere
```

If the status shows `active` and the expected rules are listed, UFW is properly enabled and configured.

## Configuration Completed

The UFW configuration is now complete. Your server is protected with a robust firewall setup, ensuring only necessary services are accessible while blocking all other traffic by default. Regularly review and update your rules to maintain optimal security.<br>
Take a look at the useFull commands

### Useful UFW Commands

Here is a list of commonly used UFW commands to manage and troubleshoot your firewall configuration:

#### **1. Check UFW Status**
Displays the current status of UFW, including active rules and policies.

```bash
ufw status
```

For a more detailed output, use:

```bash
ufw status verbose
```

#### **2. Enable/Disable UFW**
To enable the firewall:

```bash
ufw enable
```

To disable the firewall:

```bash
ufw disable
```

#### **3. Allow/Deny Specific Ports**
To allow traffic on a specific port (e.g., port 80 for HTTP):

```bash
ufw allow 80/tcp
```

To deny traffic on a specific port:

```bash
ufw deny 80/tcp
```

#### **4. Delete a Rule**
To remove a specific rule (e.g., allowing port 80):

```bash
ufw delete allow 80/tcp
```

#### **5. Reset UFW**
Resets all UFW rules to their default state. Use with caution as it will remove all custom rules:

```bash
ufw reset
```

#### **6. Enable Logging**
To enable logging of firewall activity:

```bash
ufw logging on
```

To disable logging:

```bash
ufw logging off
```

#### **7. Reload UFW**
Reloads UFW to apply changes without disabling it:

```bash
ufw reload
```


These commands provide a quick and efficient way to manage your UFW configuration.