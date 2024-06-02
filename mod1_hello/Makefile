
# will look for hello.c
obj-m := hello.o

# optional but useful
SCRIPT_DIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
KERNEL_DIR ?= $(SCRIPT_DIR)/../linux
SHARED_DIR ?= $(SCRIPT_DIR)/../shared

default: hello

modules help clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(SCRIPT_DIR) $@

hello: modules
	mkdir -p $(SHARED_DIR)/modules
	cp hello.ko $(SHARED_DIR)/modules/

