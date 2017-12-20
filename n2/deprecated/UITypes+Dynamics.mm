
# import "Common.h"
# import "UITypes+Extension.h"
# import "UITypes+Dynamics.h"

/*
# import <Box2D/Box2D.h>

class UIBox2d
: public b2ContactListener
{
public:
    
    UIBox2d();
    ~UIBox2d();
    
   	virtual void BeginContact(b2Contact* contact);
	virtual void EndContact(b2Contact* contact);
	virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
	virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    
    // 每一帧的处理
    void frame();
    
    b2World world;
    UIView* view;
};

UIBox2d::UIBox2d()
: world(b2Vec2(0, -10))
{
   
}

UIBox2d::~UIBox2d()
{
    
}

void UIBox2d::BeginContact(b2Contact *contact)
{
    B2_NOT_USED(contact);
}

void UIBox2d::EndContact(b2Contact *contact)
{
    B2_NOT_USED(contact);
}

void UIBox2d::PreSolve(b2Contact *contact, const b2Manifold *oldManifold)
{
    
}

void UIBox2d::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse)
{
    B2_NOT_USED(contact);
    B2_NOT_USED(impulse);
}

@interface UIViewBox2dExtension : NSObjectExt
{
@public
    UIBox2d box2d;
}

@property (nonatomic, assign) b2Body* body;

@end

@implementation UIViewBox2dExtension

- (void)onInit {
    [super onInit];
    [[CADisplayStage shared].signals connect:kSignalNextFrame withSelector:@selector(cbNextFrame:) ofTarget:self];
}

- (void)onFin {
    [super onFin];
}

- (void)cbNextFrame:(SSlot*)s {
    CADisplayStage* stage = (CADisplayStage*)s.sender;
    box2d.world.Step(stage.frameInterval, 8, 3);
    box2d.frame();
}

@end

@interface UIView (box2d)

@property (nonatomic, readonly) UIViewBox2dExtension *box2d;

@end

@implementation UIView (box2d)

NSOBJECT_DYNAMIC_PROPERTY_READONLY_EXT(UIView, box2d, UIViewBox2dExtension, {
    [self.signals connect:kSignalBoundsChanged withSelector:@selector(__cb_uiviewdyn_boundschanged:) ofTarget:self];
    val->box2d.view = self;
});

@end

void UIBox2d::frame()
{
    for (UIView* each in view.subviews) {
        if (each.isDynamicsShape == NO)
            continue;
        if (each.box2d.body == NULL)
            continue;
        b2Vec2 const& pos = each.box2d.body->GetPosition();
        float ang = each.box2d.body->GetAngle();
        each.transform = CGAffineTransformMakeRotation(ang);
        [each setAbsolutePosition:CGPointMake(pos.x, pos.y)];
    }
}

 */
 
@implementation UIView (dynamics)

NSOBJECT_DYNAMIC_PROPERTY_IMPL_REGULAR(UIView, isDynamicsShape, setIsDynamicsShape, BOOL, {
    [NSBoolean boolean:val]
}, {
    ((NSBoolean*)val).boolValue
}, RETAIN_NONATOMIC);

/*
- (void)enableDynamics {
    [self box2d];
}

- (void)__cb_uiviewdyn_boundschanged:(SSlot*)s {
    //NSRect* rc = s.data.object;
    
    // 加入每一个shape
    for (UIView* each in self.subviews)
    {
        if (each.isDynamicsShape == NO)
            continue;
        
        AutoPtr<b2Shape> shape([self shapeForView]);
        
        CGRect rc = each.frame;
        b2BodyDef bd;
        bd.type = b2_dynamicBody;
        bd.position.Set(rc.origin.x, rc.origin.y);
    
        each.box2d.body = self.box2d->box2d.world.CreateBody(&bd);
        each.box2d.body->CreateFixture(shape, 1);
    }
}

- (b2Shape*)shapeForView {
    CGRect rc = self.frame;
    b2PolygonShape* shape = new b2PolygonShape;
    shape->SetAsBox(rc.size.width, rc.size.height);
    return shape;
}
 */

@end
