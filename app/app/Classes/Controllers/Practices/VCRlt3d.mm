
# import "app.h"
# import "VCRlt3d.h"
# include "Rlt3d.h"

@interface VCRlt3d ()
{
    RltWorld* _world;
}

@end

@implementation VCRlt3d

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    zero_release(_world);
    [super onFin];
}

- (void)start {
    if (_world == NULL)
    {
        // 实例化场景
        _world = new RltWorld(self.device);
        
        // 调整初始显示
        CGSize sz = self.view.frame.size;
        _world->screenSize.set(sz.width, sz.height);
        _world->createScreen();
    }
    
    [super start];
}

- (void)pause {
    _world->pause();
}

- (void)resume {
    _world->resume();
}

- (void)addTagPoint:(RltTag)pt {
    _world->addTagPoint(pt);
}

- (void)rotateScene:(CGPoint)per {
    _world->rotate(dimension2df(per.x, per.y));
}

- (void)zoomScene:(float)scale {
    _world->scale(scale);
}

- (void)moveScene:(CGPoint)per {
    _world->move(per.x, per.y);
}

- (void)centerScene:(CGPoint)per {
    _world->centerAt(position2df(per.x, per.y));
}

- (void)irrlichtRender:(UIIrrlichtView *)view {
    //LOG("FPS: %d", (int)self.driver->getFPS());
}

@end