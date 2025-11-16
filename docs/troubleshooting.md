# Troubleshooting

- YgéGé exits code 139: usually wrong arch (old Atom/UPX) or missing config. Ensure `/app/config.json` is a file with valid creds; request non-UPX builds for Atom.
- YgéGé "Is a directory (os error 21)": host path `${DOCKERCONFDIR}/ygege/config.json` is a folder. Replace with a real file and remount.
- Prowlarr cannot reach ygege: use URL `http://ygege:8715/`; if DNS fails, add `extra_hosts` with ygege IP or recreate the compose network.
- Sonarr/Radarr "directory does not exist": make sure they mount `/arr-data` and/or `/downloads` consistently; keep download and media paths inside `/arr-data` and enable hardlinks.
- Gluetun healthcheck fails on Synology: ICMP is blocked; rely on logs, or add a longer start period. Ensure VPN creds/configs are valid.
- Plex remote access: forward TCP 32400 on the router and allow it in DSM firewall; Plex runs in host mode.
