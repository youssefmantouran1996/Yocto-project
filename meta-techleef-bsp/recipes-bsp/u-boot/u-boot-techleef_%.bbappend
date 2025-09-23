# U-Boot configuration for Raspberry Pi 5
UBOOT_MACHINE:raspberrypi5-techleef = "rpi_5_defconfig"

# Additional firmware for Pi 5
SRC_URI:append:raspberrypi5-techleef = " \
    file://boot.txt \
    file://config.txt \
"