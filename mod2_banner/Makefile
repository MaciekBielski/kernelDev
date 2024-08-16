
# will look for hello.c
obj-m := banner.o

# optional but useful
SCRIPT_DIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
KERNEL_DIR ?= $(SCRIPT_DIR)/../linux_build
SHARED_DIR ?= $(SCRIPT_DIR)/../shared

default: banner

modules help clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(SCRIPT_DIR) $@

banner: modules
	mkdir -p $(SHARED_DIR)/modules
	cp banner.ko $(SHARED_DIR)/modules/


