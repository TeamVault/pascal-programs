function WordToHex(w: Word): String;
const
 hexChars: array [0..$F] of Char =
   '0123456789ABCDEF';
begin
 WordToHex := hexChars[Hi(w) shr 4] + hexChars[Hi(w) and $F] +
              hexChars[Lo(w) shr 4] + hexChars[Lo(w) and $F]
end; { WordToHex }

function ValoarePtr(p: Pointer): String;
  begin
    ValoarePtr := WordToHex(Seg(p)) + ':' + WordToHex(Ofs(p))
  end; { ValoarePtr }

function ValoarePtrI(p: PInteger): String;
  begin
    ValoarePtrI := WordToHex(Seg(p)) + ':' + WordToHex(Ofs(p))
  end; { ValoarePtr }

