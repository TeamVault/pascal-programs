/************************************************\
*                                                *
*   REGEXP.DDL Public Interface Header File      *
*   Copyright (c) 1992 by Borland International  *
*                                                *
\************************************************/


#ifndef _REGEXP_H
#define _REGEXP_H

DECLARE_HANDLE(HREGEXP);        // Defined in either WINDOWS.H or WINAPI.H

typedef struct {
	unsigned int start;	        // start of match
	unsigned int stop;	        // end of match
} regmatch;


HREGEXP FAR PASCAL RegComp(const char _far *pattern, int _far *error);
int FAR PASCAL RegExec(HREGEXP regex, const char _far *string,
    regmatch _far *match);
size_t FAR PASCAL RegError(HREGEXP regex, int errcode, char _far *errbuf, 
    size_t errbuf_size);
void FAR PASCAL RegFree(HREGEXP regex);

#endif
