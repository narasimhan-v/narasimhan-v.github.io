#!/bin/bash

device=$1
namespace=$device"n1"
echo $device

nvme format $device
block_size=$((2**`nvme id-ns $namespace | grep "in use" | awk '{print $5}' | awk -F: '{print $NF}'`))
echo "Block size: $block_size"

nvme set-feature $device -f 0x0b --value=0x0100

nvme delete-ns $device -n 0xFFFFFFFF
sleep 5
nvme list

nvme get-log $device -l 200 -i 4

max_ns=`nvme id-ctrl $device | grep ^nn | awk '{print $NF}'`
echo "Maximum namespaces supported: $max_ns"
max_size=`nvme id-ctrl $device | grep -i tnvmcap | awk '{print $NF}'`
echo "Total NVMe device capacity: $max_size"
max_size=$(( $max_size*70/100 ))
echo "Total NVMe device capacity considered for creating namespaces: $max_size"
max_blocks=`expr $max_size / $block_size`
echo "Maximum blocks: $max_blocks"
per_ns_blocks=`expr $max_blocks / $max_ns`
echo "Blocks allocated per namespace: $per_ns_blocks"


for i in $(eval echo {1..$max_ns})
do
    echo $i
    echo "nvme create-ns $device --nsze=$per_ns_blocks --ncap=$per_ns_blocks --flbas=0 --dps=0"
    nvme create-ns $device --nsze=$per_ns_blocks --ncap=$per_ns_blocks --flbas=0 --dps=0
    echo "nvme attach-ns $device --namespace-id=$i --controllers=`nvme list-ctrl $device | grep "0]" | awk -F: '{print $2}'`"
    nvme attach-ns $device --namespace-id=$i --controllers=`nvme list-ctrl $device | grep "0]" | awk -F: '{print $2}'`
    sleep 2
    nvme get-log $device -l 200 -i 4
    sleep 2
    nvme id-ns "$device"n"$i" | grep -E "nsze|nvmcap"
done
nvme ns-rescan $device
nvme list
