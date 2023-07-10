#!/bin/bash

if ! command -v kubectl &> /dev/null
then
    echo "kubectl required"
	echo "please install from https://kubernetes.io/docs/tasks/tools/"
    exit
fi

for DEPLOY in $(kubectl get deploy -o custom-columns=NAME:.metadata.name --no-headers "$@"); do
	kubectl patch deployment ${DEPLOY} -p \
		"{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"$(date +'%s')\"}}}}}" "$@"
	# allow sleep between rolls
	sleep ${1:-0}m
done
