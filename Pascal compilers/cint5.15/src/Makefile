CINTSYSDIR =  /Users/gotom/src/cint
############################################################
# platform/macos_gcc3_v3_v6
#  Platform dependent information for g++ with mininum config
#  By Alessandro Pistocchi
#  It seems like this setup is the absolute minimum. I believe
#  we can explore much more with MacOSX. Probably, you can get
#  as much as Linux_xxx. Contribution will be greatly appreciated.
#  Cint ver6 features turned on
############################################################

# Tools
RM	    = rm -f
CP	    = cp
AR	    = ar
AROPT       = clq
KRCC        = cc
CC          = gcc
CPP         = g++
LD          = g++
CPREP       = gcc -E -C
CPPPREP     = g++ -E -C

# Compiler and linker option
CCDLLOPT    = -fno-common
LDDLLOPT    = -bundle -flat_namespace -undefined suppress
OPTIMIZE    = -g -DG__ASM_DBG
LDOPT       = -lm -ldl -lcurses 
SYSMACRO    = -DG__SHAREDLIB -DG__OSFDLL -DG__ANSI -DG__ERRORCALLBACK -DG__MACOSX__ -DG__SIGNEDCHAR -DG__LONGBUF -DG__NEWSTDHEADER -DG__CINT_VER6 -DG__NATIVELONGLONG
OTHMACRO   = -DG__APPLE -DG__P2FCAST -DG__NOPOWEROPR -DG__EXCEPTIONWRAPPER -DG__STD_EXCEPTION 
SYSIPATH    =

# libraries
MAINO	    = $(CINTSYSDIR)/main/G__cppmain.o
CINTLIB     = $(CINTSYSDIR)/src/G__ci.a
READLINEA   = $(CINTSYSDIR)/readline/libreadline.a
APIO	    = Api.o Class.o BaseCls.o Type.o DataMbr.o Method.o MethodAr.o CallFunc.o Typedf.o Apiif.o Token.o
RANLIB	    = /usr/bin/ranlib
STDLIBS     = gcc3strm.o stdstrct.o
PLATFORM    =  
CINT_V6     = bc_autoobj.o bc_cfunc.o bc_inst.o bc_parse.o bc_reader.o bc_type.o bc_exec.o bc_vtbl.o bc_eh.o bc_debug.o bc_assign.o

# source code postfix
CSRCPOST    = .c
CHDRPOST    = .h
CPPSRCPOST  = .C
CPPHDRPOST  = .h
OBJPOST     = .o
DLLPOST     = .so
 



##########################################################
# Control default behavior of cint command line input
##########################################################
#INPUTMODE = C++
#INPUTMODE = root
INPUTMODE = cint
#INPUTMODELOCK = on
INPUTMODELOCK = off
##############################################################
# $CINTSYSDIR/src/Makefile.base
#
# Author                 Masaharu Goto 
# Copyright(c) 1995~2003 Masaharu Goto (MXJ02154@niftyserve.or.jp)
#
# Description:
#   This file is a base of cint library makefile. There are examples
#  of platform dependent setup information under platform
#  directory. Do following to create a complete Makefile,
#
#  $ cat ../platform/[YourPlatform] Makefile.base > Makefile
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

HEADERS =       common.h global.h fproto.h memtest.h sunos.h ../G__ci.h 

OBJECTS = 	$(PLATFORM) \
		$(STDLIBS) \
		$(APIO) \
		$(CINT_V6) \
		auxu.o \
		cast.o \
		debug.o \
		decl.o \
		disp.o \
		dump.o \
		end.o \
		error.o \
		expr.o \
		fread.o \
		func.o \
		gcoll.o \
		global1.o \
		global2.o \
		g__cfunc.o \
		ifunc.o \
		inherit.o \
		init.o \
		input.o \
		intrpt.o \
		loadfile.o \
		macro.o \
		malloc.o \
		memtest.o \
		new.o \
		newlink.o \
		oldlink.o \
		opr.o \
		parse.o \
		pause.o \
		pcode.o \
		pragma.o \
		quote.o \
		scrupto.o \
		shl.o \
		sizeof.o \
		struct.o \
		stub.o \
		tmplt.o \
		typedef.o \
		val2a.o \
		value.o \
		var.o

# Cint core as static library
$(CINTSYSDIR)/src/G__ci.a : $(OBJECTS)
	if test -r $(CINTLIB); then rm $(CINTLIB);fi
	$(AR) $(AROPT) $@ $(OBJECTS);
	-if [ -f "$(RANLIB)" ]; then $(RANLIB) $(CINTLIB); fi

# Cint core as shared library on Linux
$(CINTSYSDIR)/libcint.so : $(OBJECTS)
	$(LD) $(LDDLLOPT) $(SHLIB_OPT) -o $@ $(OBJECTS)

# Cint core as shared library on HP-UX
$(CINTSYSDIR)/libcint.sl : $(OBJECTS)
	$(LD) $(LDDLLOPT) $(SHLIB_OPT) -o $@ $(OBJECTS)

# Cint core as shared library on Cygwin
$(CINTSYSDIR)/libcint.dll : $(OBJECTS)
	$(LD) $(LDDLLOPT) $(SHLIB_OPT) -o $@ $(OBJECTS) $(LDOPT)
	$(DLLTOOL) --as=$(AS) --dllname $@ --def libcint.def --output-lib $(CINTSYSDIR)/libcint.lib

#	$(LDDLL) -s --base-file libcint.base $(LDDLLOPT) $(SHLIB_OPT) --dll -o $@ $(OBJECTS) $(LIBS) -e G__cygwin_dll_entry
#	$(DLLTOOL) --as=$(AS) --dllname $(OBJECT) --def libcint.def --base-file libcint.base --output-exp libcint.exp
#	$(LDDLL) -s --base-file libcint.base libcint.exp $(LDDLLOPT) $(SHLIB_OPT) --dll -o $@ $(OBJECTS) $(LIBS) -e G__cygwin_dll_entry
#	$(DLLTOOL) --as=$(AS) --dllname $(OBJECT) --def libcint.def --base-file libcint.base --output-exp libcint.exp
#	$(LDDLL) -s libcint.exp $(LDDLLOPT) $(SHLIB_OPT) --dll -o $@ $(OBJECTS) $(LIBS) -e G__cygwin_dll_entry
#	$(DLLTOOL) --as=$(AS) --dllname $@ --def libcint.def --output-lib $(CINTSYSDIR)/libcint.lib

############################################################################
# iostream library
############################################################################
# Common for many old C++ compilers
libstrm.o : libstrm.cxx libstrm.h $(HEADERS) ../lib/stream/iostrm.h
	$(CPP) -I../lib/stream $(IPATH) $(MACRO) $(OPTIMIZE) -c libstrm.cxx

# Microsoft Visual C++ compiler
vcstrm.o : vcstrm.cxx vcstrm.h $(HEADERS) ../lib/vcstream/iostrm.h
	$(CPP) -I../lib/vcstream $(IPATH) $(MACRO) $(OPTIMIZE) -c vcstrm.cxx

# QNX Dinkum STL
vc7strm.o : vc7strm.cxx vc7strm.h $(HEADERS) ../lib/vc7strm/iostrm.h
	$(CPP) -I../lib/vc7strm $(IPATH) $(MACRO) $(OPTIMIZE) -c vc7strm.cxx

# Borland C++ compiler
bcstrm.o : bcstrm.cxx bcstrm.h $(HEADERS) ../lib/bcsteam/iostrm.h
	$(CPP) -I../lib/bcstream $(IPATH) $(MACRO) $(OPTIMIZE) -c bcstrm.cxx

# Borland C++ Builder
cbstrm.o : cbstrm.cpp cbstrm.h $(HEADERS) ../lib/cbsteam/iostrm.h
	$(CPP) -I../lib/cbstream $(IPATH) $(MACRO) $(OPTIMIZE) -c cbstrm.cpp

# KAI C++ compiler
kccstrm.o : kccstrm.cxx kccstrm.h $(HEADERS)
	$(CPP) -I../lib/kccstream $(IPATH) $(MACRO) $(OPTIMIZE) -c kccstrm.cxx

# Sun CC5 compiler
sunstrm.o : sunstrm.cxx sunstrm.h $(HEADERS) ../lib/snstream/iostrm.h
	$(CPP) -I../lib/snstream $(IPATH) $(MACRO) $(OPTIMIZE) -c sunstrm.cxx

sun5strm.o : sun5strm.cxx sunstrm.h $(HEADERS) ../lib/snstream/iostrm.h
	$(CPP) -I../lib/snstream $(IPATH) $(MACRO) $(OPTIMIZE) -c sun5strm.cxx

# GNU C++ compiler ver 3.xx
gcc3strm.o : gcc3strm.cxx gcc3strm.h $(HEADERS) ../lib/gcc3strm/iostrm.h
	$(CPP) -I../lib/gcc3strm $(IPATH) $(MACRO) $(OPTIMIZE) -c gcc3strm.cxx

# Intel C++ compiler
iccstrm.o : iccstrm.cxx iccstrm.h $(HEADERS) ../lib/gcc3strm/iostrm.h
	$(CPP) -I../lib/iccstrm $(IPATH) $(MACRO) $(OPTIMIZE) -c iccstrm.cxx

# Use interpreted iostream
fakestrm.o : fakestrm.cxx $(HEADERS)
	$(CPP) $(IPATH) $(MACRO) $(OPTIMIZE) -c fakestrm.cxx

# C compiler only
dmystrm.o : dmystrm.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c dmystrm.c

# For all platform switching automatically , experimental
allstrm.o : allstrm.cxx $(HEADERS)
	$(CPP) $(IPATH) $(MACRO) $(OPTIMIZE) -c allstrm.cxx

############################################################################
# SunOS 4.1 specific source
############################################################################
sunos.o : sunos.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -DNONANSI -c sunos.c

############################################################################
# NewsOS specific source
############################################################################
newsos.o : newsos.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -DNONANSI -c newsos.c

############################################################################
# Windows-NT specific source
############################################################################
winnt.o : winnt.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c winnt.c

############################################################################
# input.c depends on GNU readline library
############################################################################
input.o : input.c $(HEADERS)
	if test -n "$(READLINEA)" && test -r $(READLINEA); \
	then \
	  $(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -DG__GNUREADLINE -c input.c ;\
	else \
	  $(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c input.c;\
	fi 

############################################################################
# lconv, div_t, ldiv_t, tm struct
############################################################################
stdstrct.o : stdstrct.c stdstrct.h $(HEADERS)
	$(CC) -I../lib/stdstrct $(IPATH) $(MACRO) $(OPTIMIZE) -c stdstrct.c

dmystrct.o : dmystrct.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c dmystrct.c

############################################################################
# To install cint core as shared library
############################################################################
$(CINTSYSDIR)/main/G__setup.o : $(CINTSYSDIR)/main/G__setup.c
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c $< -o $@

############################################################################
# Common sources
############################################################################
auxu.o : auxu.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c auxu.c

cast.o : cast.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c cast.c

debug.o : debug.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c debug.c

decl.o : decl.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c decl.c

disp.o : disp.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c disp.c

dmyinit.o : dmyinit.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c dmyinit.c

dump.o : dump.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c dump.c

end.o : end.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c end.c

error.o : error.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c error.c

expr.o : expr.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c expr.c

fread.o : fread.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c fread.c

func.o : func.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c func.c

gcoll.o : gcoll.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c gcoll.c

global1.o : global1.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c global1.c

global2.o : global2.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c global2.c

g__cfunc.o : g__cfunc.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c g__cfunc.c

ifunc.o : ifunc.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c ifunc.c

inherit.o : inherit.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c inherit.c

init.o : init.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c init.c

intrpt.o : intrpt.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c intrpt.c

loadfile.o : loadfile.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c loadfile.c

macro.o : macro.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c macro.c

malloc.o : malloc.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c malloc.c

memtest.o : memtest.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c memtest.c

new.o : new.c $(HEADERS) $(SECURITYH) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c new.c

newlink.o : newlink.c $(HEADERS) $(DLLREVH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c newlink.c

oldlink.o : oldlink.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c oldlink.c

opr.o : opr.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c opr.c

parse.o : parse.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c parse.c

pause.o : pause.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c pause.c

pcode.o : pcode.c $(HEADERS) bc_exec_asm.h
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c pcode.c

pragma.o : pragma.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c pragma.c

quote.o : quote.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c quote.c

scrupto.o : scrupto.c $(HEADERS) $(SECURITYH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c scrupto.c

sizeof.o : sizeof.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c sizeof.c

shl.o : shl.c $(HEADERS) $(DLLREVH)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c shl.c

struct.o : struct.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c struct.c

stub.o : stub.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c stub.c

tmplt.o : tmplt.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c tmplt.c

typedef.o : typedef.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c typedef.c

val2a.o : val2a.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c val2a.c

value.o : value.c $(HEADERS)
	$(CC) $(IPATH) $(MACRO) $(OPTIMIZE) -c value.c

var.o : var.c $(HEADERS) $(SECURITYH)
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
	  ../G__ci.h

Token.o : $(APIHEADER) Token.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Token.cxx

Typedf.o : $(APIHEADER) Typedf.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Typedf.cxx

Class.o : $(APIHEADER) Class.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Class.cxx

BaseCls.o : $(APIHEADER) BaseCls.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c BaseCls.cxx
	
Type.o : $(APIHEADER) Type.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Type.cxx

DataMbr.o : $(APIHEADER) DataMbr.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c DataMbr.cxx

Method.o : $(APIHEADER) Method.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Method.cxx

MethodAr.o : $(APIHEADER) MethodAr.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c MethodAr.cxx

CallFunc.o : $(APIHEADER) CallFunc.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c CallFunc.cxx

Api.o : $(APIHEADER) Api.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Api.cxx

Apiif.o : $(APIHEADER) Apiif.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c Apiif.cxx

longif.o : $(APIHEADER) longif.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c longif.cxx

longif3.o : $(APIHEADER) longif3.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c longif3.cxx

############################################################################
# Cint6.x Re-engineering
############################################################################

BCHEADER = bc_autoobj.h \
	   bc_cfunc.h \
	   bc_inst.h \
	   bc_parse.h \
	   bc_reader.h \
	   bc_type.h \
	   bc_exec.h \
	   bc_vtbl.h \
	   bc_eh.h \
	   bc_debug.h \
	   bc_assign.h \
	   common.h \
	  ../G__ci.h

bc_autoobj.o : $(APIHEADER) $(BCHEADER) bc_autoobj.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c bc_autoobj.cxx

bc_cfunc.o : $(APIHEADER) $(BCHEADER) bc_cfunc.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c bc_cfunc.cxx

bc_inst.o : $(APIHEADER) $(BCHEADER) bc_inst.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c bc_inst.cxx

bc_parse.o : $(APIHEADER) $(BCHEADER) bc_parse.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c bc_parse.cxx

bc_reader.o : $(APIHEADER) $(BCHEADER) bc_reader.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c bc_reader.cxx

bc_type.o : $(APIHEADER) $(BCHEADER) bc_type.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c bc_type.cxx

bc_exec.o : $(APIHEADER) $(BCHEADER) bc_exec.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c bc_exec.cxx

bc_vtbl.o : $(APIHEADER) $(BCHEADER) bc_vtbl.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c bc_vtbl.cxx

bc_eh.o : $(APIHEADER) $(BCHEADER) bc_eh.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c bc_eh.cxx

bc_debug.o : $(APIHEADER) $(BCHEADER) bc_debug.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c bc_debug.cxx

bc_assign.o : $(APIHEADER) $(BCHEADER) bc_assign.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c bc_assign.cxx

# Not used
bc_dict.o : $(APIHEADER) $(BCHEADER) bc_dict.cxx
	$(CPP) $(IPATH) $(OPTIMIZE) $(MACRO) -c bc_dict.cxx


############################################################################
# clean
############################################################################
clean :
	$(RM) $(OBJECTS) $(CINTLIB) core

