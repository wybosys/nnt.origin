
# import "NSTypes+DB.h"

@interface DbUser : DBObject

@property (nonatomic, readonly) DBColumnString *name, *address;
@property (nonatomic, readonly) DBColumnInteger *gender;

@end

@interface DbAvatar : DBObject

@property (nonatomic, readonly) DBColumnString *name, *avatar;

@end

@interface DbSimple : DBObject

@property (nonatomic, readonly) DBColumnString *value;

@end
