#!/bin/bash

set -o pipefail

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
elif ! command -v envsubst &> /dev/null
then
    echo "kubectl required"
	echo "please install from https://kubernetes.io/docs/tasks/tools/"
    exit
fi

# parse options and help output
parser_definition() {
	setup REST plus:true help:usage abbr:true -- \
	    	"Usage: ${2##*/} [options...] [arguments...]" ''
					param TOTAL -t  init:=500 -- "how many total containers to create (default: 500)"
					param BATCH -b  init:=100 -- "how many replicas per deployment (default: 100)"
					param TEMPLATE -f init:="deployment-template.yaml" -- "file to use for deployment (default: deployment-template.yaml)"
					disp :usage -h --help
}

eval "$(getoptions parser_definition - "$0") exit 1"

export NAMESPACE=${KUBE_NAMESPACE:-default}
export BATCH=$BATCH

# Change what valuee you want deployments to have
# will be randomly selected from the arrays
#CPU_OPTIONS=(250m 500m 750m 1 2)
CPU_OPTIONS=(250m 500m 750m 1)
#MEM_OPTIONS=(128M 256M 512M 1G 2G)
MEM_OPTIONS=(512M 750M 1G 1500M 2G)

CPU_OPTIONS_LENG=${#CPU_OPTIONS[@]}
MEM_OPTIONS_LENG=${#MEM_OPTIONS[@]}

COUNT=0
while (test $COUNT -lt $TOTAL); do
	RAND=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
	export CPU=${CPU_OPTIONS[$[$RANDOM % $CPU_OPTIONS_LENG]]}
	export MEM=${MEM_OPTIONS[$[$RANDOM % $MEM_OPTIONS_LENG]]}
	export NAME="batch-${CPU,,}-${MEM,,}-${RAND}"
	echo "Creating ${NAME} with ${BATCH} replicas"
	cat "${TEMPLATE:-deployment-template.yaml}" \
		| envsubst \
		| kubectl apply -n ${NAMESPACE} -f -
	COUNT=$((COUNT+$BATCH))
done
