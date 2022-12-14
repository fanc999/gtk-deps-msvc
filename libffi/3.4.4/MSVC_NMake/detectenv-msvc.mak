# Change this (or specify PREFIX= when invoking this NMake Makefile) if
# necessary, so that the results of the build will be copied to its
# appropriate subdirectories upon 'install'.

!if "$(PREFIX)" == ""
PREFIX = ..\..\vs$(VSVER)\$(PLAT)
!endif

# Location of the Python interpreter, to help generate pkg-config files
# for this package.

!if "$(PYTHON)" == ""
PYTHON = python
!endif

# The items below this line should not be changed, unless one is maintaining
# the NMake Makefiles.  The exception is for the CFLAGS_ADD line(s) where one
# could use his/her desired compiler optimization flags, if he/she knows what is
# being done.

# Check to see we are configured to build with MSVC (MSDEVDIR, MSVCDIR or
# VCINSTALLDIR) or with the MS Platform SDK (MSSDK or WindowsSDKDir)
!if !defined(VCINSTALLDIR) && !defined(WINDOWSSDKDIR)
MSG = ^
This Makefile is only for Visual Studio 2008 and later.^
You need to ensure that the Visual Studio Environment is properly set up^
before running this Makefile.
!error $(MSG)
!endif

ERRNUL  = 2>NUL
_HASH=^#

!if ![echo VCVERSION=_MSC_VER > vercl.x] \
    && ![echo $(_HASH)if defined(_M_IX86) >> vercl.x] \
    && ![echo PLAT=Win32 >> vercl.x] \
    && ![echo $(_HASH)elif defined(_M_AMD64) >> vercl.x] \
    && ![echo PLAT=x64 >> vercl.x] \
    && ![echo $(_HASH)elif defined(_M_ARM64) >> vercl.x] \
    && ![echo PLAT=arm64 >> vercl.x] \
    && ![echo $(_HASH)endif >> vercl.x] \
    && ![cl -nologo -TC -P vercl.x $(ERRNUL)]
!include vercl.i
!if ![echo VCVER= ^\> vercl.vc] \
    && ![set /a $(VCVERSION) / 100 - 6 >> vercl.vc]
!include vercl.vc
!endif
!endif
!if ![del $(ERRNUL) /q/f vercl.x vercl.i vercl.vc]
!endif

VSVER = 0
PDBVER = 0
VSVER_SUFFIX = 0

!if $(VCVERSION) > 1499 && $(VCVERSION) < 1600
PDBVER = 9
!elseif $(VCVERSION) > 1599 && $(VCVERSION) < 1700
PDBVER = 10
!elseif $(VCVERSION) > 1699 && $(VCVERSION) < 1800
PDBVER = 11
!elseif $(VCVERSION) > 1799 && $(VCVERSION) < 1900
PDBVER = 12
!elseif $(VCVERSION) > 1899 && $(VCVERSION) < 2000
PDBVER = 14
!elseif $(VCVERSION) > 1909 && $(VCVERSION) < 1920
VSVER_SUFFIX = 1
VSVER = 15
!elseif $(VCVERSION) > 1919 && $(VCVERSION) < 1930
VSVER_SUFFIX = 2
VSVER = 16
!elseif $(VCVERSION) > 1929 && $(VCVERSION) < 2000
VSVER_SUFFIX = 3
VSVER = 17
!endif
!if "$(VSVER)" == "0" && $(PDBVER) > 0
VSVER = $(PDBVER)
!endif

!if "$(VSVER)" == "0"
MSG = ^
This NMake Makefile set supports Visual Studio^
9 (2008) through 17 (2022).  Your Visual Studio^
version is not supported.
!error $(MSG)
!endif

VALID_CFGSET = FALSE
!if "$(CFG)" == "release" || "$(CFG)" == "Release" || "$(CFG)" == "debug" || "$(CFG)" == "Debug"
VALID_CFGSET = TRUE
!endif

# One may change these items, but be sure to test
# the resulting binaries
!if "$(CFG)" == "release" || "$(CFG)" == "Release"
CFLAGS_ADD = /MD /O2 /MP /GL
!if "$(VSVER)" != "9"
CFLAGS_ADD = $(CFLAGS_ADD) /d2Zi+
!endif
!if $(VSVER) >= 14
CFLAGS_ADD = $(CFLAGS_ADD) /utf-8
!endif
!else
CFLAGS_ADD = /MDd /Od
!endif

!if "$(PLAT)" == "x64"
LDFLAGS_ARCH = /machine:x64
!elseif "$(PLAT)" == "arm64"
LDFLAGS_ARCH = /machine:arm64
!else
LDFLAGS_ARCH = /machine:x86
!endif

!if "$(VALID_CFGSET)" == "TRUE"
CFLAGS = $(CFLAGS_ADD) /W3 /Zi
LDFLAGS_BASE = $(LDFLAGS_ARCH) /libpath:$(PREFIX)\lib /DEBUG

!if "$(CFG)" == "debug" || "$(CFG)" == "Debug"
ARFLAGS = $(LDFLAGS_ARCH)
LDFLAGS = $(LDFLAGS_BASE)
!else
ARFLAGS = $(LDFLAGS_ARCH) /LTCG
LDFLAGS = $(LDFLAGS_BASE) /LTCG /opt:ref
!endif
!endif
