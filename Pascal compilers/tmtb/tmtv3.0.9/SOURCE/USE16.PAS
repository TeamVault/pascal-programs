(****************************************************************)
(*                                                              *)
(*       TMT Pascal 4 Runtime Library                           *)
(*       16-bit Types                                           *)
(*       Targets: MS-DOS, OS/2, Win32                           *)
(*                                                              *)
(*       Copyright (c) 1995, 2001 TMT Development Corporation   *)
(*       Author: Vadim Bodrov                                   *)
(*                                                              *)
(****************************************************************)


unit Use16;

interface

type
  Integer  = System.SmallInt;
  PInteger = ^System.SmallInt;

const
  MAXINT      = High(System.SmallInt);
  MAXINTEGER  = High(System.SmallInt);
  MININT      = Low(System.SmallInt);
  MININTEGER  = Low(System.SmallInt);

implementation

end.