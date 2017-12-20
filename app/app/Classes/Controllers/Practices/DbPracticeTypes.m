
# import "app.h"
# import "DbPracticeTypes.h"

@implementation DbUser

- (void)onInit {
    [super onInit];
    
    _name = [DBColumnString new];
    _name.name = @"name";
    
    _address = [DBColumnString new];
    _address.name = @"address";
    
    _gender = [DBColumnInteger new];
    _gender.name = @"gender";
}

@end

@implementation DbAvatar

- (void)onInit {
    [super onInit];
    
    _name = [DBColumnString new];
    _name.name = @"name";
    
    _avatar = [DBColumnString new];
    _avatar.name = @"avatar";
}

@end

@implementation DbSimple

- (void)onInit {
    [super onInit];
    
    _value = [DBColumnString new];
    _value.name = @"value";
}

@end
