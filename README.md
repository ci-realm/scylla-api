scylla-api
==========

Scylla websocket protocol and client.

Usage
-----


```bash
# provide config
# copy and edit provided sample
cp scylla-api.conf ~/.scylla-api.conf

nix build
./result/bin/scylla-api lastBuilds

# use --help to list all available commands
```

Configuration
-------------

API tries to load config from `~/.scylla-api.conf` or according to `SCYLLA_API_CONF` if provided.
