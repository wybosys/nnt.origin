
# import "Common.h"
# import "CxxTypes+Extension.h"

NS_BEGIN(ns)

Id::Id()
{

}

Id::Id(Id const& r)
{
    set(r.get());
}

Id::~Id()
{
    [(id)_obj release];
    _obj = nil;
}

Id& Id::operator = (void* p)
{
    set((id)p);
    return *this;
}

void Id::set(id o) const
{
    if (_obj == o)
        return;
    [(id)_obj release];
    _obj = [o retain];
}

id Id::get() const
{
    return (id)_obj;
}

BOOL Id::operator == (id o) const
{
    return [NSObject IsEqual:get() to:o];
}

NS_END
