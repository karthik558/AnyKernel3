# AnyKernel3 Ramdisk Mod Script
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
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=none;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel install
split_boot;

if mountpoint -q /data; then
  # Optimize F2FS extension list (@arter97)
  for list_path in $(find /sys/fs/f2fs* -name extension_list); do

    ui_print "  • Optimizing F2FS extension list"
    echo "Optimizing F2FS extension list"
    echo "Updating extension list: $list_path"

    echo "Clearing extension list"

    hot_count="$(grep -n 'hot file extens' $list_path | cut -d':' -f1)"
    list_len="$(cat $list_path | wc -l)"
    cold_count="$((list_len - hot_count))"

    cold_list="$(head -n$((hot_count - 1)) $list_path | grep -v ':')"
    hot_list="$(tail -n$cold_count $list_path)"

    for ext in $cold_list; do
      [ ! -z $ext ] && echo "[c]!$ext" > $list_path
    done

    for ext in $hot_list; do
      [ ! -z $ext ] && echo "[h]!$ext" > $list_path
    done
    ui_print "  • Writing new extension list: $list_path"
    echo "Writing new extension list"

    for ext in $(cat $home/f2fs-cold.list | grep -v '#'); do
      [ ! -z $ext ] && echo "[c]$ext" > $list_path
    done

    for ext in $(cat $home/f2fs-hot.list); do
      [ ! -z $ext ] && echo "[h]$ext" > $list_path
    done
  done
fi

decomp_image=$home/Image
comp_image=$decomp_image.gz-dtb

# Hex-patch the kernel if Magisk is installed ('skip_initramfs' -> 'want_initramfs')
# This negates the need to reflash Magisk afterwards
if [ -f $comp_image ]; then
  comp_rd=$split_img/ramdisk.cpio
  decomp_rd=$home/_ramdisk.cpio
  $bin/magiskboot decompress $comp_rd $decomp_rd || cp $comp_rd $decomp_rd

  if $bin/magiskboot cpio $decomp_rd "exists .backup"; then
    ui_print "  • Preserving Magisk";
    $bin/magiskboot decompress $comp_image $decomp_image;
    $bin/magiskboot hexpatch $decomp_image 736B69705F696E697472616D667300 77616E745F696E697472616D667300;
    $bin/magiskboot compress=gzip $decomp_image $comp_image;
  else
  	ui_print "  • Magisk not found / not installed"
  fi;
fi;


# end ramdisk changes

flash_boot;
flash_dtbo;
## end install
