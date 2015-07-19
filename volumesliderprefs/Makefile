ARCHS = armv7 arm64
include theos/makefiles/common.mk

BUNDLE_NAME = VolumeSliderPrefs
VolumeSliderPrefs_FILES = VolumeSliderPrefs.mm
VolumeSliderPrefs_INSTALL_PATH = /Library/PreferenceBundles
VolumeSliderPrefs_FRAMEWORKS = Foundation UIKit
VolumeSliderPrefs_PRIVATE_FRAMEWORKS = Preferences Twitter

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/VolumeSliderPrefs.plist$(ECHO_END)
