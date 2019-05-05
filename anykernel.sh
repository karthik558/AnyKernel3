# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=AzurE Kernel by Panchajanya1999 @ xda-developers
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=violet
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=8.1.0 - 9
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;


## AnyKernel install
dump_boot;



# begin ramdisk changes
#insert_line init.rc "init.spectrum.rc" after "import /init.azure.rc" "import /init.spectrum.rc";

#insert_line /vendor/etc/init/hw/init.qcom.rc "init.azure.rc" after "import /vendor/etc/init/hw/init.qcom.usb.rc" "import /init.azure.rc";
#insert_line /vendor/etc/init/hw/init.qcom.rc "init.spectrum.rc" after "import /init.azure.rc" "import /init.spectrum.rc";

# init.rc
backup_file init.rc;
replace_string init.rc "cpuctl cpu,timer_slack" "mount cgroup none /dev/cpuctl cpu" "mount cgroup none /dev/cpuctl cpu,timer_slack";

# Remove CAF Boost Framework cuz CAF is a hoe
#mount -o rw,remount -t auto /vendor >/dev/null;
#rm -rf /vendor/etc/perf;
#mount -o ro,remount -t auto /vendor >/dev/null;

# end ramdisk changes

write_boot;

## end install
