# Technical documentation

# WARNING:

All command, and all configuration are made as the root user.

## Table of Contents
- [Technical documentation](#technical-documentation)
  - [Configuration](#configuration)
  - [The VPN](#the-vpn)
    - [Dependencies](#dependencies)
    - [Technologies: Wireguard](#technologies-wireguard)
    - [Installation](#installation)
      - [Dependencies](#dependencies-1)
      - [Step 1: Private and public key](#step-1-private-and-public-key)
      - [Step 2: The configuration file](#step-2-the-configuration-file)
      - [Step 3: Start the VPN](#step-3-start-the-vpn)
      - [Step 4: Add client](#step-4-add-client)


# Configuration:

Before starting the project, i made a proxmox server at my home. I will create 3 LXC container on it, running on debian 11.
This 3 container will be connected to a new VPN on my VPS located at Velouzy-Villacoulbay in France.

## The VPN.

## Dependencies:

In this doc, we will use UFW (uncomplicated firewall), a front-end of ipTables. Please make sure you have it installed or install it.

```
apt install ufw -y
```

### Technologies: Wireguard

For the VPN we will use wireguard as it is ligher than OpenVPN, easier to configure, faster than openVpn, more secure (using modern cryptography and state-of-the-art protocols). Including is performance, wireguard have a lower cpu usage.
But wireguard does not support login/password auth, it's could be a negative point. But this VPN will only be used to access the intra-net, everybody should get his one configuration.

### Installation:

#### Dependencies:

To run a wireguard service, we need to install the wireguard packet. And before, we will update all of our packages using the following command:

```sh
apt update;
apt upgrade -y;
```

Now we can install wireguard using the command:

```sh
apt install wireguard -y
```
We will also install `qrencode` as it is required to create qrCode from configuration file
```
apt install qrencode -y
```
#### Step 1: Private and public key.

**Do NOT share the server private key. I can cause several security issues.**

##### Private key:

Now that wireguard is installed, we need to configure it.
In first, we will setup the server interface.<br>
For it, we need to generate a new private key using the command `wg genkey` and save it, as exemple, we will use `server_privateKey` file to save it, but you can use the one you want. <br>
The complete command to generate a private key and save it is the following one:

```sh
wg genkey > server_privateKey
```

You can check if the key is well generated using the command:

```sh
cat server_privateKey
```

A key should be printed in the terminal.

##### Public key:

The server also need to share with client a public key, as wireguard use an asynchrone cryptography.
So, to get the public key, we will derive the private key with the same command `wg genkey`. We will save the public key for later in `server_publicKey` file, but you can use the file you want.
The complete command is:

```sh
wg genkey < server_privateKey > server_publicKey
```

This line will give the private key to the `wg genkey` command and save the result in `server_publicKey` file.<br>
You can check if the key is well derived using the command:

```sh
cat server_publicKey
```

A key should be printed

#### Step 2: The configuration file

Now that we have all the key, we can procced by creating the wireguard configuration file. <br>
Wireguard file are located in `/etc/wireguard`, and the file name will correspond to the interface name. <br>
As default, we save the configuration under the `/etc/wireguard/wg0.conf` file.
There is a wireguard server configuration file without any client exemple using ufw:

```
[Interface]
PrivateKey = <server_privateKey>
Address = 10.0.0.1/24
ListenPort = 51820
PostUp=ufw allow 51820/udp
PostUp=ufw route allow in on eth0 out on wg0
PostUp=ufw route allow in on wg0 out on eth0
PostDown=ufw deny 51820/udp
PostDown=ufw route deny in on eth0 out on wg0
PostDown=ufw route deny in on wg0 out on eth0
```

In this file, please make sure you replace:

-   **<server_privateKey>** by the private key you generated before (you can see it using cat) (**required**)
-   **Address**: You can replace the ip address and the submask to use the network you want. (_optional_)
-   **eth0**: Replace it by the name of your main network interface (_optional_)
-   **wg0**: The name of your file (without the .conf) corresponding to the VPN interface name(_optional_)

This configuration use UFW to allow traffic to the listening port on the firewall at VPN startup and deny it when it stop. It also forward traffic automatically.<br>
The VPN is defined on the 10.0.0.0/24 network,
so the first IP is 10.0.0.1 used by the VPN interface as gateway
and the last one is 10.0.0.254.

#### Step 3: Start the VPN

Now the VPN is well configure, we need to start it. The wireguard command to performe the start up is: 
```
wg-quick up <interface_name>
```
so for us, is 
```
wg-quick up wg0
```
But this command will not start it again when server reboot. To make the vpn automatically start, we need to add it to system service with the following command:
```
systemctl enable --now wg-quick@<interface_name>
```
so for us is:
```
systemctl enable --now wg-quick@wg0
```
This command will enable the wg0 wireguard interface on system start-up and allow to use command such as:
```
systemctl <status|reboot|stop|start>
```
on the interface.

#### Step 4: Add client
Now the VPN is configured and start, we can add new client.
To add client, you can:
- Generate a new key pair on the server and give the configuration to the client
- Generate a new private key on the client and send the public key to the server.

To make it easier, we will do everything on the server side.
So there is the step: <br>
- Create a new private Key and derive the public key from.
- Give an ip for this new client.
- Generate a client configuration file
- Add peer to the current running VPN
- Save the peer in the server configuration file.

To make all this step, i write a simple shell [Script](./wg-add-.sh).
This shell generate key, find the first client IP available, set client DNS, generate the client configuration, add the client to the current running wireguard interface, and save the new client in the wireguard server interface configuration file.
 
At the end of this script, you will get a qrCode that can be scan using wireguard mobile app to load the configuration automatically, or you can find the clients configuration files in the `/etc/wireguard/clients` folder.

