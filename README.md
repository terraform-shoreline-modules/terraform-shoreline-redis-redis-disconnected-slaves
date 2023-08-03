
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Redis disconnected slaves incident
---

This incident type refers to an issue with Redis where one or more slave instances have become disconnected, resulting in replication failure. This can cause data inconsistencies and may require immediate attention to restore normal functioning. The incident may be caused by a variety of factors, such as network issues, server failures, or misconfiguration.

### Parameters
```shell
# Environment Variables

export REDIS_HOST="PLACEHOLDER"

export REDIS_PORT="PLACEHOLDER"

export REDIS_INSTANCE_NAME="PLACEHOLDER"

export MASTER_HOSTNAME="PLACEHOLDER"

export MASTER_PORT="PLACEHOLDER"


```

## Debug

### Check if Redis is running
```shell
systemctl status redis
```

### Check Redis logs for any errors
```shell
tail -n 100 /var/log/redis/redis.log
```

### Check Redis replication status
```shell
redis-cli info replication
```

### Check number of connected slaves
```shell
redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} info clients | grep connected_slaves
```

### Check Redis latency
```shell
redis-cli --latency
```

### Check network connectivity to Redis instance
```shell
ping ${REDIS_HOST}
```

### Check if Redis instance is listening on the correct port
```shell
netstat -tuln | grep ${REDIS_PORT}
```

### Check Redis configuration file for any issues
```shell
cat /etc/redis/redis.conf
```

### Check resource utilization of Redis instance
```shell
top -c -p $(pidof redis-server)
```

## Repair

### Get the Redis instance name
```shell
redis_instance=${REDIS_INSTANCE_NAME}
```

### Check the replication status
```shell
redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} info replication | grep -E '^(role|connected_slaves|slave[[:digit:]]*):'
```

### Identify the disconnected slaves
```shell
redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} info replication | grep -E '^(role|connected_slaves|slave[[:digit:]]*):' | grep -v 'role:master' | grep -v 'connected_slaves:0' | grep -v 'slave[[:digit:]]*:ip' | grep -v 'slave[[:digit:]]*:state=online'
```
### Restart the Redis server and monitor the replication status.
```shell
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

```

### Manually replicate the data from the master to the disconnected slaves.
```shell
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

```