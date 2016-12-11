{************************************************}
{                                                }
{   ObjectWindows Demo                           }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Collect1;

uses Objects, WinCrt, Strings;

type
  PClient = ^TClient;
  TClient = object(TObject)
    Account, Name, Phone: PChar;
    constructor Init(NewAccount, NewName, NewPhone: PChar);
    destructor Done; virtual;
    procedure Print; virtual;
  end;

{ TClient }
constructor TClient.Init(NewAccount, NewName, NewPhone: PChar);
begin
  Account := StrNew(NewAccount);
  Name := StrNew(NewName);
  Phone := StrNew(NewPhone);
end;

destructor TClient.Done;
begin
  StrDispose(Account);
  StrDispose(Name);
  StrDispose(Phone);
end;

procedure TClient.Print;
begin
  Writeln('  ',
    Account, '':10 - StrLen(Account),
    Name, '':20 - StrLen(Name),
    Phone, '':16 - StrLen(Phone));
end;

{ Use ForEach iterator to display client information }

procedure PrintAll(C: PCollection);

procedure CallPrint(P : PClient); far;
begin
  P^.Print;                   { Call Print method }
end;

begin { Print }
  Writeln;
  Writeln;
  Writeln('Client list:');
  C^.ForEach(@CallPrint);     { Print each client }
end;

{ Use FirstThat iterator to search non-key field }

procedure SearchPhone(C: PCollection; PhoneToFind: PChar);

function PhoneMatch(Client: PClient): Boolean; far;
begin
  PhoneMatch := StrPos(Client^.Phone, PhoneToFind) <> nil;
end;

var
  FoundClient: PClient;

begin { SearchPhone }
  Writeln;
  FoundClient := C^.FirstThat(@PhoneMatch);
  if FoundClient = nil then
    Writeln('No client met the search requirement')
  else
  begin
    Writeln('Found client:');
    FoundClient^.Print;
  end;
end;

var
  ClientList: PCollection;

begin
  ClientList := New(PCollection, Init(10, 5));

  { Build collection }
  with ClientList^ do
  begin
    Insert(New(PClient, Init('91-100', 'Anders, Smitty', '(406) 111-2222')));
    Insert(New(PClient, Init('90-167', 'Smith, Zelda', '(800) 555-1212')));
    Insert(New(PClient, Init('90-177', 'Smitty, John', '(406) 987-4321')));
    Insert(New(PClient, Init('90-160', 'Johnson, Agatha', '(302) 139-8913')));
  end;

  { Use ForEach iterator to print all }
  PrintAll(ClientList);

  { Use FirstThat iterator to find match with search pattern }
  SearchPhone(ClientList, '(406)');

  { Clean up }
  Dispose(ClientList, Done);
end.
