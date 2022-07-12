#!/bin/bash


export OverrideDrmRegion=0
echo "options i915 enable_guc=3 enable_rc6=0 smem_access_control=5 reset=0 enable_hangcheck=0" > /etc/modprobe.d/i915.conf
modprobe i915

read -p "How long you want to run PTU : (sec) " ptu_time
read -p "How many cards you want to run PTU : (cards) " ptu_cards
read -p "What's the percentage you want to run PTU : (0-100) " ptu_percent
read -p "What's the test you want to run PTU : (-gemm -hbm -triad -int) " ptu_test

export path=/home/user/PTU/PVCPTATRev_0.2.tar/PVCPTATRev_0.2

echo "$path/PVCPTATMon -csv -t $ptu_time" > $path/PTUMon.sh
chmod 777 $path/PTUMon.sh
$path/PTUMon.sh & 

i=$((ptu_cards-1))
while [ $i != -1 ]
do
	echo "$path/PVCPTATGen $ptu_test -c $i -p $ptu_percent -t $ptu_time" > $path/PTUGen_$i.sh
	chmod 777 $path/PTUGen_$i.sh
	$path/PTUGen_$i.sh &
	((i--))
done

rm $path/PTUMon*
rm $path/PTUGen*
