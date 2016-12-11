/* /% C %/ */
/***********************************************************************
 * cint (C/C++ interpreter)
 ************************************************************************
 * Source file dmystrm.c
 ************************************************************************
 * Description:
 *  iostream and ERTTI API dummy function for C compiler only intallation
 ************************************************************************
 * Copyright(c) 1995~1999  Masaharu Goto 
 *
 * Permission to use, copy, modify and distribute this software and its 
 * documentation for any purpose is hereby granted without fee,
 * provided that the above copyright notice appear in all copies and
 * that both that copyright notice and this permission notice appear
 * in supporting documentation.  The author makes no
 * representations about the suitability of this software for any
 * purpose.  It is provided "as is" without express or implied warranty.
 ************************************************************************/

#include <stdio.h> 
#include "common.h"

#ifndef G__OLDIMPLEMENTATION463
extern FILE *G__serr;
#endif

void G__cpp_setupG__stream() {
  /* dummy */
}

void G__cpp_setupG__API() {
  /* dummy */
  if(G__dispmsg>=G__DISPWARN) {
#ifndef G__OLDIMPLEMENTATION463
    G__fprinterr(G__serr,
	 "Warning: ERTTI API not available. Install CINT with C++ compiler\n");
#else
    fprintf(stderr,
	 "Warning: ERTTI API not available. Install CINT with C++ compiler\n");
#endif
  }
}

#ifndef G__OLDIMPLEMENTAITON472
/***********************************************************************
* set linkage of precompiled library function
***********************************************************************/
int G__SetGlobalcomp(funcname,param,globalcomp)
char *funcname;
char *param;
int globalcomp;
{
  int i;
  struct G__ifunc_table *ifunc;

  ifunc = &G__ifunc;
  while(ifunc) {
    for(i=0;i<ifunc->allifunc;i++) {
      if(strcmp(funcname,ifunc->funcname[i])==0) {
	ifunc->globalcomp[i] = globalcomp;
      }
    }
    ifunc = ifunc->next;
  }
  return(0);
}
#endif

#ifndef G__OLDIMPLEMENTATION1781
int G__ForceBytecodecompilation(funcname,param)
char *funcname;
char *param;
{
  return(0);
}
#endif

#ifndef G__OLDIMPLEMENTATION1635
void G__redirectcout(filename) 
char *filename;
{
}
void G__unredirectcout() {
}
void G__redirectcerr(filename)
char *filename;
{
}
void G__unredirectcerr() {
}
void G__redirectcin(filename)
char *filename;
{
}
void G__unredirectcin() {
}
#endif /* 1635 */
