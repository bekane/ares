#!/bin/bash

# Check for required arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <host> <port> <protocol>"
    echo "Example: $0 192.168.1.100 4789 udp"
    exit 3
fi

HOST=$1
PORT=$2
PROTOCOL=$3

# Check if protocol is valid
if [[ "$PROTOCOL" != "udp" && "$PROTOCOL" != "tcp" ]]; then
    echo "Invalid protocol: $PROTOCOL (use 'udp' or 'tcp')"
    exit 3
fi

# Check the port using netcat
if nc -z -v -w2 -u "$HOST" "$PORT" &>/dev/null; then
    echo "OK: $PROTOCOL port $PORT on $HOST is open"
    exit 0
else
    echo "CRITICAL: $PROTOCOL port $PORT on $HOST is not open"
    exit 2
fi

