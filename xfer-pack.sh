#!/bin/sh
# Modattu lähteestä
# https://www.avrfreaks.net/s/topic/a5C3l000000UZmfEAG/t151347
# Kun tämän on pyöräyttänyt, voi kääntää "niinkin helposti" kuin pistämällä -B ja -isystem kääntökutsuun à
# avr-gcc-5.4.0 -mmcu=atmega808 -B $pack_dir/gcc/dev/atmega808 -isystem $pack_dir/include -o ulos.elf main.c


# Define source and target directories.
# Purettu Atpack-arkisto, niitä saa http://packs.download.atmel.com/
# ja ne on vain hassupäätteisiä zippejä.
pack_dir=$1
# AVR-GCC:n librakansio, omalla koneella /lib/gcc/avr/5.4.0
dest_dir=$2

devs_dir=$pack_dir/gcc/dev
if [ ! -d $devs_dir ]; then
  echo  "*** bad directory: $devs_dir "
  exit 1
fi
devs=`(cd $devs_dir; ls)`

# Start building destination.
mkdir -p $dest_dir

# Install include files.
#mkdir -p $dest_dir/include
#(cd $pack_dir/include; tar cf - . ) | (cd $dest_dir/include; tar xf -)

# Install device-spec files.
mkdir -p $dest_dir/device-specs
for dev in $devs; do
  cp $devs_dir/$dev/device-specs/specs-$dev $dest_dir/device-specs/
done

# Install lib files.
mkdir -p $dest_dir/lib
for dev in $devs; do
  for dir in `ls $devs_dir/$dev`; do
    case $dir in
    device-specs) ;;
    *) (cd $devs_dir/$dev; tar cf - $dir) | (cd $dest_dir/lib; tar xf -) ;;
    esac
  done
done
