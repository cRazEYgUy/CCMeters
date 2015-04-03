ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0

THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

BUNDLE_NAME = CCMetersSettings
CCMetersSettings_CFLAGS = -fobjc-arc
CCMetersSettings_FILES = CCMetersSettings.m CCMetersMeterList.m CCMetersColorPicker.m CCMetersColorPickerLinkCell.m CCMetersTitleCell.m ../UIColor-Additions.m
CCMetersSettings_INSTALL_PATH = /Library/PreferenceBundles
CCMetersSettings_FRAMEWORKS = UIKit CoreGraphics Social
CCMetersSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CCMetersSettings.plist$(ECHO_END)
