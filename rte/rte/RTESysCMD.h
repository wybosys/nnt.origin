
# ifndef __SYSCMD_EFCDF206007B44E58699A9B070AFFE3D_H_INCLUDED
# define __SYSCMD_EFCDF206007B44E58699A9B070AFFE3D_H_INCLUDED

# import "RTExchangeObject.h"

@interface RTESysCMDObject : NSObject

- (BOOL)readData:(NSDictionary*)dict;

@end

@interface RTESysCMD : RTExchangeObject {
    NSInteger _command;
    RTESysCMDObject* _cmdobj;
}

@property (nonatomic, readonly) NSInteger command;
@property (nonatomic, readonly, retain) RTESysCMDObject* cmdobj;

@end

enum { RTE_SYSCMD = 7 };

# endif
