#!/bin/bash

container_name="srv1"
image_name="tr23malyarchuk/pa-tr23malyarchuk:latest"
cpu_core="0"

srv2_name="srv2"
srv2_cpu="1"
srv3_name="srv3"
srv3_cpu="2"
srv4_name="srv4"
srv4_cpu="3"
srv2_port=8082
srv3_port=8083
srv4_port=8084

cleanup_existing_container() {
    if docker ps -a --format '{{.Names}}' | grep -q "^$container_name\$"; then
        echo "Removing existing container $container_name..."
        docker rm -f "$container_name" > /dev/null 2>&1
    fi
}

cleanup_container_by_name() {
    local name=$1
    if docker ps -a --format '{{.Names}}' | grep -q "^$name\$"; then
        echo "Removing existing container $name..."
        docker rm -f "$name" > /dev/null 2>&1
    fi
}

launch_container() {
    local name=$1
    local core=$2
    local port=$3
    echo "Starting container $name on CPU core #$core with port $port..."
    docker run -d \
        --name "$name" \
        --cpuset-cpus="$core" \
        -p "$port:8081" \
        "$image_name"
}

monitor_container_busy() {
    local container=$1
    local next_container_name=$2
    local next_container_port=$3
    local next_container_cpu=$4
    local busy_count=0
    local idle_count=0
    local max_busy_count=$5
    local max_idle_count=2

    while true; do
        cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" "$container" | sed 's/%//')
        echo "Debug: $container CPU usage is $cpu_usage%"

        if (( $(echo "$cpu_usage > 0.0" | bc -l) )); then
            busy_count=$((busy_count + 1))
            idle_count=0
            echo "Container $container is busy for $busy_count minute(s)..."
        else
            idle_count=$((idle_count + 1))
            busy_count=0
            echo "Container $container is idle for $idle_count minute(s)..."
        fi

        if [ $idle_count -ge $max_idle_count ]; then
            echo "Container $container has been idle for 2 consecutive minutes. Exiting the script."
            exit 0
        fi

        if [ $busy_count -ge $max_busy_count ]; then
            echo "Container $container has been busy for $max_busy_count consecutive minutes."
            echo "Launching container $next_container_name on port $next_container_port."
            cleanup_container_by_name "$next_container_name"
            launch_container "$next_container_name" "$next_container_cpu" "$next_container_port"
            break
        fi
        sleep 60
    done
}

cleanup_on_interrupt() {
    echo "Stopping container $container_name..."
    docker stop "$container_name" > /dev/null 2>&1
    docker rm -f "$container_name" > /dev/null 2>&1
    echo "Container stopped."
    exit 0
}

check_for_image_update() {
    echo "Checking for a new version of the image $image_name..."
    if docker pull "$image_name" | grep -q "Downloaded newer image"; then
        echo "Newer image found. Starting update process."
        update_all_containers
    else
        echo "Image is already up-to-date. Continuing with the current logic."
        return 1
    fi
}

update_all_containers() {
    local accessible_container=""
    for container in "srv1" "srv2" "srv3" "srv4"; do
        if docker ps --format '{{.Names}}' | grep -q "^$container\$"; then
            if [ -z "$accessible_container" ]; then
                accessible_container="$container"
                echo "$accessible_container is accessible among all the containers during updates."
                continue
            fi
            echo "Updating $container..."
            cleanup_container_by_name "$container"
            launch_container "$container" "$(get_cpu_for_container "$container")" "$(get_port_for_container "$container")"
        fi
    done

    if [ -n "$accessible_container" ]; then
        echo "Re-updating the accessible container: $accessible_container"
        cleanup_container_by_name "$accessible_container"
        launch_container "$accessible_container" "$(get_cpu_for_container "$accessible_container")" "$(get_port_for_container "$accessible_container")"
    fi
    echo "All containers updated with the new image."
}

get_port_for_container() {
    case "$1" in
        "srv1") echo "8081" ;;
        "srv2") echo "8082" ;;
        "srv3") echo "8083" ;;
        "srv4") echo "8084" ;;
    esac
}

get_cpu_for_container() {
    case "$1" in
        "srv1") echo "0" ;;
        "srv2") echo "1" ;;
        "srv3") echo "2" ;;
        "srv4") echo "3" ;;
    esac
}

trap cleanup_on_interrupt SIGINT

cleanup_existing_container
launch_container "$container_name" "$cpu_core" "8081"

echo "Container $container_name is running on port 8081. Press Ctrl+C to stop."

while true; do
    if check_for_image_update; then
        echo "Image update process completed. Resuming normal logic."
    else
        monitor_container_busy "$container_name" "$srv2_name" "$srv2_port" "$srv2_cpu" 2
        monitor_container_busy "$srv2_name" "$srv3_name" "$srv3_port" "$srv3_cpu" 2
        monitor_container_busy "$srv3_name" "$srv4_name" "$srv4_port" "$srv4_cpu" 2
        monitor_container_busy "$srv4_name" "" "" "" 2
    fi
    sleep 120
done

