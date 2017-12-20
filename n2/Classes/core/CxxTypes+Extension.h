
# ifndef __CXXTYPESEXTENSION_5A11FD2AFC284792B895357AC25D2CE9_H_INCLUDED
# define __CXXTYPESEXTENSION_5A11FD2AFC284792B895357AC25D2CE9_H_INCLUDED
# ifdef CXX_MODE

template <typename T>
inline void* object_memdup(T const& o)
{
    void* ret = malloc(sizeof(T));
    memcpy(ret, &o, sizeof(T));
    return ret;
}

template <typename T, typename R>
inline void object_memcpy(R* m, T const& o)
{
    memcpy((void*)m, &o, sizeof(T));
}

typedef struct {} refobj_type;
template <typename T>
class RefObject : public refobj_type
{
public:
    RefObject() : _refcnt(1)
    {}
    
    virtual T* addref() const {
        ++_refcnt;
        return (T*)this;
    }
    
    virtual T* decref() const {
        if (--_refcnt) {
            delete this;
            return NULL;
        }
        return (T*)this;
    }
    
    virtual long refcount() const {
        return _refcnt;
    }
    
protected:
    mutable long _refcnt;
};

# define pcall(obj, func) if ((obj)) (obj)->func

typedef struct {} true_type;
typedef struct {} false_type;

template <typename TT, typename FT, bool B>
struct truefalse_type
{
    typedef TT type;
};

template <typename TT, typename FT>
struct truefalse_type <TT, FT, false>
{
    typedef FT type;
};

template <typename L, typename R>
L type_cast(R const&);

template <typename L, typename R>
L present_cast(R const&);

# define safe_call(obj, func) if (obj) (obj)->func;
# define safe_pcall(obj, func) if (obj && *obj) (*obj)->func;

template <typename T, typename TD>
class is_derived
{
public:
    
    static int _check(TD*);
    static int _check(TD const*);
    
    static char _check(void*);
    static char _check(void const*);
    
    enum
    {
        VALUE = sizeof(int) == sizeof(_check((T*)0))
    };
    
    typedef typename truefalse_type< ::true_type, ::false_type, VALUE>::type type;
};

template <typename T>
struct mixin_type
{
    typedef T type;
    typedef T& ref_type;
    typedef T const& cref_type;
    typedef T* ptr_type;
    typedef T const* cptr_type;
};

template <typename T>
struct mixin_type <T const>
{
    typedef T type;
    typedef T& ref_type;
    typedef T const& cref_type;
    typedef T* ptr_type;
    typedef T const* cptr_type;
};

template <typename T>
struct mixin_type <T&>
{
    typedef T type;
    typedef T& ref_type;
    typedef T const& cref_type;
    typedef T* ptr_type;
    typedef T const* cptr_type;
};

template <typename T>
struct mixin_type <T const&>
{
    typedef T type;
    typedef T& ref_type;
    typedef T const& cref_type;
    typedef T* ptr_type;
    typedef T const* cptr_type;
};

template <typename T>
struct mixin_type <T*>
{
    typedef T type;
    typedef T& ref_type;
    typedef T const& cref_type;
    typedef T* ptr_type;
    typedef T const* cptr_type;
};

template <typename T>
struct mixin_type <T const*>
{
    typedef T type;
    typedef T& ref_type;
    typedef T const& cref_type;
    typedef T* ptr_type;
    typedef T const* cptr_type;
};

template <typename T>
struct mixin_type <T *const>
{
    typedef T type;
    typedef T& ref_type;
    typedef T const& cref_type;
    typedef T* ptr_type;
    typedef T const* cptr_type;
};

template <>
struct mixin_type <void*>
{
    typedef void type, ref_type;
    typedef void const cref_type;
    typedef void* ptr_type;
    typedef void const* cptr_type;
};

template <typename T>
inline void safe_delete(T*& o)
{
    if (o)
    {
        delete o;
        o = NULL;
    }
}

inline void safe_free(void*& o)
{
    if (o)
    {
        free(o);
        o = NULL;
    }
}

template <typename T,
typename X = typename is_derived<T, refobj_type>::type>
struct _safe_retain
{
    T* operator () (T* o)
    {
        if (o)
            o->retain();
            return o;
    }
};

template <typename T>
struct _safe_retain <T, ::false_type>;

template <typename T>
inline T* safe_retain(T* o)
{
    return _safe_retain<T>()(o);
}

template <typename T>
inline T* safe_retain(T const* o)
{
    return _safe_retain<T>()(down_const(o));
}

template <typename T>
inline T safe_retain(T o)
{
    return o;
}

template <typename T,
typename X = typename is_derived<T, refobj_type>::type>
struct _safe_release
{
    
    void operator () (T*& o)
    {
        if (o)
        {
            int cnt = o->retainCount();
            T* obj = o;
            if (cnt == 1)
                o = NULL;
                
                obj->release();
                }
    }
    
};

template <typename T>
struct _safe_release <T, ::false_type>
{
    void operator () (T*& o)
    {
        safe_delete(o);
    }
};

template <typename T>
inline void safe_release(T*& o)
{
    _safe_release<T>()(o);
}

template <typename T>
inline void safe_release(T o)
{
}

template <typename T,
typename X = typename is_derived<T, refobj_type>::type>
struct _zero_release
{
    void operator () (T*& o)
    {
        T* obj = o;
        if (obj)
        {
            o = NULL;
            obj->release();
        }
    }
};

template <typename T>
struct _zero_release <T, ::false_type>
{
    void operator () (T*& o)
    {
        safe_delete(o);
    }
};

template <typename T>
inline void zero_release(T*& o)
{
    _zero_release<T>()(o);
}

template <typename T>
inline T& down_const(T const& r)
{
    return const_cast<T&>(r);
}

template <typename T>
inline T& down_const(T& r)
{
    return r;
}

template <typename T>
inline T* down_const(T const* r)
{
    return const_cast<T*>(r);
}

template <typename T>
inline T*& down_const(T*& r)
{
    return r;
}

template <typename T>
inline T const& up_const(T& r)
{
    return r;
}

template <typename T>
inline T const& up_const(T const& r)
{
    return r;
}

template <typename T>
inline T const* up_const(T* r)
{
    return r;
}

template <typename T>
inline T const* up_const(T const* r)
{
    return r;
}

template <typename T>
inline T& ref_cast(T& r)
{
    return r;
}

template <typename T>
inline T& ref_cast(T* r)
{
    return *r;
}

template <typename T>
inline T& ref_cast(T const& r)
{
    return down_const(r);
}

template <typename T>
inline T& ref_cast(T const* r)
{
    return *down_const(r);
}

template <typename T>
inline T const& cref_cast(T& r)
{
    return r;
}

template <typename T>
inline T const& cref_cast(T* r)
{
    return *r;
}

template <typename T>
inline T const& cref_cast(T const& r)
{
    return r;
}

template <typename T>
inline T const& cref_cast(T const* r)
{
    return *r;
}

template <typename T>
inline T*& ptr_cast(T*& r)
{
    return r;
}

template <typename T>
inline T*& ptr_cast(T const*& r)
{
    return (T*&)r;
}

template <typename T>
inline T*& ptr_cast(T& r)
{
    return &r;
}

template <typename T>
inline T* ptr_cast(T const& r)
{
    return (T*)&r;
}

template <typename T>
inline T*& ptr_cast(T** r)
{
    return *r;
}

template <typename T>
inline T*& ptr_cast(T const** r)
{
    return (T*&)*r;
}

template <typename T>
inline T const* cptr_cast(T* r)
{
    return r;
}

template <typename T>
inline T const* cptr_cast(T const* r)
{
    return r;
}

template <typename T>
inline T const* cptr_cast(T** r)
{
    return *r;
}

template <typename T>
inline T const* cptr_cast(T const** r)
{
    return *r;
}

template <typename T>
inline T const* cptr_cast(T& r)
{
    return &r;
}

template <typename T>
inline T const* cptr_cast(T const& r)
{
    return &r;
}

template <typename T>
class AutoPtr
{
    AutoPtr(AutoPtr const&);
    
public:
    
    AutoPtr()
    : _o(NULL)
    {
        
    }
    
    AutoPtr(void* o)
    : _o((T*)o)
    {
        
    }
    
    AutoPtr(T* o)
    : _o(o)
    {
        
    }
    
    ~AutoPtr()
    {
        zero_release(_o);
    }
    
    operator T& ()
    {
        return *_o;
    }
    
    operator T const& () const
    {
        return *_o;
    }
    
    operator T* ()
    {
        return _o;
    }
    
    operator T const* () const
    {
        return _o;
    }
    
    T* operator -> ()
    {
        return _o;
    }
    
    T const* operator -> () const
    {
        return _o;
    }
    
    /* C++11
     template <typename C>
     explicit operator C* ()
     {
     return (C*)_o;
     }
     
     template <typename C>
     explicit operator C const* () const
     {
     return (C const*)_o;
     }
     */
    
    void reset(T* o)
    {
        if (_o == o)
            return;
        
        zero_release(_o);
        _o = o;
    }
    
    AutoPtr& operator = (T* r)
    {
        reset(r);
        return *this;
    }
    
    T* ptr()
    {
        return _o;
    }
    
    T const* ptr() const
    {
        return _o;
    }
    
    bool null() const
    {
        return _o == NULL;
    }
    
    T& operator * ()
    {
        return *_o;
    }
    
    T const& operator * () const
    {
        return *_o;
    }
    
protected:
    
    T* _o;
    
private:
    
    AutoPtr& operator = (AutoPtr& r);
    
};

template <typename T>
class AutoInstance
: public AutoPtr <T>
{
public:
    
    AutoInstance()
    {
        this->reset(new T);
    }
    
    AutoInstance(T const& r)
    {
        this->reset(new T);
        *this = r;
    }
    
    AutoInstance& renew()
    {
        this->reset(new T);
        return *this;
    }
    
    operator T* ()
    {
        return this->_o;
    }
    
    operator T const* () const
    {
        return this->_o;
    }
    
    T& operator * ()
    {
        return *this->_o;
    }
    
    T const& operator * () const
    {
        return *this->_o;
    }
    
    operator T& ()
    {
        return *this->_o;
    }
    
    operator T const& () const
    {
        return *this->_o;
    }
    
    template <typename R>
    T& operator = (R const& r) const
    {
        return *this->_o = r;
    }
    
};
    
template <typename T>
class SharedPtr
{
public:
    
    SharedPtr()
    : _o(NULL)
    {
        
    }
    
    explicit SharedPtr(T* r)
    : _o(r)
    {
        safe_retain(_o);
    }
    
    explicit SharedPtr(AutoPtr<T>& r)
    : _o(r)
    {
        safe_retain(_o);
    }
    
    SharedPtr(SharedPtr& r)
    : _o(r._o)
    {
        safe_retain(_o);
    }
    
    SharedPtr(SharedPtr const& r)
    : _o((T*)r._o)
    {
        safe_retain(_o);
    }
    
    template <typename R>
    SharedPtr(R* r)
    : _o((T*)r)
    {
        safe_retain(_o);
    }
    
    ~SharedPtr()
    {
        zero_release(_o);
    }
    
    operator T& ()
    {
        return *_o;
    }
    
    operator T const& () const
    {
        return *_o;
    }
    
    operator T* ()
    {
        return _o;
    }
    
    operator T const* () const
    {
        return _o;
    }
    
    template <typename C>
    operator C* ()
    {
        return (C*)_o;
    }
    
    template <typename C>
    operator C const* () const
    {
        return (C const*)_o;
    }
    
    T* operator -> ()
    {
        return _o;
    }
    
    T const* operator -> () const
    {
        return _o;
    }
    
    SharedPtr& operator = (T* r)
    {
        reset(r);
        return *this;
    }
    
    SharedPtr& operator = (SharedPtr& r)
    {
        reset(r._o);
        return *this;
    }
    
    void reset(T* o)
    {
        if (_o == o)
            return;
        
        zero_release(_o);
        _o = o;
        safe_retain(_o);
    }
    
    T* ptr()
    {
        return _o;
    }
    
    T*& ref()
    {
        return _o;
    }
    
    T const* ptr() const
    {
        return _o;
    }
    
    bool null() const
    {
        return _o == NULL;
    }
    
    T& operator * ()
    {
        return *_o;
    }
    
    T const& operator * () const
    {
        return *_o;
    }
    
    static SharedPtr<T> Use(T* r)
    {
        SharedPtr<T> ret(NULL);
        ret._o = r;
        return ret;
    }
    
protected:
    
    T* _o;
    
};
    
class Any
{
public:
    
    Any(void* obj)
    : _obj(obj)
    {
        
    }
    
    template <typename T>
    operator T* ()
    {
        return static_cast<T*>(_obj);
    }
    
    template <typename T>
    operator T const* () const
    {
        return static_cast<T const*>(_obj);
    }
    
    template <typename T>
    operator T& ()
    {
        return *(T*)(*this);
    }
    
    template <typename T>
    operator T const& () const
    {
        return *(T const*)(*this);
    }
    
    Any& operator = (void* r)
    {
        _obj = r;
        return *this;
    }
    
protected:
    
    void* _obj;
    
};
    
template <typename T>
class Use
{
public:
    
    Use()
    : _obj(NULL)
    {
        
    }
    
    Use(void* r)
    : _obj((T*)r)
    {
        
    }
    
    Use(void const* r)
    : _obj((T*)r)
    {
        
    }
    
    Use(T* r)
    {
        _obj = r;
    }
    
    Use(T const* r)
    {
        _obj = down_const(r);
    }
    
    Use(Use const& r)
    : _obj((T*)r._obj)
    {
        
    }
    
    template <typename R>
    Use(R const* r)
    : _obj((T*)down_const(r))
    {
        
    }
    
    template <typename R>
    Use(R const& r)
    : _obj((T*)ref_cast(r))
    {
        
    }
    
    operator T* ()
    {
        return _obj;
    }
    
    operator T const* () const
    {
        return _obj;
    }
    
    operator T& ()
    {
        return *_obj;
    }
    
    operator T const& () const
    {
        return *_obj;
    }
    
    T* operator -> ()
    {
        return _obj;
    }
    
    T const* operator -> () const
    {
        return _obj;
    }
    
    T* ptr()
    {
        return _obj;
    }
    
    T const* ptr() const
    {
        return _obj;
    }
    
    bool null() const
    {
        return _obj == NULL;
    }
    
protected:
    
    T* _obj;
    
};
    
template <typename T>
class Value
{
public:
        
    Value(T const& v = 0)
    : _v(v)
    {
        
    }
    
    template <typename R>
    Value(R const& r)
    : _v((T)r)
    {
        
    }
    
    operator T& ()
    {
        return _v;
    }
    
    operator T const& () const
    {
        return _v;
    }
    
    /*
     operator T* ()
     {
     return &_v;
     }
     
     operator T const* () const
     {
     return &_v;
     }
     */
    
    void reset()
    {
        _v = 0;
    }
    
    bool null() const
    {
        return _v == 0;
    }
    
    Value& operator = (Value const& r)
    {
        _v = r._v;
        return *this;
    }
    
    T& operator * ()
    {
        return _v;
    }
    
    T const& operator * () const
    {
        return _v;
    }
    
    T& operator () ()
    {
        return _v;
    }
    
    T const& operator () () const
    {
        return _v;
    }
    
    T* ptr()
    {
        return &_v;
    }
    
    T const* ptr() const
    {
        return &_v;
    }
    
    T& ref()
    {
        return _v;
    }
    
    T const& ref() const
    {
        return _v;
    }
    
    typename mixin_type<T>::ptr_type operator -> ()
    {
        return ptr_cast(_v);
    }
    
    typename mixin_type<T>::cptr_type operator -> () const
    {
        return cptr_cast(_v);
    }
    
protected:
    
    T _v;
    
};
    
template <typename T, T V = 0>
class ValueSp
: public Value <T>
{
        
public:
        
    ValueSp(T v = V)
    {
        this->_v = v;
    }
    
};
    
template <typename T>
class Mask
{
public:
        
    Mask(T v)
    : val(v)
    {
        
    }
    
    bool on(T v) const
    {
        return ((v & val) == v);
    }
    
    Mask& set_on(T v)
    {
        val |= v;
        return *this;
    }
    
    Mask& set_off(T v)
    {
        val &= ~v;
        return *this;
    }
    
    template <typename R>
    R get(T v, R r, R def = (R)0) const
    {
        if (on(v))
            return r;
        return def;
    }
    
    T val;
};

# include <map>
# include <vector>

# ifdef OBJC_MODE
NS_BEGIN(ns)

class Id
{
public:
    
    Id();
    Id(Id const&);
    ~Id();
    
    void set(id) const;
    id get() const;
    
    template <typename T>
    operator T () {
        return get();
    }
    
    Id& operator = (id o) {
        set(o);
        return *this;
    }
    Id& operator = (void*);
    
    BOOL operator == (id o) const;
    BOOL operator != (id o) const {
        return !(*this == o);
    }
    
protected:
    mutable void* _obj;
};

template <typename T>
class Object : public Id
{
public:
    using Id::operator =;
    
    operator T* () const {
        return get();
    }
    
    T* operator * () const {
        return get();
    }
    
    void cmd(void(^block)(T* obj)) {
        block(*this);
    }
};

template <typename Tid>
inline void zero_release(::std::vector<Tid>& ctr) {
    for (auto i = ctr.begin(); i != ctr.end(); ++i) {
        ZERO_RELEASE(*i);
    }
}

template <typename Tk, typename Tv>
inline void zero_release(::std::map<Tk, Tv>& ctr) {
    for (auto i = ctr.begin(); i != ctr.end(); ++i) {
        ZERO_RELEASE(i->second);
    }
}

NS_END
# endif // objc
    
# endif // c++
# endif // h
