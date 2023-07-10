#!/bin/bash

set -euo pipefail

# check dependencies
if ! command -v getoptions &> /dev/null
then
    echo "getoptions required for flag parsing"
	echo "please install from https://github.com/ko1nksm/getoptions"
    exit
elif ! command -v kubectl &> /dev/null
then
    echo "kubectl required"
	echo "please install from https://kubernetes.io/docs/tasks/tools/"
    exit
elif

# parse options and help output
parser_definition() {
	setup REST plus:true help:usage abbr:true -- \
	    	"Usage: ${2##*/} [options...] [arguments...]" ''
					param SCALE -s pattern:"up | down" -- "scale up or down (default: random)"
					param TIME -t -- "time to wait in minutes between scaling (default: 0m)"
					disp :usage -h --help
}

eval "$(getoptions parser_definition - "$0") exit 1"

RANDOM_SCALE=0
# add up or down to only scale in 1 direction
if [ "${SCALE,,}" == "up" ]; then
	echo "Only scaling up"
	UP_OR_DOWN=1
elif [ "${SCALE,,}" == "down" ]; then
	echo "Only scaling down"
	UP_OR_DOWN=2
fi

# get deployments
for DEPLOY in $(kubectl get deploy -o custom-columns=NAME:.metadata.name --no-headers "$@"); do
	# get scaling number
	if [ -z ${UP_OR_DOWN+x} ]; then
		# set this so we randomly scale up and down on each loop
		RANDOM_SCALE=1
	fi
	if [ $RANDOM_SCALE -eq 1 ]; then
		UP_OR_DOWN=$(shuf -i1-2 -n1)
	fi
	SCALE=$(shuf -i1-10 -n1)
	CURRENT_REPLICAS=$(k get deploy $DEPLOY -o custom-columns=SPEC:.spec.replicas --no-headers)
	PERCENTAGE="$(( CURRENT_REPLICAS*SCALE/100 ))"
	if [ $UP_OR_DOWN -eq 1 ]; then
		NEW_REPLICAS="$(( CURRENT_REPLICAS+PERCENTAGE ))"
		echo "scale $DEPLOY from $CURRENT_REPLICAS to ${NEW_REPLICAS}"
	else
		NEW_REPLICAS="$(( CURRENT_REPLICAS-PERCENTAGE ))"
		echo "scale $DEPLOY $CURRENT_REPLICAS to ${NEW_REPLICAS}"
	fi
	kubectl scale deploy $DEPLOY --replicas ${NEW_REPLICAS} "$@"
	# send second argument to sleep between scaling
	sleep ${TIME:-0}m
done

