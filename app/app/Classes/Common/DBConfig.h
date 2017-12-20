
# ifndef __DBCONFIG_EB3EF3D392BE427C8160D050522BE40F_H_INCLUDED
# define __DBCONFIG_EB3EF3D392BE427C8160D050522BE40F_H_INCLUDED

@interface DBConfig : NSObject

@property (nonatomic, copy) NSString* path;

+ (instancetype)config;
+ (instancetype)file:(NSString*)file;
+ (instancetype)tempFile:(NSString*)filename;

@end

# endif
