
obj-m := widget.o

# optional but useful
SCRIPT_DIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
KERNEL_DIR ?= $(SCRIPT_DIR)/../linux_build
SHARED_DIR ?= $(SCRIPT_DIR)/../shared

default: widget

modules help clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(SCRIPT_DIR) $@

widget: modules
	mkdir -p $(SHARED_DIR)/modules
	cp widget.ko $(SHARED_DIR)/modules/

