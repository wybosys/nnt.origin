//
//  VMoniter.h
//  voice
//
//  Created by Joe on 12-12-25.
//
//

#import <Foundation/Foundation.h>

@protocol VMoniterDelegate;

@interface VMoniter : NSObject


@property (nonatomic,assign) id<VMoniterDelegate> delegate;
@property (readonly,getter = getPeakPower)float power;

+(VMoniter*)sharedInstance;
-(void)startMoniter;
-(void)stopMoniter;

@end

@protocol VMoniterDelegate <NSObject>
@optional
-(void)didStartMoniter:(VMoniter*)moniter;
-(void)didStopMoniter:(VMoniter*)moniter;
-(void)valueUpdateMoniter:(VMoniter*)moniter Power:(float)power;
@end