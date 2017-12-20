
# include "Common.h"
# include "Rlt3d.h"
# include <Irrlicht/CSceneNodeAnimatorRotation.h>

extern real random_between(real l, real h);
extern float kUIScreenScale;
static double M_DEGREE = M_PI/180;

static void RltRotateNode(ISceneNode* node, float ang, vector3df const& axis)
{
    core::quaternion q;
    q.fromAngleAxis(ang*DEGTORAD, axis);
    core::matrix4 m1 = q.getMatrix();
    node->updateAbsolutePosition();
    core::matrix4 m2 = node->getAbsoluteTransformation();
    core::matrix4 m = m1*m2;
    core::vector3df rot = m.getRotationDegrees();
    node->setRotation(rot);
    node->updateAbsolutePosition();
}

/*
static float RltGetAngle(vector3df const& l, vector3df const& r)
{
    float length = l.getLengthSQ() * r.getLengthSQ();
    if(equals(length, 0.f))
        return 0;
    return acos(l.dotProduct(r) * core::reciprocal_squareroot(length)) * RADTODEG64;
}
 */

RltTagPoint::RltTagPoint(RltTagType _type, ISceneNode* parent, ISceneManager* mgr, s32 idr)
: ISceneNode(parent, mgr, idr), type(_type)
{
    //Material.Wireframe = true;
    Material.Lighting = false;
    Material.Shininess = 0;
    Material.ZBuffer = ECFN_DISABLED;
    setMaterialType(EMT_TRANSPARENT_ALPHA_CHANNEL);
    
    IVideoDriver* driver = mgr->getVideoDriver();
    if (type == kRltTagNormalPoint)
        setMaterialTexture(0, driver->getTexture("apprlt.bundle/hot.png"));
    else
        setMaterialTexture(0, driver->getTexture("apprlt.bundle/hot2.png"));
}

RltTagPoint::~RltTagPoint()
{
}

void RltTagPoint::OnRegisterSceneNode()
{
    if (IsVisible)
        SceneManager->registerNodeForRendering(this);
    ISceneNode::OnRegisterSceneNode();
}

void RltTagPoint::render()
{
    if (_taginfos.size() == 0)
        return;
    
    // 调整一下亮点的坐标
    // 遍历每一个 face
    for (s32 idx = 0; idx < _taginfos.size(); ++idx)
    {
        TagInfo& ti = _taginfos[idx];
        
        // 如果 sct != 0，则代表需要缩放
        float ani = 1;
        if (ti.sct) {
            ani = ti.sco + ti.sct;
            if (ani >= 1) {
                ti.sct = -ti.sct;
                ani = 1;
            } else if (ani <= 0.5) {
                ti.sct = -ti.sct;
                ani = 0.5;
            } else {
                ani += ti.sct;
            }
            ti.sco = ani;
        }
        
        // 调整点坐标
        S3DVertex& v0 = Vertices[idx * 4];
        S3DVertex& v1 = Vertices[idx * 4 + 1];
        S3DVertex& v2 = Vertices[idx * 4 + 2];
        S3DVertex& v3 = Vertices[idx * 4 + 3];
        
        // 生成目标大小的平面
        float plw = ti.radius * ani;
        v0.Pos.set(-plw, plw, 3);
        v1.Pos.set(plw, plw, 3);
        v2.Pos.set(-plw, -plw, 3);
        v3.Pos.set(plw, -plw, 3);
        
        v0.Pos = ti.ang * v0.Pos;
        v1.Pos = ti.ang * v1.Pos;
        v2.Pos = ti.ang * v2.Pos;
        v3.Pos = ti.ang * v3.Pos;
        
        v0.Pos += ti.pos;
        v1.Pos += ti.pos;
        v2.Pos += ti.pos;
        v3.Pos += ti.pos;
    }
    
    // 绘制
    IVideoDriver* driver = SceneManager->getVideoDriver();
    driver->setMaterial(Material);
    driver->setTransform(video::ETS_WORLD, AbsoluteTransformation);
    driver->drawIndexedTriangleList(Vertices.pointer(), Vertices.size(), Indices.pointer(), _taginfos.size() * 2);
}

void RltTagPoint::addHot(const triangle3df &tri, const vector3df &pos, const RltTag &pt)
{
    TagInfo ti;
    ti.radius = TRIEXPRESS(pt.radius, pt.radius, 32);
    if (type == kRltTagNormalPoint)
    {
        ti.sct = 0.005;
        ti.sco = random_between(0, 1);
    }
    else
    {
        ti.sct = 0;
        ti.sco = 1;
    }
    
    vector3df trin = tri.getNormal().normalize();
    
    // 计算依赖信息
    ti.ang.rotationFromTo(vector3df(0, 0, 1), trin);
    ti.pos = pos;
    _taginfos.push_back(ti);
    
    // 添加索引
    u16 idx = Vertices.size();
    // tri up
    Indices.push_back(idx);
    Indices.push_back(idx + 2);
    Indices.push_back(idx + 1);
    // tri down
    Indices.push_back(idx + 2);
    Indices.push_back(idx + 3);
    Indices.push_back(idx + 1);
    
    // 添加顶点坐标，等同于增加一个正方形
    Vertices.push_back(S3DVertex(vector3df(), trin, SColor(0xffffffff), vector2df(0, 1)));
    Vertices.push_back(S3DVertex(vector3df(), trin, SColor(0xffffffff), vector2df(1, 1)));
    Vertices.push_back(S3DVertex(vector3df(), trin, SColor(0xffffffff), vector2df(0, 0)));
    Vertices.push_back(S3DVertex(vector3df(), trin, SColor(0xffffffff), vector2df(1, 0)));
}

RltWorld::RltWorld(IrrlichtDevice* device)
: _device(device)
{
}

RltWorld::~RltWorld()
{
}

void RltWorld::createScreen()
{
    ISceneManager* scene = _device->getSceneManager();
    IVideoDriver* driver = scene->getVideoDriver();
    
    // 摄像机
    with(scene->addCameraSceneNode(0, vector3df(0, 0, 3000), vector3df(0, 0, 0)), {
        _pnCamera = it;
        it->setProjectionMatrix(matrix4().buildProjectionMatrixOrthoLH(screenSize.Width*2, screenSize.Height*2, 1, 10000), true);
    });
    
    // 光源
    scene->setAmbientLight(SColor(0xffffffff));
    
    // 地球
    _radiusSphere = ::std::min(screenSize.Width, screenSize.Height) / 2 * kUIScreenScale * 0.85;
    with(scene->addSphereSceneNode(_radiusSphere, 50), {
        _pnEarth = it;
        it->setMaterialFlag(EMF_LIGHTING, false);
        //it->setMaterialFlag(EMF_WIREFRAME, true);
        it->setMaterialTexture(0, driver->getTexture("apprlt.bundle/earth.jpg"));
        
        // 为了当添加热点时需要或得到目标的偏远，所以预先设置一个选择器
        _pkEarth = scene->createTriangleSelector(it->getMesh(), it);
        it->setTriangleSelector(_pkEarth);
        _pkEarth->drop();
        
        // 添加标记点
        _pnNormalTags = new RltTagPoint(kRltTagNormalPoint, it, scene);
        _pnNormalTags->drop();
        
        _pnSourceTags = new RltTagPoint(kRltTagSourcePoint, it, scene);
        _pnSourceTags->drop();
    });
    
    // 大气层
    float radiusAtom = _radiusSphere * 512/460;
    with(scene->addBillboardSceneNode(0, dimension2df(radiusAtom*2, radiusAtom*2), vector3df(0, 0, _radiusSphere)), {
        _pnAtom = it;
        it->setMaterialFlag(EMF_LIGHTING, false);
        it->setMaterialType(EMT_TRANSPARENT_ALPHA_CHANNEL);
        it->setMaterialTexture(0, driver->getTexture("apprlt.bundle/air.png"));
    });
    
    // 自动的旋转
    /*
    with(scene->createRotationAnimator(vector3df(0, -.1f, 0)), {
        _aniRot = it;
        _pnEarth->addAnimator(it);
        _aniRot->drop();
    });
     */
}

void RltWorld::addTagPoint(const RltTag &pt)
{
    // 计算出射线
    real lng = pt.longitude * M_DEGREE - M_PI;
    real lat = pt.latitude * M_DEGREE;
    
    line3df ray;
    ray.start = vector3df(0, 0, 0);
    ray.end = vector3df(cos(lat) * cos(lng), sin(lat), cos(lat) * sin(lng)).normalize() * 10000.f;
    
    // 记录选中的位置
    vector3df intersection;
    triangle3df triangle;
    
    ISceneManager* scene = _device->getSceneManager();
    ISceneCollisionManager* coll = scene->getSceneCollisionManager();
    ISceneNode* node = coll->getSceneNodeAndCollisionPointFromRay(ray,
                                                                  intersection,
                                                                  triangle);
    if (node == NULL) {
        WARN("热点不在地球上");
        return;
    }
    
    if (pt.type == kRltTagNormalPoint)
        _pnNormalTags->addHot(triangle, intersection, pt);
    else
        _pnSourceTags->addHot(triangle, intersection, pt);
}

void RltWorld::pause()
{
    /*
    _aniRot->setEnabled(false);
    _aniRot->setStartTime(_device->getTimer()->getTime());
     */
}

void RltWorld::resume()
{
    /*
    _aniRot->setEnabled(true, _device->getTimer()->getTime());
    _aniRot->setStartTime(_device->getTimer()->getTime());
     */
}

void RltWorld::scale(float scale)
{
    _pnEarth->setScale(vector3df(scale));
    
    IBillboardSceneNode* bsn = dynamic_cast<IBillboardSceneNode*>(_pnAtom);
    float radiusAtom = _radiusSphere * 512/460 * scale;
    bsn->setSize(dimension2df(radiusAtom*2, radiusAtom*2));
}

void RltWorld::move(float x, float y)
{
    vector3df d(x/screenSize.Width, y/screenSize.Height, 0);
    d *= _radiusSphere*2;
    
    vector3df pos = _pnEarth->getPosition();
    pos -= d;
    _pnEarth->setPosition(pos);
    
    pos = _pnAtom->getPosition();
    pos -= d;
    _pnAtom->setPosition(pos);
}

void RltWorld::rotate(const position2df &pt)
{
    vector3df old = _pnEarth->getRotation();
    
    // 先旋转一下，再计算是否角度超限
    RltRotateNode(_pnEarth, pt.Y/5, vector3df(1, 0, 0));
    
    // 先不加垂直限制
    /*
    vector3df vec(0, 1, 0);
    matrix4 mat = _pnEarth->getAbsoluteTransformation();
    mat.rotateVect(vec);
    float ang = RltGetAngle(vec, vector3df(0, 1, 0));
    if (ang > 30) {
        // 控制垂直轴偏移
        _pnEarth->setRotation(old);
        _pnEarth->updateAbsolutePosition();
    }
     */
    
    // 水平转动
    RltRotateNode(_pnEarth, -pt.X/2, vector3df(0, 1, 0));
}

void RltWorld::centerAt(const position2df &pt)
{
    // 计算出射线
    real lng = pt.X - 270;
    real lat = -pt.Y;
    _pnEarth->setRotation(vector3df(lat, lng, 0));
}
