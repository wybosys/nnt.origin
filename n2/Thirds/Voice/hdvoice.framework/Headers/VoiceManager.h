//
//  VoiceManager.h
//  voice
//
//  Created by wangfeng on 12-11-4.
//
//

#import <Foundation/Foundation.h>
@class Player;
@class Recorder;
@class AFPlayer;
@class AFRecorder;
@class AQPlayer;
@class AQRecorder;
@class AUPlayer;
@class AURecorder;
@class VMoniter;

#define k_VMNotification_StopAll  @"k_VMNotification_StopAll"
#define k_VMNotification_Reset      @"k_VMNotification_Reset"
@interface VoiceManager : NSObject

@property (nonatomic, readonly) BOOL inputAvailable;

+(VoiceManager*)sharedInstance;
+(void)stopAll:(BOOL)keepSilent;
+(BOOL)isPlaying;
+(BOOL)isRecording;

-(BOOL)setupAudioSession;
-(BOOL)activeAudioSession;
-(BOOL)deactiveAudioSession;

-(VMoniter*)getMoniter;

-(AUPlayer*)getAUPlayer;
-(AURecorder*)getAURecorder;

-(AFPlayer*)getAFPlayer;
-(AFRecorder*)getAFRecorder;

-(AQPlayer*)getAQPlayer;
-(AQRecorder*)getAQRecorder;

- (BOOL)isUsingSpeaker;
- (BOOL)isUsingMicrophone;


@end
