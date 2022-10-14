#!/bin/bash

# Find missing tiles in S3 
# Tony Cannistra <tcannistra@outsideinc.com>

# Works by:
# * defining a bounding box or GeoJSON area
# * enumerating the tiles within it at a particular
# zoom level
# * listing an s3 bucket/prefix to determine extant tiles
# * comparing the two lists
# Requires supermercado, aws-cli

if [ "$#" -ne 5 ]; then
    echo "$#"
    echo "usage: check_tiles_s3.sh bucket prefix extension zoom west,south,east,north|path to GeoJSON"
    exit 1
fi

BUCKET=$1
PREFIX=$2
EXTENSION=$3
ZOOM=$4
GEOINPUT=$5
TMPDIR=$(mktemp -d)
BBOX=0

if [[ "$GEOINPUT" =~ "," ]]; then 
    BBOX=1
fi;

if [[ "$BBOX" -ge 1 ]]; then
    echo "[$GEOINPUT]"\
        | mercantile tiles $ZOOM | sed -E  's/\[//g;s/\]//g;s/ //g'\
        | sort > $TMPDIR/alltiles.txt
else 
    cat $GEOINPUT | supermercado burn $ZOOM \
        | sed -E  's/\[//g;s/\]//g;s/ //g'\
        | sort > $TMPDIR/alltiles.txt
fi;

aws s3api list-objects \
    --bucket $BUCKET --prefix $PREFIX/$ZOOM/ \
    | jq -r '.Contents[] | .Key' \
    | sed "s/$PREFIX//;s/$EXTENSION//;s/\///"\
    | awk 'BEGIN {FS = "/"; OFS = "," } ; {print $2, $3, $1}'\
    | sort \
    > $TMPDIR/s3_inventory.txt

comm -12 $TMPDIR/alltiles.txt $TMPDIR/s3_inventory.txt \
    > $TMPDIR/present_in_both_lists.txt

comm -23 $TMPDIR/alltiles.txt $TMPDIR/present_in_both_lists.txt \
    > $TMPDIR/missing.txt

>&2 echo "Total Tiles: $(cat $TMPDIR/alltiles.txt | wc -l | xargs)"
>&2 echo "Tiles Present in S3: $(cat $TMPDIR/present_in_both_lists.txt | wc -l | xargs)"
>&2 echo "Missing Tiles: $(cat $TMPDIR/missing.txt | wc -l | xargs)"

cat $TMPDIR/missing.txt

rm -rf $TMPDIR
