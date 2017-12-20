
# import "Common.h"
# import "Objc+Extension.h"
# import <objc/objc.h>
# import <objc/objc-sync.h>

id class_callMethod(Class cls, SEL sel, ...) {
    Method mtd = class_getClassMethod(cls, sel);
    IMP imp = method_getImplementation(mtd);
    char ctype;
    method_getReturnType(mtd, &ctype, sizeof(char));
    
    va_list va;
    va_start(va, sel);
    id argu = va_arg(va, id);
    
    id ret = nil;
    if (ctype == _C_ID) {
        ret = ((id(*)(id, SEL, id))imp)(nil, sel, argu);
    } else {
        ((void(*)(id, SEL, id))imp)(nil, sel, argu);
    }
    
    va_end(va);
    return ret;
}

id object_getProperty(id obj, objc_property_t prop) {
    Class cls = object_getClass(obj);
    char const* propName = property_getName(prop);
    SEL propSel = sel_getUid(propName);
    if (propSel == @selector(description) ||
        propSel == @selector(debugDescription))
        return nil;
    Method mtd = class_getInstanceMethod(cls, propSel);
    IMP imp = method_getImplementation(mtd);
    id propObj = ((id(*)(id, SEL))imp)(obj, propSel);
    return propObj;
}

id object_getPropertyObject(id obj, objc_property_t prop) {
    Class cls = object_getClass(obj);
    char const* propName = property_getName(prop);
    SEL propSel = sel_getUid(propName);
    if (propSel == @selector(description) ||
        propSel == @selector(debugDescription))
        return nil;
    Method mtd = class_getInstanceMethod(cls, propSel);
    char rtype;
    method_getReturnType(mtd, &rtype, 1);
    if (rtype != _C_ID)
        return nil;
    IMP imp = method_getImplementation(mtd);
    id propObj = ((id(*)(id, SEL))imp)(obj, propSel);
    return propObj;
}

BOOL property_isReadonly(objc_property_t prop) {
    char const* str = property_getAttributes(prop);
    return strstr(str, "R") != NULL;
}

BOOL class_existMethod(Class cls, SEL sel) {
    Method mtd = class_getClassMethod(cls, sel);
    return mtd != NULL;
}

void class_swizzleMethod(Class c, SEL origs, SEL news) {
    Method origMethod = class_getInstanceMethod(c, origs);
    Method newMethod = class_getInstanceMethod(c, news);
    if(class_addMethod(c, origs, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, news, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

IMP class_getImplementation(Class c, SEL sel) {
    return method_getImplementation(class_getInstanceMethod(c, sel));
}

char const* objc_getClassName(id obj) {
    return class_getName([obj class]);
}

/*
id object_invokeSelector(id obj, SEL sel, id argu) {
    id ret = objc_msgSend(obj, sel, argu);
    return ret;
}

id object_syncInvokeSelector(id obj, SEL sel, id argu) {
    int sta = objc_sync_enter(obj);
    if (sta != OBJC_SYNC_SUCCESS)
        WARN("object sync 上锁失败");
    id ret = object_invokeSelector(obj, sel, argu);
    if (sta == OBJC_SYNC_SUCCESS) {
        sta = objc_sync_exit(obj);
        if (sta != OBJC_SYNC_SUCCESS)
            WARN("object sync 解锁失败");
    }
    return ret;
}
 */

@implementation NSObject (swizzle)

+ (BOOL)SwizzleMethod:(SEL)sel with:(SEL)tosel with:(objc_swizzle_t *)data {
    data->cls = [self class];
    data->pimpl = class_getImplementation(data->cls, sel);
    data->psel = sel;
    if (data->pimpl == nil)
        return NO;
    data->impl = class_getImplementation(data->cls, tosel);
    if (data->impl == nil)
        return NO;
    data->sel = tosel;
    class_swizzleMethod(data->cls, sel, tosel);
    return YES;
}

+ (void)Swizzles {
    PASS;
}

@end
