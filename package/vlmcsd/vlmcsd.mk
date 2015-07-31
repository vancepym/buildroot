################################################################################
#
# vlmcsd
#
################################################################################

VLMCSD_VERSION = master
VLMCSD_SITE = $(call github,vancepym,vlmcsd,$(VLMCSD_VERSION))

define VLMCSD_BUILD_CMDS
	$(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D) all
endef

define VLMCSD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/vlmcsd \
		$(TARGET_DIR)/usr/sbin
	$(INSTALL) -D -m 0755 $(@D)/vlmcs \
		$(TARGET_DIR)/usr/sbin
endef

define VLMCSD_INSTALL_INIT_SYSV
	$(INSTALL) -m 755 -D package/vlmcsd/S49vlmcsd \
		$(TARGET_DIR)/etc/init.d/S49vlmcsd
endef

$(eval $(generic-package))
