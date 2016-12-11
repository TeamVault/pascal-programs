  {pt lucrul cu tastatura CRT ne pune la dispozitie 2 functii,keypressed &readkey}
  program crtDOVADAputeri;
  uses crt;
  var tasta :char;
  begin
    while tasta<>chr(32) do
         if keypressed then
              begin
              tasta:=readkey;
              writeln(ord(tasta));delay(700);
              end
                        else writeln('nimic apasat,APASA ESCAPE!');
  end.