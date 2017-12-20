//
//  AVPlayer.h
//  voice
//
//  Created by wangfeng on 12-11-4.
//
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "Player.h"

@interface AFPlayer : Player<AVAudioPlayerDelegate>

+(AFPlayer*)sharedInstance;
@end
