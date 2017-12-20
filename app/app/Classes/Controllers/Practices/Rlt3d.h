
# include "UIIrrlichtController.h"

typedef enum {
    kRltTagNormalPoint = 0, // 普通点
    kRltTagSourcePoint = 1, // 发源点
} RltTagType;

typedef struct {
    double longitude, latitude; // 热点的经纬度
    RltTagType type; // 热点的类型
    float radius; // 热点的半径
} RltTag;

# ifdef CXX_MODE

IRR_USING;

class RltTagPoint
: public ISceneNode
{
protected:
    
    class TagInfo
    {
    public:
        
        // 旋转
        quaternion ang;
        
        // 位置
        vector3df pos;
        
        // 缩放、缩放的步进
        float sco, sct;
        
        // 半径
        float radius;
    };
    
public:
    
    RltTagPoint(RltTagType _type, ISceneNode* parent, ISceneManager* mgr, s32 idr = -1);
    virtual ~RltTagPoint();
    
    virtual void OnRegisterSceneNode();    
    virtual void render();
    virtual const aabbox3df& getBoundingBox() const
    {
        return Parent->getBoundingBox();
    }
    
    virtual u32 getMaterialCount() const
    {
        return 1;
    }
    
    virtual video::SMaterial& getMaterial(u32 i = 0)
    {
        return Material;
    }
    
    // 添加一个热点信息
    void addHot(triangle3df const& tri, vector3df const& pos, RltTag const& pt);
    
protected:
    RltTagType type;
    core::array<S3DVertex> Vertices;
    core::array<u16> Indices;
    SMaterial Material;
    core::array<TagInfo> _taginfos;
};

class RltWorld
{
public:
    
    RltWorld(IrrlichtDevice* device);
    virtual ~RltWorld();
    
    // 创建
    void createScreen();
    
    ICameraSceneNode* getCamera()
    {
        return _pnCamera;
    }

    // 添加热点
    void addTagPoint(RltTag const& pt);

    // 停止
    void pause();
    
    // 恢复
    void resume();
    
    // 缩放
    void scale(float scale);
    
    // 平移
    void move(float x, float y);
    
    // 旋转
    void rotate(position2df const& pt);
    
    // 居中某个点
    void centerAt(position2df const& pt);
    
    // 屏幕尺寸
    dimension2df screenSize;
    
protected:
    
    // 球的大小
    float _radiusSphere;
    
    // 屏幕对象
    IrrlichtDevice* _device;
    ISceneNode *_pnEarth, *_pnAtom;
    RltTagPoint *_pnNormalTags, *_pnSourceTags;
    ITriangleSelector *_pkEarth;
    //ISceneNodeAnimator *_aniRot;
    ICameraSceneNode *_pnCamera;
    
    // 交互相关
    position2df _ptTouch;
};

# endif // c++
