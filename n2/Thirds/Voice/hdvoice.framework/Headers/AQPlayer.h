//
//  VoicePlayer.h
//  SpeakHere
//
//  Created by  on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "VoiceCommon.h"
#import "Player.h"

#define NUM_BUFFERS         3

@interface AQPlayer : Player

+(AQPlayer*)sharedInstance;

@end





