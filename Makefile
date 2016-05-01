include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Vili
Vili_FILES = Tweak.xm $(wildcard CBAutoScrollLabel/*.m)
Vili_FRAMEWORKS = Foundation UIKit QuartzCore
Vili_PRIVATE_FRAMEWORKS = MediaRemote
SHARED_CFLAGS = -fobjc-arc

GO_EASY_ON_ME = 1;

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += vili
include $(THEOS_MAKE_PATH)/aggregate.mk
