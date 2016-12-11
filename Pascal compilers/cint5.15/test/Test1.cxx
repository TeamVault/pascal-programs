// Test1.cxx

#if defined(__GNUC__) && (__GNUC__>=3)
#include <iostream>
using namespace std;
#else
#include <iostream.h>
#endif
#include "Complex.h"
#include "MyString.h"
#include "MyAlgo0.h"

int main()
{
  // instantiation of array or container
  const int ASIZE = 5;
  int      iary[ASIZE]; 
  Complex  cary[ASIZE];
  MyString sary[ASIZE];

  // assignment to container elements
  for(int i=0;i<ASIZE;i++) {
    iary[i] = i;
    cary[i] = Complex(i,i*2); // explicit type conversion
    sary[i] = i;         // implicit type conversion
  }

  // display container elements
  Disp(&iary[0],&iary[ASIZE]);
  Disp(&cary[0],&cary[ASIZE]);
  Disp(&sary[0],&sary[ASIZE]);

  // summation of container elements
  int      isum = Sum(&iary[0],&iary[ASIZE],0);
  Complex  csum = Sum(&cary[0],&cary[ASIZE],Complex());
  MyString ssum = Sum(&sary[0],&sary[ASIZE],MyString());

  cout << "isum=" << isum << endl;
  cout << "csum=" << csum << endl;
  cout << "ssum=" << ssum << endl;

  return(0);
} // automatic objects are automatically destoryed

