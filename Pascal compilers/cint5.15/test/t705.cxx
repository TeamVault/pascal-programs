
#if defined(G__MSC_VER) || defined(_MSC_VER)
#include <iostream>
#include <strstream>
using namespace std;
#elif (defined(G__GNUC)&&(G__GNUC>=3)) || (defined(__GNUC__)&&(__GNUC__>=3))
#include <iostream>
#include <strstream>
using namespace std;
#else
#include <iostream.h>
#include <strstream.h>
#endif

#include <stdio.h>

#if defined(__CINT__) && !defined(INTERPRET)
#pragma include "test.dll"
#else
#include "t705.h"
#endif

int main() {
  char a[10];
  int i;
  for (i=0; i<3; i++){
    if(i == 0) continue;
    istrstream is(" aa bb cc ");
    is >> a;
    cout << "a: " << a << endl;
  }
  //abc:
  for(i=0;i<3;i++) {
    if(i==0) continue;
    A b(i);
    printf("b:%d\n",b.get());
    //if(0) goto abc;
  }
  return 0;
}
