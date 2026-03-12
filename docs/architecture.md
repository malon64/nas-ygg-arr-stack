# Architecture

```
                 Internet
                    |
                [Router]
                    |
          forward TCP 32400 to Raspberry Pi
                    |
        -----------------------------------------
        |                                       |
        |         NAS (Synology)                |
        |                                       |
        |   Gluetun ---> qBittorrent            |
        |      |            |                   |
        |      |            +--> /volume1/arr-data/torrents
        |      |
        |      +--> VPN tunnel
        |                                       |
        |   /volume1/arr-data                   |
        |     |- torrents/incomplete            |
        |     |- torrents/completed             |
        |     |- media/movies                   |
        |     `- media/shows                    |
        |                                       |
        |   NFS export: /volume1/arr-data ------+------------------+
        -----------------------------------------                  |
                                                                   |
                                                                   v
                                                --------------------------------
                                                | Raspberry Pi                 |
                                                |                              |
                                                | /arr-data (NFS mount)        |
                                                |                              |
                                                | Prowlarr  Radarr  Sonarr     |
                                                | Watchlistarr                 |
                                                | Plex (host network)          |
                                                |                              |
                                                | Plex reads /data/... mapped  |
                                                | from /arr-data/media/...     |
                                                --------------------------------
```

- qBittorrent remains behind the VPN on the NAS.
- `/volume1/arr-data` remains the single source of truth and is exported to the Pi over NFS.
- Radarr, Sonarr, Watchlistarr, and Plex consume the same storage from the Pi at `/arr-data`.
- Plex runs on the Pi in host mode, so router port forwarding for TCP `32400` must target the Pi.
