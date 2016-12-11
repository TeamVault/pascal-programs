/******************************************************
* sin.c
*
* array pre-compiled class library is needed to run 
* this demo program.
******************************************************/
#include <array.h>
main() {
  double height = 3.0, width = 200.0;
  array x=array(0 , width , 100 ); // start,stop,npoint
  plot << x << (cos(x/5)+sin(x/7))*height/4 << "\n" ;
}
