#define INTERP
#ifdef INTERP
#include "VObject.cxx"
#include "VPerson.cxx"
#include "VCompany.cxx"
#include "VArray.cxx"
#include "VString.cxx"
#else
#include "VPerson.dll"
#endif

#define NUM 5

void test1() {
  VArray a;
  VPerson* p;
  VCompany* p1;
  Int_t i;
  for(i=0;i<NUM;i++) {
    if(i%2) {
      p=new VPerson("name",i);
      a.Add(p,-1);
    }
    else {
      p1=new VCompany("company",i);
      a.Add(p1,-1);
    }
  }  

  for(i=0;i<NUM;i++) {
    a[i].disp();
  }  

  for(i=0;i<NUM;i++) {
    delete a.Delete(-1,0);
  }  
}

void test2() {
  VArray a;
  //VPerson* p;
  Int_t i;
  for(i=0;i<NUM;i++) {
    if(i%2) a.Add(new VPerson("name",i),-1);
    else    a.Add(new VCompany("company",i),-1);
  }  

  for(i=0;i<NUM;i++) {
    a[i].disp();
  }  

  for(i=0;i<NUM;i++) {
    a.Delete(-1,1);
  }  
}

int main() {
  test1();
  test2();
  return 0;
}
