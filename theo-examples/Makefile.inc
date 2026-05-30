ifndef DAFNY_HOME
$(error Variable DAFNY_HOME is not set)
endif
ifndef JAVA_HOME
$(error Variable JAVA_HOME is not set)
endif

ifeq ($(OS),Windows_NT)
DAFNY      = $(subst \,/,$(DAFNY_HOME))/dafny.exe
JAVA       = $(subst \,/,$(JAVA_HOME))/bin/java.exe
TARGET_EXT = .exe
PSEP       = ;
## $(MSYS_HOME)\usr\bin\{cp.exe, make.exe, wget.exe}
CP         = /usr/bin/cp.exe
ECHO       = /usr/bin/echo.exe
FIND       = /usr/bin/find.exe
MKDIR      = /usr/bin/mkdir.exe
RM         = /usr/bin/rm.exe
TOUCH      = /usr/bin/touch.exe
WGET       = /usr/bin/wget
else
DAFNY      = $(DAFNY_HOME)/bin/dafny
JAVA       = $(JAVA_HOME)/bin/java
TARGET_EXT =
PSEP       = :
CP         = cp
ECHO       = echo
FIND       = find
MKDIR      = mkdir
MVN        = mvn
RM         = rm
TOUCH      = touch
WGET       = wget
endif
