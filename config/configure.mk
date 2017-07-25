OS_NAME =
CORE_JBUILD_FILE =
CLIBS_FILE =
CFLAGS_FILE =

UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
  OS_NAME = LINUX
  CORE_JBUILD_FILE = src/core/jbuild.x11
  CLIBS_FILE = config/c_libs.x11
  CFLAGS_FILE = config/c_flags.x11
endif
ifeq ($(UNAME), Darwin)
  OS_NAME = OSX
  CORE_JBUILD_FILE = src/core/jbuild.cocoa
  CLIBS_FILE = config/c_libs.cocoa
  CFLAGS_FILE = config/c_flags.cocoa
endif
ifeq ($(UNAME), windows32)
  OS_NAME = WIN
  CORE_JBUILD_FILE = src/core/jbuild.win
  CLIBS_FILE = config/c_libs.win
  CFLAGS_FILE = config/c_flags.win
endif
 