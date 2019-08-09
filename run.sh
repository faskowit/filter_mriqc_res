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

function help_prompt {
cat <<helptext
	USAGE ${0} 
		-f 		path to mriqc's group_bold.tsv
		-a 		path to mriqc's group_T1w.tsv
		-t 		threshold percent num of fd outliers (def 25; as in 25 percent)
		-o 		path to output directory

		need to minimally provide a tsv and output dir

helptext
}

if [[ $# -lt 2 ]] ; then
	help_prompt
	exit 1
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
        * )                     help_prompt
                                exit 1
    esac
    shift #this shift "moves up" the arg in after each case
done

if [[ -z ${oDir} ]] ; then
	echo "need provide output dir"
	exit 1
fi

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

