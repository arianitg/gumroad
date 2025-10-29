#!/bin/bash

set -e

consul_put() {
  curl \
    --silent \
    --request PUT \
    --data $2 \
    http://docker-host.intranet:8500/v1/kv/$1 > /dev/null
}

cd /app

# Keep critical and default in order, shuffle the rest
priority_queues=("critical" "default")
other_queues=("mongo" "low")

# Shuffle only the non-priority queues
shuffled_other=($(printf "%s\n" "${other_queues[@]}" | shuf))

# Combine priority queues with shuffled queues
all_queues=("${priority_queues[@]}" "${shuffled_other[@]}")

# Build the sidekiq command
queue_args=""
for queue in "${all_queues[@]}"; do
  queue_args="$queue_args -q $queue"
done

bundle exec sidekiq $queue_args
