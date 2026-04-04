# Environment Preparation For SimpleKernelInstaller
# By KeJia

# setup
chmod +x $MODPATH/tools/*
PATH="$MODPATH/tools:$PATH"
BACKUP='/data/boot_backup_'
WORKDIR=$MODPATH/workdir
mkdir $WORKDIR

# print kernel name as a title
TITLE=" $(grep '^name=' $MODPATH/customize.sh | cut -d '=' -f 2) Installer "
linelen=$(echo -n "$TITLE" | wc -c)
len=$linelen
bar=$(printf "%${len}s" | tr ' ' '*')
ui_print "$bar"
ui_print "$TITLE"
ui_print "$bar"

# self check
if [ ! -e $MODPATH/kernel ] && [ ! -e $MODPATH/*Image* ] && [ ! -e $MODPATH/*dtb ] && [ ! -e $MODPATH/*dtbo*.img ]; then
    abort "! kernel/dtb/dtbo not found! This package may be broken!"
fi

# check data
DATA=false
mount /data 2>/dev/null
if grep ' /data ' /proc/mounts | grep -vq 'tmpfs'; then
    touch /data/.rw && rm /data/.rw && DATA=true
fi

# devicename check (from anykernel3)
check_devicename() {
    local device devicename match product testname vendordevice vendorproduct;
    ui_print "- Checking devicename...";
    device=$(getprop ro.product.device 2>/dev/null);
    product=$(getprop ro.build.product 2>/dev/null);
    vendordevice=$(getprop ro.product.vendor.device 2>/dev/null);
    vendorproduct=$(getprop ro.vendor.product.device 2>/dev/null);
    for testname in $(grep '^devicename.*=' $MODPATH/customize.sh | cut -d= -f2-); do
        for devicename in $device $product $vendordevice $vendorproduct; do
            if [ "$devicename" == "$testname" ]; then
                ui_print "- This device is '$testname'."
                    match=1
                    break 2
            fi
            ui_print "! This device is not '$testname'."
        done
    done
    if [ ! "$match" ]; then
        abort "! This device cannot use this kernel."
    fi
}

install() {
    cd $WORKDIR
    if [ -n "$(ls /dev/block/bootdevice/by-name/boot*)" ]; then
        ui_print "- Getting 'boot' Image..."
        dd if="/dev/block/bootdevice/by-name/boot$(getprop ro.boot.slot_suffix)" of=boot.img
        ui_print "- Unpacking 'boot' Image..."
        magiskboot unpack boot.img
        if [ -e $MODPATH/kernel ]; then
            ui_print "- Replacing kernel..."
            mv $MODPATH/kernel .
        elif [ -e $MODPATH/*Image*-dtb ]; then
            ui_print "- Replacing kernel and dtb..."
            magiskboot split $(find $MODPATH/ -type f -name "*Image*-dtb")
            REPLACEDDTB=true
        elif [ -e $MODPATH/Image ]; then
            ui_print "- Replacing kernel..."
            mv $MODPATH/Image kernel
        elif [ -e $MODPATH/*Image* ]; then
            ui_print "- Replacing kernel..."
            magiskboot decompress $(find $MODPATH/ -type f -name "*Image*") kernel
        fi
        if [ "$REPLACEDDTB" != "true"  ] && [ -e $MODPATH/*dtb ]; then
            ui_print "- Replacing dtb..."
            if [ -e $MODPATH/kernel_dtb ]; then
                mv $MODPATH/kernel_dtb .
                REPLACEDDTB=true
            elif [ -e $MODPATH/*.dtb ]; then
                mv $MODPATH/*.dtb kernel_dtb
                REPLACEDDTB=true
            fi
        fi
        ui_print "- Repacking 'boot' Image..."
        magiskboot repack boot.img
        if $DATA; then
            ui_print "- Backing up 'boot' Image..."
            if [ "$(ls -1 $BACKUP* | wc -l)" -ge 3 ]; then
                rm "$(ls -1 $BACKUP* | head -1)"
            fi
            mv boot.img "$BACKUP$(date +'%Y%m%d_%H%M%S').img"
            ui_print "- You can find 'boot' backup in /data !"
        else
            ui_print "! /data is not writable! Skipping backup..."
        fi
        ui_print "- Flashing 'boot' Image..."
        dd if=new-boot.img of="/dev/block/bootdevice/by-name/boot$(getprop ro.boot.slot_suffix)"
    else
        abort "! Unsupport Environment!"
    fi
    if [ -e $MODPATH/*dtbo*.img ] && [ -n "$(ls /dev/block/bootdevice/by-name/dtbo*)" ]; then
        ui_print "- Flashing 'dtbo' Image..."
        dd if=$(find $MODPATH/ -type f -name "*dtbo*.img") of="/dev/block/bootdevice/by-name/dtbo$(getprop ro.boot.slot_suffix)"
        REPLACEDDTB=true
    fi
    if $DATA && [ "$REPLACEDDTB" == "true"  ]; then
        ui_print "- Cleaning Dalvik cache..."
        rm -rf /data/dalvik-cache/*
    fi
    ui_print "- Install Success!"
}