PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Enable ADB authentication and root
ADDITIONAL_DEFAULT_PROPERTIES += \
    ro.secure=0 \
    ro.adb.secure=0 \
    persist.sys.root_access=3

# OSE Tweaks
PRODUCT_PROPERTY_OVERRIDES += \
    pm.sleep.mode=1 \
    wifi.supplicant_scan_interval=180 \
    windowsmgr.max_events_per_sec=150 \
    debug.performance.tuning=1 \
    ro.ril.power_collapse=1 \
    persist.service.lgospd.enable=0 \
    persist.service.pcsync.enable=0 \
    ro.facelock.black_timeout=400 \
    ro.facelock.det_timeout=1500 \
    ro.facelock.rec_timeout=2500 \
    ro.facelock.lively_timeout=2500 \
    ro.facelock.est_max_time=600 \
    ro.facelock.use_intro_anim=false \
    dalvik.vm.dex2oat-flags "--compiler-filter=interpret-only" \
    dalvik.vm.profiler=1 \
    dalvik.vm.isa.arm.features=lpae,div

# Disable excessive dalvik debug messages
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.debug.alloc=0

# Chromium Prebuilt
ifeq ($(PRODUCT_PREBUILT_WEBVIEWCHROMIUM),yes)
-include prebuilts/chromium/$(TARGET_DEVICE)/chromium_prebuilt.mk
endif

# Prebuilt Apks
PRODUCT_COPY_FILES += \
    vendor/ose/prebuilt/common/app/ESFile.apk:system/app/ESFile.apk

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/ose/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/ose/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/ose/prebuilt/common/bin/50-ose.sh:system/addon.d/50-ose.sh \
    vendor/ose/prebuilt/common/bin/99-backup.sh:system/addon.d/99-backup.sh \
    vendor/ose/prebuilt/common/etc/backup.conf:system/etc/backup.conf

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/ose/prebuilt/common/bin/otasigcheck.sh:system/bin/otasigcheck.sh

# OSE-specific init file
PRODUCT_COPY_FILES += \
    vendor/ose/prebuilt/common/etc/init.local.rc:root/init.ose.rc

# Copy latinime for gesture typing
PRODUCT_COPY_FILES += \
    vendor/ose/prebuilt/common/lib/libjni_latinimegoogle.so:system/lib/libjni_latinimegoogle.so

# Copy libgif for Nova Launcher 3.0
PRODUCT_COPY_FILES += \
    vendor/ose/prebuilt/common/lib/libgif.so:system/lib/libgif.so

# SELinux filesystem labels
PRODUCT_COPY_FILES += \
    vendor/ose/prebuilt/common/etc/init.d/50selinuxrelabel:system/etc/init.d/50selinuxrelabel

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/ose/prebuilt/common/etc/mkshrc:system/etc/mkshrc \
    vendor/ose/prebuilt/common/etc/sysctl.conf:system/etc/sysctl.conf

PRODUCT_COPY_FILES += \
    vendor/ose/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/ose/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit \
    vendor/ose/prebuilt/common/bin/sysinit:system/bin/sysinit

# Embed SuperUser
SUPERUSER_EMBEDDED := true

# Required packages
PRODUCT_PACKAGES += \
    CellBroadcastReceiver \
    Development \
    Superuser \
    su

# Optional packages
PRODUCT_PACKAGES += \
    Basic \
    LiveWallpapersPicker \
    PhaseBeam

# AudioFX
PRODUCT_PACKAGES += \
    AudioFX

# Extra Optional packages
PRODUCT_PACKAGES += \
    BluetoothExt \
    DashClock \
    LatinIME \
    LockClock \
    OSELauncher

# Extra tools
PRODUCT_PACKAGES += \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat

ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libstagefright_soft_ffmpegadec \
    libstagefright_soft_ffmpegvdec \
    libFFmpegExtractor \
    libnamparser
endif

# easy way to extend to add more packages
-include vendor/extra/product.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/ose/overlay/common

# Boot animation include
ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))

# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/ose/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

PRODUCT_COPY_FILES += \
    vendor/ose/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
endif

# Versioning System
# OSELP first version.
PRODUCT_VERSION_MAJOR = 5.0.2
PRODUCT_VERSION_MINOR = Build
PRODUCT_VERSION_MAINTENANCE = 1
ifdef OSE_BUILD_EXTRA
    OSE_POSTFIX := -$(OSE_BUILD_EXTRA)
endif
ifndef OSE_BUILD_TYPE
    OSE_BUILD_TYPE := UNOFFICIAL
    PLATFORM_VERSION_CODENAME := UNOFFICIAL
    OSE_POSTFIX := -$(shell date +"%Y%m%d-%H%M")
endif

# Set all versions
OSE_VERSION := OSE-$(PRODUCT_VERSION_MAJOR)-$(OSE_BUILD_TYPE)-$(shell date +%m%d%Y-%H%M)
OSE_MOD_VERSION := OSE-$(OSE_BUILD)-$(PRODUCT_VERSION_MAJOR)-$(OSE_BUILD_TYPE)-$(shell date +%m%d%Y-%H%M)

# HFM Files
PRODUCT_COPY_FILES += \
    vendor/ose/prebuilt/etc/hosts.alt:system/etc/hosts.alt \
    vendor/ose/prebuilt/etc/hosts.og:system/etc/hosts.og

PRODUCT_PROPERTY_OVERRIDES += \
    BUILD_DISPLAY_ID=$(BUILD_ID) \
    ose.ota.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE) \
    ro.ose.version=$(OSE_VERSION) \
    ro.modversion=$(OSE_MOD_VERSION) \
    ro.ose.buildtype=$(OSE_BUILD_TYPE)

EXTENDED_POST_PROCESS_PROPS := vendor/ose/tools/ose_process_props.py

