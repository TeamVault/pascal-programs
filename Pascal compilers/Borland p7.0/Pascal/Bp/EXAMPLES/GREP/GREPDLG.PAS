{************************************************}
{                                                }
{   Turbo Vision Grep Dialog Unit                }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit GrepDlg;

interface

uses Objects, Drivers, Views, Dialogs, Regexp;

const
  roCase   = $01;
  roSubDir = $02;

type
  TRequest = record
    Expression: String[80];
    FileMask: String[12];
    StartDir: String[79];
    Options: Word;
  end;

type
  PGrepDialog = ^TGrepDialog;
  TGrepDialog = object(TDialog)
    constructor Init;
  end;

implementation

uses Strings, MsgBox;

type
  PRegexInput = ^TRegexInput;
  TRegexInput = object(TInputLine)
    function Valid(Command: Word): Boolean; virtual;
  end;

function TRegexInput.Valid(Command: Word): Boolean;
var
  Exp: array[0..255] of Char;
  Regex: HRegexp;
  Error: Integer;
begin
  if (Command <> cmCancel) and (Command <> cmValid) then
  begin
    Valid := False;
    Regex := 0;
    Error := 0;
    if Data^ <> '' then
    begin
      Regex := RegComp(StrPCopy(Exp, Data^), Error);
      if Regex = 0 then
      begin
        RegError(Regex, Error, Exp);
        MessageBox('Invalid regular expression: ' +
          StrPas(Exp), nil, mfError + mfOkButton);
        Select;
      end
      else
        Valid := True;
      RegFree(Regex);
    end
    else
    begin
      MessageBox('Expression cannot be empty.', nil, mfError + mfOkButton);
      Select;
    end;
  end
  else
    Valid := inherited Valid(Command)
end;

constructor TGrepDialog.Init;
var
  R: TRect;
  Control: PView;
begin
  R.Assign(3, 4, 75, 15);
  inherited Init(R, 'Search Parameters');

  { Edit }
  R.Assign(15, 2, 68, 3);
  Control := New(PRegexInput, Init(R, 80));
  Insert(Control);
  {Static  Drive}
  R.Assign(3, 2, 14, 3);
  Insert(New(PLabel, Init(R, '~E~xpression', Control)));

  { Edit }
  R.Assign(15, 3, 68, 4);
  Control := New(PInputLine, Init(R, 12));
  Insert(Control);
  {Static  Drive}
  R.Assign(3, 3, 14, 4);
  Insert(New(PLabel, Init(R, '~F~ile mask', Control)));

  { Edit }
  R.Assign(15, 4, 68, 5);
  Control := New(PInputLine, Init(R, 79));
  Insert(Control);
  R.Assign(3, 4, 14, 5);
  Insert(New(PLabel, Init(R, '~D~irectory', Control)));

  {Check Button }
  R.Assign(15, 6, 68, 7);
  Control := New(PCheckBoxes, Init(R,
    NewSItem('~C~ase sensitive     ',
    NewSItem('~R~ecurse subdirectories',
    nil))));
  Insert(Control);
  R.Assign(3, 6, 11, 7);
  Insert(New(PLabel, Init(R, 'Options', Control)));

  { Button  Ok }
  R.Assign(47, 8, 57, 10);
  Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));

  { Button Cancel }
  R.Move(12, 0);
  Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

  SelectNext(False);
end;

end.
