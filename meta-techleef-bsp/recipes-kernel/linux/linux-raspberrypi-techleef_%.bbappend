FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Enable Pi 5 specific drivers
KERNEL_MODULE_AUTOLOAD:append:raspberrypi5-techleef = " bcm2712-pcie"

# Custom kernel configuration
SRC_URI += "file://techleef.cfg"

do_configure:append() {
    # Add Pi 5 specific configs
    echo "CONFIG_PCIE_BRCMSTB=y" >> ${B}/.config
    echo "CONFIG_BCM2712_PCIE=y" >> ${B}/.config
}