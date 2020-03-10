
# import "Common.h"
# import "AppSpoor.h"
# import "AppDelegate+Extension.h"
# import "NSStorage.h"
# import "CoreFoundation+Extension.h"

# include <sys/syscall.h>
# include <sys/sysctl.h>

# ifdef IOS_SIMULATOR
//#   include <sys/proc_info.h>
#define PROC_PIDPATHINFO_MAXSIZE 2048
# endif

@interface UITouchPointIdentifier : UIViewExt @end
@implementation UITouchPointIdentifier

- (void)onInit {
    [super onInit];
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.border = [CGLine lineWithColor:[UIColor grayColor].CGColor width:3];
    self.size = CGSizeMake(30, 30);
    [self cornerRoundlize];
    self.alpha = .6f;
}

@end

static NSString* kSpoorLaunchCount = @"::app::spoor::launch::count";
static NSString* kSpoorDeactivityCount = @"::app::spoor::deactivity::count";

@interface AppSpoor ()
{
    // 承载 touchid
    UIView* _rootView;
}

@property (nonatomic, readonly) NSMutableArray *touchPts, *gesPts;

@end

@implementation AppSpoor

SHARED_IMPL;

+ (void)Launch {
    [(AppSpoor*)[self.class shared] start];
}

- (id)init {
    self = [super init];
    _rootView = [UIAppDelegate shared].window.rootViewController.view;
    _touchPts = [[NSMutableArray alloc] init];
    _gesPts = [[NSMutableArray alloc] init];
    // 切换到后台计数器
    [[UIAppDelegate shared].signals connect:kSignalAppDeactiving withSelector:@selector(cbDeactiviting) ofTarget:self];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_touchPts);
    ZERO_RELEASE(_gesPts);
    [super dealloc];
}

- (void)cbDeactiviting {
    [[NSStorageExt shared] setInteger:[[NSStorageExt shared] getIntegerForKey:kSpoorDeactivityCount def:0] + 1
                           forKey:kSpoorDeactivityCount];
}

- (void)start {
    // 启动次数计数器
    [[NSStorageExt shared] setInteger:[[NSStorageExt shared] getIntegerForKey:kSpoorLaunchCount def:0] + 1
                               forKey:kSpoorLaunchCount];
    
    // 显示触摸的点
    DEBUG_EXPRESS([self showTouchPoint]);
    
    // 测试用
    //[SystemProcesse MyProcesses];
    //[SystemApplication AllInstalled];
}

- (void)showTouchPoint {
    [[UIKit shared].signals connect:kSignalTouchesBegan withSelector:@selector(tpTouchesBegan:) ofTarget:self];
    [[UIKit shared].signals connect:kSignalTouchesMoved withSelector:@selector(tpTouchesMoved:) ofTarget:self];
    [[UIKit shared].signals connect:kSignalTouchesDone withSelector:@selector(tpTouchesEnded:) ofTarget:self];
    
    [[UIKit shared].signals connect:kSignalGestureBegan withSelector:@selector(tpGestureBegan:) ofTarget:self];
    [[UIKit shared].signals connect:kSignalGestureChanged withSelector:@selector(tpGestureMoved:) ofTarget:self];
    [[UIKit shared].signals connect:kSignalGestureEnded withSelector:@selector(tpGestureEnded:) ofTarget:self];
}

- (void)tpTouchesBegan:(SSlot*)s {
    NSSet* touches = s.data.object;
    [_touchPts growByType:[UITouchPointIdentifier class] toSize:touches.count init:^(UITouchPointIdentifier* obj, NSInteger idx) {
        [_rootView addSubview:obj];
    }];
    [touches foreach:^IteratorType(UITouch* touch, NSInteger idx) {
        CGPoint pt = [touch locationInView:_rootView];
        UITouchPointIdentifier* ptv = [_touchPts objectAtIndex:idx];
        ptv.visible = YES;
        ptv.center = pt;
        return YES;
    }];
}

- (void)tpTouchesMoved:(SSlot*)s {
    NSSet* touches = s.data.object;
    [touches foreach:^IteratorType(UITouch* touch, NSInteger idx) {
        CGPoint pt = [touch locationInView:_rootView];
        UITouchPointIdentifier* ptv = [_touchPts objectAtIndex:idx];
        ptv.center = pt;
        return YES;
    }];
}

- (void)tpTouchesEnded:(SSlot*)s {
    NSSet* touches = s.data.object;
    [touches foreach:^IteratorType(UITouch* touch, NSInteger idx) {
        UITouchPointIdentifier* ptv = [_touchPts objectAtIndex:idx];
        ptv.hidden = YES;
        return YES;
    }];
}

- (void)tpGestureBegan:(SSlot*)s {
    UIGestureRecognizer* ges = s.data.object;
    [_gesPts growByType:[UITouchPointIdentifier class] toSize:ges.numberOfTouches init:^(UITouchPointIdentifier* obj, NSInteger idx) {
        [_rootView addSubview:obj];
    }];
    [ges foreachTouch:^BOOL(CGPoint pt, NSInteger idx) {
        UITouchPointIdentifier* ptv = [_gesPts objectAtIndex:idx];
        ptv.center = pt;
        ptv.visible = YES;
        return YES;
    } inView:_rootView];
}

- (void)tpGestureMoved:(SSlot*)s {
    UIGestureRecognizer* ges = s.data.object;
    [ges foreachTouch:^BOOL(CGPoint pt, NSInteger idx) {
        UITouchPointIdentifier* ptv = [_gesPts objectAtIndex:idx];
        ptv.center = pt;
        return YES;
    } inView:_rootView];
}

- (void)tpGestureEnded:(SSlot*)s {
    [_gesPts foreach:^BOOL(UITouchPointIdentifier* obj) {
        obj.hidden = YES;
        return YES;
    }];
}

@end

@implementation SystemProcesse

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_name);
    ZERO_RELEASE(_path);
    
    [super dealloc];
}

+ (NSSet*)SystemProcessesList {
    return [NSSet setWithObjects:
            @"kernel_task",
            @"launchd",
            @"UserEventAgent",
            @"wifid",
            @"timed",
            @"mediaremoted",
            @"iaptransportd",
            @"backboardd",
            @"sharingd",
            @"mDNSResponder",
            @"SpringBoard",
            @"routined",
            @"aggregated",
            @"syslogd",
            @"aosnotifyd",
            @"keybagd",
            @"powerd",
            @"ubd",
            @"lockdownd",
            @"locationd",
            @"identityservices",
            @"configd",
            @"imagent",
            @"vmd",
            @"BTServer",
            @"installd",
            @"fseventsd",
            @"wirelessproxd",
            @"AppleIDAuthAgent",
            @"CommCenter",
            @"sandboxd",
            @"notifyd",
            @"xpcd",
            @"MobileGestaltHel",
            @"lsd",
            @"distnoted",
            @"networkd",
            @"networkd_privile",
            @"accountsd",
            @"apsd",
            @"securityd",
            @"dataaccessd",
            @"librariand",
            @"gamed",
            @"itunescloudd",
            @"itunesstored",
            @"geod",
            @"medialibraryd",
            @"IMDPersistenceAg",
            @"tccd",
            @"touchsetupd",
            @"kbd",
            @"mobileassetd",
            @"MobileMail",
            @"softwareupdatese",
            @"assetsd",
            @"filecoordination",
            @"absd",
            @"recentsd",
            @"SiriViewService",
            @"MobilePhone",
            @"MobileSMS",
            @"CMFSyncAgent",
            @"EscrowSecurityAl",
            @"calaccessd",
            @"limitadtrackingd",
            @"afcd",
            @"syslog_relay",
            @"notification_pro",
            @"mobile_installat",
            @"Weather",
            @"mediaserverd",
            @"nsnetworkd",
            @"FaceTime",
            @"MobileSafari",
            @"AppStore",
            @"adid",
            @"storebookkeeperd",
            @"CloudKeychainPro",
            @"sbd",
            @"voiced",
            @"ptpd",
            @"XcodeDeviceMonit",
            @"syncdefaultsd",
            @"debugserver",
            @"amfid",
            @"assistantd",
            @"pasteboardd",
            @"assistant_servic",
            @"awdd",
            @"mdworker",
            @"bash",
            @"launchd_sim",
            @"cookied",
            @"ocspd",
            @"usbmuxd",
            @"mds",
            @"blued",
            @"helpd",
            @"ntpd",
            @"clang",
            @"cplogd",
            @"coresymbolicatio",
            @"CommCenterClassi",
            @"lockbot",
            @"schelper",
            @"mobile_assertion",
            @"CFNetworkAgent",
            @"fairplayd.H2",
            @"DuetLST",
            @"deleted",
            @"softwarebehavior",
            @"softwareupdated",
            @"BlueTool",
            @"BTLEServer",
            nil];
}

+ (NSArray*)MyProcesses {
	int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    
    size_t size;
    int st = 0;
    sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc* process = NULL;
    do
	{
		size += size / 10;
        struct kinfo_proc* newprocess = realloc(process, size);
        if (!newprocess)
		{
			if (process)
			{
                free(process);
				process = NULL;
            }
            return nil;
        }
        
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
    }
    while (st == -1 && errno == ENOMEM);
    
    if (st == 0)
	{
        if (size % sizeof(struct kinfo_proc) == 0)
		{
            NSSet* list = [self SystemProcessesList];
            int nprocess = size / sizeof(struct kinfo_proc);
            if (nprocess)
			{
                NSMutableDictionary* ret = [NSMutableDictionary dictionaryWithCapacity:nprocess];
                
                for (int i = nprocess - 1; i >= 0; i--)
				{
                    SystemProcesse* proc = [SystemProcesse temporary];
                    struct kinfo_proc* kproc = process + i;
                    
                    proc.name = [NSString stringWithFormat:@"%s", kproc->kp_proc.p_comm];
                    if ([proc.name hasPrefix:@"com.apple."])
                        continue;
                    if ([list containsObject:proc.name])
                        continue;
                    if ([ret valueForKey:proc.name])
                        continue;
                         
                    proc.pid = kproc->kp_proc.p_pid;
                    
# ifdef IOS_SIMULATOR
                    extern void proc_pidpath(pid_t, char*, size_t);
                    char buf[PROC_PIDPATHINFO_MAXSIZE];
                    proc_pidpath(proc.pid, buf, sizeof(buf));
                    proc.path = [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
# endif
                    
                    if (proc.path)
                    {
                        if ([proc.path hasPrefix:@"/usr"])
                            continue;
                        if ([proc.path hasPrefix:@"/sbin"])
                            continue;
                        if ([proc.path hasPrefix:@"/bin"])
                            continue;
                        if ([proc.path hasPrefix:@"/System"])
                            continue;
                        if ([proc.path hasPrefix:@"/Applications/Xcode.app"])
                            continue;
                    }
                    
                    //LOG(proc.name.UTF8String);
                    //LOG(proc.path.UTF8String);
                    
                    [ret setObject:proc forKey:proc.name];
                }
                
                free(process);
				process = NULL;
				return [ret allValues];
            }
        }
    }
    
    free(process);
    process = NULL;
    
    return nil;
}

@end

@interface AppBundleInfo ()

- (void)readDataFromDict:(NSDictionary*)dict;

@end

@interface AppSchemesInfo ()

- (void)readDataFromDict:(NSDictionary*)dict;

@end

@implementation AppBundleInfo

- (void)dealloc {
    ZERO_RELEASE(_identifier);
    ZERO_RELEASE(_name);
    ZERO_RELEASE(_nickname);
    ZERO_RELEASE(_process);
    ZERO_RELEASE(_version);
    ZERO_RELEASE(_home);
    ZERO_RELEASE(_path);

    [super dealloc];
}

- (void)readDataFromDict:(NSDictionary*)dict {
    self.identifier = [dict valueForKey:(NSString*)kCFBundleIdentifierKey];
    self.name = [dict valueForKey:(NSString*)kCFBundleNameKey];
    self.nickname = [dict valueForKey:kCFBundleDisplayNameKey];
    self.process = [dict valueForKey:(NSString*)kCFBundleExecutableKey];
    self.version = [dict valueForKey:(NSString*)kCFBundleVersionKey];
    self.home = [[dict valueForKey:kCFEnvironmentVariablesKey] valueForKey:kCFHomeKey];
    self.path = [dict valueForKey:kCFPathKey];
}

@end

@implementation AppSchemesInfo

- (void)dealloc {
    ZERO_RELEASE(_items);
    
    [super dealloc];
}

- (void)readDataFromDict:(NSDictionary*)dict {
    NSMutableArray* items = [NSMutableArray array];
    for (NSDictionary* each in [dict valueForKey:kCFBundleURLTypesKey]) {
        NSArray* vals = [each valueForKey:kCFBundleURLSchemesKey];
        [items addObjectsFromArray:vals];
    }
    self.items = items;
}

@end

@interface SystemApplication ()

- (void)readDataFromDict:(NSDictionary*)dict;

@end

@implementation SystemApplication

- (id)init {
    self = [super init];
    _bundle = [[AppBundleInfo alloc] init];
    _schemes = [[AppSchemesInfo alloc] init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_bundle);
    ZERO_RELEASE(_schemes);
    
    [super dealloc];
}

+ (NSArray*)AllInstalled {
    NSMutableArray* ret = [NSMutableArray array];
    
    NSDictionary *cacheDict = nil;
    NSString *path = nil;
    // Loop through all possible paths the cache could be in
    for (short i = 0; 1; i++)
    {
        switch (i) {
            case 0: // Jailbroken apps will find the cache here; their home directory is /var/mobile
            {
                NSString *relativeCachePath = [[@"Library" stringByAppendingPathComponent:@"Caches"]
                                               stringByAppendingPathComponent:@"com.apple.mobile.installation.plist"];
                path = [NSHomeDirectory() stringByAppendingPathComponent:relativeCachePath];
            } break;
            case 1: // App Store apps and Simulator will find the cache here; home (/var/mobile/) is 2 directories above sandbox folder
            {
                NSString* filenm = @"com.apple.mobile.installation.plist";
                NSString *relativeCachePath = [[@"Library" stringByAppendingPathComponent:@"Caches"]
                                               stringByAppendingPathComponent:filenm];
                path = [[NSHomeDirectory() stringByAppendingPathComponent:@"../.."]
                        stringByAppendingPathComponent:relativeCachePath];
            } break;
            case 2:
            {
                UIDeviceType dt = [UIDevice DeviceType];
                NSString* filenm = @"com.apple.mobile.installation.plist";
                if ([NSMask Mask:kUIDeviceTypeSimulator Value:dt]) {
                    if ([NSMask Mask:kUIDeviceTypeIPad Value:dt]) {
                        filenm = @"com.apple.mobile.installation~iPad.plist";
                    } else {
                        filenm = @"com.apple.mobile.installation~iPhone.plist";
                    }
                }
                NSString *relativeCachePath = [[@"Library" stringByAppendingPathComponent:@"Caches"]
                                               stringByAppendingPathComponent:filenm];
                path = [[NSHomeDirectory() stringByAppendingPathComponent:@"../.."]
                        stringByAppendingPathComponent:relativeCachePath];
            } break;
            case 3: // If the app is anywhere else, default to hardcoded /var/mobile/
            {
                NSString *relativeCachePath = [[@"Library" stringByAppendingPathComponent:@"Caches"]
                                               stringByAppendingPathComponent:@"com.apple.mobile.installation.plist"];
                path = [@"/var/mobile" stringByAppendingPathComponent:relativeCachePath];
            } break;
            default: // Cache not found (loop not broken)
                return ret;
            break; }
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath: path isDirectory: &isDir] && !isDir) // Ensure that file exists
            cacheDict = [NSDictionary dictionaryWithContentsOfFile: path];
        if (cacheDict) // If cache is loaded, then break the loop. If the loop is not "broken," it will return NO later (default: case)
            break;
    }
    
    NSDictionary* users = [cacheDict objectForKey:@"User"];
    for (NSDictionary* each in users.allValues)
    {
        SystemApplication* sa = [[SystemApplication alloc] init];
        [sa readDataFromDict:each];
        [ret addObject:sa];
        SAFE_RELEASE(sa);
    }
    
    return ret;
}

- (void)readDataFromDict:(NSDictionary*)dict {
    [_bundle readDataFromDict:dict];
    
    // 查找 info.plist
    NSString* infop = [_bundle.path stringByAppendingString:@"/Info.plist"];
    NSDictionary* infod = [NSDictionary dictionaryWithContentsOfFile:infop];
    [_schemes readDataFromDict:infod];
}

@end
