# Infrastructure Project Documentation

## Overview

This document explains the setup and configuration of the infrastructure, which consists of three virtual machines (VMs).

## Table of Contents

1. [Overview](#overview)
    - [Infrastructure Overview](#infrastructure-overview)
    - [Hosts Overview](#hosts-overview)
    - [Domain Name](#domain-name)
2. [VPN Configuration](#vpn-configuration)
3. [Monitoring](#monitoring)
4. [Pterodactyl Setup](#pterodactyl-setup)
5. [Web](#web)
6. [Security Measures](#security-measures)
7. [Best Practices](#best-practices)

---

### Infrastructure Overview
![Infrastructure Diagram Overview](./Projet-INFRA.drawio.png)

### Hosts Overview

1. **VPS (Real VPS)**

    - **IP/CIDR**: `10.0.0.1/24`
    - **Purpose**: Serves as the central hub for the VPN, linking VMs together and exposing specific ports to the internet.
    - **Services**:
        - **WireGuard VPN**: Documentation available [here](./VPN/docs.md).
        - **Reverse Proxy**: Documentation available [here](./Web/Wordpress.md#2-reverse-proxy).
    - **Host**: This VPS is provided by [RedHeberg.Fr](https://redheberg.Fr).
    - **Ressources**:
      |**CPU** | **RAM** | **Disk** | **Network** |
      |---------|---------|----------|-------------------|
      | 4 vCPU | 6 GB | 60 GB | 10 Gbps (shared) |

2. **VM 1 (Local)**

    - **IP/CIDR**: `10.0.0.2/24`
    - **Purpose**: Acts as an intranet VM connected to the VPN, hosting internal services and applications that are not exposed to the internet.
    - **Services**:
        - **Monitoring**: Refer to the documentation [here](./Monitoring/monitoring.md).
        - **Pterodactyl Panel**: Installed on this VM. Documentation is available [here](./Web/Pterodactyl.md#1-pterodactyl-installation).
        - **Pterodactyl Wings**: Used for managing Docker containers. Documentation can be found [here](./Web/Pterodactyl.md#2-wings-installation).
    - **Host**: This VM is hosted on my Proxmox server at home.
    - **Ressources**:
      |**CPU** | **RAM** | **Disk** | **Network** |
      |---------|---------|----------|-------------------|
      | 2 vCPU | 4 GB | 30 GB | 500 Mbps (shared) |

3. **VM 2 (Local)**
    - **IP/CIDR**: `10.0.0.3`.
    - **Purpose**: Connected to the VPN for remote access. This VM is used for all applications that should be exposed on the internet, with a reverse proxy running on the VPS.
    - **Services**:
        - **Node Exporter (metrics)**: Documentation available [here](./Monitoring/monitoring.md#3-node-exporter-installation).
        - **Pterodactyl Wings**: Installed to manage docker containers. Found the documentation [here](./Web/Pterodactyl.md#2-wings-installation).
        - **WordPress**: Deployed using Pterodactyl. Documentation for WordPress setup is [here](./Web/Wordpress.md)
    - **Host**: This VM is hosted on my Proxmox server at my house
    - **Ressources**:
      |**CPU** | **RAM** | **Disk** | **Network** |
      |---------|---------|----------|-------------------|
      | 2 vCPU | 4 GB | 30 GB | 500 Mbps (shared) |

### Domain Name

For this project, we own the `infra.doomoon.fr` subdomain. We have full administrative access, allowing us to create and manage unlimited subdomains under it. This flexibility enables us to allocate specific subdomains for different services or applications as needed, ensuring a clean and organized structure for external access.

---

## VPN Configuration

The WireGuard VPN is configured on the VPS to allow secure communication between all VMs. The two local VMs connect to the VPN, enabling access from anywhere as long as the VPN is active. Refer to the [VPN documentation](./VPN/docs.md) for detailed setup instructions.  
You can also find the rationale behind the choice of technologies in the documentation, available [here](./VPN/technicalDocumentation.md#technologies-wireguard).

---

## Monitoring

Monitoring tools are deployed across the infrastructure to ensure optimal performance and health tracking. The intranet VM hosts run monitoring services such as `Grafana` and `Prometheus`, providing centralized oversight of the system. Additionally, Node Exporter is installed on all VPN-connected hosts, enabling detailed metrics collection and monitoring for the entire infrastructure. This setup ensures proactive issue detection and streamlined performance analysis. Refer to the [Monitoring documentation](./Monitoring/monitoring.md) for detailed setup and more information.

---

## Pterodactyl Setup

In this project, we opted to use Pterodactyl for managing our Docker containers. Although Pterodactyl was originally designed for game server management, its open-source nature allows it to run virtually any application that can operate within a Docker container. This flexibility makes it a powerful tool for managing diverse workloads beyond its initial purpose.
Because Pterodactyl allow to manage docker container on many differents host (node) at time, we call it the 'management panel', so it's should not be exposed on internet. This panel is so installed in intra-net.

-   **Panel**: Installed on the VPS with the IP address `10.0.0.2` (intra-net).
-   **Wings**:
    -   Installed on the VM 2 (`10.0.0.2`) to manage internal docker container.
    -   Installed on VM 2 (`10.0.0.3`) to extend server management capabilities and to split internal from external web app.
-   **Nodes**: Here is the node list that can be found on our pterodactyl panel
    | **Node Name** | **Node URL** |
    |---------------|--------------|
    | node-intra | `http://10.0.0.2` |
    | node-extra | `http://10.0.0.3` |

Refer to [Pterodactyl and Wings documentation](./Web/Pterodactyl.md) for more details about setup and [usage](./Web/Pterodactyl.md#3-pterodactyl-usage)

## Web

For this project, we have deployed a WordPress website accessible at `blog.infra.doomoon.fr`. This website is hosted on the external node (`node-extra`) managed through [Pterodactyl](#pterodactyl-setup). By leveraging Pterodactyl's container management capabilities, we ensure a streamlined and efficient deployment process.

The WordPress instance is configured to run securely and efficiently, with the reverse proxy on the VPS handling external traffic. This setup ensures that the website remains accessible while maintaining a secure and organized infrastructure.

For detailed instructions on the WordPress setup and configuration, refer to the [WordPress documentation](./Web/Wordpress.md).

---

## Security Measures

This security measures was apply on all host

-   **VPN**: The WireGuard VPN is implemented to establish a secure and encrypted communication channel between all VMs. It creates a virtual private network, enabling remote access to the infrastructure from anywhere while ensuring data confidentiality and integrity. Find documentation [here](./VPN/docs.md)
-   **Firewall Rules**: Configured to restrict access to essential services only.
-   **Regular Updates**: All software and operating systems are kept up-to-date using automated cron jobs to ensure security and stability.
-   **Monitoring**: Continuous monitoring is implemented using Grafana and Prometheus to track system performance and detect issues proactively. Find documentation [here](./Monitoring/monitoring.md)
-   **SSH**: Here is all we have do to securise SSH connection
    -   **Disable Root Login**: Ensure that the root user cannot log in directly via SSH.
    -   **Change Default SSH Port**: Use a non-standard port for SSH to reduce the risk of automated attacks (1501).
    -   **Limit SSH Connections**: Configure `sshd` to limit the number of simultaneous connections and prevent brute-force attacks.
    -   **Use Fail2Ban**: Install and configure Fail2Ban to block IP addresses after a certain number of failed login attempts.

Refer to the [Security documentation](./Security/Security.md) for detailed security practices and configurations.

---

## Best Practices

-   **Documentation**: Ensure all configurations, setups, and processes are thoroughly documented for easy reference and onboarding of new team members.
-   **Network Segmentation**: Separate internal and external services using a VPN and reverse proxy to enhance security and reduce attack surfaces.
-   **Access Control**: Implement strict access controls, such as using VPN for internal services and limiting public exposure to only necessary services through the reverse proxy.
-   **Monitoring**: Deploy monitoring tools like Prometheus and Grafana to track system health and set up alerts for anomalies or failures.
-   **Firewall Rules**: Configure firewalls to allow only necessary traffic, blocking unauthorized access to internal and external servers.
-   **Regular Updates**: Keep all software, operating systems, and dependencies up-to-date to mitigate vulnerabilities.
-   **Secure Communication**: Use encrypted protocols (e.g., HTTPS, SSH, VPN) for all communications to protect data in transit.
-   **Reverse Proxy Configuration**: Properly configure the reverse proxy to handle SSL termination, caching, and routing efficiently.
-   **Scalability**: Design the infrastructure to allow easy addition of new services, VMs, or nodes as the project grows (with Pterodactyl).
-   **User Authentication**: Use strong authentication mechanisms, such as SSH keys and two-factor authentication, for accessing servers and panel.

---

# Outside of documentation:

Voici les différents problème que l'on a rencontré lors de la mise en place de l'infrastructure:

## Problème: **Wordpress ne s'installé pas**

### Description:

L'oeuf pour installer des applications web dans des containers docket via pterodactyl utilises la commande wget pour installer l'archive de wordpress, or, le serveur renvoie une erreur avec un status code 434 signifiant que la version de TLS utilisés est invalide.
De plus le serveur n'étaient pas installés correctement car PHP ne pouvait pas s'éxécuter en raison de l'inexistance du dossier dans le quel le socket est censé être créé.

### Solution:

Modifié le script d'installation pour utilisé curl au lieu de wget.
Tout d'abord, il faut installer curl, car l'image utilisé pour l'installation, l'image alpine est une image linux très légére avec le minimum de packet installé, nous devons donc d'abord installé curl avec la commande suivante

```
apk --update add curl
```

Cette commande permet d'installer curl tout en mettant à jour la listes des packets.
Nous pouvons désormais remplacer la condition et le bloc de code permettant d'installer wordpress par le code suivant:

```
if [ "${WORDPRESS}" == "true" ] || [ "${WORDPRESS}" == "1" ]; then
    echo -e "Installing wordpress"
    cd /mnt/server/webroot
    curl -LO http://wordpress.org/latest.tar.gz
    tar xzf latest.tar.gz
   mv wordpress/* .
   rm -rf wordpress latest.tar.gz
   echo -e "Install complete go to http://ip:port/wp-admin "
   exit 0
fi
```

Pour résoudre le deuxième problèmes de dossiers, nous devons ajoutés la lignes suivantes:

```
mkdir /mnt/server/tmp /mnt/server/logs
```

Cette commande permet de créé le dossier tmp et logs sur le serveur. Le dossier `logs` est nécéssaire pour nginx qui cause une erreur et arrête de fonctionner si on ne le mets pas.

## Problème: **Les packets n'étaient pas envoyé à cause du MTU.**

### Description:

L'interface réseau définit par les wings pour configurer le réseau sur docker étaient de 1500. Ce n'aurait pas poser de soucis en condition classique car le MTU de 1500 est par défaut sur la machine. Or, dans notre cas, c'est problèmatique car la machine est connecté à un VPN, qui lui utilise un MTU de 1420, bien sur, tout le traffic doit passer par le VPN, donc les packets de 1500 Bytes étaient bloqué au niveau de l'envoie par le VPN.
Le VPN a un MTU (1420) plus bas afin de garantir la sécurité, ceci lui permet de rajouter des données à chaque packets pour les sécurisés (encapsulation).

### Solution:

Nous avons du réduire le MTU de l'interface réseau de docker en rajoutant dans le fichier `/etc/docker/daemon.json` le contenu suivant:

```
{
  "mtu": 1392
}
```

Cela permet de garantir que docker n'enverra pas de packet qui ont une taille supérieur à 1392 Bytes à partir de ses réseaux virtuels.
Cependant cela ne suffit pas, étant donné que pterodactyl avec les wings crée un réseau virtuel dédié, nommé 'pterodactyl_nw'.
Nous avons donc du modifier le fichier de configuration des wings sur le serveur en définissant la valeur du MTU a `1392` dans le fichier
`/etc/pterodactyl/config.yml`. Voici une commande qui ferait le changement pour vous:

```
sed -i 's/network_mtu: 1500/network_mtu: 1392/' /etc/pterodactyl/config.yml
```

Il faut ensuite supprimer le réseau de docker avec la commande suivante:

```
docker network rm pterodactyl_nw
```

et pour terminer, il faut redémarrer les wings pour recréé le réseau avec les bonnes valeurs:

```
systemctl restart wings
```

Voici toutes les commandes à éxécutés regroupés:

```
echo '{"mtu": 1392}' > /etc/docker/daemon.json
sed -i 's/network_mtu: 1500/network_mtu: 1392/' /etc/pterodactyl/config.yml
docker network rm pterodactyl_nw
systemctl restart wings

```

### Infos:

Wireguard utilise un MTU inférieur de 80 à celui de l'interface réseau principale. Cela est du au fait qu'il encapsule les packets pour y rajouter une sur-charge (headers) contenant les en-têtes de protocoles et ses propres en-têtes, cela correspond donc environ à 60 octets. Les 20 octets supplémentaire sont utilisés dans le cas d'ipv6 incluant une sur-charge supplémentaire de 20 octets.
Le MTU de 1392 correspond à une en-tête supplémentaire car nous avons remarqué que la taille des packets que nous souhaitons envoyés, étaient toujours augmenté de 28. On a aperçu cela grâce au requêtes ping, lorsuq'on utilise la commande `ping` avec l'option `-s 1420`, pour signifier d'envoyer des packets de 1420 octets, on constate que les packets ne s'envoient pas à cause du MTU, et que la taille des packets envoyés est de 1448. On voit donc bien une différence de 28 octets. Et donc pour s'assurer que les packets pourront passer, nous avons limités le MTU à 1392 (1420-28)

```
root@VM-Extra:~# ping -M do -s 1400 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 1400(1428) bytes of data.
ping: local error: message too long, mtu=1420
```

## Problème: **La virtualisation imbriquée (nested virtualization) n'était pas activée**

### Description:

Lors de la mise en place de l'infrastructure, nous avons rencontré un problème où les machines virtuelles (VMs), qui utilisait une technologie `LXC` (pour `Linux Container`) ne pouvaient pas faire de la virtualisation. Cela était dû au fait que la virtualisation imbriquée (nested virtualization) n'était pas activée dans la configuration des VMs sur Proxmox.

La virtualisation imbriquée est essentielle pour permettre à une VM d'utiliser des technologies comme Docker, qui nécessite les accès à la virtualisation.

### Solution:

Pour résoudre ce problème, nous avons activé la virtualisation imbriquée sur Proxmox. Voici comment faire:

-   Assurez vous que votre processeur le supporte.
-   Assurez vous d'avoir un accès à l'hote des VM.
-   Activer la virtualisation imbriqués dans le fichier de configuration du conteneur LXC situé dans `/etc/pve/lxc/<CTID>.conf` et ajoutez la ligne suivante :
    ```
    features: nesting=1
    ```
-   Redémarrez le conteneur concerné pour appliquer les modifications ou bien avec l'interface graphique de Proxmox, ou bien avec la commande suivante:
    ```shell
    pct reboot <CTID>
    ```
