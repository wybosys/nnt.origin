
# ifndef __COMMON_C72804D9231745458B1B87337F88F6B8_H_INCLUDED
# define __COMMON_C72804D9231745458B1B87337F88F6B8_H_INCLUDED

# import "Compiler.h"

# ifdef OBJC_MODE
#   import "Architect.h"
#   import "SSObject.h"
#   import "NSTypes+Extension.h"
# endif

# ifdef CXX_MODE
#   include <iostream>
#   include <string>
#   include <vector>
#   include <list>
#   include <map>
#   include <set>
#   include <deque>
#   include <stack>
NS_USING(::std);
#   include "CxxTypes+Extension.h"
# endif

# ifdef IOS_DEVICE
#   import "UITypes+Extension.h"
# endif

# endif
