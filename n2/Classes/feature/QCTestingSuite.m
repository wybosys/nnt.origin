
# import "Common.h"
# import "QCTestingSuite.h"
# import "AppDelegate+Extension.h"

// 只有非发布环境才支持自动测试
# ifdef DEVELOP_MODE

@interface UIViewExtension ()
- (UITouch*)currentTouch;
@end

@implementation QCTestingAction

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    ZERO_RELEASE(_position);
    ZERO_RELEASE(_size);
    ZERO_RELEASE(_signal);
    [super onFin];
}

- (void)play {
    UIView* rootView = [UIAppDelegate shared].rootViewController.view;
    UIView* tgtView = [rootView querySubview:^IteratorType(UIView *v) {
        CGRect rc = [rootView convertRect:v.frame fromView:v.superview];
        if (CGRectContainsPoint(rc, _position.point) == NO)
            return kIteratorTypeBreak;
        if (_size.size.width > rc.size.width ||
            _size.size.height > rc.size.height)
            return kIteratorTypeBreak;
        if (v.class == _type)
            return kIteratorTypeOk;
        return kIteratorTypeNext;
    }];
    if (tgtView) {
        [tgtView.signals emit:_signal];
    }
}

@end

@interface QCTestingProfile ()

@property (nonatomic, readonly) NSMutableArray *actions;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, readonly) NSCountTimer *playtimer;

@end

@implementation QCTestingProfile

- (void)onInit {
    [super onInit];
    self.time = [NSDate date];
    _actions = [NSMutableArray new];
    
    _playtimer = [NSCountTimer temporary];
    _playtimer.timeStep = 1;
}

- (void)onFin {
    ZERO_RELEASE(_name);
    ZERO_RELEASE(_time);
    ZERO_RELEASE(_path);
    ZERO_RELEASE(_actions);
    ZERO_RELEASE(_playtimer);
    [super onFin];
}

- (void)load {
    
}

- (void)unload {
    
}

- (void)record {
    LOG("开始录制");
    [_actions removeAllObjects];
    [[UIKit shared].signals connect:kSignalClicked withSelector:@selector(cbClicked:) ofTarget:self];
}

- (void)stop {
    LOG("结束录制");
    [[UIKit shared].signals disconnectToTarget:self];
}

- (void)play {
    LOG("开始播放");
    [_playtimer start];
    [_playtimer.signals connect:kSignalTakeAction withSelector:@selector(cbTimePlay:) ofTarget:self];
}

- (void)cbTimePlay:(SSlot*)s {
    NSCountTimer* tm = (id)s.sender;
    QCTestingAction* action = [_actions objectAtIndex:tm.countSteps def:nil];
    if (action == nil) {
        [tm stop];
        return;
    }
    
    [action play];
}

// 连接到 uikit 上以来接受动作的通知
- (void)cbClicked:(SSlot*)s {
    UIView* view = [s.data.object behalfView];
    UIView* rootView = [UIAppDelegate shared].rootViewController.view;
    
    CGPoint pt;
    if (view.extension.currentTouch) {
        [view.extension positionTouchedIn:rootView];
    } else {
        CGRect rc = [rootView convertRect:view.frame fromView:view.superview];
        pt = CGRectCenter(rc);
    }
    
    QCTestingAction* action = [QCTestingAction temporary];
    action.position = [NSPoint point:pt];
    action.size = [NSSize size:view.frame.size];
    action.type = view.class;
    action.signal = kSignalClicked;
    [_actions addObject:action];
}

@end

@interface QCTestingSuite ()

@property (nonatomic, retain) QCTestingProfile *recordingProfile;

@end

@implementation QCTestingSuite

SHARED_IMPL;

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    ZERO_RELEASE(_recordingProfile);
    [super onFin];
}

+ (void)Launch {
    [[QCTestingSuite shared] start];
}

- (void)start {
    PASS;
}

- (QCTestingProfile*)record {
    QCTestingProfile* p = [QCTestingProfile temporary];
    self.recordingProfile = p;
    [p record];
    return p;
}

@end

# endif
