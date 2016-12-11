{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Step01a;

uses OWindows;

type
  TMyApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

procedure TMyApplication.InitMainWindow;
begin
  MainWindow := New(PWindow, Init(nil, 'Steps'));
end;

var
  MyApp: TMyApplication;

begin
  MyApp.Init('Steps');
  MyApp.Run;
  MyApp.Done;
end.