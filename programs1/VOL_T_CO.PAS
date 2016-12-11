Program trunchi_de_con;
var A,R,B,h:real;
const pi=3.1415;
Begin
Write ('dati raza mare:');
readln (R);
write ('dati raza mica:');
readln (B);
write ('dati inaltimea:');
readln (h);
A:=(pi*h/3)*(R*R+B*B+R*B);
write ('volumul este :',A:9:5);
readln;
End.