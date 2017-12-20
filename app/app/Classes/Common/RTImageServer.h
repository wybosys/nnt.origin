
# ifndef __RTIMAGESERVER_5DFF88A9435745159DAAB6E0C5193D07_H_INCLUDED
# define __RTIMAGESERVER_5DFF88A9435745159DAAB6E0C5193D07_H_INCLUDED

/*
 运行时的图片服务器
 实现功能：
 任何通过URL访问的图片，会在下载成功后按照指定的大小生成缩略图，以提高性能
 当复用imageview控件时，自动控制下载队列
 */

@protocol RTImageUpdate <NSObject>

// 更新image
- (void)setImage:(UIImage*)image;

@end

@interface RTImageServer : NSObjectExt

// 下载目录
@property (nonatomic, copy) NSString *directory;

// 下载图片
- (NSObject*)download:(NSURL*)url;

// 绑定显示和url，会生成缩率图
- (void)setImage:(NSURL*)url toView:(UIView*)view;

@end

# endif
