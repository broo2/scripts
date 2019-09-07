#!/bin/bash
Echo "Re-balancing Docker Services..."

docker service ls --format "{{.Name}}" | while read line
do
  echo "updating "$line"..." 
  docker service update --force $line
done
