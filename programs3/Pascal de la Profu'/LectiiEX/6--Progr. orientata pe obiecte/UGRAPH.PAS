Unit UGraph;
  Interface
    procedure InitGr;
    function CeDirectie(var DirX,DirY : ShortInt) : Boolean;
    procedure OutTextLN(S:String);
    procedure RotestePunct(var x,y:Integer; cx,cy,unghi:Integer);
  Implementation
     Uses
       Graph,Crt;
     Const
       PathToBGI = 'h:\BP\BGI';
     Var
       GraphDriver,
       GraphMode : Integer;
     function CeDirectie(var DirX,DirY : ShortInt) : Boolean;
     { preia o tasta functionala sageata si seteaza DirX si DirY
       intorcand True
       la Enter sau orice alta tasta diferita de sageti intoarce False
     }
       var
         CodCar : Byte;
         Gata : Boolean;
       Begin
         DirX := 0;
         DirY := 0;
         CeDirectie := True;
         Repeat
           CodCar := Ord(ReadKey);
           Gata := True;
           Case CodCar of
             0 : Begin         { cod de tasta functionala }
                   CodCar := Ord(ReadKey);
                   Case CodCar of
                     72 : DirY := -1;   { sageata sus }
                     80 : DirY :=  1;   { sageata jos }
                     75 : DirX := -1;   { sageata stanga }
                     77 : DirX :=  1;   { sageata dreapta }
                     else Gata := False;
                   End;
                 End;
             13 : CeDirectie := False   { termina }
             else Gata := False
           End;
         Until Gata;
       End; { CeDirectie }
     Procedure InitGr;
       Begin
         DetectGraph(GraphDriver,GraphMode);
         InitGraph(GraphDriver,GraphMode,PathToBGI);
         If GraphResult <> grOK
           then
             Begin
               WriteLn(GraphErrorMsg(GraphDriver));
               If GraphDriver = grFileNotFound
                 then
                   WriteLn('in ',PathToBGI,'. Modificati "PathToBGI" in unit-ul UGraph');
               WriteLn('Apasati ENTER ...');
               ReadLn;
               Halt(1)
             End;
       End; { InitGr }
     procedure OutTextLN(S:String);
       Begin
         OutText(S);
         MoveTo(0,GetY+12)
       End; { OutTextLn }
    procedure RotestePunct(var x,y:integer; cx,cy,unghi:Integer);
      { roteste punctul (x, y) in jurul centrului (cx, cy) cu
        unghiul unghi - dat in grade

         * (final)      * (x, y)  (pozitie initiala)
          \           /
           r\ unghi /r
              \   /   fi
                *  -----------------> OX
            (cx, cy)

    legatura dintre coordonatele polare (r, fi) si coordonatele carteziene
    (x, y) este urmatoarea:

      x = cx + r cos fi
      y = cy + r sin fi

    si invers,

      r = sqrt(x*x + y*y)
      cos fi = (x - cx) / r
      sin fi = (y - cy) / r

      }
      Var
        r,dx,dy,uu,sf,cf,su,cu,s,c : Real;
      Begin
        dx := x-cx;
        dy := y-cy;
        r := sqrt(dx*dx+dy*dy);
        If r = 0.0
          then Exit;
        sf := dy / r;   { sin fi }
        cf := dx / r;   { cos fi }
        uu := unghi * pi / 180;   { unghi in radiani }
        su := sin(uu);            { sin unghi }
        cu := cos(uu);            { cos unghi }
        c := cf * cu - sf * su;   { cos (fi + unghi) }
        s := sf * cu + cf * su;   { sin (fi + unghi) }
        x := cx + round(r * c);   { noul x }
        y := cy + round(r * s);   { noul y }
      End; { RotestePunct }

End. { UGraph }