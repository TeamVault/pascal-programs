/************************************************\
*                                                *
*   REGEXP.DDL Interface module                  *
*   Copyright (c) 1992 by Borland International  *
*                                                *
\************************************************/

/*  This module defines the exported interface functions
 *  provided by REGEXP.DLL.  It provides the multi client
 *  support managment by managing regular expression
 *  handles.
 */

#define  STRICT

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <limits.h>

#include <winapi.h>

#include "regexp.h"
#include "_regexp.h"

HINSTANCE Instance;    // Instance handle

// Handle managment ------------------------------------------------

#define MAX_HANDLES 128

int FreeList = 1;
regexp *Handles[MAX_HANDLES];

void InitializeHandles(void)
{
    int i;

    for (i = 0; i < MAX_HANDLES - 1; i++)
    {
        Handles[i] = (regexp *)(i + 1);
    }
    Handles[i] = NULL;
}

#define	UCHARAT(p)	((int)*(unsigned char *)(p))
BOOL VerifyHandle(HREGEXP reg)
{
    return reg && (int)reg < MAX_HANDLES &&
       Handles[(int) reg] != NULL  &&
       UCHARAT(Handles[(int) reg]->program) == MAGIC;
}

HREGEXP AllocateHandle(void)
{

    if ( FreeList )
    {
        HREGEXP Handle = (HREGEXP) FreeList;

        FreeList = (int)Handles[FreeList];

        return Handle;
    }
    else
        return (HREGEXP) 0;
}

void FreeHandle(HREGEXP Handle)
{
    Handles[(int) Handle] = (regexp *)FreeList;
    FreeList = (int) Handle;
}

// Exported function -----------------------------------------------

HREGEXP _export FAR PASCAL RegComp(const char *pattern, int *error)
{
    HREGEXP Handle = AllocateHandle();

    if ( Handle )
    {
        Handles[(int) Handle] = regcomp(pattern);
        if ( Handles[(int) Handle] == NULL )
        {
            *error = regerror;
            FreeHandle(Handle);
            return (HREGEXP) 0;
        }
    }
    else
        *error = RE_OUTOFMEMORY;

    return Handle;
}

int _export FAR PASCAL RegExec(HREGEXP reg, const char *string,
  regmatch *match)
{
    if ( VerifyHandle(reg) )
    {
        regexp *preg = Handles[(int) reg];

        regerror = 0;

        if ( regexec(preg, string) )
        {
            match->start = preg->startp[0] - (char *)string;
            match->stop  = preg->endp[0] - (char *)string;

            return 0;
        }
        else
            return regerror != 0 ? regerror : RE_NOTFOUND;
    }
    else
        return RE_INVALIDPARAMETER;
}

#pragma argsused
size_t _export FAR PASCAL RegError(HREGEXP reg, int errcode,
  char *errbuf, size_t errbuf_size)
{
    // "reg" could be used to provide more information about
    // the error.

    LoadString(Instance, errcode, errbuf, errbuf_size);

    return 0;
}

void _export FAR PASCAL RegFree(HREGEXP reg)
{
    if ( VerifyHandle(reg) )
    {
        free(Handles[(int) reg]);

        FreeHandle(reg);
    }
}

// DLL initialization and shutdown ---------------------------------

#pragma argsused
int FAR PASCAL LibMain(HINSTANCE hInstance, WORD wDataSegment,
  WORD wHeapSize, LPSTR lpszCmdLine)
{
    // Initialize the handle table
    InitializeHandles();

    Instance = hInstance;

    return 1;   // Indicate that the DLL was initialized successfully.
}

#pragma argsused
int FAR PASCAL WEP ( int bSystemExit )
{
    return 1;
}
