/*****************************************************************************\
*                                                                             *
* winapi.h -    Windows functions, types, and definitions                     *
*                                                                             *
\*****************************************************************************/

#ifndef __WINAPI_H     /* prevent multiple includes */
#define __WINAPI_H

#ifdef __cplusplus
extern "C" {            /* Assume C declarations for C++ */
#endif  /* __cplusplus */

#define VOID                void
#define FAR                 _far
#define NEAR                _near
#define PASCAL              _pascal
#define CDECL               _cdecl
#define WINAPI              _far _pascal
#define CALLBACK            _far _pascal

typedef int                 BOOL;
#define FALSE               0
#define TRUE                1

typedef unsigned char       BYTE;
typedef unsigned short      WORD;
typedef unsigned long       DWORD;
typedef unsigned int        UINT;
#ifdef STRICT
typedef signed long         LONG;
#else
#define LONG long
#endif

#ifndef NULL
#define NULL                0
#endif

typedef char NEAR*          PSTR;
typedef char NEAR*          NPSTR;

typedef char FAR*           LPSTR;
typedef const char FAR*     LPCSTR;

typedef BYTE NEAR*          PBYTE;
typedef BYTE FAR*           LPBYTE;

typedef int NEAR*           PINT;
typedef int FAR*            LPINT;

typedef WORD NEAR*          PWORD;
typedef WORD FAR*           LPWORD;

typedef long NEAR*          PLONG;
typedef long FAR*           LPLONG;

typedef DWORD NEAR*         PDWORD;
typedef DWORD FAR*          LPDWORD;

typedef void FAR*           LPVOID;

#ifdef STRICT
typedef const void NEAR*        HANDLE;
#define DECLARE_HANDLE(name)    struct name##__ { int unused; }; \
                                typedef const struct name##__ NEAR* name
#define DECLARE_HANDLE32(name)  struct name##__ { int unused; }; \
                                typedef const struct name##__ FAR* name
#else   /* STRICT */
typedef UINT                    HANDLE;
#define DECLARE_HANDLE(name)    typedef UINT name
#define DECLARE_HANDLE32(name)  typedef DWORD name
#endif  /* !STRICT */

typedef HANDLE*             PHANDLE;
typedef HANDLE NEAR*        SPHANDLE;
typedef HANDLE FAR*         LPHANDLE;

typedef HANDLE              HGLOBAL;
typedef HANDLE              HLOCAL;

typedef HANDLE              GLOBALHANDLE;
typedef HANDLE              LOCALHANDLE;

typedef UINT                ATOM;

#ifdef STRICT
typedef void (CALLBACK*     FARPROC)(void);
typedef void (NEAR PASCAL*  NEARPROC)(void);
#else
typedef int (CALLBACK*      FARPROC)();
typedef int (NEAR PASCAL*   NEARPROC)();
#endif

DECLARE_HANDLE(HINSTANCE);
typedef HINSTANCE HMODULE;  /* HMODULEs can be used in place of HINSTANCEs */
DECLARE_HANDLE(HRSRC);
DECLARE_HANDLE(HWND);

#ifdef STRICT
typedef BOOL (CALLBACK* GNOTIFYPROC)(HGLOBAL);
#else
typedef FARPROC GNOTIFYPROC;
#endif

#define LOBYTE(w)           ((BYTE)(w))
#define HIBYTE(w)           ((BYTE)((UINT)(w) >> 8))

#define LOWORD(l)           ((WORD)(l))
#define HIWORD(l)           ((WORD)((DWORD)(l) >> 16))

#define MAKELONG(low, high) ((LONG)(((WORD)(low)) | (((DWORD)((WORD)(high))) << 16)))

/* Flags returned by GetWinFlags */

#define WF_PMODE        0x0001
#define WF_CPU286       0x0002
#define WF_CPU386       0x0004
#define WF_CPU486       0x0008
#define WF_STANDARD     0x0010
#define WF_WIN286       0x0010
#define WF_ENHANCED     0x0020
#define WF_WIN386       0x0020
#define WF_CPU086       0x0040
#define WF_CPU186       0x0080
#define WF_LARGEFRAME   0x0100
#define WF_SMALLFRAME   0x0200
#define WF_80x87        0x0400
#define WF_PAGING       0x0800
#define WF_WLO          0x8000

/* Global Memory Flags */

#define GMEM_FIXED          0x0000
#define GMEM_MOVEABLE       0x0002
#define GMEM_NOCOMPACT      0x0010
#define GMEM_NODISCARD      0x0020
#define GMEM_ZEROINIT       0x0040
#define GMEM_MODIFY         0x0080
#define GMEM_DISCARDABLE    0x0100
#define GMEM_NOT_BANKED     0x1000
#define GMEM_SHARE          0x2000
#define GMEM_DDESHARE       0x2000
#define GMEM_NOTIFY         0x4000

/* GlobalFlags return flags (in addition to GMEM_DISCARDABLE) */

#define GMEM_DISCARDED      0x4000
#define GMEM_LOCKCOUNT      0x00FF

/* Message Box Flags */

#define MB_OK               0x0000
#define MB_OKCANCEL         0x0001
#define MB_ABORTRETRYIGNORE 0x0002
#define MB_YESNOCANCEL      0x0003
#define MB_YESNO            0x0004
#define MB_RETRYCANCEL      0x0005
#define MB_TYPEMASK         0x000F

#define MB_ICONHAND         0x0010
#define MB_ICONQUESTION     0x0020
#define MB_ICONEXCLAMATION  0x0030
#define MB_ICONASTERISK     0x0040
#define MB_ICONMASK         0x00F0

#define MB_ICONINFORMATION  MB_ICONASTERISK
#define MB_ICONSTOP         MB_ICONHAND

#define MB_DEFBUTTON1       0x0000
#define MB_DEFBUTTON2       0x0100
#define MB_DEFBUTTON3       0x0200
#define MB_DEFMASK          0x0F00

#define MB_APPLMODAL        0x0000
#define MB_SYSTEMMODAL      0x1000
#define MB_TASKMODAL        0x2000

#define MB_NOFOCUS          0x8000

/* Windows API Functions */

int         WINAPI AccessResource(HINSTANCE, HRSRC);
UINT        WINAPI AllocDStoCSAlias(UINT);
UINT        WINAPI AllocSelector(UINT);
UINT        WINAPI ChangeSelector(UINT sourceSel, UINT destSel);
DWORD       WINAPI GetSelectorBase(UINT);
DWORD       WINAPI GetSelectorLimit(UINT);
void        WINAPI FatalExit(int);
HRSRC       WINAPI FindResource(HINSTANCE, LPCSTR, LPCSTR);
void        WINAPI FreeLibrary(HINSTANCE);
BOOL        WINAPI FreeResource(HGLOBAL);
UINT        WINAPI FreeSelector(UINT);
LPSTR       WINAPI GetDOSEnvironment(void);
DWORD       WINAPI GetFreeSpace(UINT);
int         WINAPI GetModuleFileName(HINSTANCE, LPSTR, int);
HMODULE     WINAPI GetModuleHandle(LPCSTR);
int         WINAPI GetModuleUsage(HINSTANCE);
FARPROC     WINAPI GetProcAddress(HINSTANCE, LPCSTR);
DWORD       WINAPI GetVersion(void);
DWORD       WINAPI GetWinFlags(void);
HGLOBAL     WINAPI GlobalAlloc(UINT, DWORD);
DWORD       WINAPI GlobalCompact(DWORD);
DWORD       WINAPI GlobalDosAlloc(DWORD);
UINT        WINAPI GlobalDosFree(UINT);
void        WINAPI GlobalFix(HGLOBAL);
void        WINAPI GlobalUnfix(HGLOBAL);
UINT        WINAPI GlobalFlags(HGLOBAL);
HGLOBAL     WINAPI GlobalFree(HGLOBAL);
DWORD       WINAPI GlobalHandle(UINT);
#ifdef STRICT
void FAR*   WINAPI GlobalLock(HGLOBAL);
#else
char FAR*   WINAPI GlobalLock(HGLOBAL);
#endif
HGLOBAL     WINAPI GlobalLRUNewest(HGLOBAL);
HGLOBAL     WINAPI GlobalLRUOldest(HGLOBAL);
void        WINAPI GlobalNotify(GNOTIFYPROC);
UINT        WINAPI GlobalPageLock(HGLOBAL);
UINT        WINAPI GlobalPageUnlock(HGLOBAL);
HGLOBAL     WINAPI GlobalReAlloc(HGLOBAL, DWORD, UINT);
DWORD       WINAPI GlobalSize(HGLOBAL);
BOOL        WINAPI GlobalUnlock(HGLOBAL);
HINSTANCE   WINAPI LoadLibrary(LPCSTR);
HGLOBAL     WINAPI LoadResource(HINSTANCE, HRSRC);
int         WINAPI LoadString(HINSTANCE, UINT, LPSTR, int);
#ifdef STRICT
void FAR*   WINAPI LockResource(HGLOBAL);
#else
char FAR*   WINAPI LockResource(HGLOBAL);
#endif
HGLOBAL     WINAPI LockSegment(UINT);
int         WINAPI MessageBox(HWND, LPCSTR, LPCSTR, UINT);
UINT        WINAPI PrestoChangoSelector(UINT sourceSel, UINT destSel);
UINT        WINAPI SetSelectorBase(UINT, DWORD);
UINT        WINAPI SetSelectorLimit(UINT, DWORD);
DWORD       WINAPI SizeofResource(HINSTANCE, HRSRC);
void        WINAPI UnlockSegment(UINT);

#define     GlobalAllocPtr(flags, cb)   \
                (GlobalLock(GlobalAlloc((flags), (cb))))
#define     GlobalDiscard(h)            \
                (GlobalReAlloc((h), 0L, GMEM_MOVEABLE))
#define     GlobalFreePtr(lp)           \
                (GlobalUnlockPtr(lp), (BOOL)GlobalFree(GlobalPtrHandle(lp)))
#define     GlobalLockPtr(lp)           \
                ((BOOL)SELECTOROF(GlobalLock(GlobalPtrHandle(lp))))
#define     GlobalPtrHandle(lp)         \
                ((HGLOBAL)LOWORD(GlobalHandle(SELECTOROF(lp))))
#define     GlobalReAllocPtr(lp, cbNew, flags)  \
                (GlobalUnlockPtr(lp), GlobalLock(GlobalReAlloc(GlobalPtrHandle(lp) , (cbNew), (flags))))
#define     GlobalUnlockPtr(lp)         \
                (GlobalUnlock(GlobalPtrHandle(lp)))
#define     UnlockResource(h)           \
                (GlobalUnlock(h))

#ifdef __cplusplus
}                       /* End of extern "C" { */
#endif  /* __cplusplus */

#endif  /* __WINAPI_H */

