Program Umplere;

  Uses UGraph, Graph;

  Procedure Colorare(u, v, CuloareNoua: Integer);
    { coloreaza in jurul punctului (u,v) cu culoarea CuloareNoua }
    var
      CuloareVeche: Integer;
    Procedure UmpleInJur(u, v: Integer);
      { coloreaza punctele din jurul punctului (u, v) cu CuloareNoua
        daca (u, v) este colorat cu CuloareVeche }
      begin { UmpleInJur }
        if GetPixel(u, v) = CuloareVeche then begin
          PutPixel(u, v, CuloareNoua);
          UmpleInJur(u+1, v);
          UmpleInJur(u-1, v);
          UmpleInJur(u, v+1);
          UmpleInJur(u, v-1)
        end;
      end;  { UmpleInJur }
    begin { Colorare }
      CuloareVeche := GetPixel(u, v);
      UmpleInJur(u, v)
    end;  { Colorare }

  begin
    InitGr;    { initializeaza modul grafic }
    SetColor(Blue);
    Circle(300,200,35);
    SetColor(LightBlue);
    Circle(290, 190, 7);
    Circle(310, 190, 7);
    SetColor(Brown);
    Circle(297, 200, 2);
    Circle(303, 200, 2);
    SetColor(LightRed);
    Circle(300, 217, 10);
    Colorare(300, 200, Yellow);
    ReadLn;
    CloseGraph { termina modul grafic }
  end. { Culoare }