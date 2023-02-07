# Mediacenter (Plex, Nextcloud, Transmission, VPN)

# Features

* Automatic setup of Plex, Nextcloud, and Transmission that uses a common data folder.
* Torrent traffic is going through VPN.
* Update dynamic DNS entries to google domains using DDclient.
* Downloaded torrents will be available to Nextcloud using a cronjob that runs every 5 mins.
* Required database credentials are generated automatically.
* Tight security using a reverse proxy, specific user/folder permissions, and randomly generated credentials.

## Default Ports

| Service | Port |
|----|----|
| Plex | 32400 |
| Nextcloud | 8181 |
| Transmission | 9091 |
| Nginx | 81 |

# Containers Used

[Plex](https://www.plex.tv/) - Streaming media service and a client–server media player platform

[Nextcloud](https://nextcloud.com/) - Onprem cloud storage

[Transmission](https://transmissionbt.com/) - Bittorrent Client

[OpenVPN](https://openvpn.net/) - Virtual private network (VPN) used with Transmission for torrenting

[Nginx](https://www.nginx.com/) - Web server that can also be used as a reverse proxy, load balancer, mail proxy and HTTP cache

[DDclient](https://ddclient.net/) - Perl client used to update dynamic DNS entries for accounts on Dynamic DNS Network Service Provider

# Requirements

* Docker 
* At least 4 GB Ram (I will be using Raspberry Pi 4 Model B 8GB)
* At least 2 CPU cores (1.5 GHz)
* VPN Account (I will be using NordVPN for the setup)
* A domain name (not required but useful)
* Storage (HDD, SSD, …)

# Pre-Setup


1. Clone the repository

   `git clone https://github.com/mycodeinpeace/mediacenter.git`
2. Create a folder to store the configurations

   ex: `/home/pi/mediaserver-configs`
3. Create a folder to store the data

   ex: `/mnt/mediaserver-data`
4. Navigate into the cloned `mediacenter` repository

   `cd mediacenter`
5. Make `setup.sh` executable

   `chmod +x setup.sh`

# Configuration

Change `temp.env` file for the configurations.

## Global configurations

### TZ

If you're not sure what timezone you should fill in, you can look at the following list: <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones> Use the column that says "TZ database name".

## Plex configurations

### PLEX_HOSTNAME

Sets the hostname inside the docker container

### PLEX_ADVERTISE_IP

This variable defines the additional IPs on which the server may be found. This adds to the list where the server advertises that it can be found.

### PLEX_CLAIM

The PleX claim token is used to connect your server to your account. It can be obtained at <https://www.plex.tv/claim/> and is **valid for 4 minutes** after generating the token.

## OpenVPN configurations

I will use NordVPN configurations in this example however, it can be applied to other VPNs as well. Please see <http://haugene.github.io/docker-transmission-openvpn/config-options/> for configuration details.

### OPENVPN_PROVIDER

Sets the OpenVPN provider to use.

Supported providers can be found here; <http://haugene.github.io/docker-transmission-openvpn/supported-providers/>

### OPENVPN_CONFIG (Not required)

<http://haugene.github.io/docker-transmission-openvpn/run-container/#2_it_is_not_mandatory_but_setting_openvpn_config_is_good>

### NORDVPN_COUNTRY

Two-character country code. See [here](https://api.nordvpn.com/v1/servers/countries) for the full list.

### NORDVPN_CATEGORY

Server type (P2P, Standard, etc). See [here](https://api.nordvpn.com/v1/servers/groups) for the full list. Use either title or identifier from the list.

### NORDVPN_PROTOCOL

Either `tcp` or `udp`. (values identifier more available at <https://api.nordvpn.com/v1/technologies>)

### OPENVPN_USERNAME

NordVPN service username.

You can find your NordVPN service credentials (username and password) through the Nord Account __[dashboard](https://my.nordaccount.com/dashboard/nordvpn/)__.

 ![](/api/attachments.redirect?id=9276e56a-34c9-4bf6-a303-846d56e54629)

### OPENVPN_PASSWORD

NordVPN service password.

You can find your NordVPN service credentials (username and password) through the Nord Account __[dashboard](https://my.nordaccount.com/dashboard/nordvpn/)__.

## Transmission configurations

### LOCAL_NETWORK

This is needed to access the WebUI. This is because the VPN is active, and since docker is running in a different ip range than your client the response to your request will be treated as "non-local" traffic and therefore be routed out through the VPN interface.

LOCAL_NETWORK property must be aimed at a subnet and not at an IP Address. For instance if your local network uses the IP range 192.168.0.0/24 you would pass 

```javascript
LOCAL_NETWORK=192.168.0.0/24
```

### TRANSMISSION_RPC_USERNAME

Username to access the WebUI. Be cautious of special characters in the username or password.

### TRANSMISSION_RPC_PASSWORD

Password to access the WebUI. Be cautious of special characters in the username or password. Escaping special characters could be an option, but the easiest solution is just to avoid them. Make the password longer instead.

### TRANSMISSION_WEB_UI

This container comes bundled with some alternative Web UIs:

* [Combustion UI](https://github.com/Secretmapper/combustion)
* [Kettu](https://github.com/endor/kettu)
* [Transmission-Web-Control](https://github.com/ronggang/transmission-web-control/)
* [Flood for Transmission](https://github.com/johman10/flood-for-transmission)
* [Shift](https://github.com/killemov/Shift)

To use one of them instead of the default Transmission UI you can set `TRANSMISSION_WEB_UI` to either `combustion`, `kettu`, `transmission-web-control`, `flood-for-transmission`, or `shift`.

## Nextcloud configurations

### NEXTCLOUD_ADMIN_USER

Your admin username to access nextcloud webgui. This user will also be used to access the Plex libraries directly from the nextcloud.

### NEXTCLOUD_ADMIN_PASSWORD

Your admin password to access nextcloud webgui. 

### NEXTCLOUD_TRUSTED_DOMAINS

One or more trusted domains can be set through environment variable

## Example Configuration File

```bash
# If you're not sure what timezone you should fill in, you can look at the following list:
# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
# Use the column that says "TZ database name".
TZ=Europe/Amsterdam
# The PleX claim token is used to connect your server to your account. It can be obtained at
# https://www.plex.tv/claim/ and is valid for 4 minutes after generating the token.
PLEX_CLAIM=
PLEX_HOSTNAME=media.example.com
PLEX_ADVERTISE_IP=http://192.168.178.31:32400/
# Nord VPN for Transmission
OPENVPN_PROVIDER=NORDVPN
OPENVPN_CONFIG=NL
NORDVPN_COUNTRY=NL
NORDVPN_PROTOCOL=udp
OPENVPN_USERNAME=***
OPENVPN_PASSWORD=***
# http://haugene.github.io/docker-transmission-openvpn/vpn-networking/
# The container supports the LOCAL_NETWORK environment variable.
# For instance if your local network uses the IP range 192.168.0.0/24 you would pass -e LOCAL_NETWORK=192.168.0.0/24
LOCAL_NETWORK=192.168.0.0/16
# Transmission
TRANSMISSION_RPC_USERNAME=mytorrentuser
TRANSMISSION_RPC_PASSWORD=m9MHTbqHzQLxKP5a
# Use the specified bundled web UI
# Values; combustion, kettu, transmission-web-control, flood-for-transmission or shift
# http://haugene.github.io/docker-transmission-openvpn/config-options/#alternative_web_uis
TRANSMISSION_WEB_UI=flood-for-transmission
# Nextcloud
NEXTCLOUD_ADMIN_USER=myclouduser
NEXTCLOUD_ADMIN_PASSWORD=nTe4w3m7CN2U4GBk
NEXTCLOUD_TRUSTED_DOMAINS=cloud.example.com
# Autogenerated variables
# Values for this will be generated by setup.sh
```

## DDclient Configuration

Change the `ddclient.conf` configuration file for your domains.

I will be using domains from Google Domains for this configuration.

```bash
protocol=dyndns2
use=web
server=domains.google.com
ssl=yes
# First domain
login='<username from google domains console>'
password='<passwrod from google domains console>'
cloud.example.com
# Second domain
protocol=dyndns2
server=domains.google.com
login='<username from google domains console>'
password='<passwrod from google domains console>'
media.example.com
```

For additional configurations please look at the official documentation; <https://ddclient.net/usage#configuring-ddclient>

To enable Dynamic DNS in Google Domains;

### **Set up dynamic DNS**


1. On your computer, sign in to [Google Domains](https://domains.google.com/registrar).
2. Select your domain.
3. Click Menu → then **DNS**.
4. Select **Default name servers Google Domains (Active)**.

* If “Custom name servers (Active)” is selected, you already have custom name servers and can't use Google Domains’ Dynamic DNS service.


4. Click **Show advanced settings**.
5. Click **Manage dynamic DNS → Create new record**.
6. To assign a Dynamic IP, enter the name of the subdomain or root domain.
7. Click **Save**.

The following are some other options to manage your Dynamic DNS:

* **To view the record values:** Next to the record, click the triangle.
* **To view the username and password created for a record:** Click **View Credentials**.

 ![](/api/attachments.redirect?id=adbfdc5f-0124-4127-b47f-25f30f0094be)

* **To configure your gateway or client software so that it contacts the Google name servers:** Use the username and password created for the record.
* **To delete a record:**

  
  1. Go to “Resource records.”
  2. Next to “Dynamic DNS,” click the triangle.
  3. Select **Delete**.

# Setup

Run `setup.sh`

```bash
./setup.sh <configuration folder> <data folder>
```

Example: `./setup.sh /home/pi/mediaserver-configs /mnt/mediaserver-data`

This will automatically;

* remove the previous containers (if any)
* set up the required users and folders
* set up the permissions
* create database credentials
* run docker-compose to bring up the containers
* setup cron job

# Post-Setup

## Configure Nginx

Go to `<IP_Address>:81`

The default login credentials are:

Username: **admin@example.com**

Password: **changeme**

Change the default username and password after logging in for the first time.

### Create Proxies for Plex and Nextcloud

Open the Nginx Proxy Manager

[http://<IP_Address>:81/](http://192.168.178.213:81/)

Once at the NPM dashboard click on “**Proxy Hosts**” Then **Add Proxy Host**


 ![](/api/attachments.redirect?id=801b6055-b10e-44fe-877c-b42183cf10ca)

#### For Nextcloud

 ![](/api/attachments.redirect?id=989548d0-6906-4565-8cab-fb4b2e52302a)

Now press the “**SSL**” top menu.

Under “**SSL Certificate**” where it says “**None**” click then click on “**Request a new SSL Certificate**“

 ![](/api/attachments.redirect?id=20ca44de-cd5b-4d10-ab7f-e5ce7a570915)

Once it completes successfully it will return to the Dashboard. You should now see your domain listed.

**Please Note: There is a little bug here which we have to fix before proceeding.**

You will need to go back into the edit settings by clicking the “**hamburger menu**” at the end of your domain section and click on “**Edit**“.

 ![](/api/attachments.redirect?id=8f4106cf-6b0f-435e-ba03-4c877602ff8f)

Then click on the “**SSL**” top menu.

Please ensure that both “**Force SS**L” and “**HTTP/2 Support**” are checked. If they have defaulted back then re-select them and click on “**Save**” again.

 ![](/api/attachments.redirect?id=304928b0-cd08-4152-9dd5-5e811fea8e94)

#### For Plex

Use similar steps from the Nextcloud configuration for Plex as well changing the domain name and IP address/port

# Accessing the servers

Below are the default ports for the services if you need to access them from your local network. Otherwise, you can use the domain names that you configured in Nginx Proxy Manager.

Access by going to `<ip_address>:<port>` in your browser.

| Service | Port |
|----|----|
| Plex | 32400 |
| Nextcloud | 8181 |
| Transmission | 9091 |
| Nginx | 81 |
