
# import "Common.h"
# import "DBConfig.h"
# import "FileSystem+Extension.h"

@implementation DBConfig

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_path);
    [super dealloc];
}

+ (instancetype)config {
    return [[[DBConfig alloc] init] autorelease];
}

+ (instancetype)file:(NSString *)file {
    DBConfig* ret = [[self class] config];
    ret.path = file;
    return ret;
}

+ (instancetype)tempFile:(NSString*)filename {
    return [[self class] file:[[FSApplication shared] pathTmp:filename]];
}

@end
