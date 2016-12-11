{************************************************}
{                                                }
{   ObjectWindows Paint demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Bitmaps;

{ This unit augments the HBitmap type by implementing load and store of the
  bitmap to a file.

  Presently operates only on Windows format for bitmaps.
}
{$S-,R-}

interface

uses WinTypes, WinProcs;

{ Read a bitmap from file (full pathname).
  Returns 0 if error or HBitmap.
}
function LoadBitmapFile(FileName: PChar): HBitmap;

{ Write a bitmap to file (full pathname).
  Returns 0 if error else non-zero.
}
function StoreBitmapFile(FileName: PChar; HBM: HBitmap): Integer;

implementation

procedure AHIncr; far; external 'KERNEL' index 114;

const
  OneIO = 32768;  { Number bytes handled per huge IO operation }
  BMType = $4D42;  { = 'BM' }

type
  PtrRec = record
    Lo, Hi: Word
  end;
  IOFunction = function(FP: integer; Buf: PChar; Size: Integer): Word;

{ Perform IO operation in chunks to avoid memory segment crossings.
  Returns 0 if error else non-zero.
}
function HugeIO(IOFunc: IOFunction; F: Integer; P: Pointer; Size: Longint)
               : Word;
var
  L, N: Longint;	       	 { L maintains total bytes }
begin   			 { N maintains bytes for current pass }
  HugeIO := 1;
  L := 0;
  while L < Size do
  begin
    N := Size - L;
    if N > OneIO then N := OneIO;
    if IOFunc(F,
    { Compute the segment and offset reached.
      The Hi word of P contains the initial segment.
      Think of the following as performing arithmetic
        modulo segment-size, since the size of a segment
        fills one word:
      The Hi word of L contains the number of segments crossed
        (the size of one segment fills the Lo word, so Hi word
        will roll over as segments are filled).
        Multiply by Ofs(AHIncr) to obtain the number used to
        indicate this number of segments.
      The Lo word of L contains the number of bytes already
        passed in the present segment.
     }
	       Ptr(PtrRec(P).Hi + PtrRec(L).Hi * Ofs(AHIncr),
               PtrRec(L).Lo),
               Integer(N))     { Guaranteed to be in Integer range }
       <> N then
    begin
      HugeIO := 0;
      Exit; { abnormal termination }
    end; 
    Inc(L, N);
  end;
end;

function _LFileSize(F : integer) : longint;        
{- an equivalent to TP's FileSize() function }     
var                                                
  CurPos : longint;                                
begin                                               
  CurPos := _llseek(F,0,1);                    
  _LFileSize := _llseek(F,0,2);                
  _llseek(F,CurPos,0);                         
end;                                           

{ Read a bitmap from file (full pathname).
  Returns 0 if error or HBitmap.
}
function LoadBitmapFile(FileName: PChar): HBitmap;
var
  F: Integer;			{ File Handle for Windows file functions }
  H: THandle;			{ Handle to memory for bitmap }
  DC: HDC;			{ Drawing context for application }
  Size, N: Longint;		{ Size of bitmap, Size of color spec }
  P: PBitmapInfo;		{ Windows bitmap format info header }
  Header: TBitmapFileHeader;    { Bitmap file header }

begin
  LoadBitmapFile := 0;
  F := _LOpen(FileName, of_Read);
  if F = -1 then Exit;

  { read in the Bitmap file header }
  if (_LRead(F, @Header, SizeOf(Header)) <> SizeOf(Header)) or
    (Header.bfType <> BMType) then
  begin
    _LClose(F);
    Exit;
  end;

  { read the rest of the file }
  Size := _LFileSize(F) - SizeOf(TBitmapFileHeader);     
  H := GlobalAlloc(gmem_Moveable, Size);	{ Allocate the memory }
  if H = 0 then
  begin
    _LClose(F);
    Exit;
  end;

  P := GlobalLock(H);				{ Lock it down }

  if (HugeIO(_LRead, F, P, Size) <> 0) and
    (P^.bmiHeader.biSize = SizeOf(TBitmapInfoHeader)) then
  begin
    { Compute the offset from the beginning of P^ }      
    { where the actual image begins }                    
    N := Header.bfOffBits - SizeOf(TBitmapFileHeader);

    { actually create the Bitmap }
    DC := GetDC(0);
    LoadBitmapFile := CreateDIBitmap(DC, P^.bmiHeader,
      cbm_Init, Ptr(PtrRec(P).Hi,N),P^, dib_RGB_Colors); 

    { clean up }
    ReleaseDC(0, DC);
  end;

  GlobalUnlock(H);
  GlobalFree(H);
  _LClose(F);
end;


{ Write a bitmap to file (full pathname).
  Returns 0 if error else non-zero.
}
function StoreBitmapFile(FileName: PChar; HBM: HBitmap): Integer;
  var
    BM:   TBitmap;		{ Bitmap information }
    BFH:  TBitmapFileHeader;	{ Bitmap file information }
    BIP:  PBitmapInfo;		{ Part of bitmap file information }
    DC:   HDC;			{ Drawing context }

    HMem: THandle;		{ Handle to memory for bitmap }
    Buf:  Pointer;		{ Memory for bitmap }

    ColorSize, DataSize: Longint; { Size needed to store Color/Data }
    BitCount: Word;		{ Number of bits per pixel }
    FP: Integer;		{ File }

  { Takes the size in bits and returns the (aligned) size in bytes.
    Bitmap data format requires word alignment.
  }
  function bmAlignDouble(Size: Longint): Longint;
  begin
    bmAlignDouble := (Size + 31) div 32 * 4;
  end;

begin
   StoreBitmapFile := 0;
   { Get the information about the Bitmap }
   if GetObject(HBM, SizeOf(TBitmap), @BM) = 0 then Exit;

   BitCount := bm.bmPlanes * bm.bmBitsPixel;
   if (BitCount <> 24) then
     ColorSize := SizeOf(TRGBQuad) * (1 shl BitCount)
   else
     ColorSize := 0;
   DataSize := bmAlignDouble(bm.bmWidth * BitCount) * bm.bmHeight;

   { Create the file }
   FP := _lcreat(FileName, 0);
   if FP = -1 then Exit;

   { Allocate memory for the bitmap info structure }
   GetMem(BIP, SizeOf(TBitmapInfoHeader) + ColorSize);
   if BIP <> nil then
   begin
     { Fill in the Bitmap info header }
     with BIP^.bmiHeader do
     begin
       biSize := SizeOf(TBitmapInfoHeader);
       biWidth := bm.bmWidth;
       biHeight := bm.bmHeight;
       biPlanes := 1;
       biBitCount := BitCount;
       biCompression := 0;
       biSizeImage := DataSize;
       biXPelsPerMeter := 0;
       biYPelsPerMeter := 0;
       biClrUsed := 0;
       biClrImportant := 0;
     end;

     { Fill in the file header }
     with BFH do
     begin
       bfOffBits := SizeOf(BFH) + SizeOf(TBitmapInfo) + ColorSize;
       bfReserved1 := 0;
       bfReserved2 := 0;
       bfSize :=  bfOffBits + DataSize;
       bfType := BMType;
     end;

     { Create the memory Bitmap }
     HMem := GlobalAlloc(gmem_Fixed, DataSize);
     if HMem <> 0 then
     begin
       Buf := GlobalLock(HMem);

       { Get the bitmap bits in device independent format }
       DC := GetDC(0);
       if GetDIBits(DC, hbm, 0, DataSize, Buf, BIP^, dib_RGB_Colors) <> 0 then
       begin
         ReleaseDC(0, DC);
         { Write to file }
         _lwrite(FP, @BFH, SizeOf(BFH));
         _lwrite(FP, PChar(BIP), SizeOf(TBitmapInfo) + ColorSize);
         HugeIO(_lwrite, FP, Buf, DataSize);
         StoreBitmapFile := 1;
       end;

       { Clean up }
       GlobalUnlock(HMem);
       GlobalFree(HMem);
     end;

     FreeMem(BIP, SizeOf(TBitmapInfoHeader) + ColorSize);
   end;

   _lclose(FP);

end;

end.
