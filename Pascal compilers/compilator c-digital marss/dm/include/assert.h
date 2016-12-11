
/* Copyright (C) 1986-2001 by Digital Mars. $Revision: 1.1.1.1 $ */
#if __DMC__ || __RCC__
#pragma once
#endif

#ifndef __ASSERT_H
#define __ASSERT_H 1

#if __cplusplus
extern "C" {
#endif


/* Define _CRTAPI1 (for compatibility with the NT SDK) */
#ifndef _CRTAPI1
#define _CRTAPI1 __cdecl
#endif


/* Define _CRTAPI2 (for compatibility with the NT SDK) */
#ifndef _CRTAPI2
#define _CRTAPI2 __cdecl
#endif

/* Define CRTIMP */
#ifndef _CRTIMP
#if defined(_WIN32) && defined(_DLL)
#define _CRTIMP  __declspec(dllimport)
#else
#define _CRTIMP
#endif
#endif


#undef assert

#ifdef NDEBUG
    #define assert(ignore)	((void) 0)
#else
    #define assert(e)	((void)((e) || (_assert(#e,__FILE__,__LINE__),1)))
    extern void
    #ifdef __STDC__
    #elif __OS2__ && __INTSIZE == 4
	__stdcall
    #else
	__cdecl
    #endif
	    _assert(void *,void *,unsigned);
    #pragma noreturn(_assert)
#endif

#if __cplusplus
}
#endif

#endif
