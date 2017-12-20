
# import "Common.h"
# import "NSSystemFeatures.h"
# import "CoreFoundation+Extension.h"
# import <AddressBook/AddressBook.h>
# import <MessageUI/MessageUI.h>
# import "AppDelegate+Extension.h"
# import <AVFoundation/AVFoundation.h>
# import <MobileCoreServices/MobileCoreServices.h>
# import <CoreMotion/CoreMotion.h>
# include <asl.h>

# if defined(IOS8_FEATURES)
#   import <LocalAuthentication/LocalAuthentication.h>
# endif

@interface NSLocationInfo ()

@property (nonatomic, retain) CLLocation *locationValue, *fromLocation;
@property (nonatomic, retain) CLHeading *heading;
@property (nonatomic, retain) NSString *city, *province, *street, *number, *address, *district, *business;

@end

@implementation NSLocationInfo

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    ZERO_RELEASE(_heading);
    ZERO_RELEASE(_locationValue);
    ZERO_RELEASE(_fromLocation);
    ZERO_RELEASE(_city);
    ZERO_RELEASE(_province);
    ZERO_RELEASE(_street);
    ZERO_RELEASE(_number);
    ZERO_RELEASE(_address);
    ZERO_RELEASE(_district);
    ZERO_RELEASE(_business);
    [super onFin];
}

- (NSString*)description {
    NSMutableString* str = [NSMutableString string];
    [str appendFormat:@"address: %@\n", _address];
    [str appendFormat:@"location: lng:%lf lat:%lf alt:%lf\n", _locationValue.coordinate.longitude, _locationValue.coordinate.latitude, _locationValue.altitude];
    [str appendFormat:@"accuracy: hor:%lf vec:%lf\n", _locationValue.horizontalAccuracy, _locationValue.verticalAccuracy];
    [str appendFormat:@"north: %f\n", _locationValue.course];
    [str appendFormat:@"speed: %f\n", _locationValue.speed];
    return str;
}

- (void)readData:(NSDictionary*)result {
    self.address = [result valueForKeyPath:@"formatted_address"];
    self.city = [result valueForKeyPath:@"addressComponent.city"];
    self.province = [result valueForKeyPath:@"addressComponent.province"];
    self.street = [result valueForKeyPath:@"addressComponent.street"];
    self.number = [result valueForKeyPath:@"addressComponent.street_number"];
    self.district = [result valueForKeyPath:@"addressComponent.district"];
    self.business = [result valueForKeyPath:@"addressComponent.business"];
}

- (CGAngle*)orientation {
    return [CGAngle Angle:self.heading.trueHeading];
}

- (id)copyWithZone:(NSZone *)zone {
    NSLocationInfo* ret = [[self.class alloc] init];
    SAFE_COPY(ret.locationValue, self.locationValue);
    SAFE_COPY(ret.fromLocation, self.fromLocation);
    SAFE_COPY(ret.heading, self.heading);
    SAFE_COPY(ret.address, self.address);
    SAFE_COPY(ret.city, self.city);
    SAFE_COPY(ret.province, self.province);
    SAFE_COPY(ret.street, self.street);
    SAFE_COPY(ret.number, self.number);
    SAFE_COPY(ret.district, self.district);
    SAFE_COPY(ret.business, self.business);
    return ret;
}

@end

@interface ChinaLocationExtension : NSObject
@end

@implementation ChinaLocationExtension

+ (void)asyncEncodeLocation:(CLLocationCoordinate2D)coord
                        suc:(void(^)(CLLocationCoordinate2D result))succb
                        err:(void(^)(NSError* err))errcb
{
    NSString* url = [NSString stringWithFormat:@"http://api.map.baidu.com/ag/coord/convert?x=%.8f&y=%.8f&from=0&to=2&mode=1",
                     coord.longitude, coord.latitude];
    
    DISPATCH_ASYNC_BEGIN
    
    NSError* err = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURLString:url]
                                         returningResponse:nil error:&err];
    
    if (err) {
        [err log];
        if (errcb)
            errcb(err);
        return;
    }
    
    NSString* strd = [NSString stringWithData:data encoding:NSUTF8StringEncoding];
    NSArray* jsobjs = strd.jsonObject;
    if (jsobjs.count == 0) {
        if (errcb)
            errcb(nil);
        return;
    }
    
    NSDictionary* jsobj = jsobjs.firstObject;
    if ([jsobj getInt:@"error"] != 0) {
        if (errcb)
            errcb(nil);
        return;
    }
    
    NSString* strx = [jsobj getString:@"x"];
    NSString* stry = [jsobj getString:@"y"];
    strx = [strx debase64];
    stry = [stry debase64];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(stry.doubleValue, strx.doubleValue);
    if (succb)
        succb(coord);
    
    DISPATCH_ASYNC_END
}

+ (void)asyncQueryLocation:(CLLocationCoordinate2D)coord
                       iso:(BOOL)iso
                       suc:(void(^)(NSDictionary* result))succb
                       err:(void(^)(NSError* err))errcb
{
    NSString* url = [NSString stringWithFormat:@"http://api.map.baidu.com/geocoder/v2/?coordtype=%@&location=%.8f,%.8f&output=json&ak=huaSZmtzFy1uY9AgQCvrkw2o",
                     TRIEXPRESS(iso, @"wgs84ll", @"gcj02ll"),
                     coord.latitude, coord.longitude];
    
    DISPATCH_ASYNC_BEGIN
    
    NSError* err = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURLString:url]
                                         returningResponse:nil error:&err];
    
    if (err) {
        [err log];
        if (errcb)
            errcb(err);
        return;
    }
    
    NSString* strd = [NSString stringWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary* jsobj = strd.jsonObject;
    if ([jsobj getInt:@"status"] != 0) {
        if (errcb)
            errcb(nil);
        return;
    }
    
    NSDictionary* result = [jsobj objectForKey:@"result"];
    if (succb)
        succb(result);
    
    DISPATCH_ASYNC_END
}

@end

@interface NSLocationService ()
<CLLocationManagerDelegate>
{
    BOOL _fetchmode;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL running;

@end

@implementation NSLocationService

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    self.offsetChina = NO;
    _info = [[NSLocationInfo alloc] init];
    
    if ([CLLocationManager locationServicesEnabled] == NO)
        LOG("定位服务不可用");
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        LOG("用户不允许程序获得地理位置");
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //_locationManager.headingFilter = kCLHeadingFilterNone;
    
# ifdef IOS8_FEATURES
    if (kIOS8Above) {
        NSDictionary *dictInfo = [[NSBundle mainBundle] infoDictionary];
        if ([dictInfo exists:@"NSLocationWhenInUseUsageDescription"] == NO)
            FATAL("iOS8 需要在 Info.plist 里面写一个 NSLocationWhenInUseUsageDescription 的 string，用来提示用户为什么会使用位置信息，如果不存在这个值，则会造成不能获取到位置");
        
        [_locationManager requestWhenInUseAuthorization];
    }
# endif
}

- (void)onFin {
    ZERO_RELEASE(_locationManager);
    ZERO_RELEASE(_info);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalLocationChanged)
SIGNAL_ADD(kSignalHeadingChanged)
SIGNAL_ADD(kSignalDecodeSucceed)
SIGNALS_END

- (void)fetch {
    if (self.running)
        return;
    _fetchmode = YES;
    [self start];
}

- (void)start {
    if (self.running)
        return;
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    self.running = YES;
    
    // 延迟释放
    SAFE_RETAIN(self);
}

- (void)stop {
    if (!self.running)
        return;
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
    self.running = NO;
    
    SAFE_RELEASE(self);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    _info.fromLocation = oldLocation;
    _info.locationValue = newLocation;
    
    // 如果需要反查地址信息
    if (self.decodesInfo) {
        // 如果需要转换为火星坐标，则得先转换一下
        if (self.offsetChina)
        {
            [ChinaLocationExtension asyncEncodeLocation:newLocation.coordinate
                                                    suc:^(CLLocationCoordinate2D result) {
                                                        [ChinaLocationExtension asyncQueryLocation:result
                                                                                               iso:NO
                                                                                               suc:^(NSDictionary *result) {
                                                                                                   [_info readData:result];
                                                                                                   [self.signals emit:kSignalLocationChanged withResult:_info];
                                                                                                   
                                                                                                   if (_fetchmode) {
                                                                                                       _fetchmode = NO;
                                                                                                       [self stop];
                                                                                                   }
                                                                                               }
                                                                                               err:nil];
                                                    } err:nil];
        }
        else
        {
            [ChinaLocationExtension asyncQueryLocation:newLocation.coordinate
                                                   iso:!self.offsetChina
                                                   suc:^(NSDictionary *result) {
                                                       [_info readData:result];
                                                       [self.signals emit:kSignalLocationChanged withResult:_info];
                                                       
                                                       if (_fetchmode) {
                                                           _fetchmode = NO;
                                                           [self stop];
                                                       }
                                                   }
                                                   err:nil];
        }
    } else {
        [self.signals emit:kSignalLocationChanged withResult:_info];
        
        if (_fetchmode) {
            _fetchmode = NO;
            [self stop];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    _info.heading = newHeading;
    [self.signals emit:kSignalHeadingChanged withResult:_info];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
# ifdef DEBUG_MODE
    static BOOL logonce = YES;
    if (logonce) {
        [error log];
        logonce = NO;
    }
# endif
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    PASS;
}

- (void)decode:(CLLocationCoordinate2D)location {
    NSLocationInfo* li = [NSLocationInfo temporary];
    if (self.offsetChina)
    {
        [ChinaLocationExtension asyncEncodeLocation:location
                                                suc:^(CLLocationCoordinate2D result) {
                                                    [ChinaLocationExtension asyncQueryLocation:result
                                                                                           iso:NO
                                                                                           suc:^(NSDictionary *result) {
                                                                                               [li readData:result];
                                                                                               
                                                                                               [self.signals emit:kSignalDecodeSucceed withResult:li];
                                                                                           }
                                                                                           err:nil];
                                                } err:nil];
    }
    else
    {
        [ChinaLocationExtension asyncQueryLocation:location
                                               iso:!self.offsetChina
                                               suc:^(NSDictionary *result) {
                                                   [li readData:result];
                                                   
                                                   [self.signals emit:kSignalDecodeSucceed withResult:li];
                                               }
                                               err:nil];
    }
}

@end

@implementation NSApnsService

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    self.badge = YES;
    self.sound = YES;
    self.alert = YES;
    
    [[UIAppDelegate shared].signals connect:kSignalDeviceTokenGot ofTarget:self];
    [[UIAppDelegate shared].signals connect:kSignalDeviceTokenGetFailed ofTarget:self];
    [[UIAppDelegate shared].signals connect:kSignalNotificationLocal ofTarget:self];
    [[UIAppDelegate shared].signals connect:kSignalNotificationRemote ofTarget:self];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalDeviceTokenGot)
SIGNAL_ADD(kSignalDeviceTokenGetFailed)
SIGNAL_ADD(kSignalNotificationLocal)
SIGNAL_ADD(kSignalNotificationRemote)
SIGNALS_END

- (void)start {
    if (kIOS8Above)
    {
# ifdef IOS8_FEATURES
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *sets = [UIUserNotificationSettings settingsForTypes:types
                                                                             categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:sets];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        return;
# endif
    }
    
    UIRemoteNotificationType tp = 0;
    if (self.badge)
        tp |= UIRemoteNotificationTypeBadge;
    if (self.sound)
        tp |= UIRemoteNotificationTypeSound;
    if (self.alert)
        tp |= UIRemoteNotificationTypeAlert;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:tp];
}

- (void)stop {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

- (BOOL)running {
    if (kIOS8Above)
    {
# ifdef IOS8_FEATURES
        return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
# endif
    }
    return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] != 0;
}

@end

@implementation NSAppBadgeService

SHARED_IMPL;

SIGNALS_BEGIN
SIGNAL_ADD(kSignalValueChanged)
SIGNALS_END

- (void)onInit {
    [super onInit];
}

@dynamic value;

- (int)value {
    return [UIApplication shared].applicationIconBadgeNumber;
}

- (void)setValue:(int)value {
    if (self.value == value)
        return;
    
# ifdef IOS8_FEATURES
    if (kIOS8Above)
    {
        UIUserNotificationSettings* sets = [UIApplication sharedApplication].currentUserNotificationSettings;
        UIUserNotificationType types = sets.types;
        if ([NSMask Mask:UIUserNotificationTypeBadge Value:types] == NO)
        {
            [[[UIAppDelegate shared].signals connect:kSignalNotificationSettingsChanged withBlock:^(SSlot *s) {
                UIUserNotificationSettings* sets = s.data.object;
                UIUserNotificationType types = sets.types;
                if ([NSMask Mask:UIUserNotificationTypeBadge Value:types])
                    [self updateData];
            }] oneshot];
            
            types |= UIUserNotificationTypeBadge;
            sets = [UIUserNotificationSettings settingsForTypes:types
                                                     categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:sets];
            return;
        }
    }
# endif
    
    [UIApplication shared].applicationIconBadgeNumber = value;
    [self.signals emit:kSignalValueChanged withResult:@(value)];
}

@end

@interface NSIpcService ()
{
    NSMutableDictionary* _store;
}

@property (nonatomic, retain) UIPasteboardExt *pb;

@end

@implementation NSIpcService

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    
    self.name = DEBUG_SYMBOL(@"com.nnt.service.ipc") RELEASE_SYMBOL(@"C3320F05-6D09-4F12-9DEA-ED0945C50147");
    
    _store = [[NSMutableDictionary alloc] init];
}

- (void)setName:(NSString *)name {
    if ([_name isEqualToString:name])
        return;
    PROPERTY_COPY(_name, name);
    
    self.pb = [UIPasteboardExt Open:self.name];
    
    // 先读取一下数据
    [self _read];
}

- (void)onFin {
    ZERO_RELEASE(_store);
    ZERO_RELEASE(_pb);
    ZERO_RELEASE(_name);
    [super onFin];
}

- (void)_save {
    NSData* da = [NSKeyedArchiver archivedDataWithRootObject:_store];
    self.pb.string = da.base64;
}

- (void)_read {
    NSString* str = self.pb.string;
    NSData* da = str.debase64data;
    if (da == nil) {
        [_store removeAllObjects];
        return;
    }
    [_store setDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:da]];
}

- (void)setObject:(id<NSCoding>)obj forKey:(id<NSCopying>)key {
    [self _read];
    [_store setObject:obj forKey:key];
    [self _save];
}

- (id)objectForKey:(id)key {
    return [_store objectForKey:key];
}

- (NSDictionary*)objects {
    return _store;
}

- (void)removeAllObjects {
    [_store removeAllObjects];
    [self _save];
}

@end

@interface NSAddressBookRecord : NSObject

@property (nonatomic, assign) ABRecordRef record;

- (NSString*)valueForKey:(ABPropertyID)property;
- (NSArray *)findProperty:(ABPropertyID)property;
- (NSArray *)labelsForProperty:(ABPropertyID)property;

@end

@implementation NSAddressBookRecord

- (id)initWithHandle:(ABRecordRef)hdl {
    self = [super init];
    self.record = hdl;
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (NSString*)valueForKey:(ABPropertyID)property {
    return [(NSString *)ABRecordCopyValue(_record, property) autorelease];
}

- (NSArray *)findProperty:(ABPropertyID)property {
    CFTypeRef thProperty = ABRecordCopyValue(_record, property);
    if (thProperty == nil)
        return nil;
    
    NSArray *items = (NSArray *)ABMultiValueCopyArrayOfAllValues(thProperty);
    CFRelease(thProperty);
    return [items autorelease];
}

- (NSArray *)labelsForProperty:(ABPropertyID)property {
    CFTypeRef theProperty = ABRecordCopyValue(_record, property);
    NSMutableArray *labels = [NSMutableArray array];
    for (int i = 0; i < ABMultiValueGetCount(theProperty); i++) {
        NSString *label = (NSString *)ABMultiValueCopyLabelAtIndex(theProperty, i);
        if (label == nil)
            continue;
        [labels addObject:label];
        CFRelease(label);
    }
    CFRelease(theProperty);
    return labels;
}

@end

@implementation NSAddressBookContact

- (void)onInit {
    [super onInit];
    _phones = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_firstname);
    ZERO_RELEASE(_lastname);
    ZERO_RELEASE(_middlename);
    ZERO_RELEASE(_nickname);
    ZERO_RELEASE(_phones);
    [super onFin];
}

- (NSString*)primaryPhone {
    return [_phones.firstObject secondObject];
}

- (NSString*)primaryPhoneLabel {
    return [_phones.firstObject firstObject];
}

- (NSString*)nickname {
    if (_nickname)
        return _nickname;
    NSMutableArray* tmp = [NSMutableArray temporary];
    [tmp addObject:_lastname def:nil];
    [tmp addObject:_firstname def:nil];
    return [tmp componentsJoinedByString:@""];
}

@end

@interface NSAddressBook ()
{
    ABAddressBookRef _hdl;
}

@end

@implementation NSAddressBook

+ (BOOL)isAvaliable {
    ABAddressBookRef hdl = ABAddressBookCreate();
    if (hdl == nil)
        return NO;
    __block BOOL isgranted;
    NSSyncLoop* sl = [NSSyncLoop temporary];
    ABAddressBookRequestAccessWithCompletion(hdl, ^(bool granted, CFErrorRef error) {
        [NSTime SleepMilliSecond:10];
        isgranted = granted;
        [sl continuee];
    });
    [sl wait];
    CFSAFE_RELEASE(hdl);
    return isgranted;
}

- (void)onInit {
    [super onInit];
    
    _hdl = ABAddressBookCreate();
    if (_hdl == NULL) {
        WARN("联系人初始化失败");
    }
}

- (void)onFin {
    CFSAFE_RELEASE(_hdl);
    [super onFin];
}

SHARED_IMPL;

- (NSArray*)allContacts {
    if ([self.class isAvaliable] == NO) {
        [UIHud Noti:@"联系人数据访问不了，请您去“设置中心”、“隐私”打开对应的权限"];
        return [NSArray array];
    }
    
    NSMutableArray* contacts = [NSMutableArray temporary];
    NSArray* abps = (NSArray*)ABAddressBookCopyArrayOfAllPeople(_hdl);
    for (id each in abps) {
        NSAddressBookRecord* rcd = [[NSAddressBookRecord alloc] initWithHandle:each];
        NSAddressBookContact* contact = [[NSAddressBookContact alloc] init];
        
        contact.firstname = [rcd valueForKey:kABPersonFirstNameProperty];
        contact.lastname = [rcd valueForKey:kABPersonLastNameProperty];
        contact.middlename = [rcd valueForKey:kABPersonMiddleNameProperty];
        contact.nickname = [rcd valueForKey:kABPersonNicknameProperty];
        
        NSArray* phones = [rcd findProperty:kABPersonPhoneProperty];
        NSArray* lblphones = [rcd labelsForProperty:kABPersonPhoneProperty];
        if (phones.count == lblphones.count) {
            for (int i = 0; i < phones.count; ++i) {
                NSString* phone = [phones objectAtIndex:i];
                NSString* lbl = [lblphones objectAtIndex:i];
                
                [contact.phones addObject:[NSPair pairFirst:lbl Second:phone]];
            }
        }
        
        [contacts addObject:contact];
        SAFE_RELEASE(contact);
        SAFE_RELEASE(rcd);
    }
    SAFE_RELEASE(abps);
    
    return contacts;
}

@end

@interface NSComposeSMS ()
<MFMessageComposeViewControllerDelegate>

@end

@implementation NSComposeSMS

+ (BOOL)isAvaliable {
    Class clsFmw = NSClassFromString(@"MFMessageComposeViewController");
    if (clsFmw == nil) {
        LOG("没有找到发送短信的类");
        return NO;
    }
    return [clsFmw canSendText];
}

SHARED_IMPL;

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSucceed)
SIGNAL_ADD(kSignalCancel)
SIGNAL_ADD(kSignalFailed)
SIGNALS_END

- (void)sendText:(NSString*)text to:(NSString*)phone {
    if ([[self class] isAvaliable] == NO) {
        [UIHud Text:@"此设备不支持发短信"];
        return;
    }
    
    SAFE_RETAIN(self);
    
    MFMessageComposeViewController* ctlr = [MFMessageComposeViewController temporary];
    ctlr.messageComposeDelegate = self;
    ctlr.navigationBar.tintColor= [UIColor blackColor];
    ctlr.body = text;
    ctlr.recipients = [NSArray arrayWithObject:phone];
    [[UIAppDelegate shared] presentModalViewController:ctlr];
}

- (void)sendText:(NSString*)text phone:(NSArray*)phones {
    if (phones.count == 0) {
        [UIHud Noti:@"没有存在可用的电话号码用来发短信"];
        return;
    }
    if (phones.count == 1) {
        [self sendText:text to:phones.firstObject];
        return;
    }
    
    UIActionSheetExt* as = [UIActionSheetExt temporary];
    as.title = @"请选择一个号码";
    for (NSString* each in phones) {
        [[as addItem:each].signals connect:kSignalClicked withBlock:^(SSlot *s) {
            [self sendText:text to:each];
        }];
    }
    [as addCancel:@"取消"];
    [as show];
}

- (void)sendTexts:(NSString*)text phones:(NSArray*)phones {
    if ([[self class] isAvaliable] == NO) {
        [UIHud Text:@"此设备不支持发短信"];
        return;
    }
    
    SAFE_RETAIN(self);
    
    MFMessageComposeViewController* ctlr = [MFMessageComposeViewController temporary];
    ctlr.messageComposeDelegate = self;
    ctlr.navigationBar.tintColor= [UIColor blackColor];
    ctlr.body = text;
    ctlr.recipients = phones;
    [[UIAppDelegate shared] presentModalViewController:ctlr];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled: {
            [self.signals emit:kSignalCancel];
        } break;
        case MessageComposeResultSent: {
            [self.signals emit:kSignalSucceed];
        } break;
        case MessageComposeResultFailed: {
            [self.signals emit:kSignalFailed];
        } break;
    }
    [controller goBack];
    SAFE_RELEASE(self);
}

@end

@implementation NSDialPhone

+ (BOOL)isAvaliable {
    return [[UIApplication sharedApplication] canOpenURLString:@"tel://13000000000"];
}

- (void)dial:(NSString*)phone {
    if ([[self class] isAvaliable] == NO) {
        LOG("该设备不支持打电话");
        return;
    }
    
    [[UIApplication sharedApplication] openURLString:[NSString stringWithFormat:@"tel://%@", phone]];
}

@end

@interface NSTouchIDService ()
# ifdef IOS8_FEATURES
# endif
@end

@implementation NSTouchIDService

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    self.message = @"请求授权";
}

- (void)onFin {
    ZERO_RELEASE(_message);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalSucceed)
SIGNAL_ADD(kSignalFailed)
SIGNAL_ADD(kSignalTakeAction)
SIGNALS_END

+ (BOOL)isAvaliable {
# ifdef IOS8_FEATURES
    Class laCls = NSClassFromString(@"LAContext");
    if (laCls == nil)
        WARN("项目需要链接 LocationAuthorization Framework 才能使用 TouchID");
    id ctx = nil;
    OBJC_NOEXCEPTION(ctx = [laCls temporary]);
    return [ctx canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
# endif
    return NO;
}

- (void)authorize {
# ifdef IOS8_FEATURES
    Class laCls = NSClassFromString(@"LAContext");
    id ctx = nil;
    OBJC_NOEXCEPTION(ctx = [laCls temporary]);
    [ctx evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
        localizedReason:self.message
                  reply:^(BOOL success, NSError *error) {
                      if (success)
                      {
                          [self.signals emit:kSignalSucceed];
                      }
                      else
                      {
                          if (error.code == LAErrorUserFallback) {
                              [self.signals emit:kSignalTakeAction];
                          }
                          else
                          {
                              [error log];
                              [self.signals emit:kSignalFailed withResult:error];
                          }
                      }
                  }];
    if (ctx == nil) {
        DISPATCH_DELAY_BEGIN(1)
        [self.signals emit:kSignalFailed];
        DISPATCH_DELAY_END
    }
# else
    DISPATCH_DELAY_BEGIN(1)
    [self.signals emit:kSignalFailed];
    DISPATCH_DELAY_END
# endif
}

@end

@interface NSTTSService ()
<AVSpeechSynthesizerDelegate>

@property (nonatomic, readonly) AVSpeechSynthesizer *syn;
@property (nonatomic, readonly) NSMutableArray* strings;
@property (nonatomic, readonly) BOOL isSpeaking;

@end

@implementation NSTTSService

SHARED_IMPL;

+ (BOOL)isAvaliable {
    return kIOS7Above;
}

- (void)onInit {
    [super onInit];
    if (!kIOS7Above)
        return;
    
    _syn = [[AVSpeechSynthesizer alloc] init];
    _syn.delegate = self;
    
    _strings = [[NSMutableArray alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_syn);
    ZERO_RELEASE(_strings);
    [super onFin];
}

- (void)speak:(NSString *)string {
    [_strings push:string];
    [self playNext];
}

- (void)playNext {
    if (_isSpeaking)
        return;
    
    NSString* str = [_strings pop];
    AVSpeechUtterance* ut = [AVSpeechUtterance speechUtteranceWithString:str];
    //ut.rate = AVSpeechUtteranceMinimumSpeechRate;
    [_syn speakUtterance:ut];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    _isSpeaking = YES;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    _isSpeaking = NO;
    
    // 播放下一个
    [self playNext];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance {
    PASS;
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance {
    PASS;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    _isSpeaking = NO;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
    PASS;
}

@end

@interface NSPostureInfo ()

@property (nonatomic, retain) CMDeviceMotion *motion;

@end

@implementation NSPostureInfo

- (CGAngle*)angleRotation {
    return [CGAngle Rad:atan2(self.motion.gravity.x, self.motion.gravity.y)];
}

- (CGAngle*)angle {
    return [CGAngle Rad:atan2(self.motion.gravity.z, sqrtf(self.motion.gravity.x * self.motion.gravity.x + self.motion.gravity.y * self.motion.gravity.y))];
}

- (NSString*)description {
    NSMutableString* str = [NSMutableString string];
    [str appendFormat:@"gravity: %f", self.motion.gravity.x];
    [str appendFormat:@",%f,", self.motion.gravity.y];
    [str appendFormat:@",%f", self.motion.gravity.z];
    return str;
}

- (id)copyWithZone:(NSZone *)zone {
    NSPostureInfo* ret = [[self.class alloc] init];
    SAFE_COPY(ret.motion, self.motion);
    return ret;
}

@end

@interface NSPostureService ()
{
    BOOL _isposturing, _isacceling, _isgyroing, _ismagnetoing;
}

@property (nonatomic, readonly) CMMotionManager *mtmgr;
@property (nonatomic, retain) NSPoint3d *accelerometer, *gyro, *magneto;
@property (nonatomic, assign) BOOL neared;

@end

// 小的间隔，来达到精确的目的，业务需要根据自己的需求来降低间隔以提高性能
NSTimeInterval kNSPostureServiceDefaultDuration = 0.1;

@implementation NSPostureService

SHARED_IMPL;

- (void)onInit {
    [super onInit];

    _mtmgr = [[CMMotionManager alloc] init];
    self.durationPosture = kNSPostureServiceDefaultDuration;
    self.durationAccelerometer = kNSPostureServiceDefaultDuration;
    self.durationGyro = kNSPostureServiceDefaultDuration;
}

- (void)onFin {
    [self stop];
    ZERO_RELEASE(_mtmgr);
    ZERO_RELEASE(_accelerometer);
    ZERO_RELEASE(_gyro);
    ZERO_RELEASE(_magneto);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalValueChanged)
SIGNAL_ADD(kSignalPostureStarted)
SIGNAL_ADD(kSignalPostureChanged)
SIGNAL_ADD(kSignalPostureStopped)
SIGNAL_ADD(kSignalAccelerometerStarted)
SIGNAL_ADD(kSignalAccelerometerStopped)
SIGNAL_ADD(kSignalAccelerometerChanged)
SIGNAL_ADD(kSignalGyroStarted)
SIGNAL_ADD(kSignalGyroStopped)
SIGNAL_ADD(kSignalGyroChanged)
SIGNAL_ADD(kSignalMagnetoStarted)
SIGNAL_ADD(kSignalMagnetoStopped)
SIGNAL_ADD(kSignalMagnetoChanged)
SIGNAL_ADD(kSignalNearGot)
SIGNAL_ADD(kSignalNearLost)
SIGNAL_ADD(kSignalNearChagned)
SIGNALS_END

- (void)start {
    [self startPosture];
    [self startAccelerometer];
    [self startGyro];
    [self startMagneto];

# ifdef DEBUG_MODE
    DISPATCH_ONCE_EXPRESS({
        INFO("因为接近传感器启动会导致靠近时屏幕黑掉，所以默认启动所有时不包括启动接近传感器");
    });
# endif
}

- (void)stop {
    [self stopAccelerometer];
    [self stopGyro];
    [self stopMagneto];
    [self stopNear];
}

- (void)setDurationPosture:(NSTimeInterval)durationPosture {
    _durationPosture = durationPosture;
    _mtmgr.deviceMotionUpdateInterval = durationPosture;
}

- (void)setDurationAccelerometer:(NSTimeInterval)durationAccelerometer {
    _durationAccelerometer = durationAccelerometer;
    _mtmgr.accelerometerUpdateInterval = durationAccelerometer;
}

- (void)setDurationGyro:(NSTimeInterval)durationGyro {
    _durationGyro = durationGyro;
    _mtmgr.gyroUpdateInterval = durationGyro;
}

- (BOOL)isPostureAvailable {
    return _mtmgr.isDeviceMotionAvailable;
}

- (BOOL)isPostureRunning {
    return _isposturing;
}

- (BOOL)isAccelerometerAvailable {
    return _mtmgr.isAccelerometerAvailable;
}

- (BOOL)isAccelerometerRunning {
    //return _mtmgr.isAccelerometerActive;
    return _isacceling;
}

- (BOOL)isGyroAvailable {
    return _mtmgr.isGyroAvailable;
}

- (BOOL)isGyroRunning {
    //return _mtmgr.isGyroActive;
    return _isgyroing;
}

- (BOOL)isMagnetoAvailable {
    return _mtmgr.isMagnetometerAvailable;
}

- (BOOL)isMagnetoRunning {
    //return _mtmgr.isMagnetometerActive;
    return _ismagnetoing;
}

- (void)startPosture {
    if (self.isPostureRunning)
        return;
    BLOCK_WEAK_SELF();
    [_mtmgr startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                withHandler:^(CMDeviceMotion *motionData, NSError *error) {
                                    if (error) {
                                        [error log];
                                    } else {
                                        NSPostureInfo* info = [NSPostureInfo temporary];
                                        info.motion = motionData;
                                        weak_self.posture = info;
                                    }
                                }];
    _isposturing = YES;
    [self.touchSignals emit:kSignalPostureStarted];
}

- (void)stopPosture {
    if (self.isPostureRunning == NO)
        return;
    _isposturing = NO;
    [_mtmgr stopDeviceMotionUpdates];
    [self.touchSignals emit:kSignalPostureStopped];
}

- (void)setPosture:(NSPostureInfo *)val {
    PROPERTY_RETAIN(_posture, val);
    if (_posture) {
        [self.touchSignals emit:kSignalPostureChanged withResult:_posture];
        [self.touchSignals emit:kSignalValueChanged];
    }
}

- (void)startAccelerometer {
    if (self.isAccelerometerRunning)
        return;
    BLOCK_WEAK_SELF();
    [_mtmgr startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                 withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                     if (error) {
                                         [error log];
                                     } else {
                                         CGPoint3d pt = {
                                             accelerometerData.acceleration.x,
                                             accelerometerData.acceleration.y,
                                             accelerometerData.acceleration.z
                                         };
                                         weak_self.accelerometer = [NSPoint3d point3d:pt];
                                     }
                                 }];
    _isacceling = YES;
    [self.touchSignals emit:kSignalAccelerometerStarted];
}

- (void)stopAccelerometer {
    if (self.isAccelerometerRunning == NO)
        return;
    _isacceling = NO;
    [_mtmgr stopAccelerometerUpdates];
    [self.touchSignals emit:kSignalAccelerometerStopped];
}

- (void)setAccelerometer:(NSPoint3d *)val {
    PROPERTY_RETAIN(_accelerometer, val);
    if (_accelerometer) {
        [self.touchSignals emit:kSignalAccelerometerChanged withResult:_accelerometer];
        [self.touchSignals emit:kSignalValueChanged];
    }
}

- (void)startGyro {
    if (self.isGyroRunning)
        return;
    BLOCK_WEAK_SELF();
    [_mtmgr startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
                        withHandler:^(CMGyroData *gyroData, NSError *error) {
                            if (error) {
                                [error log];
                            } else {
                                CGPoint3d pt = {
                                    gyroData.rotationRate.x,
                                    gyroData.rotationRate.y,
                                    gyroData.rotationRate.z
                                };
                                weak_self.gyro = [NSPoint3d point3d:pt];
                            }
                        }];
    _isgyroing = YES;
    [self.touchSignals emit:kSignalGyroStarted];
}

- (void)stopGyro {
    if (self.isGyroRunning == NO)
        return;
    _isgyroing = NO;
    [_mtmgr stopGyroUpdates];
    [self.touchSignals emit:kSignalGyroStopped];
}

- (void)setGyro:(NSPoint3d *)val {
    PROPERTY_RETAIN(_gyro, val);
    if (_gyro) {
        [self.touchSignals emit:kSignalGyroChanged withResult:_gyro];
        [self.touchSignals emit:kSignalValueChanged];
    }
}

- (void)startMagneto {
    if (self.isMagnetoRunning)
        return;
    BLOCK_WEAK_SELF();
    [_mtmgr startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
                                    if (error) {
                                        [error log];
                                    } else {
                                        CGPoint3d pt = {
                                            magnetometerData.magneticField.x,
                                            magnetometerData.magneticField.y,
                                            magnetometerData.magneticField.z
                                        };
                                        weak_self.magneto = [NSPoint3d point3d:pt];
                                    }
                                }];
    _ismagnetoing = YES;
    [self.touchSignals emit:kSignalMagnetoStarted];
}

- (void)stopMagneto {
    if (self.isMagnetoRunning == NO)
        return;
    _ismagnetoing = NO;
    [_mtmgr stopMagnetometerUpdates];
    [self.touchSignals emit:kSignalMagnetoStopped];
}

- (void)setMagneto:(NSPoint3d *)val {
    PROPERTY_RETAIN(_magneto, val);
    if (_magneto) {
        [self.touchSignals emit:kSignalMagnetoChanged withResult:_magneto];
        [self.touchSignals emit:kSignalValueChanged];
    }
}

- (CGPoint3d)percentAccelerometer {
    static CGFloat _1_G = 1 / 9.8;
    return [self.accelerometer pointMultiply:_1_G].point3d;
}

- (CGPoint3d)percentGyro {
    return [self.gyro pointMultiply:M_1_2PI].point3d;
}

- (void)startNear {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__cb_near_noti)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];
}

- (void)stopNear {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceProximityStateDidChangeNotification
                                                  object:nil];
}

- (void)__cb_near_noti {
    self.neared = [UIDevice currentDevice].proximityState;
}

- (void)setNeared:(BOOL)neared {
    if (_neared == neared)
        return;
    _neared = neared;
    if (_neared) {
        [self.touchSignals emit:kSignalNearGot];
    } else {
        [self.touchSignals emit:kSignalNearLost];
    }
    [self.touchSignals emit:kSignalNearChagned withResult:[NSBoolean boolean:_neared]];
    [self.touchSignals emit:kSignalValueChanged];
}

@end

@implementation NSWalkerInfo

@end

@interface NSWalkerService ()
{
    BOOL _isstepcnting;
    BOOL _ispedoing;
}

@property (nonatomic, readonly) CMStepCounter *stepcnt;

# ifdef IOS8_FEATURES
@property (nonatomic, readonly) CMPedometer *pedom;
# endif

@end

@implementation NSWalkerService

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    
    _stepcnt = [[CMStepCounter alloc] init];
# ifdef IOS8_FEATURES
    if (kIOS8Above)
        _pedom = [[CMPedometer alloc] init];
# endif
    
    _info = [[NSWalkerInfo alloc] init];
}

- (void)onFin {
    [self stop];
    ZERO_RELEASE(_stepcnt);
# ifdef IOS8_FEATURES
    ZERO_RELEASE(_pedom);
# endif
    ZERO_RELEASE(_info);
    [super onFin];
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalWalkerStepStarted)
SIGNAL_ADD(kSignalWalkerStepStopped)
SIGNAL_ADD(kSignalWalkerStepChanged)
SIGNAL_ADD(kSignalPedometerStarted)
SIGNAL_ADD(kSignalPedometerStopped)
SIGNAL_ADD(kSignalPedometerChanged)
SIGNALS_END

- (void)start {
    [self startStepCount];
    [self startPedometer];
}

- (void)stop {
    [self stopStepCount];
    [self stopPedometer];
}

- (BOOL)isStepCountAvailable {
    if (kIOS7Above)
        return [CMStepCounter isStepCountingAvailable];
    return NO;
}

- (BOOL)isStepCountRunning {
    return _isstepcnting;
}

- (void)startStepCount {
    if (self.isStepCountRunning)
        return;
    BLOCK_WEAK_SELF();
    [_stepcnt startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue]
                                     updateOn:1
                                  withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
                                      if (error) {
                                          [error log];
                                      } else {
                                          weak_self->_info.steps += numberOfSteps;
                                          
                                          NSWalkerInfo* wi = [NSWalkerInfo temporary];
                                          wi.steps = numberOfSteps;
                                          [weak_self.touchSignals emit:kSignalWalkerStepChanged withResult:wi];
                                      }
                                  }];
    _isstepcnting = YES;
    [self.touchSignals emit:kSignalWalkerStepStarted];
}

- (void)stopStepCount {
    if (self.isStepCountRunning == NO)
        return;
    _isstepcnting = NO;
    [_stepcnt stopStepCountingUpdates];
    [self.touchSignals emit:kSignalWalkerStepStopped];
}

- (BOOL)isPedometerAvailable {
    return kIOS8Above;
}

- (BOOL)isPedometerRunning {
    return _ispedoing;
}

- (void)startPedometer {
    if (self.isPedometerRunning)
        return;
# ifdef IOS8_FEATURES
    if (kIOS8Above) {
        BLOCK_WEAK_SELF();
        [_pedom startPedometerUpdatesFromDate:[NSDate distantFuture]
                                  withHandler:^(CMPedometerData *pedometerData, NSError *error) {
                                      if (error) {
                                          [error log];
                                      } else {
                                          NSWalkerInfo* wi = [NSWalkerInfo temporary];
                                          wi.steps = pedometerData.numberOfSteps.integerValue;
                                          wi.distance = pedometerData.distance.floatValue;
                                          if (pedometerData.floorsAscended.floatValue)
                                              wi.floor = pedometerData.floorsAscended.floatValue;
                                          else if (pedometerData.floorsDescended.floatValue)
                                              wi.floor = pedometerData.floorsDescended.floatValue;
                                          
                                          weak_self->_info.floor += wi.floor;
                                          if (self.isStepCountRunning == NO)
                                              weak_self->_info.steps += wi.steps;
                                          
                                          [weak_self.touchSignals emit:kSignalPedometerChanged withResult:wi];
                                      }
                                  }];
        _ispedoing = YES;
        [self.touchSignals emit:kSignalPedometerStarted];
    }
# endif
}

- (void)stopPedometer {
    if (self.isPedometerRunning == NO)
        return;
# ifdef IOS8_FEATURES
    if (kIOS8Above) {
        _ispedoing = NO;
        [_pedom stopPedometerUpdates];
        [self.touchSignals emit:kSignalPedometerStopped];
    }
# endif
}

@end

@interface NSSystemLogRecord ()

@property (nonatomic, readonly) NSMutableDictionary *datas;

@end

@implementation NSSystemLogRecord

- (void)onInit {
    [super onInit];
    _datas = [[NSMutableDictionary alloc] init];
}

- (void)onFin {
    ZERO_RELEASE(_datas);
    [super onFin];
}

- (NSString*)description {
    NSMutableString* str = [NSMutableString temporary];
    [_datas foreach:^IteratorType(id key, id obj) {
        [str appendFormat:@"%@: %@, ", key, obj];
        return YES;
    }];
    return str;
}

@end

@implementation NSSystemLogService

SHARED_IMPL;

- (NSArray*)logsForLevel:(NSSystemLogLevel)level {
    asl_object_t q;
    if (level == kNSSystemLogLevelAll) {
        q = asl_new(ASL_TYPE_LIST);
    } else {
        q = asl_new(ASL_TYPE_QUERY);
        asl_set_query(q, ASL_KEY_LEVEL, @(level).stringValue.UTF8String, ASL_QUERY_OP_EQUAL);
    }
    
    NSMutableArray* ret = [NSMutableArray temporary];
    aslresponse r = asl_search(NULL, q);
    aslmsg m;
    while ((m = asl_next(r))) {
        NSSystemLogRecord* rcd = [NSSystemLogRecord temporary];
        char const* val;
        
# define ASL_GET(key) \
if ((val = asl_get(m, key))) \
[rcd.datas setObject:NSOBJECT_EXPDEF([NSString stringWithUTF8String:val], @"") forKey:@key];
        
        ASL_GET(ASL_KEY_TIME);
        ASL_GET(ASL_KEY_TIME_NSEC);
        ASL_GET(ASL_KEY_HOST);
        ASL_GET(ASL_KEY_SENDER);
        ASL_GET(ASL_KEY_FACILITY);
        ASL_GET(ASL_KEY_PID);
        ASL_GET(ASL_KEY_UID);
        ASL_GET(ASL_KEY_GID);
        ASL_GET(ASL_KEY_LEVEL);
        ASL_GET(ASL_KEY_MSG);
        ASL_GET(ASL_KEY_READ_UID);
        ASL_GET(ASL_KEY_READ_GID);
        ASL_GET(ASL_KEY_EXPIRE_TIME);
        ASL_GET(ASL_KEY_MSG_ID);
        ASL_GET(ASL_KEY_SESSION);
        ASL_GET(ASL_KEY_REF_PID);
        ASL_GET(ASL_KEY_REF_PROC);
        ASL_GET(ASL_KEY_AUX_TITLE);
        ASL_GET(ASL_KEY_AUX_UTI);
        ASL_GET(ASL_KEY_AUX_URL);
        ASL_GET(ASL_KEY_AUX_DATA);
        ASL_GET(ASL_KEY_OPTION);
        ASL_GET(ASL_KEY_MODULE);
        ASL_GET(ASL_KEY_SENDER_INSTANCE);
        ASL_GET(ASL_KEY_SENDER_MACH_UUID);
        ASL_GET(ASL_KEY_FINAL_NOTIFICATION);
        ASL_GET(ASL_KEY_OS_ACTIVITY_ID);
        [ret addObject:rcd];
    }
    if (r) aslresponse_free(r);
    asl_free(q);
    return ret;
}

@end
