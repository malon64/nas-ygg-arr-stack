# Architecture (text diagram)

```
                 Internet
                    |
                [Router]
                    |
             (port forward 32400 for Plex)
                    |
        ---------------------------
        |        NAS (Synology)   |
        |                         |
        |  [Gluetun+qBittorrent]  |  (VPN namespace)
        |         |               |
        |         | localhost:8080|
        |         v               |
        |    qbittorrent client   |
        |                         |
        |  [media-net bridge]     |
        |   |  |  |  |  |  |      |
        |   |  |  |  |  |  |      |
        |  Jackett Flaresolverr   |
        |  Prowlarr Radarr Sonarr |
        |  Watchlistarr Recommendarr |
        |  YgéGé                   |
        |                         |
        |  Plex (host network)    |  -> DLNA/clients on LAN
        ---------------------------
```

- qBittorrent shares Gluetun network namespace; traffic goes through VPN.
- Jackett/Flaresolverr/Prowlarr/Radarr/Sonarr/Watchlistarr/Recommendarr/YgéGé sit on `media-net` and talk to each other via container hostnames.
- Plex uses host networking for discovery/remote access (forward TCP 32400 if needed).
