# ripe-atlas-software-probe-docker


Usage:
```bash

docker run -d --restart=unless-stopped \
	--cap-drop=ALL --cap-add=CHOWN --cap-add=DAC_OVERRIDE \
    --cap-add=NET_RAW --cap-add=SETGID --cap-add=SETUID \
	--log-driver json-file --log-opt max-size=1m \
	--cpus=1 --memory=64m --memory-reservation=64m \
	-v /etc/ripe-atlas/:/app/etc/ripe-atlas/ \
	-v /var/run/ripe-atlas/status/:/app/var/run/ripe-atlas/status/ \
    --network=host \
	--name ripe-atlas --hostname "$(hostname --fqdn)" \
	ghcr.io/iakat/ripe-atlas-software-probe-docker:latest

```

&&

```bash
cat /etc/ripe-atlas/probe_key.pub
```

&&

Login to https://atlas.ripe.net/ and [add the probe](https://atlas.ripe.net/apply/swprobe/) with the key above.
