
# import "Common.h"
# import "UIIrrlichtController.h"
# import "AppDelegate+Extension.h"
# import <OpenGLES/EAGL.h>
# import <OpenGLES/ES1/gl.h>
# import <OpenGLES/ES1/glext.h>
# include <Irrlicht/CIrrDeviceStub.h>
# include <Irrlicht/IImagePresenter.h>
# include <Irrlicht/CIrrDeviceiOS.h>
# import "FileSystem+Extension.h"

using namespace irr;

@interface UIColor (irr)

- (video::SColor)irrColor;

@end

@implementation UIColor (irr)

- (video::SColor)irrColor; {
    return video::SColor(self.argb);
}

@end

class IrrDevice : public CIrrDeviceIPhone
{
public:
    IrrDevice(SIrrlichtCreationParameters const& param)
    : CIrrDeviceIPhone(param)
    {
    }
};

@interface UIIrrlichtView ()
{
    IrrDevice* _device;
    ns::Object<UIView> _glview;
    CADisplayStage *_stage;
    BOOL _stop;
    
    DEBUG_EXPRESS(long _framecnt);
}

@end

@implementation UIIrrlichtView

- (void)onInit {
    [super onInit];
    self.userInteractionEnabled = NO;
    
    // 创建场景
    [self createScene];
    
    // 渲染控制
    _stage = [CADisplayStage new];
    _stage.asyncMode = NO; // 同步模式
    _stage.fps = 60;
    [_stage.signals connect:kSignalTakeAction withSelector:@selector(cbRenderFrame) ofTarget:self];
}

- (void)onFin {
    // 清理场景
    [self removeScene];
    
    // 清理其他数据
    ZERO_RELEASE(_stage);
    [super onFin];
}

- (void)createScene {
    // 从引擎中获得到渲染用的 view
    UIWindow* tmp = [UIWindow temporary];
    
    SIrrlichtCreationParameters param;
    param.DriverType = video::EDT_OGLES2;
    param.WindowSize = core::dimension2d<u32>(0, 0);
    param.WindowId = (OBJC_ARC_SYMBOL(__bridge) void*)tmp;
    param.Bits = 24;
    param.ZBufferBits = 16;
    param.AntiAlias = 0;
    param.OGLES2ShaderPath = "irrlicht-shaders.bundle/";
    param.WithAlphaChannel = true;
    
    _device = new IrrDevice(param);
    if (_device == NULL) {
        FATAL("创建 Irr 设备失败");
        return;
    }
    _driver = _device->getVideoDriver();
    _scene = _device->getSceneManager();
    _guiscene = _device->getGUIEnvironment();
    _collision = _scene->getSceneCollisionManager();
    
    // 添加到界面上
    with(tmp.rootViewController.view, {
        _glview = it;
        it.layer.opaque = NO;
        it.userInteractionEnabled = NO;
        [self addSubview:it];
    });
}

- (void)removeScene {
    [self stop];
    
    if (_device)
        _device->drop();
    
    _device = NULL;
    _driver = NULL;
    _scene = NULL;
    _guiscene = NULL;
    _collision = NULL;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalStart)
SIGNAL_ADD(kSignalStop)
SIGNAL_ADD(kSignalTakeAction)
SIGNALS_END

@dynamic device;
- (::irr::IrrlichtDevice*)device {
    return _device;
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    _glview.cmd(^(UIView *obj) {
        obj.frame = rect;
    });
}

- (void)cbRenderFrame {
    if (_device &&
        [UIApplication shared].applicationState == UIApplicationStateActive &&
        _device->run())
    {
        // 发出信号，业务层可以通过信号来响应变更
        if ([self.delegate respondsToSelector:@selector(irrlichtRender:)])
            [self.delegate irrlichtRender:self];
        [self.signals emit:kSignalTakeAction];
        
        // 渲染一帧
        _driver->beginScene(true, true, self.backgroundColor.irrColor);
        _scene->drawAll();
        _guiscene->drawAll();
        _driver->endScene();
    }
    
    [_stage continuee];
}

- (void)start {
    [_stage start];
}

- (void)stop {
    [_stage stop];
}

@end

IRR_USING;

@implementation UIIrrlichtController

- (void)onInit {
    [super onInit];
    self.classForView = [UIIrrlichtView class];
}

- (void)onFin {
    UIIrrlichtView* view = (id)self.view;
    view.delegate = nil;
    self.view = nil;
    
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    
    UIIrrlichtView* view = (id)self.view;
    view.delegate = self;
    
    _device = view.device;
    _driver = view.driver;
    _scene = view.scene;
    _guiscene = view.guiscene;
    _collision = view.collision;
}

- (void)start {
    UIIrrlichtView* view = (id)self.view;
    [view start];
}

- (void)stop {
    UIIrrlichtView* view = (id)self.view;
    [view stop];
}

- (void)removeScene {
    UIIrrlichtView* view = (id)self.view;
    [view removeScene];
}

- (void)createScene {
    UIIrrlichtView* view = (id)self.view;
    [view createScene];
}

- (UIIrrlichtView*)irrlicht {
    return (id)self.view;
}

- (void)irrlichtRender:(UIIrrlichtView *)view {
    PASS;
}

@end
