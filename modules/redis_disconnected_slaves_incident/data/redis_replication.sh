#!/bin/bash

# Set the Redis master hostname and port

REDIS_MASTER=${MASTER_HOSTNAME}:${MASTER_PORT}

# Set the list of Redis slave instances to replicate to

REDIS_SLAVES="PLACEHOLDER"

# Loop through the list of Redis slaves and replicate data from the master

for redis_slave in "${REDIS_SLAVES[@]}"

do

  # Extract the hostname and port from the Redis slave string

  IFS=':' read -ra redis_slave_parts <<< "$redis_slave"

  redis_slave_hostname="${redis_slave_parts[0]}"

  redis_slave_port="${redis_slave_parts[1]}"

  # Replicate data from the Redis master to the slave

  redis-cli -h $redis_slave_hostname -p $redis_slave_port SLAVEOF $REDIS_MASTER

done

echo "Data replication from Redis master to all disconnected slaves completed."