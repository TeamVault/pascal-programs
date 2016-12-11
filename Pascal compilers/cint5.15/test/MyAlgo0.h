// MyAlgo0.h

#if defined(__GNUC__) && (__GNUC__>=3)
#include <iostream>
using namespace std;
#else
#include <iostream.h>
#endif

// コンテナ中の全要素を表示するアルゴリズム
template<class InputIter> 
void Disp(InputIter first,InputIter last)
{
  while(first!=last) cout << *first++ << " " ;
  cout << endl;
}

// コンテナ中の全要素の総和を求めるアルゴリズム
template<class T,class InputIter> 
T Sum(InputIter first,InputIter last,const T initval)
{
  T sum = initval;
  while(first!=last) sum += *first++ ;
  return(sum);
}
