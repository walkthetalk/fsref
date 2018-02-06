fatload mmc 0 0x3000000 ${kernel_image} && fatload mmc 0 0x32c0000 ${devicetree_image} && fatload mmc 0 0x3300000 ${ramdisk_image}

sf erase 0x800000 0x800000
sf write 0x3000000 0x800000 0x800000

