//
//  USCRecognizerDialog.h
//  USCUIView
//
//  Created by hejinlai on 12-12-4.
//  Copyright (c) 2012年 yunzhisheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>


@protocol USCRecognizerDialogDelegate <NSObject>

/*
     部分识别结果回调，isLast表示是否是最后一次
 */
- (void)onResult:(NSString *)result isLast:(BOOL)isLast;


/*
     识别结束回调，error为nil表示成功，否则表示出现了错误
 */
- (void)onEnd:(NSError *)error;


@end


/*
 语音设置属性key
 */

typedef enum
{
    USC_SERVICE_ADDRESS_PORT = 100,    //设置私有识别服务器
    SAMPLE_RATE_AUTO = 400,            //设置2G/3G智能切换
} USCPropertyKey;


@interface USCRecognizerDialog : UIWindow

@property (nonatomic, assign) id<USCRecognizerDialogDelegate> delegate;

/*
     初始化, 请到开发者网站http://dev.hivoice.cn申请appKey
 */
- (id)initWithAppKey:(NSString *)appkey;

/*
     显示对话框，并开始识别
 */
- (void)showInView:(UIView *)view;

/*
     默认调用show函数显示在屏幕中间
 */

- (void) show;

/*
     设置说话停顿的超时时间，单位ms
     frontTime：说话之前的停顿超时时间，默认3000ms
     backTime： 说话之后的停顿超时时间，默认1000ms
 */
- (void)setVadFrontTimeout:(int)frontTime BackTimeout:(int)backTime;

/*
 设置识别超时时间
 */
- (void)setRecognizationTimeout:(float)recognizationTime;

 /*
     设置录音采样率，支持8000和16000，默认为16000
 */
- (void)setSampleRate:(int)rate;

/*
     设置识别参数
 */
- (BOOL)setEngine:(NSString *)engine;

/*
     当前的版本号
 */
+ (NSString *)getVersion;

/*
     取消识别
 */

- (void) cancel;

/*
 设置是否允许播放提示音
 */

- (void) setPlayingBeep:(BOOL)isAllowed;

/*
    设置语言
 */
- (void) setLanguage:(NSString *)language;

/*
 设置标点符号
 */
- (void) setPunctuation:(BOOL)isEnable;


/*
 设置属性
 */
- (void)setProperty:(NSString *)property forKey:(int)key;

@end
