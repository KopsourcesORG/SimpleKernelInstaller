# Simple Kernel Installer
##### Flash Android Kernel in Recovery/Magisk/KernelSU/APatch/KernelFlasher.
##### SKI Anywhere!
---
* Keep It Simple Stupid.
---
* Supported kernel/dtb format (sort by flashing order)
```
*Image*-dtb
*Image*
*.dtb
(If the first one exists, the last two will not be installed)
```
* Supported dtbo format:
```
*dtbo*.img
```
---
##### Usage:
* Put your kernel (*Image*-dtb or *Image*) into this package.
* Put your dtb (*.dtb) into this package (if you have).
* Put your dtbo (*dtbo*.img) into this package (if you have).
* Change The Kernel Name and Devicename in customize.sh
* Flash it in Recovery(3rd-party recoverys only), Magisk(as a module), KernelSU(as a module), APatch(as a apm module) or KernelFlasher(as a AK3 package)!
---
##### Credits:
* [Magisk](https://github.com/topjohnwu/Magisk): We used magiskboot and some functions from magisk.
* [Anykernel3](https://github.com/osm0sis/AnyKernel3): We used device check from Anykernel3.
