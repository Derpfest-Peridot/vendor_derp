# Allow vendor/extra to override any property by setting it first
$(call inherit-product-if-exists, vendor/extra/product.mk)

PRODUCT_BRAND ?= DerpFest

PRODUCT_BUILD_PROP_OVERRIDES += DateUtc=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

ifeq ($(TARGET_BUILD_VARIANT),eng)
# Disable ADB authentication
PRODUCT_SYSTEM_PROPERTIES += ro.adb.secure=0
else
# Enable ADB authentication
PRODUCT_SYSTEM_PROPERTIES += ro.adb.secure=1

# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_PROPERTIES += persist.sys.strictmode.disable=true
endif

# Backup Tool
ifneq ($(TARGET_EXCLUDE_BACKUPTOOL),true)
PRODUCT_COPY_FILES += \
    vendor/derp/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/derp/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/derp/prebuilt/common/bin/50-derp.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-derp.sh

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/addon.d/50-derp.sh

ifneq ($(strip $(AB_OTA_PARTITIONS) $(AB_OTA_POSTINSTALL_CONFIG)),)
PRODUCT_COPY_FILES += \
    vendor/derp/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/derp/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/derp/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh

PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/backuptool_ab.sh \
    system/bin/backuptool_ab.functions \
    system/bin/backuptool_postinstall.sh
endif
endif

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.ota.allow_downgrade=true
endif

# DerpFest-specific init rc file
PRODUCT_COPY_FILES += \
    vendor/derp/prebuilt/common/etc/init/init.derp-system_ext.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.derp-system_ext.rc

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_PRODUCT)/usr/keylayout/Vendor_045e_Product_0719.kl

# Pixel customization
TARGET_IS_PIXEL ?= false
TARGET_PIXEL_STAND_SUPPORTED ?= false
TARGET_SUPPORTS_QUICK_TAP ?= true
TARGET_USES_MINI_GAPPS ?= false
TARGET_USES_PICO_GAPPS ?= false

# Face Unlock
TARGET_FACE_UNLOCK_SUPPORTED ?= $(TARGET_SUPPORTS_64_BIT_APPS)
ifeq ($(TARGET_FACE_UNLOCK_SUPPORTED),true)
    PRODUCT_PACKAGES += \
        ParanoidSense
    PRODUCT_SYSTEM_EXT_PROPERTIES += \
        ro.face.sense_service=true
    PRODUCT_COPY_FILES += \
        frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml
else
    PRODUCT_PACKAGES += \
        SettingsGoogleFutureFaceEnroll
endif

# Enforce privapp-permissions whitelist
PRODUCT_SYSTEM_PROPERTIES += \
    ro.control_privapp_permissions?=enforce

# Support many users/work profiles
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.sys.max_profiles?=16 \
    fw.max_users=32

# Include extra packages
include vendor/derp/config/packages.mk

# Permissions for Google product apps
PRODUCT_COPY_FILES += \
    vendor/derp/prebuilt/common/etc/permissions/default-permissions-product.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/default-permissions/default-permissions-product.xml

# Livedisplay
PRODUCT_COPY_FILES += \
    vendor/derp/prebuilt/common/etc/permissions/privapp-permissions-lineagehw.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-lineagehw.xml

# ANGLE
PRODUCT_COPY_FILES += \
    vendor/derp/prebuilt/common/etc/permissions/product-privapp-permissions-aosp.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/product-privapp-permissions-aosp.xml

# DerpFest-specific broadcast actions whitelist
PRODUCT_COPY_FILES += \
    vendor/derp/prebuilt/common/etc/permissions/derpfest-sysconfig.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/derpfest-sysconfig.xml

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

# Disable iorapd
PRODUCT_SYSTEM_PROPERTIES += \
    ro.iorapd.enable=false

# Include AOSP initial package stopped states.
PRODUCT_PACKAGES += \
    initial-package-stopped-states-aosp.xml

# Screen Resolution
TARGET_SCREEN_WIDTH ?= 1080
TARGET_SCREEN_HEIGHT ?= 1920

PRODUCT_COPY_FILES += \
    vendor/derp/prebuilt/common/etc/init/init.derp-updater.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.derp-updater.rc

PRODUCT_COPY_FILES += \
    vendor/derp/prebuilt/common/etc/init/init.openssh.rc:$(TARGET_COPY_OUT_PRODUCT)/etc/init/init.openssh.rc

# Google Assistant
PRODUCT_PRODUCT_PROPERTIES += \
    ro.opa.eligible_device?=true

# Storage manager
PRODUCT_SYSTEM_PROPERTIES += \
    ro.storage_manager.enabled=true

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    procmem

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/bin/procmem
endif

# Blur
ifndef TARGET_NOT_USES_BLUR
    USES_BLUR=1
endif

ifeq ($(TARGET_NOT_USES_BLUR),true)
    USES_BLUR=0
else
    USES_BLUR=1
endif

PRODUCT_PRODUCT_PROPERTIES += \
    ro.sf.blurs_are_expensive=$(USES_BLUR) \
    ro.surface_flinger.supports_background_blur=$(USES_BLUR) \
    persist.sysui.disableBlur=$(shell echo $$((1 - $(USES_BLUR))))

# BtHelper
PRODUCT_PACKAGES += \
    BtHelper

ifneq ($(filter %_lemonades %_kebab,$(TARGET_PRODUCT)),)
PRODUCT_PACKAGES += DerpFestRemovePackages
endif

# DerpFest Framework
PRODUCT_PACKAGES += \
    DerpFestManifest \
    framework-derpfest

PRODUCT_PACKAGES += \
    DerpFestSystemUI

# Root
PRODUCT_PACKAGES += \
    adb_root

# TextClassifier
PRODUCT_PACKAGES += \
    libtextclassifier_annotator_en_model \
    libtextclassifier_annotator_universal_model \
    libtextclassifier_actions_suggestions_universal_model \
    libtextclassifier_lang_id_model

# SystemUI
PRODUCT_DEXPREOPT_SPEED_APPS += \
    DerpLauncherQuickStep \
    Settings \
    SystemUI

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    dalvik.vm.systemuicompilerfilter=speed

# Disable RescueParty due to high risk of data loss
PRODUCT_PRODUCT_PROPERTIES += \
	persist.sys.disable_rescue=true

# Don't compile SystemUITests
EXCLUDE_SYSTEMUI_TESTS := true

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/derp/overlay/no-rro
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/derp/overlay/common \
    vendor/derp/overlay/no-rro

-include $(WORKSPACE)/build_env/image-auto-bits.mk

# Art
include vendor/derp/config/art.mk

# Versioning
include vendor/derp/config/version.mk
