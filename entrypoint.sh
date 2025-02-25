#!/usr/bin/env sh
set -eu -o pipefail
# If /etc/ripe-atlas/config.txt does not exist, let's set RXTXRPT=yes.

if [ ! -f /app/etc/ripe-atlas/config.txt ]; then
    echo "RXTXRPT=yes" > /app/etc/ripe-atlas/config.txt
fi

# If /app/etc/ripe-atlas/mode does not exist, let's set it to "prod".

if [ ! -f /app/etc/ripe-atlas/mode ]; then
    echo "prod" > /app/etc/ripe-atlas/mode
fi

# Ensure /app/var/atlasdata is a tmpfs, if not, sleep for 60 seconds to let the user notice.
# This is because we want to keep ephemeral data ephemeral.

if ! mount | grep -q /app/var/atlasdata; then
    echo "Warning: /app/var/atlasdata is not a tmpfs. Please mount it as a tmpfs."
    echo "Add to your docker run: --mount type=tmpfs,destination=/app/var/atlasdata,size=64m"
    echo "For more information, see https://docs.docker.com/engine/storage/tmpfs/"
    echo "Sleeping for 60 seconds to let you notice."
    for i in $(seq 1); do
        sleep 1
        echo -n "."
    done
fi

# Detect whether we are running inside a --network=host container by checking
# whether the mac address of the main interface starts with "02:42".

MAIN_IFACE=$(ip route | grep default | awk '{print $5}')
MAC_ADDR=$(cat /sys/class/net/$MAIN_IFACE/address)
MAC_ADDR_FIRST_TWO=$(echo $MAC_ADDR | cut -d: -f1-2)
MAC_ADDR_CUT_LOWER=$(echo $MAC_ADDR_FIRST_TWO | tr '[:upper:]' '[:lower:]')
# check if the mac address starts with "02:42"
if [ "$MAC_ADDR_CUT_LOWER" = "02:42" ]; then
    # We are not --network=host. Bail.
    echo "Error: This container must be run with --network=host."
    # If I_PINKY_PROMISE_I_AM_NOT_USING_NETWORK_HOST is set, we can bypass the check.
    if [ -z "${I_PINKY_PROMISE_I_AM_NOT_USING_NETWORK_HOST:-}" ]; then
        exit 1
    fi
fi

# Let's go measuring! <|:-)

exec /app/sbin/ripe-atlas "$@"
