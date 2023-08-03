#!/bin/bash

# Stop the Redis server

sudo systemctl stop redis

# Wait for the server to stop

sleep 5

# Start the Redis server

sudo systemctl start redis

# Wait for the server to start

sleep 5

# Monitor the replication status

redis-cli info replication