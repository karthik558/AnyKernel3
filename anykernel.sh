# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=
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
# this property will be set later, when we check for the presence of ramdisk.cpio
# ramdisk_compression=none;
customdd="bs=1048576"

# Check if we have appended FPS in kernel zip name, set accordingly
case "$ZIPFILE" in
  *"dtbo"*|*dtbo*)
    export flashdtbo=true;
    echo "DTBO build detected"
    ui_print "  • DTBO inclusion detected in Zip File"
    ;;
  *)
    echo " DTBO-less Normal build"
    ui_print "  • DTBO-less Normal build"
    ;;
esac

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

magisk_check;

## AnyKernel install
if [ "$magisk_present" = true ]; then
  # AnyKernel file attributes
  # set permissions/ownership for included ramdisk files
  #set_perm_recursive 0 0 755 644 $ramdisk/*;
  #set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

  dump_boot;

  # Add skip_override parameter to cmdline so user doesn't have to reflash Magisk
  if [ -d $ramdisk/.backup ]; then
    ui_print "  • Rooted Mode [Magisk] detected";
    patch_cmdline "skip_override" "skip_override";
  else
    patch_cmdline "skip_override" "";
    ui_print "  • Rootless Mode detected"
  fi;
else
  split_boot;
fi

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
    ui_print "  • Writing new extension list"
    echo "Writing new extension list"

    for ext in $(cat $home/f2fs-cold.list | grep -v '#'); do
      [ ! -z $ext ] && echo "[c]$ext" > $list_path
    done

    for ext in $(cat $home/f2fs-hot.list); do
      [ ! -z $ext ] && echo "[h]$ext" > $list_path
    done
  done
fi

# end ramdisk changes

if [ "$magisk_present" = true ]; then
  write_boot;
else
  flash_boot;
  flash_dtbo;
fi
## end install
