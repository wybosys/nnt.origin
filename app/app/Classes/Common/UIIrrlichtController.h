
# ifdef CXX_MODE
# import <Irrlicht/Irrlicht.h>
# ifndef IRR_USING
#   define IRR_USING \
NS_USING(irr); NS_USING(irr::core); NS_USING(irr::video); NS_USING(irr::scene); NS_USING(irr::gui);
# endif
# endif

# ifdef OBJC_MODE

@protocol UIIrrlichtViewDelegate;

@interface UIIrrlichtView : UIViewExt

@property (nonatomic, readonly) CXXTYPE(::irr::IrrlichtDevice) *device;
@property (nonatomic, readonly) CXXTYPE(::irr::video::IVideoDriver) *driver;
@property (nonatomic, readonly) CXXTYPE(::irr::scene::ISceneManager) *scene;
@property (nonatomic, readonly) CXXTYPE(::irr::gui::IGUIEnvironment) *guiscene;
@property (nonatomic, readonly) CXXTYPE(::irr::scene::ISceneCollisionManager) *collision;

@property (nonatomic, assign) id<UIIrrlichtViewDelegate> delegate;

/** 清空场景 */
- (void)removeScene;

/** 重建场景 */
- (void)createScene;

@end

@protocol UIIrrlichtViewDelegate <NSObject>

/** 渲染当前帧的回调 */
- (void)irrlichtRender:(UIIrrlichtView*)view;

@end

@interface UIIrrlichtController : UIViewControllerExt
<UIIrrlichtViewDelegate>

@property (nonatomic, readonly) UIIrrlichtView* irrlicht;

@property (nonatomic, readonly) CXXTYPE(::irr::IrrlichtDevice) *device;
@property (nonatomic, readonly) CXXTYPE(::irr::video::IVideoDriver) *driver;
@property (nonatomic, readonly) CXXTYPE(::irr::scene::ISceneManager) *scene;
@property (nonatomic, readonly) CXXTYPE(::irr::gui::IGUIEnvironment) *guiscene;
@property (nonatomic, readonly) CXXTYPE(::irr::scene::ISceneCollisionManager) *collision;

/** 启动渲染 */
- (void)start;

/** 停止渲染 */
- (void)stop;

/** 清空场景 */
- (void)removeScene;

/** 重建场景 */
- (void)createScene;

@end

# endif
