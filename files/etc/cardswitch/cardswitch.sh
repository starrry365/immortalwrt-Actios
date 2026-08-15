#!/bin/sh
# SIM 卡槽切换脚本
# 用法: cardswitch.sh <1|2|3|4>
# 切换后重启 modem 使设置生效

if [ -z "$1" ]
then
	echo "Run with the slot you want to switch to (1-4)"
	exit 1
fi

case "$1" in
	1)
		echo 1 > /sys/class/leds/sim:sel/brightness
		echo 0 > /sys/class/leds/sim:en/brightness
		echo 0 > /sys/class/leds/sim:sel2/brightness
		echo 0 > /sys/class/leds/sim:en2/brightness
		;;
	2)
		echo 0 > /sys/class/leds/sim:sel/brightness
		echo 1 > /sys/class/leds/sim:en/brightness
		echo 0 > /sys/class/leds/sim:sel2/brightness
		echo 0 > /sys/class/leds/sim:en2/brightness
		;;
	3)
		echo 0 > /sys/class/leds/sim:sel/brightness
		echo 0 > /sys/class/leds/sim:en/brightness
		echo 1 > /sys/class/leds/sim:sel2/brightness
		echo 0 > /sys/class/leds/sim:en2/brightness
		;;
	4)
		echo 0 > /sys/class/leds/sim:sel/brightness
		echo 0 > /sys/class/leds/sim:en/brightness
		echo 0 > /sys/class/leds/sim:sel2/brightness
		echo 1 > /sys/class/leds/sim:en2/brightness
		;;
	*)
		echo "Invalid slot: $1 (use 1-4)"
		exit 1
		;;
esac

# 重启 modem 使 SIM 切换生效
# 若模块被占用无法卸载则跳过（modprobe 会因已加载自动忽略），不中断脚本
rmmod qcom-q6v5-mss 2>/dev/null || true
modprobe qcom-q6v5-mss 2>/dev/null || true
service rmtfs restart 2>/dev/null || true
service modemmanager restart 2>/dev/null || true