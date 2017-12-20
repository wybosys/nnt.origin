

#import "DataMatrix.h"

#if __has_feature(objc_arc)
# define ARC_MODE
# define SAFE_RELEASE(obj) {}
# define SAFE_RETAIN(obj) obj
# define SAFE_AUTORELEASE(obj) obj
# define SUPER_DEALLOC
#else
# define SAFE_RELEASE(obj) [obj release]
# define SAFE_RETAIN(obj) [obj retain]
# define SAFE_AUTORELEASE(obj) [obj autorelease]
# define SUPER_DEALLOC [super dealloc]
#endif

@implementation DataMatrix

- (id)initWith:(int)dimension {
    if ([super init]) {
        self->dim = dimension;
        self->data = (bool**)malloc(sizeof(bool*) * self->dim);
        for (int y=0; y<self->dim; y++) {
            self->data[y] = (bool*)malloc(sizeof(bool) * self->dim);
            if (self->data[y]==NULL) {
                NSLog(@"null!");
            }
        }
        
    }
    return self;
}

- (int)dimension {
    return self->dim;
}

- (void)set:(bool)value x:(int)x y:(int)y {
    self->data[y][x] = value;
}

- (bool)valueAt:(int)x y:(int)y {
    return self->data[y][x];
}

- (NSString*)toString {
    NSString* string = [NSString string];
    for (int y=0; y<self->dim; y++) {
        for (int x=0; x<self->dim; x++) {
            bool value = self->data[y][x];
            string = [string stringByAppendingFormat:@"%d", value];
        }
        string = [string stringByAppendingString:@"\n"];
    }
    return string;
}

- (void)dealloc {
    for (int y=0; y<self->dim; y++) {
        free(self->data[y]);
    }
    free(self->data);
    
    SUPER_DEALLOC;
}

@end
