$GRAPHNA_PANEL = {
  docker_container_cpu_load: { id: 4, interval: 5.minutes, query: "count_scalar(container_memory_usage_bytes{{app-name}}&start=1494927915&end=1494928815&s" },
  docker_container_cpu_core: { id: 7, interval: 5.minutes },
  docker_container_mem_load: { id: 5, interval: 5.minutes },
  docker_container_mem_used: { id: 2, interval: 5.minutes },
  docker_container_disk_load: { id: 6, interval: 5.minutes },
  docker_container_disk_used: { id: 3, interval: 5.minutes },
  docker_container_running_containers: { id: 9, interval: 1.minutes },
  docker_container_system_load: { id: 10, interval: 1.minutes },
  docker_container_io_usage: { id: 15, interval: 1.minutes },
  docker_container_container_cpu_usage: { id: 8, interval: 1.minutes },
  docker_container_container_mem_usage: { id: 11, interval: 1.minutes },
  docker_container_cached_mem_usaged: { id: 12, interval: 1.minutes },
  docker_container_network_input: { id: 13, interval: 1.minutes },
  docker_container_network_output: { id: 14, interval: 1.minutes },
  docker_host_cpu_usage: { id: 5, interval: 1.minutes },
  docker_host_mem_usage: { id: 6, interval: 1.minutes },
}

