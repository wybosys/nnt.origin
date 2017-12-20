//
//  VoiceUtility.h
//  SpeakHere
//
//  Created by  on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define USE_AURECORD


#define SAMPLE_RATE         8000.0f

#define VOICE_PROCESS_SAMPLE_RATE   44100.0f
#define CHANNELS            1

enum {
    kAudioFormatSPX   = '.spx'
};



enum {
    kAudioFileCreate    = 1,
    kAudioFileOpen      = 2,
    kAudioFileCreateForConvert = 3,
};


//property types
enum {
    kVoicePropertyDataFormat,
    kVoicePropertyClientDataFormat,
    kVoicePropertyMagicCookieDataInfo,
    kVoicePropertyMagicCookieData,
    kVoicePropertyChannelLayoutInfo,
    kVoicePropertyChannelLayout
};


#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif


#if defined(__cplusplus)
extern "C"
{
#endif
    
BOOL isSpeexFile(NSString *fileName);

AudioStreamBasicDescription CanonicalASBD(Float64 sampleRate, UInt32 channel);
AudioStreamBasicDescription AUCanonicalASBD(Float64 sampleRate, UInt32 channel);
AudioStreamBasicDescription makeASBD(NSUInteger formatID);
void printASBD(AudioStreamBasicDescription asbd);
    
void makeABL(AudioBufferList **abl, const AudioStreamBasicDescription *asbd);
void freeABL(AudioBufferList *abl);
    
#if defined(__cplusplus)
}
#endif

static void checkError(OSStatus err,const char *message){
    if(err){
        char property[5];
        *(UInt32 *)property = CFSwapInt32HostToBig(err);
        property[4] = '\0';
        NSLog(@"%s = %-4.4s, %ld",message, property,err);
    }
}

@interface BaseAudioFile : NSObject

@property (readonly, nonatomic) NSString *fileName;
@property (readonly, nonatomic) NSInteger openType;

@property (readonly, nonatomic) NSInteger sampleRate;
@property (readonly, nonatomic) NSInteger channels;
@property (readonly, nonatomic) NSInteger framesPerChannel;
@property (readonly, nonatomic) NSInteger framesPerPacket;
@property (readonly, nonatomic) NSInteger bitsPerChannel;
@property (readonly, nonatomic, getter = getTotalFrames) SInt64 totalFrames;
@property (readonly, nonatomic, getter = getDuration) Float64 duration;

- (BOOL)open:(NSString*)fileName flag:(NSInteger)flag format:(AudioStreamBasicDescription*)dataFormat extra:(void*)extra;
- (void)close;
- (BOOL)write:(void*)data size:(UInt32)dataSize currentPacket:(UInt32)currentPacket inNumPackets:(UInt32*)inNumPackets extra:(const void*)extra;
- (BOOL)read:(void*)data size:(UInt32*)dataSize startingPacket:(UInt32)startingPacket numPackets:(UInt32*)numPackets extra:(void*)extra;
- (BOOL)read:(UInt32 *)ioNumberFrames data:(AudioBufferList *)ioData;
- (BOOL)write:(UInt32)ioNumberFrames data:(const AudioBufferList *) ioData;
- (UInt32)getBufferSize:(int*)packetsToRead;
- (BOOL)setProperty:(UInt32)type size:(UInt32)size value:(void*)value;
- (BOOL)getProperty:(UInt32)type size:(UInt32*)size value:(void*)value;
- (BOOL)seek:(SInt64)frameOffset;
- (BOOL)isOpen;
@end





