#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="zImage"
DTBIMAGE="dtb"
DEFCONFIG="find7_defconfig"

# Kernel Details
VER=".R1.FIND7"
AK_VER="$BASE_AK_VER$VER"

# Vars
export LOCALVERSION=~`echo $AK_VER`
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=latolium
export KBUILD_BUILD_HOST=DarkRoom

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="/media/dizzy/Extern/android/AK-OnePone-AnyKernel2"
PATCH_DIR="/media/dizzy/Extern/android/AK-OnePone-AnyKernel2/patch"
MODULES_DIR="/media/dizzy/Extern/android/AK-OnePone-AnyKernel2/modules"
ZIP_MOVE="/media/dizzy/Extern/android/releases"
ZIMAGE_DIR="/media/dizzy/Extern/android/find7_kernel_cm/arch/arm/boot"

# Functions
function clean_all {
		rm -rf $MODULES_DIR/*
		cd ~/android/find7_kernel_cm/out/kernel
		rm -rf $DTBIMAGE
		git reset --hard > /dev/null 2>&1
		git clean -f -d > /dev/null 2>&1
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		
}

function make_modules {
		rm `echo $MODULES_DIR"/*"`
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
}

function make_dtb {
		$REPACK_DIR/tools/dtbToolCM -2 -o $REPACK_DIR/$DTBIMAGE -s 2048 -p scripts/dtc/ arch/arm/boot/
}

function make_boot {
		cp -vr $ZIMAGE_DIR/zImage $REPACK_DIR/zImage
		
		. appendramdisk.sh
}


function make_zip {
		cd $REPACK_DIR
		zip -r9 `echo $AK_VER`.zip *
		mv  `echo $AK_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")


echo -e "${green}"
echo "-----------------"
echo "Making Despair Kernel:"
echo "-----------------"
echo -e "${restore}"

while read -p "Do you want to use UBERTC(1) or SaberMod(2) or Linaro(3)? " echoice
do
case "$echoice" in
	1 )
		export CROSS_COMPILE=/media/dizzy/Extern/android/arm-eabi-4.9/bin/arm-eabi-
		TC="UBER"
		echo
		echo "Using UBERTC"
		break
		;;
	2 )
		export CROSS_COMPILE=/home/despairfactor/tmp/arm-linux-gnueabi-5.2/bin/arm-eabi-
		TC="SM"
		echo
		echo "Using SM"
		break
		;;
	3 )
		export CROSS_COMPILE=${HOME}/android/linarobuild/out/linaro-arm-eabi-5.2/bin/arm-eabi-
		TC="LINARO"
		echo
		echo "Using Linaro"
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build (Y or N)? " dchoice
do
case "$dchoice" in
	y|Y )
		BASE_AK_VER="Trash"
		AK_VER="$BASE_AK_VER$VER$TC"
		export LOCALVERSION=~`echo $AK_VER`
		make_kernel
		make_dtb
		make_modules
		make_boot
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done


echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
