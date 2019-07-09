#!/bin/bash

# helper func
function checkisfile {

	inFile=$1
	if [[ ! -f ${inFile} ]] ; then
		echo "file does not exist: $inFile"
		exit 1
	fi
}

# where we executing this?
EXEDIR=$(dirname "$(readlink -f "$0")")/
funcThrP=25

if [[ $# -lt 2 ]] ; then
	echo "need at least two args"
	exit
fi

# read in files
while [ "$1" != "" ]; do
    case $1 in
        -f | -func ) shift
                               	fmriTSV=$1
                          		checkisfile $1
                               	;;
        -a | -anat ) shift
								anatTSV=$1
								checkisfile $1
                                ;;
        -t | -thrp ) shift
								funcThrP=$1
								re='^[0-9]+$'
								[[ $funcThrP =~ $re ]] || \
									{ echo "error: ${funcThrP} not number" >&2; exit 1 ; }
								;;
        -o | -out ) shift
								oDir=$1
								;;
        * )                     echo "see script"
                                exit 1
    esac
    shift #this shift "moves up" the arg in after each case
done

# make the output dir
mkdir -p $oDir

# run func
if [[ ! -z ${fmriTSV} ]] ; then

	cmd="Rscript src/read_mriqc_func.R ${fmriTSV} ${oDir} ${funcThrP}"
	echo $cmd
	eval $cmd
fi

# run anat
if [[ ! -z ${anatTSV} ]] ; then

	cmd="Rscript src/read_mriqc_anat.R ${anatTSV} ${oDir}"
	echo $cmd
	eval $cmd
fi

