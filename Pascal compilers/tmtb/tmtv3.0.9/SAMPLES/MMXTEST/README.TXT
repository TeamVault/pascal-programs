This program coomputes the inner (or dot) product of the vectors
(1,2,3,4,5,...,200) and (200,199,198,197,...,1).
The computation is done first in Pascal, then in assembler, and then
in MMX-assembler.  Each computation is repeated 10,000 times
and then the run-time for each part is given.  A sample output is below.
Of course the run-times will varry with the computer.  The product
however should be the same: 1353400.

Note that the code with MMX is more than three times as fast as the
assembler code without it.  This is because the MMX code can do four
multiplications at a time.

N. B. If you have a high school student handy (who knows algebra), he
should be able to get this answer (1,353,400) without a computer.  Ask
him to find a formula for it.


OUTPUT:
pascal=225
asm x86=40
asm mmx=12
1353400
1353400
1353400

By the way, if you want more information about MMX, Intel gives lots of
it.  More details see the FAQ section of our web-page.

Hint: Use CPU_haveMMX function from ZenTimer unit to detect MMX technology.