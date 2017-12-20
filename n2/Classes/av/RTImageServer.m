
# import "Common.h"
# import "RTImageServer.h"
# import "FileSystem+Extension.h"

/*
 下载时因为要及时通知给UI层，那么需要维持 ui-dlqueue, dlqueue-url 之间的一对一的关系，不然会发生错误通知
 */

@interface RTIS_operation : NSOperation

// 后续操作
@property (nonatomic, readonly) NSMutableArray* nextOperations;

@end

@implementation RTIS_operation

@synthesize nextOperations;

- (void)dealloc {
    ZERO_RELEASE(nextOperations);
    SUPER_DEALLOC;
}

SIGNALS_BEGIN
SIGNAL_ADD(kSignalDone)
SIGNALS_END

- (NSMutableArray*)nextOperations {
    SYNCHRONIZED_BEGIN
    if (nextOperations == nil)
        nextOperations = [[NSMutableArray alloc] init];
    SYNCHRONIZED_END
    return nextOperations;
}

@end

@interface RTIS_download_operation : RTIS_operation
{
    NSURLConnectionExt* _cnn;
}

// 文件信息
@property (nonatomic, copy) NSURL *url, *output;

// 期望的文件名
@property (nonatomic, readonly) NSString *filename;

// 是否存在
- (BOOL)exists;

@end

@implementation RTIS_download_operation

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_url);
    ZERO_RELEASE(_output);
    SUPER_DEALLOC;
}

- (NSString*)filename {
    NSString* fp = [self.url.filePath lastPathComponent];
    NSString* ext = [fp pathExtension];
    NSString* str = [NSString stringWithFormat:@"%@.%@", [fp md5], ext];
    return str;
}

- (BOOL)exists {
    return [[FSApplication shared] exists:self.output.absoluteString];
}

- (NSUInteger)hash {
    return self.output.hash;
}

- (void)main {
    //LOG("开始下载文件 %s", _url.absoluteString.UTF8String);
    
    NSURLRequest* req = [NSURLRequest requestWithURL:self.url];
    NSSyncLoop *loop = [NSSyncLoop loop];
    _cnn = [NSURLConnectionExt connectionWithRequest:req startImmediately:YES];
    _cnn.outputFile = self.output;
    [_cnn.signals connect:kSignalDone ofTarget:self];
    [_cnn.signals connect:kSignalProcessed withSelector:@selector(continuee) ofTarget:loop];
    [loop wait];
    
    LOG("下载文件完成 %s 到 %s", _url.absoluteString.UTF8String, _output.absoluteString.UTF8String);
}

@end

@interface RTIS_thumb_operation : RTIS_operation

@property (nonatomic, copy) NSURL *url, *output, *local;
@property (nonatomic, assign) CGSize size;

// 期望的文件名
@property (nonatomic, readonly) NSString *filename;

@end

@implementation RTIS_thumb_operation

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    ZERO_RELEASE(_url);
    ZERO_RELEASE(_output);
    ZERO_RELEASE(_local);
    SUPER_DEALLOC;
}

- (BOOL)exists {
    return [[FSApplication shared] exists:self.output.absoluteString];
}

- (NSString*)filename {
    NSString* fp = [self.url.filePath lastPathComponent];
    NSString* ext = @"png";//[fp pathExtension]; 使用png作为目标文件格式
    NSString* str = [fp md5];
    str = [str stringByAppendingFormat:@"__%d_%d.%@", (int)_size.width, (int)_size.height, ext];
    return str;
}

- (NSUInteger)hash {
    return self.output.hash;
}

- (void)main {
    UIImage* imgsrc = [UIImage imageWithContentsOfFile:self.local.absoluteString];
    UIImage* imgdes = [imgsrc imageResize:self.size contentMode:UIViewContentModeScaleAspectFit];
    [imgdes saveTo:self.output.absoluteString];
    [self.signals emit:kSignalDone];
    
    LOG("生成缩略图 %s 到 %s", _url.absoluteString.UTF8String, _output.absoluteString.UTF8String);
}

@end

@interface RTIS_thumb_operation_holder : NSObjectExt

@property (nonatomic, retain) RTIS_thumb_operation *operation;

@end

@implementation RTIS_thumb_operation_holder

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    ZERO_RELEASE(_operation);
    [super onFin];
}

@end

@interface UIView (RTIS)

@property (nonatomic, retain) RTIS_thumb_operation_holder *operThumb;

@end

@implementation UIView (RTIS)

NSOBJECT_DYNAMIC_PROPERTY_DECL(UIView, operThumb);
NSOBJECT_DYNAMIC_PROPERTY_IMPL_GET(UIView, operThumb);

- (void)setOperThumb:(RTIS_thumb_operation_holder *)operThumb {
    if (self.operThumb == operThumb)
        return;
    [self.operThumb.operation.signals disconnect:kSignalDone withSelector:@selector(__rtis_thumb_done:) ofTarget:self];
    NSOBJECT_DYNAMIC_PROPERTY_SET(UIView, operThumb, RETAIN_NONATOMIC, operThumb);
    [operThumb.operation.signals connect:kSignalDone withSelector:@selector(__rtis_thumb_done:) ofTarget:self];
}

- (void)__rtis_thumb_done:(SSlot*)s {
    [(id<RTImageUpdate>)self setImage:[UIImage imageWithContentsOfFile:self.operThumb.operation.output.absoluteString]];
}

@end

@interface RTImageServer ()
{
    NSOperationQueue* _queDownloading; // 下载队列
    NSMutableArray* _queDownloads; // 等待下载队列
    NSLock *_mtxDownload;
    
    NSOperationQueue* _queThumbing; // 缩略图队列
}

@property (nonatomic, readonly) NSMutableDictionary* mpDownloads; // 全部下载
@property (nonatomic, readonly) NSMutableDictionary* mpThumbs; // 全部缩略图

@end

@implementation RTImageServer

SHARED_IMPL;

- (void)onInit {
    [super onInit];
    
    self.directory = [[FSApplication shared].dirTmp stringByAppendingString:@"sys.rtis/"];
    
    _queDownloading = [[NSOperationQueue alloc] init];
    _queDownloading.maxConcurrentOperationCount = 4;
    _queDownloads = [[NSMutableArray alloc] init];
    _mpDownloads = [[NSMutableDictionary alloc] init];
    _mtxDownload = [[NSLock alloc] init];
    
    _queThumbing = [[NSOperationQueue alloc] init];
    _queThumbing.maxConcurrentOperationCount = 8;
    _mpThumbs = [[NSMutableDictionary alloc] init];
}

- (void)onFin {
    [_queDownloading cancelAllOperations];
    ZERO_RELEASE(_queDownloading);
    
    ZERO_RELEASE(_queDownloads);
    ZERO_RELEASE(_mpDownloads);
    ZERO_RELEASE(_mtxDownload);

    [_queThumbing cancelAllOperations];
    ZERO_RELEASE(_queThumbing);

    ZERO_RELEASE(_mpThumbs);
    [super onFin];
}

- (void)setDirectory:(NSString *)directory {
    if ([_directory isEqualToString:directory])
        return;
    PROPERTY_COPY(_directory, directory);
    [[FSApplication shared] mkdir:_directory];
}

SIGNALS_BEGIN
SIGNALS_END

- (NSObject*)download:(NSURL*)url {
    RTIS_download_operation* oper = nil;
    
    [_mtxDownload lock];
    oper = [_mpDownloads objectForKey:url];
    [_mtxDownload unlock];
    if (oper)
        return oper;
    
    oper = [RTIS_download_operation temporary];
    oper.url = url;
    oper.output = [NSURL URLWithString:[self.directory stringByAppendingString:oper.filename]];
    
    // 如果文件存在，则直接返回并激活信号
    if (oper.exists)
        return oper;
    
    [_mtxDownload lock];
    [_mpDownloads setObject:oper forKey:url];
    [_mtxDownload unlock];
    
    // 如果运行完毕，则需要置换一下队列
    oper.completionBlock = ^()
    {
        [_mtxDownload lock];
        // 移除自己
        [_mpDownloads removeObjectForKey:url];
        
        // 调度下一个
        RTIS_download_operation *top = _queDownloads.pop;
        if (top) {
            [_queDownloading addOperation:top];
            [_mpDownloads removeObjectForKey:top.url];
        }
        [_mtxDownload unlock];
    };
    
    [_mtxDownload lock];
    // 如果队列现在运行的数目小于可并发的最大数目，则直接加入队列
    if (_queDownloading.operationCount < _queDownloading.maxConcurrentOperationCount)
    {
        [_queDownloading addOperation:oper];
    }
    else
    {
        // 添加到队列最前面
        [_queDownloads insertObject:oper atIndex:0];
    }
    [_mtxDownload unlock];
    
    return oper;
}

- (void)setImage:(NSURL*)url toView:(UIView<RTImageUpdate>*)view {
    CGSize szV = CGSizeIntegral(view.bounds.size);
    
    // 实例化thumb操作
    RTIS_thumb_operation* operThumb = [RTIS_thumb_operation temporary];
    operThumb.url = url;
    operThumb.size = szV;
    
    // 如果正在队列里面，直接使用队列里面的
    BOOL resused = NO;
    if (szV.width && szV.height)
    {
        operThumb.output = [NSURL URLWithString:[self.directory stringByAppendingString:operThumb.filename]];
        RTIS_thumb_operation* tmp = [_mpThumbs objectForKey:operThumb.output];
        if (tmp != nil) {
            LOG("复用缩略图任务 %s", operThumb.output.absoluteString.UTF8String);
            operThumb = tmp;
            resused = YES;
        }
    }
    
    // 绑定当缩略图生成后的回调
    [operThumb.signals connect:kSignalDone withSelector:@selector(__rtis_thumb_update:) ofTarget:self];
    
    // 请求下载
    RTIS_download_operation* operDownload = (id)[self download:url];
    
    // 绑定尺寸变化的处理
    RTIS_thumb_operation_holder* holderThumb = [RTIS_thumb_operation_holder temporary];
    holderThumb.operation = operThumb;
    view.operThumb = holderThumb;
    [view.signals connect:kSignalBoundsChanged withSelector:@selector(__rtis_thumb_changed:) ofTarget:self];
    
    // 如果尺寸为0，直接返回，因为设置image也没意义，等待view的尺寸变化的时候再处理
    if (szV.width == 0 || szV.height == 0)
        return;
    
    // 如果已经下载好了
    if (operDownload.exists)
    {
        // 设置成本地的图片
        operThumb.local = operDownload.output;
        
        // 已经生成缩略图，则直接应用
        if (operThumb.exists)
        {
            [view setImage:[UIImage imageWithContentsOfFile:operThumb.output.absoluteString]];
        }
        else
        {
            if (operThumb.isExecuting) {
                PASS;
            } else {
                // 没有生成，则放队列中
                OBJC_NOEXCEPTION(
                                 [_queThumbing addOperation:operThumb]
                                 );
                if (resused == NO)
                    [_mpThumbs setObject:operThumb forKey:operThumb.output];
            }
        }
        return;
    }
    
    // 如果没有下载好，则放到队列中等待
    if (resused == NO) {
        [_mpThumbs setObject:operThumb forKey:operThumb.output];
        [operDownload.nextOperations addObject:operThumb];
    }
    
    // 等待下载好，让后放到队列里面生成thumb
    [operDownload.signals connect:kSignalDone withSelector:@selector(__rtis_thumb_origin_download:) ofTarget:self];
}

- (void)__rtis_thumb_origin_download:(SSlot*)s {
    RTIS_download_operation* operDownload = (id)s.sender;
    
    // 没有保存出文件
    if (operDownload.exists == NO)
        return;
    
    // 拿出等待生成thumb的操作
    NSArray* operThumbs = [operDownload.nextOperations popAllObjects];
    
    // 加入到队列
    for (RTIS_thumb_operation* operThumb in operThumbs) {
        operThumb.local = operDownload.output;
        OBJC_NOEXCEPTION(
                         [_queThumbing addOperation:operThumb]
                         );
    }
}

- (void)__rtis_thumb_changed:(SSlot*)s {
    UIView* v = (id)s.sender;
    RTIS_thumb_operation_holder* holderThumb = v.operThumb;
    if (holderThumb == nil)
        return;
    [self setImage:holderThumb.operation.url toView:v];
}

- (void)__rtis_thumb_update:(SSlot*)s {
    RTIS_thumb_operation* operThumb = s.data.object;
    // 从队列中移除
    [_mpThumbs removeObjectForKey:operThumb.output];
}

@end
