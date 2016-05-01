include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Vili
Vili_FILES = vilRootListController.m
Vili_INSTALL_PATH = /Library/PreferenceBundles
Vili_FRAMEWORKS = UIKit
Vili_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Vili.plist$(ECHO_END)
