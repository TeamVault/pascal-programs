/************************************************\
*                                                *
*   REGEXP.DDL Internal data definitions         *
*   Copyright (c) 1992 by Borland International  *
*   Copyright (c) 1986 by Univerisity of Toronto *
*                                                *
\************************************************/

#define RE_OK                   0
#define RE_NOTFOUND             1
#define RE_INVALIDPARAMETER     2
#define RE_EXPRESSIONTOOBIG     3
#define RE_OUTOFMEMORY          4
#define RE_TOOMANYSUBEXPS       5
#define RE_UNMATCHEDPARENS      6
#define RE_INVALIDREPEAT        7
#define RE_NESTEDREPEAT         8
#define RE_INVALIDRANGE         9
#define RE_UNMATCHEDBRACKET     10
#define RE_TRAILINGBACKSLASH    11
#define RE_INTERNAL             20

#define NSUBEXP  10

/*
 * The first byte of the regexp internal "program" is actually this magic
 * number; the start node begins in the second byte.
 */
#define	MAGIC	0234

typedef struct regexp {
	char *startp[NSUBEXP];
	char *endp[NSUBEXP];
	char regstart;		/* Internal use only. */
	char reganch;		/* Internal use only. */
	char *regmust;		/* Internal use only. */
	int regmlen;		/* Internal use only. */
	char program[1];	/* Internal use only. */
} regexp;

extern int regerror;
extern regexp *regcomp(const char *exp);
extern int regexec(register regexp* prog, register const char *string);
extern void regsub();
