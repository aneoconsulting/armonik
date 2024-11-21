#!/bin/bash

export CONTROL_PLANE_URL=$(cat ../../../../infrastructure/quick-deploy/aws/all/generated/armonik-output.json | jq -r '.armonik.control_plane_url')

#run  5000 tasks on 100 pods
docker run --rm \
	-e GrpcClient__Endpoint="${CONTROL_PLANE_URL}" \
	-e BenchOptions__nTasks=5000 \
	-e BenchOptions__TaskDurationMs=1 \
	-e BenchOptions__PayloadSize=1 \
	-e BenchOptions__ResultSize=1 \
	-e BenchOptions__Partition=bench \
    	-e BenchOptions__ShowEvents=false \
	-e BenchOptions__BatchSize=50 \
	-e BenchOptions__MaxRetries=5 \
	-e BenchOptions__DegreeOfParallelism=5 \
	dockerhubaneo/armonik_core_bench_test_client:$(cat ../../../../versions.tfvars.json | jq -r '.armonik_versions.core')
