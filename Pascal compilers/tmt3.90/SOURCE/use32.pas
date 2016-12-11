(****************************************************************)
(*                                                              *)
(*       TMT Pascal 4 Runtime Library                           *)
(*       32-bit Types                                           *)
(*       Targets: MS-DOS, OS/2, Win32                           *)
(*                                                              *)
(*       Copyright (c) 1995,98 TMT Development Corporation      *)
(*       Authors: Anton Moscal, Vadim Bodrov                    *)
(*                                                              *)
(****************************************************************)

unit Use32;

interface

type
  Word       = System.DWORD;
  PWord      = ^System.DWORD;

const
  MAXWORD    = High(System.DWORD);
  MINWORD    = Low(System.DWORD);

implementation

end.
