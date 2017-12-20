
# import "Common.h"
# import "Variant.h"

@implementation Variant

+ (Variant*)variantWithObject:(id)obj {
    return [[[self alloc] initWithObject:obj] autorelease];
}

+ (Variant*)variantWithPtr:(void *)obj {
    return [[[self alloc] initWithPtr:obj] autorelease];
}

- (id)init {
    self = [super init];
    return self;
}

- (id)initWithObject:(id)obj {
    if ((self = [self init]))
        _refobj = [obj retain];
    return self;
}

- (id)initWithPtr:(void *)obj {
    if ((self = [self init]))
        _ptrobj = obj;
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_refobj);
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    Variant* ret = [[[self class] alloc] init];
    ret->_refobj = [_refobj retain];
    ret->_ptrobj = _ptrobj;
    ret.number = self.number;
    return ret;
}

- (id)object {
    if (_refobj)
        return _refobj;
    if (_ptrobj)
        return (id)_ptrobj;    
    return nil;
}

- (NSString*)description {
    if (_refobj)
        return [_refobj description];
    if (_ptrobj)
        return [NSString stringWithFormat:@"pointer: %tx", (ptrdiff_t)_ptrobj];
    return [NSString stringWithFormat:@"Variant: %tx", (ptrdiff_t)self];
}

@end
