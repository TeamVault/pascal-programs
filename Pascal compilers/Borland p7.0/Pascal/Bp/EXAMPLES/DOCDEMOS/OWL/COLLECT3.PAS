{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ Read a file and add each unique word to a sorted
  collection of PChar. Use the ForEach iterator method
  to traverse the collection and print out each word. }

program Collect3;

uses Objects, WinCrt, WinDos, Strings;

const
  FileToRead = 'COLLECT3.PAS';
  MaxWordLen = 20;

{ ********************************** }
{ ***********  Iterator  *********** }
{ ********************************** }

{ Given the entire collection, use the ForEach
  iterator to traverse and print all the words. }

procedure Print(C: PCollection);

{ Must be a local, far procedure. Receives one collection
  element at a time--a pointer to a string--to print. }

procedure PrintWord(P : PChar); far;
begin
  Writeln(P);
end;

begin { Print }
  Writeln;
  Writeln;
  C^.ForEach(@PrintWord);                 { Call PrintWord }
end;

{ ********************************** }
{ **********    Globals    ********* }
{ ********************************** }

{ Abort the program and give a message }

procedure Abort(Msg, FName: PChar);
begin
  Writeln;
  Writeln(Msg, ' (', FName, ')');
  Writeln('Program aborting');
  Halt(1);
end;

{ Given an open text file, read it and return the next word }

function GetWord(S: PChar; var F : Text): PChar;
var
  C : Char;
  I: Integer;
begin
  I := 0;
  C := #0;
  { find first letter }
  while not Eof(F) and not (UpCase(C) in ['A'..'Z']) do
    Read(F, C);
  { special test in case end of file }
  if Eof(F) and (UpCase(C) in ['A'..'Z']) then
  begin
    if (I < MaxWordLen) then S[I] := C;
  end
  else
    { read chars from file, append to S }
    while (UpCase(C) in ['A'..'Z']) and not Eof(F) do
    begin
      if I < MaxWordLen then
      begin
        S[I] := C;
        Inc(I);
      end;
      Read(F, C);
    end;
  S[I] := #0;
  GetWord := S;
end;

{ ********************************** }
{ **********  Main Program ********* }
{ ********************************** }

var
  WordList: PCollection;
  WordFile: Text;
  WordFileName: array[0..79] of Char;
  WordRead: array[0..MaxWordLen] of Char;
begin
  { Initialize collection to hold 10 elements first, then grow by 5's }
  WordList := New(PStrCollection, Init(10, 5));

  { Open file of words }
  if GetArgCount = 1 then GetArgStr(WordFileName, 1, 79)
  else StrCopy(WordFileName, FileToRead);
  Assign(WordFile, WordFileName);
  {$I-}
  Reset(WordFile);
  {$I+}
  if IOResult <> 0 then
    Abort('Cannot find file', WordFileName);

  { Read each word into the collection }
  repeat
    if GetWord(WordRead, WordFile)^ <> #0 then
      WordList^.Insert(StrNew(WordRead));
  until WordRead[0] = #0;
  Close(WordFile);

  ScreenSize.X := MaxWordLen;
  ScreenSize.Y := WordList^.Count + 1;

  { Display collection contents }
  Print(WordList);

  { Cleanup }
  Dispose(WordList, Done);
end.
