
# import "Common.h"
# import "Architect.h"

Class PrivateClass_FromObject(id obj)
{
    Class cls = [obj class];
    char const* ccls = class_getName(cls);
    NSString* str = [NSString stringWithFormat:@"PrivateClass_%s", ccls];
    return NSClassFromString(str);
}