CINTSYSDIR =  \cint
############################################################
# platform/borlandcc5
#  Platform dependent information for Borland C++ Compiler 5.5
############################################################

#BCCDIR      = c:\Borland\BCC55
#BCCINC      = -I$(BCCDIR)\Include
#BCCLIB      = -L$(BCCDIR)\Lib

# Tools
RM	    = del 
CP	    = copy
KRCC        = bcc32 $(BCCINC)
CC          = bcc32 $(BCCINC)
CPP         = bcc32 -P $(BCCINC)
LD          = bcc32 $(BCCINC) $(BCCLIB)
CPREP       = cpp32 -Sr -Sc $(BCCINC)
CPPPREP     = cpp32 -Sr -Sc $(BCCINC)

# Compiler and linker option
CCDLLOPT    = 
LDDLLOPT    = -WD
OPTIMIZE    = -O2
LDOPT       = 
SHLIB_OPT   = 
SYSMACRO    = -DG__BORLANDCC5 -DG__NEWSTDHEADER
OTHMACRO    = 
SYSIPATH    =

# libraries
MAINO	    = $(CINTSYSDIR)\main\G__cppmain.obj
CINTLIB     = $(CINTSYSDIR)/libcint.lib
READLINEA   = 
APIO	    = Api.obj Class.obj BaseCls.obj Type.obj DataMbr.obj Method.obj MethodAr.obj CallFunc.obj Typedf.obj Apiif.obj Token.obj
RANLIB	    = 
STDLIBS     = cbstrm.obj stdstrct.obj
PLATFORM    = winnt.obj

# source code postfix
CSRCPOST    = .c
CHDRPOST    = .h
CPPSRCPOST  = .cpp
CPPHDRPOST  = .h
OBJPOST     = .obj
DLLPOST     = .dll










##############################################################
# $CINTSYSDIR\src\Makefile.base
#
# Author                 Masaharu Goto 
# Copyright(c) 1995~2001 Masaharu Goto (MXJ02154@niftyserve.objr.jp)
#
# Description:
#   This file is a base of cint library makefile. There are examples
#  of platform dependent setup information under platform
#  directory. Do following to create a complete Makefile,
#
#  $ cat ..\platform\[YourPlatform] Makefile.base > Makefile
#
##############################################################

#CINTSYSDIR   = ..
IPATH    = -I.. $(SYSIPATH)
MACRO    = $(SYSMACRO) $(OTHMACRO) 

############################################################################
# common variable definition 
############################################################################

SECURITYH =     security.h
DLLREVH =       dllrev.h

HEADERS =       common.h global.h fproto.h memtest.h sunos.h ..\G__ci.h 

OBJECTS = 	$(PLATFORM) \
		$(STDLIBS) \
		$(APIO) \
		auxu.obj \
		cast.obj \
		debug.obj \
		decl.obj \
		disp.obj \
		dump.obj \
		end.obj \
		error.obj \
		expr.obj \
		fread.obj \
		func.obj \
		gcoll.obj \
		global1.obj \
		global2.obj \
		g__cfunc.obj \
		ifunc.obj \
		inherit.obj \
		init.obj \
		input.obj \
		intrpt.obj \
		loadfile.obj \
		macro.obj \
		malloc.obj \
		memtest.obj \
		new.obj \
		newlink.obj \
		oldlink.obj \
		opr.obj \
		parse.obj \
		pause.obj \
		pcode.obj \
		pragma.obj \
		quote.obj \
		scrupto.obj \
		shl.obj \
		sizeof.obj \
		struct.obj \
		stub.obj \
		tmplt.obj \
		typedef.obj \
		val2a.obj \
		value.obj \
		var.obj

# Cint core as static library
#$(CINTSYSDIR)\src\G__ci.a : $(OBJECTS)
#	if test -r $(CINTLIB); then rm $(CINTLIB);fi
#	$(AR) $(AROPT) $@ $(OBJECTS);
#	-if [ -f "$(RANLIB)" ]; then $(RANLIB) $(CINTLIB); fi

# Cint core as shared library on Linux
#$(CINTSYSDIR)\libcint.so : $(OBJECTS)
#	$(LD) $(LDDLLOPT) $(SHLIB_OPT) -o $@ $(OBJECTS)

# Cint core as shared library on Windows
$(CINTSYSDIR)\libcint.dll : $(OBJECTS) $(CINTSYSDIR)\main\G__setup.obj
	$(LD) $(LDDLLOPT) $(SHLIB_OPT) -e$@ $(OBJECTS) ..\main\G__setup.obj
	implib -c $(CINTSYSDIR)\libcint.lib $(CINTSYSDIR)\libcint.dll

#	ldlibcint.bat

# Cint core as shared library on HP-UX
#$(CINTSYSDIR)\libcint.sl : $(OBJECTS)
#	$(LD) $(LDDLLOPT) $(SHLIB_OPT) -o $@ $(OBJECTS)

############################################################################
# iostream library
############################################################################
# Common for many old C++ compilers
libstrm.obj : libstrm.cxx libstrm.h $(HEADERS) ..\lib\stream\iostrm.h
	$(CPP) -I..\lib\stream $(IPATH) $(MACRO) $(OPTIMIZE) -c libstrm.cxx

# Microsoft Visual C++ compiler
vcstrm.obj : vcstrm.cxx vcstrm.h $(HEADERS) ..\lib\vcstream\iostrm.h
	$(CPP) -I..\lib\vcstream $(IPATH) $(MACRO) $(OPTIMIZE) -c vcstrm.cxx

# Borland C++ compiler
bcstrm.obj : bcstrm.cxx bcstrm.h $(HEADERS) ..\lib\bcstream\iostrm.h
	$(CPP) -I..\lib\bcstream $(IPATH) $(MACRO) $(OPTIMIZE) -c bcstrm.cxx

# Borland C++ Builder
cbstrm.obj : cbstrm.cpp cbstrm.h $(HEADERS) 
	$(CPP) -I..\\lib\\cbstream $(IPATH) $(MACRO) $(OPTIMIZE) -c cbstrm.cpp

# KAI C++ compiler
kccstrm.obj : kccstrm.cxx kccstrm.h $(HEADERS)
	$(CPP) -I..\lib\kccstream $(IPATH) $(MACRO) $(OPTIMIZE) -c kccstrm.cxx

# Sun CC5 compiler
sunstrm.obj : sunstrm.cxx sunstrm.h $(HEADERS) ..\lib\snstream\iostrm.h
	$(CPP) -I..\lib\snstream $(IPATH) $(MACRO) $(OPTIMIZE) -c sunstrm.cxx

sun5strm.obj : sun5strm.cxx sunstrm.h $(HEADERS) ..\lib\snstream\iostrm.h
	$(CPP) -I..\lib\snstream $(IPATH) $(MACRO) $(OPTIMIZE) -c sun5strm.cxx

# GNU C++ compiler ver 3.xx
gcc3strm.obj : gcc3strm.cxx gcc3strm.h $(HEADERS) ..\lib\gcc3strm\iostrm.h
	$(CPP) -I..\lib\gcc3strm $(IPATH) $(MACRO) $(OPTIMIZE) -c gcc3strm.cxx

# Intel C++ compiler
iccstrm.obj : iccstrm.cxx iccstrm.h $(HEADERS) ..\lib\gcc3strm\iostrm.h
	$(CPP) -I..\lib\iccstrm $(IPATH) $(MACRO) $(OPTIMIZE) -c iccstrm.cxx

# Use interpreted iostream
fakestrm.obj : fakestrm.cxx $(HEADERS)
	$(CPP) $(IPATH) $(MACRO) $(OPTIMIZE) -c fakestrm.cxx

# C compiler only
dmystrm.obj : dmystrm.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c dmystrm.c

############################################################################
# SunOS 4.1 specific source
############################################################################
sunos.obj : sunos.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -DNONANSI -c sunos.c

############################################################################
# NewsOS specific source
############################################################################
newsos.obj : newsos.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -DNONANSI -c newsos.c

############################################################################
# Windows-NT specific source
############################################################################
winnt.obj : winnt.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c winnt.c

############################################################################
# input.c depends on GNU readline library
############################################################################
input.obj : input.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c input.c

############################################################################
# lconv, div_t, ldiv_t, tm struct
############################################################################
stdstrct.obj : stdstrct.c stdstrct.h $(HEADERS)
	$(CC) -I..\\lib\\stdstrct $(IPATH) $(MACRO) $(OPTIMIZE) -c stdstrct.c

dmystrct.obj : dmystrct.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c dmystrct.c

############################################################################
# To install cint core as shared library
############################################################################
$(CINTSYSDIR)\main\G__setup.obj : $(CINTSYSDIR)\main\G__setup.c
	cd $(CINTSYSDIR)\main
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c G__setup.c
	cd $(CINTSYSDIR)\src

############################################################################
# Common sources
############################################################################
auxu.obj : auxu.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c auxu.c

cast.obj : cast.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c cast.c

debug.obj : debug.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c debug.c

decl.obj : decl.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c decl.c

disp.obj : disp.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c disp.c

dmyinit.obj : dmyinit.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c dmyinit.c

dump.obj : dump.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c dump.c

end.obj : end.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c end.c

error.obj : error.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c error.c

expr.obj : expr.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c expr.c

fread.obj : fread.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c fread.c

func.obj : func.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c func.c

gcoll.obj : gcoll.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c gcoll.c

global1.obj : global1.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c global1.c

global2.obj : global2.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c global2.c

g__cfunc.obj : g__cfunc.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c g__cfunc.c

ifunc.obj : ifunc.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c ifunc.c

inherit.obj : inherit.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c inherit.c

init.obj : init.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c init.c

intrpt.obj : intrpt.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c intrpt.c

loadfile.obj : loadfile.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c loadfile.c

macro.obj : macro.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c macro.c

malloc.obj : malloc.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c malloc.c

memtest.obj : memtest.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c memtest.c

new.obj : new.c $(HEADERS) $(SECURITYH) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c new.c

newlink.obj : newlink.c $(HEADERS) $(DLLREVH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c newlink.c

oldlink.obj : oldlink.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c oldlink.c

opr.obj : opr.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c opr.c

parse.obj : parse.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c parse.c

pause.obj : pause.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c pause.c

pcode.obj : pcode.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c pcode.c

pragma.obj : pragma.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c pragma.c

quote.obj : quote.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c quote.c

scrupto.obj : scrupto.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c scrupto.c

sizeof.obj : sizeof.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c sizeof.c

shl.obj : shl.c $(HEADERS) $(DLLREVH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c shl.c

struct.obj : struct.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c struct.c

stub.obj : stub.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c stub.c

tmplt.obj : tmplt.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c tmplt.c

typedef.obj : typedef.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c typedef.c

val2a.obj : val2a.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c val2a.c

value.obj : value.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c value.c

var.obj : var.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c var.c

############################################################################
# ERTTI API
############################################################################

APIHEADER = Api.h \
	  Class.h \
	  BaseCls.h \
	  Type.h \
	  DataMbr.h \
	  Method.h \
	  MethodAr.h \
	  CallFunc.h \
	  Typedf.h \
	  Apiif.h \
          Token.h \
	  ..\G__ci.h

Token.obj : $(APIHEADER) Token.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Token.cxx

Typedf.obj : $(APIHEADER) Typedf.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Typedf.cxx

Class.obj : $(APIHEADER) Class.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Class.cxx

BaseCls.obj : $(APIHEADER) BaseCls.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c BaseCls.cxx
	
Type.obj : $(APIHEADER) Type.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Type.cxx

DataMbr.obj : $(APIHEADER) DataMbr.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c DataMbr.cxx

Method.obj : $(APIHEADER) Method.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Method.cxx

MethodAr.obj : $(APIHEADER) MethodAr.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c MethodAr.cxx

CallFunc.obj : $(APIHEADER) CallFunc.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c CallFunc.cxx

Api.obj : $(APIHEADER) Api.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Api.cxx

Apiif.obj : $(APIHEADER) Apiif.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Apiif.cxx


############################################################################
# clean
############################################################################
clean :
	$(RM) *.obj
	$(RM) *.dll
	$(RM) ..\libcint.*
	$(RM) ..\main\*.obj

