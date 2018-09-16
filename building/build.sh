#!/usr/bin/env bash

declare -a ENV
while [ -n "$1" ]; do
  case "$1" in
    centos[67]|fedora|debian)
      ENV+=("$1")
      shift
      ;;
    *)
      printf "%s\n" "Environment required"
      exit 1
      ;;
  esac
done


for e in "${ENV[@]}"; do
  if docker ps -a | grep -q "build-$e"; then
    docker start "build-$e"
  else
    docker run --name "build-$e" \
      -v $(pwd)/../:/root/configsnap \
      -v /root/output:/root/output \
      -v /root/rpmbuild:/root/rpmbuild "configsnap:$e"
  fi
done
