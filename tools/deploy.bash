#!/bin/bash

cd "$(dirname "$0")"

if [ -z "$1" ]; then
	echo "No profile specified"
	exit 1
fi

PROFILE_PATH="../data/profiles/$1"

WID_ONLY="$2"

DENW=den-worker

$DENW cli set-user-environment local
ret=$?

if [ $ret -ne 0 ]; then
	echo "$DENW returned a non-zero exit code ($ret)"
	exit 1
fi

for wf in $PROFILE_PATH/*; do

	if [ -d "$wf" ]; then
		wid=$(basename $wf)

		if  [ -z "$WID_ONLY" ] || \
			[ "$wid" = "$WID_ONLY" ]; then

			for sf in $PROFILE_PATH/$wid/*.state.json; do

				$DENW $wid push-states --verbose --filespec=$sf

				sfn=$(basename $sf)
				cid="${sfn/default.state.json/current}"

				$DENW $wid remove-state --confirm --id=$cid
			done
		fi
	fi
done
