# Wireguard Technical and User documentation

## Table of Contents

1. [Documentation Overview](#documentation-overview)
2. [Proof](#proof)
    - [Configuration](#configuration)
    - [Connection](#connection)

## Documentation Overview

This project includes two types of documentation:

-   **[User Documentation](./userDocumentation.md)**: A guide for end-users on how to connect and use the VPN.

-   **[Technical Documentation](./technicalDocumentation.md)**: Detailed information about the setup, configuration, and inner workings of the Wireguard VPN.

# Proof

## Configuration

Here is the final server configuration file:

```
[Interface]
Address = 10.0.0.1/24
PostUp = ufw allow 51820/udp
PostUp = ufw route allow in on eth0 out on wg0
PostUp = ufw route allow in on wg0 out on eth0
PostDown = ufw deny 51820/udp
PostDown = ufw route deny in on eth0 out on wg0
PostDown = ufw route deny in on wg0 out on eth0
ListenPort = 51820
PrivateKey = <private key>


# VM-100-INTRA
[Peer]
PublicKey = <client public key>
AllowedIPs = 10.0.0.2/32

# VM-102-EXTRA
[Peer]
PublicKey = <client public key>
AllowedIPs = 10.0.0.3/32

# CLIENT-DANTES
[Peer]
PublicKey = <client public key>
AllowedIPs = 10.0.0.4/32

# CLIENT-WAYDE
[Peer]
PublicKey = <client public key>
AllowedIPs = 10.0.0.5/32

# CLIENT-DEVEX
[Peer]
PublicKey = <client public key>
AllowedIPs = 10.0.0.6/32
```

And here is an exemple of one of the client configuration:

```
[Interface]
PrivateKey = <private key>
Address = 10.0.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = <server public key>
Endpoint = <ip>:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

Note that the `PersistentKeepalive` option is not required and can be removed. <br>
Also note that a preshared key can be added to renforce security against quantum attack.

## Connection

Here is the proof of the connection working on all side (server/client) in a [video](./connectionProof.mp4).  
![](./connectionProof.mp4)
<video width="320" height="240" controls>
  <source src="./connectionProof.mp4" type="video/mp4">
</video>
