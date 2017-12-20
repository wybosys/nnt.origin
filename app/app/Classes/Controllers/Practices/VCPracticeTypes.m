
# import "app.h"
# import "VCPracticeTypes.h"
# import "VCPracticeWidgets.h"
# import "FileSystem+Extension.h"
# import "VCPracticeCoreData.h"
# import "VCPracticeDbKv.h"
# import "VCPracticeDbSQL.h"
# import "RTImageServer.h"
# import "VCPracticeRTISTable.h"

@interface RTISImageView : UIImageViewExt

@end

@implementation RTISImageView

- (void)onInit {
    [super onInit];
}

- (void)onFin {
    [super onFin];
}

@end

@interface VPracticeTypes : UIScrollViewExt

@property (nonatomic, readonly) VPracticeButton
*btnJsonApi,
*btnSJsonApi,
*btnRegular,
*btnUpload, *btnDownload,
*btnKvDb,
*btnSqlDb,
*btnCd,
*btnRTIS,
*btnRTISTable
;

@property (nonatomic, readonly) UIProgressView *prgDownload, *prgUpload;
@property (nonatomic, readonly) RTISImageView* imgRTIS;

@end

@implementation VPracticeTypes

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnJsonApi = [VPracticeButton temporary];
        _btnJsonApi.text = @"JsApi";
        return _btnJsonApi;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnSJsonApi = [VPracticeButton temporary];
        _btnSJsonApi.text = @"SJsApi";
        return _btnSJsonApi;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnRegular = [VPracticeButton temporary];
        _btnRegular.text = @"Regular Express";
        return _btnRegular;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnUpload = [VPracticeButton temporary];
        _btnUpload.text = @"Upload File";
        return _btnUpload;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnDownload = [VPracticeButton temporary];
        _btnDownload.text = @"Download File";
        return _btnDownload;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _prgDownload = [UIProgressView temporary];
        return _prgDownload;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _prgUpload = [UIProgressView temporary];
        return _prgUpload;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnKvDb = [VPracticeButton temporary];
        _btnKvDb.text = @"Key-Value DB";
        return _btnKvDb;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnSqlDb = [VPracticeButton temporary];
        _btnSqlDb.text = @"Sqlite DB";
        return _btnSqlDb;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnCd = [VPracticeButton temporary];
        _btnCd.text = @"NS - CoreData";
        return _btnCd;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnRTIS = [VPracticeButton temporary];
        _btnRTIS.text = @"RT Image Server";
        return _btnRTIS;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _imgRTIS = [RTISImageView temporary];
        _imgRTIS.contentMode = UIViewContentModeScaleAspectFit;
        _imgRTIS.backgroundColor = [UIColor randomColor];
        _imgRTIS.height = (int)[NSRandom valueBoundary:100 To:300];
        [[RTImageServer shared] setImage:[NSURL URLWithString:@"http://www.bzbuluo.cn/view/pics/20130927190444415.jpg"]
                                  toView:_imgRTIS];
        [_imgRTIS.signals connect:kSignalClicked withSelector:@selector(actRTISClicked) ofTarget:self];
        return _imgRTIS;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnRTISTable = [VPracticeButton temporary];
        _btnRTISTable.text = @"RTIS Table";
        return _btnRTISTable;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnJsonApi];
        [box addFlex:1 toView:_btnSJsonApi];
    }];
    
    [box addPixel:30 toView:_btnRegular];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnUpload];
        [box addFlex:1 toView:_btnDownload];
    }];
    [box addPixel:25 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_prgUpload];
        [box addFlex:1 toView:_prgDownload];
    }];
    [box addPixel:30 toView:_btnKvDb];
    [box addPixel:30 toView:_btnSqlDb];
    [box addPixel:30 toView:_btnCd];
    [box addPixel:30 toView:_btnRTIS];
    [box addPixel:30 toView:_btnRTISTable];
    [box addPixel:(_imgRTIS.frame.size.height + 5) toView:_imgRTIS];
    [box apply];
    
    self.contentHeight = box.position.y;
}

- (void)actRTISClicked {
    _imgRTIS.height = (int)[NSRandom valueBoundary:100 To:300];
    [self setNeedsLayout];
}

@end

@implementation VCPracticeTypes

- (void)onInit {
    [super onInit];
    self.classForView = [VPracticeTypes class];
}

- (void)onLoaded {
    [super onLoaded];
    VPracticeTypes* view = (id)self.view;
    [view.btnJsonApi.signals connect:kSignalClicked withSelector:@selector(actJsApi) ofTarget:self];
    [view.btnSJsonApi.signals connect:kSignalClicked withSelector:@selector(actSJsApi) ofTarget:self];
    [view.btnRegular.signals connect:kSignalClicked withSelector:@selector(actRegex) ofTarget:self];
    [view.btnUpload.signals connect:kSignalClicked withSelector:@selector(actUpload) ofTarget:self];
    [view.btnDownload.signals connect:kSignalClicked withSelector:@selector(actDownload) ofTarget:self];
    [view.btnKvDb.signals connect:kSignalClicked withSelector:@selector(actKvDB) ofTarget:self];
    [view.btnSqlDb.signals connect:kSignalClicked withSelector:@selector(actSqlDB) ofTarget:self];
    [view.btnCd.signals connect:kSignalClicked withSelector:@selector(actCoreData) ofTarget:self];
    [view.btnRTIS.signals connect:kSignalClicked withSelector:@selector(actRTIS) ofTarget:self];
    [view.btnRTISTable.signals connect:kSignalClicked withSelector:@selector(actRTISTable) ofTarget:self];
}

- (void)actJsApi {
    NetUrlObj* bt = [NetUrlObj temporary];
    bt.url = @"http://api.map.baidu.com/geocoder/v2/?address=%E7%99%BE%E5%BA%A6%E5%A4%A7%E5%8E%A6&output=json&ak=huaSZmtzFy1uY9AgQCvrkw2o";
    [[ApiSession shared] fetch:bt with:^(SNetObj *m) {
        m.showWaiting = YES;
        [m.signals connect:kSignalApiSucceed withBlock:^(SSlot *s) {
            LOG("success");
        }];
    }];
}

- (void)actSJsApi {
    NetUrlObj* bt = [NetUrlObj temporary];
    bt.url = @"https://passport.gamexhb.com/b.php";
    [[ApiSession shared] fetch:bt with:^(SNetObj *m) {
        m.showWaiting = YES;
        [m.signals connect:kSignalApiSucceed withBlock:^(SSlot *s) {
            LOG("success");
        }];
    }];
}

- (void)actRegex {
    NSString* str = @"http://xxx.baidu.com/abc.png?w123_h456";
    NSRegularExpression* rex = [NSRegularExpression cachedRegularExpressionWithPattern:@"\\?w([0-9]+)_h([0-9]+)$"];
    NSArray* vals = [rex capturesInString:str];
    LOG("width = %d, height = %d", [vals.firstObject intValue], [vals.secondObject intValue]);
}

- (void)actDownload {
    NSString* furl = @"http://www.nationalgeographic.com/astrobiology/images/MM8277_20131218_02851_blck_bckg.jpg";
    FileSessionHandle* fsh = [[FileSession shared] fetch:[NSURL URLWithString:furl]];
    [fsh.signals connect:kSignalValueChanged withBlock:^(SSlot *s) {
        VPracticeTypes* view = (id)self.view;
        view.prgDownload.percentage = s.data.object;
    }];
}

- (void)actUpload {
    NetUrlObj* bt = [NetUrlObj temporary];
    bt.url = @"http://192.168.1.31/releases/uploadfile.php";
    [bt setParam:@"projectname" value:@"aloha"];
    [bt setParam:@"platform" value:@"iOS"];
    [bt setFile:@"releasefile" path:[[FSApplication shared] pathBundle:@"uploaddata.zip"]];
    [[ApiSession shared] fetch:bt with:^(SNetObj *m) {
        m.showWaiting = YES;
        [m.signals connect:kSignalApiSucceed withBlock:^(SSlot *s) {
            [UIHud Success:@"Success"];
        }];
        [m.signals connect:kSignalApiSendProgress withBlock:^(SSlot *s) {
            VPracticeTypes* view = (id)self.view;
            view.prgUpload.percentage = s.data.object;
        }];
    }];
}

- (void)actKvDB {
    VCPracticeDbKv* ctlr = [VCPracticeDbKv temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)actSqlDB {
    VCPracticeDbSQL* ctlr = [VCPracticeDbSQL temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)actCoreData {
    VCPracticeCoreData* ctlr = [VCPracticeCoreData temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)actRTIS {
    NSArray* fss = @[
                     @"http://www.bzbuluo.cn/view/pic/2012516232419779.jpg",
                     @"http://www.bzbuluo.cn/view/bizhi/20125273465611.jpg",
                     @"http://www.bzbuluo.cn/view/pics/20130927190444415.jpg",
                     @"http://www.bzbuluo.cn/view/pics/20130223160417669.jpg",
                     @"http://www.bzbuluo.cn/view/pics/20121221234927418.jpg",
                     @"http://www.bzbuluo.cn/view/pic/2012919225515161.jpg",
                     @"http://www.bzbuluo.cn/view/pic/2012523233459551.jpg"
                     ];
    for (NSString* each in fss) {
        [[RTImageServer shared] download:[NSURL URLWithString:each]];
    }
}

- (void)actRTISTable {
    VCPracticeRTISTable* ctlr = [VCPracticeRTISTable temporary];
    [self.navigationController pushViewController:ctlr];
}

@end
