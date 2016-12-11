Program Calendar;
{Programul calculeaza in ce data este a 'n'-a zi dintr-un an oarecare}
Uses Crt;
Var zi,luna,an,Data,i:integer;
Function ConversieLuna(Var luna:integer):string;
{transforma luna curenta din tip intreg in tip string
Exemplu: luna 1 devine Ianuarie }
Begin
 Case luna of
  1: ConversieLuna:='Ianuarie';     {Prima luna}
  2: ConversieLuna:='Februarie';    {Luna 2}
  3: ConversieLuna:='Martie';       {Luna 3}
  4: ConversieLuna:='Aprilie';      {Luna 4}
  5: ConversieLuna:='Mai';          {Luna 5}
  6: ConversieLuna:='Iunie';        {Luna 6}
  7: ConversieLuna:='Iulie';        {Luna 7}
  8: ConversieLuna:='August';       {Luna 8}
  9: ConversieLuna:='Septembrie';   {Luna 9}
 10: ConversieLuna:='Octombrie';    {Luna 10}
 11: ConversieLuna:='Noiembrie';    {Luna 11}
 12: ConversieLuna:='Decembrie'     {Luna 12}
 End
End; {ConversieLuna}
Procedure CitesteAn(var an:integer);
{Citeste un an oarecare}
Begin
 Write('Dati anul: ');
 Readln(an)
End; {CitesteAn}
Function Bisect(Var an:integer):boolean;
{Intoarce true daca anul dat este bisect fals altfel
anul este bisect daca restul impartirii anului dat la 4 este 0}
begin
 If (an mod 4)= 0 then   {Calculeaza restul imparirii la 4}
   Bisect:=True
 Else
   Bisect:=False
end;  {Bisect}
Function NrZileDinLuna(Var luna,an:integer):integer;
{Calculeaza numarul de zile dintr-o luna data
tinand cont de faptul daca anul este bisect sau nu
luna se citeste ca intreg}
begin
 Case luna of
  1,3,5,7,8,10,12:
    NrZileDinLuna:=31;
  4,6,9,11:
    NrZileDinLuna:=30
  Else if (luna=2) and (Bisect(an)=True) then
    NrZileDinLuna:=29
  Else
   NrZileDinLuna:=28
 End
End;  {NrZileDinLuna}
Function NrZileDinAn(Var an:integer):integer;
{Daca anul este bisect atunci avem 366 zile
altfel avem 365 zile}
Begin
  if Bisect(an)=True then
   NrZileDinAn:=366
  else
   NrZileDinAn:=365
End;  {NrZileDinAn}
Function UrmatoareaLuna(Var luna:integer):integer;
{Realizeaza trecerea de la luna curenta la luna urmatoare
luna se citeste ca intreg si trecerea se face adunand luna cu 1.
Daca luna curenta este Decembrie (aici 12) atunci luna urmatoare devine
Ianuarie (aici 1)}
Begin
 if luna=12 then
  UrmatoareaLuna:=1
 Else
  UrmatoareaLuna:=luna+1;
End;  {UrmatoareaLuna}
Function UrmatoareaZi(var zi,luna:integer):integer;
{Realizeaza trecerea de la ziua curenta la ziua urmatoare
in functie de numarul de zile dintr-o luna a anului dat}
Begin
 If zi=NrZileDinLuna(luna,an) then
 Begin
  luna:=UrmatoareaLuna(luna);
  UrmatoareaZi:=1
 End
 else
  UrmatoareaZi:=zi+1
End; {UrmatoareaZi}
Procedure NumarulZileiDinAn(Var zi,luna,an:integer);
{Citeste numarul zilei dintr-un an dat}
Begin
  Repeat   {Structura repetitiva}
  Write('Dati ziua: ');
  Readln(zi);
  If (zi>NrZileDinAn(an)) or (zi<1) then {structura conditionala}
  Begin
   Writeln('Anul ',an,' are numai ',NrZileDinAn(an),' zile');
   Write('Dati o zi intre 1 si ',NrZileDinAn(an),' dupa ce apasati ENTER...');
   Readln;
   Clrscr;
  End;
  Until (zi<=NrZileDinAn(an)) and (zi>0);
End;  {NumarulZileiDinAn}
Begin  {Program principal}
  ClrScr;
  luna:=1;  {initializeaza luna ca fiind Ianuarie}
  Data:=1; {initializaza data cu 1 Ianuarie}
  CitesteAn(an);
  NumarulZileiDinAn(zi,luna,an);
  for i:=1 to zi-1 do
  Begin
   Data:=UrmatoareaZi(Data,luna)
   {se trece la ziua urmatoare pana cand 'i' devine 'zi-1'}
  End;
  {Cand 'i' devine 'zi-1','Data' va avea valoarea zilei urmatoare lui 'zi-1'
  care este 'zi'}
  Writeln('Ziua ',zi,' din anul ',an,' este in data de ',Data,' ',ConversieLuna(luna));
  if Bisect(an) then
    Write('Anul ',an,' este bisect')
  else
    Write('Anul ',an,' nu este bisect');
  Readln
End.  {Calendar}