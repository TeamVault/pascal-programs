/***********************************************************************
* VObject.cxx , C++
*
************************************************************************
* Description:
*
***********************************************************************/

#if defined(__GNUC__) && (__GNUC__>=3)
#include <iostream>
using namespace std;
#else
#include <iostream.h>
#endif
#include "VObject.h"

///////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
VObject::VObject()
{
}

///////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
VObject::VObject(VObject& x)
{
}

///////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
VObject& VObject::operator=(VObject& x)
{
  cerr << "VObject::operator=() must be overridden" << endl;  
  return x;
}

///////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////
VObject::~VObject()
{
  //cerr << "VObject::~VObject() must be overridden" << endl;  
}



