#if defined(__GNUC__) && (__GNUC__>=3)
#include <iostream>
using namespace std;
#else
#include <iostream.h>
#endif

int main() {
  int a[100] = { 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20};
  int b;
  int *p = a;
  int i;
  for(i=0;i<10;i++) {
    b = *++p /* + *++p */;
    cout << "i=" << i << " b=" << b << endl;
  }
  p=a;
  for(i=0;i<10;i++) {
    b = *p++ /* + *p++ */;
    cout << "i=" << i << " b=" << b << endl;
  }
  return 0;
}
