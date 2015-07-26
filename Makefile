ARCHS = armv7 arm64
THEOS_BUILD_DIR = Packages
include theos/makefiles/common.mk

TWEAK_NAME = VolumeSlider
VolumeSlider_FILES = VolumeSlider.xm
VolumeSlider_LIBRARIES = substrate flipswitch
VolumeSlider_FRAMEWORKS = Foundation UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += volumesliderprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
