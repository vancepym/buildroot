################################################################################
#
# remmina
#
################################################################################

REMMINA_VERSION = v1.1.2
REMMINA_SITE = $(call github,FreeRDP,Remmina,$(REMMINA_VERSION))
REMMINA_LICENSE = GPLv2+ with OpenSSL exception
REMMINA_LICENSE_FILES = COPYING LICENSE LICENSE.OpenSSL

REMMINA_CONF_OPTS = \
	-DWITH_AVAHI=OFF \
	-DWITH_APPINDICATOR=OFF \
	-DWITH_TELEPATHY=OFF \
	-DWITH_GNOMEKEYRING=OFF

REMMINA_DEPENDENCIES = \
	libgtk3 libgcrypt libssh libvncserver freerdp

ifeq ($(BR2_NEEDS_GETTEXT_IF_LOCALE),y)
REMMINA_DEPENDENCIES += gettext

define REMMINA_POST_PATCH_FIXINTL
	$(SED) 's/$${GTK_LIBRARIES}/$${GTK_LIBRARIES} -lintl/' \
		$(@D)/remmina/CMakeLists.txt
endef

REMMINA_POST_PATCH_HOOKS += REMMINA_POST_PATCH_FIXINTL
endif

$(eval $(cmake-package))
