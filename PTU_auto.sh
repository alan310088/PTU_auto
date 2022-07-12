read -p "How long you want to run PTU : (sec) " ptu_time
read -p "How many cards you want to run PTU : (cards) " ptu_cards
read -p "What's the percentage you want to run PTU : (0-100) " ptu_percent
read -p "What's the test you want to run PTU : (-gemm -hbm -triad -int -sysgemm) " ptu_test

path=$PWD 

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
Author:		Alan_Lo@wistron.com
Date:		2022/6/30
PTU version:	0.3.1
Agama version:	467
***********************************************************
使用之前先將環境變數export然後再使用(參照SOP for PTU)

第一次執行時要先安裝一些package.
	
	sudo su
	chmod 777 SetupEnv_Ubuntu 
	./SetupEnv_Ubuntu.sh -y

如果有問題先執行以下這條再執行一次:
	
	echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null

之後就打開terminal:

	sudo su
	modprobe i915
	ulimit -n 32768
	clinfo -l (檢查卡數有沒有正確)
	echo on > /sys/bus/pci/devices/0000\:4e\:00.1/power/control
	echo on > /sys/bus/pci/devices/0000\:53\:00.1/power/control
	echo on > /sys/bus/pci/devices/0000\:75\:00.1/power/control
	echo on > /sys/bus/pci/devices/0000\:7c\:00.1/power/control
	echo on > /sys/bus/pci/devices/0001\:1e\:00.1/power/control
	echo on > /sys/bus/pci/devices/0001\:22\:00.1/power/control
	echo on > /sys/bus/pci/devices/0001\:48\:00.1/power/control
	echo on > /sys/bus/pci/devices/0001\:4e\:00.1/power/control
	(中間的數值為lspci |grep 0bdc 中得到的bus number)

將 PTU_auto.sh 放進來

	chmod 777 PTU_auto.sh
	./PTU_auto.sh

依照提示輸入秒數、卡數、趴數、測試項目

	EX:
	How long you want to run PTU : (sec) : 10
	How many cards you want to run PTU : (cards) : 8
	What's the percentage you want to run PTU : (0-100) : 100
	What's the test you want to run PTU : (-gemm -hbm -triad -int) : -gemm

程式會在同一個terminal下跑完
之後PTUMon 生成的 csv 檔會自動存在 /opt/intel/log 裡
