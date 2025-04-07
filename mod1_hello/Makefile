
# will look for hello.c
obj-m := hello.o
# * for multiple modules generated out ot the same Makefile
# obj-m += second.o
# * or written together
# obj-m := hello.o second.o


# In case a final object has multiple sources
hello-objs := hello_src1.o

# optional but useful
SCRIPT_DIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
KERNEL_DIR ?= $(SCRIPT_DIR)/../build/linux
SHARED_DIR ?= $(SCRIPT_DIR)/../shared

default: hello

modules help clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(SCRIPT_DIR) $@

hello: modules
	mkdir -p $(SHARED_DIR)/modules
	cp hello.ko $(SHARED_DIR)/modules/

