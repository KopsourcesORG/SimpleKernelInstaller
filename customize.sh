# Simple Kernel Installer
# By KeJia

# Kernel Name
name=Example Kernel
# Device Codename
devicename1=example1
devicename2=example2
devicename3=example3

# DO NOT MODIFY THIS PART!
. $MODPATH/tools/env_prepare.sh
check_devicename
install
