{program de test pt. fis. cu tip...se face scriere, citire,etc}
program testfis;
type
    datac = record
          zi:1..31;
          luna:1..12;
          an:1800..2200;
    end;
    rec_persoana = record
         nume:string[20];
         prenume:string[20];
         adresa:string[50];
         datan:datac;
         bi:string[20];
    end;
    ppersoana:^rec_persoana;
    fis:file of rec_persoana;

var
   persoana:ppersoana;
   mfis:fis;
FUNCTION StrToData(a:str[
PROCEDURE AdaugareP(var mfis:fis);
var persoana:ppersoana;
    numet:string[20];
    datat:datac;
begin
   clrscr;
   writeln('Introducere date in baza de date...');
   writeln('Pentru a iesi lasati campul Nume gol si apasati Enter.');
   write('Nume persoana: ');readln(numet);
   while numet<>'' do begin
         new(persoana);
         with persoana^ do
              nume:=numet;
              write('Prenume persoana: ');readln(prenume);
              write('Varsta: ');readln(varsta);
              write('Clasa: ');readln(clasa);
  end {with};

