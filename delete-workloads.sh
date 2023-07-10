#!/bin/bash

set -eo pipefail

# check dependencies
if ! command -v kubectl &> /dev/null
then
    echo "kubectl command is required"
	echo "please install from https://kubernetes.io/docs/tasks/tools/"
    exit
elif ! command -v xargs &> /dev/null
then
    echo "xargs command is required"
    exit
elif ! command -v awk &> /dev/null
then
    echo "awk command is required"
    exit
elif ! command -v grep &> /dev/null
then
    echo "grep command is required"
    exit
fi

kubectl get deploy "$@" \
	| grep batch \
	| awk '{print $1}' \
	| xargs kubectl delete deploy "$@"
