#!/bin/bash

NETWORK="mynet"
SUBNET="192.168.201.0/24"

# Check if the network already exists
if docker network ls --filter name=^${NETWORK}$ --format "{{.Name}}" | grep -w ${NETWORK} > /dev/null; then
  echo "Docker network '${NETWORK}' already exists."
else
  echo "Creating docker network '${NETWORK}' with subnet '${SUBNET}'..."
  docker network create --subnet=${SUBNET} ${NETWORK}
  if [ $? -eq 0 ]; then
    echo "Docker network '${NETWORK}' created successfully."
  else
    echo "Failed to create docker network '${NETWORK}'."
    exit 1
  fi
fi