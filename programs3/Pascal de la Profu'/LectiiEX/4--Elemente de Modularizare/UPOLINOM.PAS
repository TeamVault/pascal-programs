Unit UPolinom;

Interface
  Procedure RezEc2(a, b, c: Real;
                   var x1, x2: Real;
                   var cod: Byte);
    { rezolva ecuatia de gradul II a*x^2 + b*x + c = 0 }

Implementation

  Procedure RezEc2(a, b, c: Real;
                   var x1, x2: Real;
                   var cod: Byte);
    var      { variabile locale }
      delta,                      { discriminantul }
      r: Real;                    { radical din delta sau -delta }

    begin
      delta := b * b - 4 * a * c;
      if delta > 0 then begin
        cod := 2;
        r := Sqrt(delta);
        x1 := (-b + r)/(a + a);
        x2 := (-b - r)/(a + a)
      end else if delta = 0 then begin
        cod := 3;
        x1 := -b/(a + a)
      end else begin          { delta < 0 }
        cod := 4;
        r := Sqrt(-delta);
        x1 := (-b)/(a + a);   { partea reala }
        x2 :=    r/(a + a)    { partea imaginara }
      end;
    end; { RezEc2 }

begin
end. { UPolinom }