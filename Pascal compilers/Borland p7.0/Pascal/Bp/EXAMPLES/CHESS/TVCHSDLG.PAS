{************************************************}
{                                                }
{   Turbo Vision Chess Demo                      }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit TVChsDlg;

interface

uses Objects, Views, Dialogs, TVChsCmd, Drivers;

type
  PTimeLabel = ^TTimeLabel;
  TTimeLabel = object(TLabel)
    function GetPalette: PPalette; virtual;
  end;

  PTimeInput = ^TTimeInput;
  TTimeInput = object(TInputLine)
    function GetPalette: PPalette; virtual;
    procedure SetOpt(AOptions: Word; Enable: Boolean);
  end;

  PTimeSettings = ^TTimeSettings;
  TTimeSettings = object(TRadioButtons)
    procedure MovedTo(Item: Integer); virtual;
    procedure Press(Item: Integer); virtual;
    procedure SetData(var Rec); virtual;
  end;

  PSettingsDlg = ^TSettingsDlg;
  TSettingsDlg = object(TDialog)
    TurnLabel: PTimeLabel;
    GameLabel: PTimeLabel;
    TurnInput: PTimeInput;
    GameInput: PTimeInput;
    Minutes, Seconds: PTimeLabel;
    constructor Load(var S: TStream);
    procedure EnableSet(Game, Turn: Boolean);
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure ShowSet(Game, Turn: Boolean);
    procedure Store(var S: TStream);
  end;

const
  RTimeLabel: TStreamRec = (
    ObjType: otTimeLabel;
    VmtLink: Ofs(TypeOf(TTimeLabel)^);
    Load:    @TTimeLabel.Load;
    Store:   @TTimeLabel.Store);

  RTimeInput: TStreamRec = (
    ObjType: otTimeInput;
    VmtLink: Ofs(TypeOf(TTimeInput)^);
    Load:    @TTimeInput.Load;
    Store:   @TTimeInput.Store);

  RSettingsDlg: TStreamRec = (
    ObjType: otSettingsDlg;
    VmtLink: Ofs(TypeOf(TSettingsDlg)^);
    Load:    @TSettingsDlg.Load;
    Store:   @TSettingsDlg.Store);

function CreateSettingsDlg: PDialog;

implementation

uses Validate;

function TTimeLabel.GetPalette: PPalette;
const
  P: string[Length(CTimeLabel)] = CTimeLabel;
begin
  if (Link <> nil) and (Link^.Options and ofSelectable <> 0) then
    GetPalette := inherited GetPalette
  else GetPalette := @P;
end;

function TTimeInput.GetPalette: PPalette;
const
  P: string[Length(CTimeInput)] = CTimeInput;
begin
  if Options and ofSelectable <> 0 then
    GetPalette := inherited GetPalette
  else GetPalette := @P;
end;

procedure TTimeInput.SetOpt(AOptions: Word; Enable: Boolean);
begin
  if Enable then Options := Options or AOptions
  else Options := Options and not AOptions;
  DrawView;
end;

procedure TTimeSettings.MovedTo(Item: Integer);
begin
  inherited MovedTo(Item);
  Message(Owner, evCommand, cmTimeOptChg, Pointer(Item));
end;

procedure TTimeSettings.Press(Item: Integer);
begin
  inherited Press(Item);
  Message(Owner, evCommand, cmTimeOptChg, Pointer(Item));
end;

procedure TTimeSettings.SetData(var Rec);
begin
  inherited SetData(Rec);
  Message(Owner, evCommand, cmTimeOptChg, Pointer(Value));
end;

constructor TSettingsDlg.Load(var S: TStream);
begin
  inherited Load(S);
  GetSubViewPtr(S, TurnLabel);
  GetSubViewPtr(S, GameLabel);
  GetSubViewPtr(S, TurnInput);
  GetSubViewPtr(S, Gameinput);
  GetSubViewPtr(S, Minutes);
  GetSubViewPtr(S, Seconds);
end;

procedure TSettingsDlg.EnableSet(Game, Turn: Boolean);
begin
  GameInput^.SetOpt(ofSelectable, Game);
  GameLabel^.DrawView;
  Minutes^.DrawView;
  TurnInput^.SetOpt(ofSelectable, Turn);
  TurnLabel^.DrawView;
  Seconds^.DrawView;
end;

function TSettingsDlg.GetPalette: PPalette;
const
  P: string[Length(CSettingsDlg)] = CSettingsDlg;
begin
  GetPalette := @P;
end;

procedure TSettingsDlg.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evCommand) and (Event.Command = cmTimeOptChg) then
  begin
    case Event.InfoInt of
      0: ShowSet(True, False);
      1: ShowSet(False, True);
      2: EnableSet(False, False);
      3: EnableSet(False, False);
    else Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TSettingsDlg.ShowSet(Game, Turn: Boolean);
begin
  GameInput^.SetOpt(ofSelectable, False);
  TurnInput^.SetOpt(ofSelectable, False);
  GameLabel^.SetState(sfVisible, Game);
  Minutes^.SetState(sfVisible, Game);
  GameInput^.SetState(sfVisible, Game);
  TurnLabel^.SetState(sfVisible, Turn);
  Seconds^.SetState(sfVisible, Turn);
  TurnInput^.SetState(sfVisible, Turn);
  EnableSet(Game, Turn);
end;

procedure TSettingsDlg.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S, TurnLabel);
  PutSubViewPtr(S, GameLabel);
  PutSubViewPtr(S, TurnInput);
  PutSubViewPtr(S, Gameinput);
  PutSubViewPtr(S, Minutes);
  PutSubViewPtr(S, Seconds);
end;


function CreateSettingsDlg: PDialog;
var
  Dlg : PSettingsDlg;
  R : TRect;
  Control, Labl, Histry : PView;
Begin
  R.Assign(0,0,56,15);
  New(Dlg, Init(R, 'Settings'));
  with Dlg^ do
  begin
    Options := Options or ofCentered;

    R.Assign(3,3,26,7);
    Control := New(PTimeSettings, Init(R,
      NewSItem('Limit ~g~ame time',
      NewSItem('Limit t~u~rn time',
      NewSItem('~M~atch user''s time',
      NewSItem('~N~o time limit',Nil))))));
    Insert(Control);

      R.Assign(2,2,24,3);
      Labl := New(PLabel, Init(R, 'Time limit selections', Control));
      Dlg^.Insert(Labl);

    R.Assign(14,9,22,10);
    GameInput := New(PTimeInput, Init(R, 6));
    GameInput^.SetValidator(New(PRangeValidator, Init(1, 600)));
    with GameInput^.Validator^ do
      Options := Options or voTransfer;
    Insert(GameInput);

      R.Assign(2,9,12,10);
      GameLabel := New(PTimeLabel, Init(R, 'Gam~e~ time', GameInput));
      Insert(GameLabel);

      R.Assign(22,9,26,10);
      Minutes := New(PTimeLabel, Init(R, 'min', GameInput));
      Insert(Minutes);

    R.Assign(14,9,22,10);
    TurnInput := New(PTimeInput, Init(R, 6));
    TurnInput^.SetValidator(New(PRangeValidator, Init(1, 36000)));
    with TurnInput^.Validator^ do
      Options := Options or voTransfer;
    Insert(TurnInput);

      R.Assign(2,9,12,10);
      TurnLabel := New(PTimeLabel, Init(R, 'Tu~r~n time', TurnInput));
      Insert(TurnLabel);

      R.Assign(22,9,26,10);
      Seconds := New(PTimeLabel, Init(R, 'sec', TurnInput));
      Insert(Seconds);

    R.Assign(28,3,53,8);
    Control := New(PCheckboxes, Init(R,
      NewSItem('Show ~a~ttacks',
      NewSItem('Show ~j~eopardies',
      NewSItem('Show ~b~est-line',
      NewSItem('Right click ~q~ueries',
      NewSItem('T~h~ink ahead', nil)))))));
    PCluster(Control)^.Value := 0;
    Insert(Control);

      R.Assign(27,2,33,3);
      Labl := New(PLabel, Init(R, 'Hints', Control));
      Insert(Labl);

    R.Assign(28,10,53,11);
    Control := New(PRadioButtons, Init(R,
      NewSItem('~O~ne    ',
      NewSItem('~T~wo',Nil))));
    PCluster(Control)^.Value := 0;
    Insert(Control);

      R.Assign(27,9,35,10);
      Labl := New(PLabel, Init(R, 'Players', Control));
      Insert(Labl);

    R.Assign(31,12,41,14);
    Control := New(PButton, Init(R, 'O~K~', cmOK, bfDefault));
    Insert(Control);

    Inc(R.A.X, 12); Inc(R.B.X, 12);
    Control := New(PButton, Init(R, 'Cancel', cmCancel, bfNormal));
    Insert(Control);

    SelectNext(False);
  end;
  CreateSettingsDlg := Dlg;
end;

end.