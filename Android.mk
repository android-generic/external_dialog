#
# Copyright (C) 2023 BlissLabs
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, distribute
# with modifications, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#

LOCAL_PATH := $(call my-dir)

DIALOG_CFLAGS := -D_DEFAULT_SOURCE -D_XOPEN_SOURCE=500 \
				-D_XOPEN_SOURCE_EXTENDED -DHAVE_CONFIG_H -DLOCALEDIR=\"/vendor/etc/locale\"

# build dialog
include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(call all-c-files-under,.)
LOCAL_SRC_FILES := $(filter-out samples/install/setup.c, $(LOCAL_SRC_FILES))

LOCAL_CFLAGS := $(DIALOG_CFLAGS)
LOCAL_MODULE := dialog
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SHARED_LIBRARIES := libncurses

intermediates := $(call local-generated-sources-dir)

DIALOG_CONFIG_OPTS := --without-pkg-config --with-ncursesw
DIALOG_CONFIG_STATUS := $(intermediates)/config.status
$(DIALOG_CONFIG_STATUS): $(LOCAL_PATH)/configure
	@rm -rf $(@D); mkdir -p $(@D)
	export PATH=/usr/bin:/bin:$$PATH; \
	for f in $(<D)/*; do if [ -d $$f ]; then \
		mkdir -p $(@D)/`basename $$f`; ln -sf `realpath --relative-to=$(@D)/d $$f/*` $(@D)/`basename $$f`; \
	else \
		ln -sf `realpath --relative-to=$(@D) $$f` $(@D); \
	fi; done;
	export PATH=/usr/bin:/bin:$$PATH; \
	cd $(@D); ./$(<F) $(DIALOG_CONFIG_OPTS) && \
	./$(<F) $(DIALOG_CONFIG_OPTS) --prefix=/system || \
		(rm -rf $(@F); exit 1)

LOCAL_GENERATED_SOURCES := $(DIALOG_CONFIG_STATUS)
LOCAL_C_INCLUDES := $(intermediates)

LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_C_INCLUDES)

include $(BUILD_EXECUTABLE)
