
# import "Common.h"
# import "NSWeakTypes.h"

@interface NSWeakArray () {
    ::std::vector<id> _store;
}

@end

@implementation NSWeakArray

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)addObject:(id)obj {
    _store.push_back(obj);
}

- (void)foreach:(BOOL (^)(id))block {
    for (::std::vector<id>::iterator iter = _store.begin();
         iter != _store.end();
         ++iter)
    {
        if (block(*iter) == NO)
            break;
    }
}

- (void)removeObject:(id)obj {
    ::std::vector<id>::iterator found = ::std::find(_store.begin(), _store.end(), obj);
    if (found != _store.end())
        _store.erase(found);
}

- (void)removeAllObjects {
    _store.clear();
}

- (NSUInteger)count {
    return _store.size();
}

@end

@interface NSWeakSet () {
    ::std::set<id> _store;
}

@end

@implementation NSWeakSet

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)addObject:(id)obj {
    SYNCHRONIZED_BEGIN
    _store.insert(obj);
    SYNCHRONIZED_END
}

- (void)foreach:(BOOL (^)(id))block {
    SYNCHRONIZED_BEGIN
    for (::std::set<id>::iterator iter = _store.begin();
         iter != _store.end();
         ++iter)
    {
        if (block(*iter) == NO)
            break;
    }
    SYNCHRONIZED_END
}

- (void)removeObject:(id)obj {
    SYNCHRONIZED_BEGIN
    ::std::set<id>::iterator found = ::std::find(_store.begin(), _store.end(), obj);
    if (found != _store.end())
        _store.erase(found);
    SYNCHRONIZED_END
}

- (void)removeAllObjects {
    SYNCHRONIZED_BEGIN
    _store.clear();
    SYNCHRONIZED_END
}

- (NSUInteger)count {
    SYNCHRONIZED_BEGIN
    return _store.size();
    SYNCHRONIZED_END
}

@end

@interface NSRawObjectVector ()
{
    ::std::vector<void*> _vec;
}

@end

@implementation NSRawObjectVector

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [self removeAllObjects];
    [super dealloc];
}

- (void*)allocObject:(size_t)size {
    void* ret = malloc(size);
    _vec.push_back(ret);
    return ret;
}

- (void*)objectAtIndex:(NSUInteger)idx {
    return _vec[idx];
}

- (NSUInteger)count {
    return _vec.size();
}

- (void)removeAllObjects {
    ::std::for_each(_vec.begin(), _vec.end(), free);
    _vec.clear();
}

@end
