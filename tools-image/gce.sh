#!/bin/bash

# Transform a raw image disk to gce compatible
RAWIMAGE="$1"
OUT="${2:-$RAWIMAGE.gce.raw}"
# NODE_IP="$3"
# PORT="$4"
# curl http://10.4.186.183:80/hello-kairos.raw -o $OUT
# cp -rf $RAWIMAGE $OUT

until [ -f $RAWIMAGE ]
do
    sleep 60
done
echo "raw image exists, starting conversion."

# GCP requires GCE images base raw image be named disk.raw before packaging in a tarball
mv $RAW disk.raw

GB=$((1024*1024*1024))
size=$(qemu-img info -f raw --output json disk.raw | gawk 'match($0, /"virtual-size": ([0-9]+),/, val) {print val[1]}')
# shellcheck disable=SC2004
ROUNDED_SIZE=$(echo "$size/$GB+1"|bc)
echo "Resizing raw image from \"$size\"MB to \"$ROUNDED_SIZE\"GB"
qemu-img resize -f raw disk.raw "$ROUNDED_SIZE"G
echo "Compressing raw image disk.raw to $OUT.tar.gz"
tar -c -z --format=oldgnu -f "$OUT".tar.gz disk.raw