
# import "Common.h"
# import "MapEnhance.h"
# import <CoreLocation/CoreLocation.h>
# import <CoreBluetooth/CoreBluetooth.h>

@interface iBeaconService ()
<
CBPeripheralManagerDelegate,
CLLocationManagerDelegate
>

@property (nonatomic, retain) CLBeaconRegion *region;
@property (nonatomic, retain) NSDictionary *regiondata;
@property (nonatomic, retain) CBPeripheralManager *bpmgr;
@property (nonatomic, retain) CLLocationManager *locmgr;

@end

@implementation iBeaconService

SHARED_IMPL;

- (void)onInit {
    [super onInit];

    self.proximityid = [NSString uuid:UUID_STR_36W];
    self.identifier = @"com.wybosys.ibeacon.test";
}

- (void)onFin {
    ZERO_RELEASE(_proximityid);
    ZERO_RELEASE(_region);
    ZERO_RELEASE(_regiondata);
    ZERO_RELEASE(_bpmgr);
    ZERO_RELEASE(_locmgr);
    [super onFin];
}

+ (BOOL)isAvaliable {
    if (!kIOS7Above)
        return NO;
    if ([CLLocationManager isRangingAvailable] == NO)
        return NO;
    return [CLLocationManager regionMonitoringAvailable];
}

- (BOOL)listening {
    return _region != nil;
}

- (void)listen {
    if ([[self class] isAvaliable] == NO) {
        LOG("不支持这个功能");
        return;
    }
    
    if (_region)
        return;
    
    // 初始化区域
    NSUUID* uid = [NSUUID UUIDString:self.proximityid];
    _region = [[CLBeaconRegion alloc] initWithProximityUUID:uid
                                                 identifier:self.identifier];
    self.regiondata = [_region peripheralDataWithMeasuredPower:nil];
    
    // 启动广播
    SAFE_RELEASE(_bpmgr);
    _bpmgr = [[CBPeripheralManager alloc] initWithDelegate:self
                                                     queue:nil
                                                   options:nil];
    [_bpmgr startAdvertising:self.regiondata];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSString* strsta;
    switch (peripheral.state)
    {
        case CBPeripheralManagerStateUnknown: strsta = @"CBPeripheralManagerStateUnknown"; break;
        case CBPeripheralManagerStateResetting: strsta = @"CBPeripheralManagerStateResetting"; break;
        case CBPeripheralManagerStateUnsupported: strsta = @"CBPeripheralManagerStateUnsupported"; break;
        case CBPeripheralManagerStateUnauthorized: strsta = @"CBPeripheralManagerStateUnauthorized"; break;
        case CBPeripheralManagerStatePoweredOff: strsta = @"CBPeripheralManagerStatePoweredOff"; break;
        case CBPeripheralManagerStatePoweredOn: strsta = @"CBPeripheralManagerStatePoweredOn"; break;
    }
    
    LOG(strsta.UTF8String);
}

- (void)look {
    if (_locmgr)
        return;
    
    _locmgr = [[CLLocationManager alloc] init];
    _locmgr.delegate = self;
    [_locmgr startMonitoringForRegion:self.region];
}

- (BOOL)looking {
    return _locmgr != nil;
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    if (beacons.count == 0)
        return;
    
    CLBeacon* neareast = [beacons firstObject];
    if (CLProximityNear == neareast.proximity) {
        LOG("iBeacon Near");
    } else {
        LOG("iBeacon Far");
    }
}

@end
