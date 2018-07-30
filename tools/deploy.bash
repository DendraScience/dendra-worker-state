#!/bin/bash

cd "$(dirname "$0")"

DENW=den-worker

while getopts ":dep:w:" FLAG; do
	case $FLAG in
	d)
		DRY_RUN="--dry-run"
		;;
	e)
		DENW="echo $DENW"
		;;
	p)
		PROFILE=$OPTARG
		;;
	w)
		WID_ONLY=$OPTARG
		;;
    \?)
		echo "Invalid option: -$OPTARG" >&2
		;;
	esac
done

if [ -z "$PROFILE" ]; then
	echo "No profile specified"
	exit 1
fi

PROFILE_PATH="../data/profiles/$PROFILE"

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

				$DENW $wid push-states --verbose --filespec=$sf $DRY_RUN

				sfn=$(basename $sf)
				cid="${sfn/default.state.json/current}"

				$DENW $wid remove-state --confirm --id=$cid $DRY_RUN
			done
		fi
	fi
done
