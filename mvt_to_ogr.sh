#!/bin/bash


if [ "$#" -ne 2 ]; then
    echo "usage: mvt_to_ogr.sh mvt outfile"
    exit 1
fi

MVT=$1
OUTFILE=$2


if [[ "$1" =~ .*\/([[:digit:]]{1,})\/([[:digit:]]{1,})\/([[:digit:]]{1,})\.pbf ]]; then
    Z=${BASH_REMATCH[1]}
    X=${BASH_REMATCH[2]}
    Y=${BASH_REMATCH[3]}

    ogr2ogr -oo Z=$Z -oo X=$X -oo Y=$Y $OUTFILE "MVT:"${1}
else
    echo ${MVT} " is not a path or URL to a PBF vector tile."
fi;


