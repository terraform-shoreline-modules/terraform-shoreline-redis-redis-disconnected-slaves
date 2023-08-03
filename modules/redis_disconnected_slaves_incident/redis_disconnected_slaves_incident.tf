resource "shoreline_notebook" "redis_disconnected_slaves_incident" {
  name       = "redis_disconnected_slaves_incident"
  data       = file("${path.module}/data/redis_disconnected_slaves_incident.json")
  depends_on = [shoreline_action.invoke_redis_restart_monitor,shoreline_action.invoke_redis_replication]
}

resource "shoreline_file" "redis_restart_monitor" {
  name             = "redis_restart_monitor"
  input_file       = "${path.module}/data/redis_restart_monitor.sh"
  md5              = filemd5("${path.module}/data/redis_restart_monitor.sh")
  description      = "Restart the Redis server and monitor the replication status."
  destination_path = "/agent/scripts/redis_restart_monitor.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "redis_replication" {
  name             = "redis_replication"
  input_file       = "${path.module}/data/redis_replication.sh"
  md5              = filemd5("${path.module}/data/redis_replication.sh")
  description      = "Manually replicate the data from the master to the disconnected slaves."
  destination_path = "/agent/scripts/redis_replication.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_redis_restart_monitor" {
  name        = "invoke_redis_restart_monitor"
  description = "Restart the Redis server and monitor the replication status."
  command     = "`chmod +x /agent/scripts/redis_restart_monitor.sh && /agent/scripts/redis_restart_monitor.sh`"
  params      = []
  file_deps   = ["redis_restart_monitor"]
  enabled     = true
  depends_on  = [shoreline_file.redis_restart_monitor]
}

resource "shoreline_action" "invoke_redis_replication" {
  name        = "invoke_redis_replication"
  description = "Manually replicate the data from the master to the disconnected slaves."
  command     = "`chmod +x /agent/scripts/redis_replication.sh && /agent/scripts/redis_replication.sh`"
  params      = ["MASTER_HOSTNAME","MASTER_PORT"]
  file_deps   = ["redis_replication"]
  enabled     = true
  depends_on  = [shoreline_file.redis_replication]
}

