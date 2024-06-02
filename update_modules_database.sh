#!/bin/sh

ln -fs /shared/modules/*.ko /lib/modules/$(uname -r)/
depmod -a

