ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0

THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

BUNDLE_NAME = CCMeters
CCMeters_CFLAGS = -fobjc-arc
CCMeters_FILES = CCMetersSection.m UIColor-Additions.m
CCMeters_INSTALL_PATH = /Library/CCLoader/Bundles
CCMeters_FRAMEWORKS = Foundation UIKit CoreGraphics


include $(THEOS_MAKE_PATH)/bundle.mk

SUBPROJECTS += Settings
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
