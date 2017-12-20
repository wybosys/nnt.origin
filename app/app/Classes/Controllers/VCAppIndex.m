
# import "app.h"
# import "VCAppIndex.h"
# import "NSSystemFeatures.h"
# import "VCPracticeTable.h"
# import "VCPracticeCollection.h"
# import "UIImageLibrary.h"
# import "VCPracticeInfo.h"
# import "VCPracticeToolbox.h"
# import "VCPracticeScroll.h"
# import "VCPracticeSegment.h"
# import "VCPracticeWidgets.h"
# import "VCPracticeTypes.h"
# import "VCPracticeAV.h"
# import "VCPractice3RD.h"
# import "VCPracticeSignalSlot.h"
# import "UIFilesProjector.h"
# import "VCPracticeTabbar.h"
# import "VCPracticeTableIndex.h"
# import "VCPracticeFeatures.h"
# import "VCPracticeBenchmark.h"
# import "VCPracticeStack.h"
# import "VCPracticeWebpage.h"
# import "VCPracticeCustomSearch.h"
# import "VCPractice2SegmentScroll.h"
# import "VCPracticeServices.h"
# import "VCPracticeEffects.h"
# import "VCPracticeMemory.h"
# import "VCPracticeAPPS.h"
# import "VCPractice3DX.h"

@interface VAppIndex : UIViewExt

@property (nonatomic, readonly) UILabelButton
*btnSStest;

@property (nonatomic, readonly) VPracticeButton
*btnBm, *btnInfo,
*btnTab, *btnSearch,
*btnTabIndex,
*btnTable,
*btnCollection,
*btnMemory, *btnPhotoPick, *btnPhotosPick,
*btnToolbox,
*btnScroll, *btnScroll2, *btn2Seg,
*btnWidget, *btnWeb, *btnEffects,
*btnTypes,
*btnAv, *btn3dx,
*btn3rd, *btnApps,
*btnFeatures, *btnServices,
*btnVCStack, *btnVStack
;

@property (nonatomic, readonly) VPracticeImage *imgPhoto;
@property (nonatomic, readonly) UILabelExt *lblLBS;

@end

@implementation VAppIndex

- (void)onInit {
    [super onInit];
    
    [self addSubview:BLOCK_RETURN({
        _btnSStest = [UILabelButton temporary];
        //_btnSStest.backgroundImage = [UIImage stretchImage:@"com_btn_blue"];
        //_btnSStest.highlightImage = [UIImage stretchImage:@"com_btn_red"];
        //_btnSStest.textColor = [UIColor whiteColor];
        _btnSStest.text = @"Signal/Slot";
        
        _btnSStest.backgroundColor = [UIColor whiteColor];
        _btnSStest.textColor = [UIColor orangeColor];
        _btnSStest.highlightColor = _btnSStest.textColor;
        _btnSStest.highlightedTextColor = _btnSStest.backgroundColor;
        return _btnSStest;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnBm = [VPracticeButton temporary];
        _btnBm.text = @"Benchmark";
        return _btnBm;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnInfo = [VPracticeButton temporary];
        _btnInfo.text = @"Info";
        return _btnInfo;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnTab = [VPracticeButton temporary];
        _btnTab.text = @"Tab";
        return _btnTab;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnSearch = [VPracticeButton temporary];
        _btnSearch.text = @"Search";
        return _btnSearch;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnTabIndex = [VPracticeButton temporary];
        _btnTabIndex.text = @"TabIndex";
        return _btnTabIndex;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnTable = [VPracticeButton temporary];
        _btnTable.text = @"Table";
        return _btnTable;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnCollection = [VPracticeButton temporary];
        _btnCollection.text = @"Collection";
        return _btnCollection;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnMemory = [VPracticeButton temporary];
        _btnMemory.text = @"Memory";
        return _btnMemory;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnPhotoPick = [VPracticeButton temporary];
        _btnPhotoPick.text = @"Photo";
        return _btnPhotoPick;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnPhotosPick = [VPracticeButton temporary];
        _btnPhotosPick.text = @"Photos";
        return _btnPhotosPick;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnToolbox = [VPracticeButton temporary];
        _btnToolbox.text = @"Toolbox";
        return _btnToolbox;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnScroll = [VPracticeButton temporary];
        _btnScroll.text = @"Scroll";
        return _btnScroll;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnScroll2 = [VPracticeButton temporary];
        _btnScroll2.text = @"Scroll2";
        return _btnScroll2;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btn2Seg = [VPracticeButton temporary];
        _btn2Seg.text = @"2Seg";
        return _btn2Seg;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnWidget = [VPracticeButton temporary];
        _btnWidget.text = @"Widget";
        return _btnWidget;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnWeb = [VPracticeButton temporary];
        _btnWeb.text = @"Web";
        return _btnWeb;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnEffects = [VPracticeButton temporary];
        _btnEffects.text = @"Effects";
        return _btnEffects;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnAv = [VPracticeButton temporary];
        _btnAv.text = @"Audio Video";
        return _btnAv;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btn3dx = [VPracticeButton temporary];
        _btn3dx.text = @"3DX";
        return _btn3dx;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnTypes = [VPracticeButton temporary];
        _btnTypes.text = @"Types";
        return _btnTypes;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btn3rd = [VPracticeButton temporary];
        _btn3rd.text = @"3RD";
        return _btn3rd;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnApps = [VPracticeButton temporary];
        _btnApps.text = @"APPS";
        return _btnApps;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnFeatures = [VPracticeButton temporary];
        _btnFeatures.text = @"Features";
        return _btnFeatures;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnServices = [VPracticeButton temporary];
        _btnServices.text = @"Services";
        return _btnServices;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnVCStack = [VPracticeButton temporary];
        _btnVCStack.text = @"VCStack";
        return _btnVCStack;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnVStack = [VPracticeButton temporary];
        _btnVStack.text = @"VStack";
        return _btnVStack;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _lblLBS = [UILabelExt temporary];
        _lblLBS.text = @"LBS";
        return _lblLBS;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _imgPhoto = [VPracticeImage temporary];
        _imgPhoto.contentMode = UIViewContentModeScaleAspectFit;
        _imgPhoto.disableCache = YES;
        _imgPhoto.imageDataSource = @"http://clubfiles.liba.com/2010/09/12/13/29277519.jpg";
        return _imgPhoto;
    })];
    
    self.paddingEdge = CGPaddingMake(50, 10, 10, 10);
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 HBox:^(UIHBox *box) {
        box.margin = CGMarginMake(0, 0, 0, 5);
        [box addFlex:1 toView:_btnSStest];
        [box addFlex:1 toView:_btnBm];
        [box addFlex:1 toView:_btnInfo];
    }];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnTab];
        [box addFlex:1 toView:_btnSearch];
    }];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnTable];
        [box addFlex:1 toView:_btnTabIndex];
        [box addFlex:1 toView:_btnCollection];
    }];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnMemory];
        [box addFlex:1 toView:_btnPhotoPick];
        [box addFlex:1 toView:_btnPhotosPick];
    }];
    [box addPixel:30 toView:_btnToolbox];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnScroll];
        [box addFlex:1 toView:_btnScroll2];
        [box addFlex:1 toView:_btn2Seg];
    }];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnWidget];
        [box addFlex:1 toView:_btnWeb];
        [box addFlex:1 toView:_btnEffects];
    }];
    [box addPixel:30 toView:_btnTypes];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnAv];
        [box addFlex:1 toView:_btn3dx];
    }];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnFeatures];
        [box addFlex:1 toView:_btnServices];
    }];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btn3rd];
        [box addFlex:1 toView:_btnApps];
    }];
    [box addPixel:30 HBox:^(UIHBox *box) {
        [box addFlex:1 toView:_btnVCStack];
        [box addFlex:1 toView:_btnVStack];
    }];
    [box addPixel:30 toView:_lblLBS];
    [box addFlex:1 toView:nil];
    [box addPixel:100 toView:_imgPhoto];
    [box apply];
}

@end

@implementation VCAppIndex

- (void)onInit {
    [super onInit];
    
    self.classForView = [VAppIndex class];
    self.hidesTopBarWhenPushed = YES;
}

- (void)onFin {
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    
    VAppIndex* view = (id)self.view;
    
    [view.btnSStest.signals connect:kSignalClicked withSelector:@selector(actSSTest) ofTarget:self];
    [view.btnBm.signals connect:kSignalClicked withSelector:@selector(actBm) ofTarget:self];
    [view.btnInfo.signals connect:kSignalClicked withSelector:@selector(actInfo) ofTarget:self];
    [view.btnTab.signals connect:kSignalClicked withSelector:@selector(actTabBar) ofTarget:self];
    [view.btnSearch.signals connect:kSignalClicked withSelector:@selector(actSearch) ofTarget:self];
    [view.btnTabIndex.signals connect:kSignalClicked withSelector:@selector(actTabIndex) ofTarget:self];
    [view.btnTable.signals connect:kSignalClicked withSelector:@selector(actTable) ofTarget:self];
    [view.btnCollection.signals connect:kSignalClicked withSelector:@selector(actCollection) ofTarget:self];
    [view.btnMemory.signals connect:kSignalClicked withSelector:@selector(actMemory) ofTarget:self];
    [view.btnPhotoPick.signals connect:kSignalClicked withSelector:@selector(actPicker) ofTarget:self];
    [view.btnPhotosPick.signals connect:kSignalClicked withSelector:@selector(actPickers) ofTarget:self];
    [view.btnToolbox.signals connect:kSignalClicked withSelector:@selector(actToolbox) ofTarget:self];
    [view.btnScroll.signals connect:kSignalClicked withSelector:@selector(actScroll) ofTarget:self];
    [view.btnScroll2.signals connect:kSignalClicked withSelector:@selector(actScroll2) ofTarget:self];
    [view.btn2Seg.signals connect:kSignalClicked withSelector:@selector(act2Seg) ofTarget:self];
    [view.btnWidget.signals connect:kSignalClicked withSelector:@selector(actWidgets) ofTarget:self];
    [view.btnWeb.signals connect:kSignalClicked withSelector:@selector(actWebpage) ofTarget:self];
    [view.btnEffects.signals connect:kSignalClicked withSelector:@selector(actEffects) ofTarget:self];
    [view.btnTypes.signals connect:kSignalClicked withSelector:@selector(actTypes) ofTarget:self];
    [view.btnAv.signals connect:kSignalClicked withSelector:@selector(actAV) ofTarget:self];
    [view.btn3dx.signals connect:kSignalClicked withSelector:@selector(act3DX) ofTarget:self];
    [view.btnFeatures.signals connect:kSignalClicked withSelector:@selector(actFeatures) ofTarget:self];
    [view.btnServices.signals connect:kSignalClicked withSelector:@selector(actServices) ofTarget:self];
    [view.btn3rd.signals connect:kSignalClicked withSelector:@selector(act3RD) ofTarget:self];
    [view.btnApps.signals connect:kSignalClicked withSelector:@selector(actAPPS) ofTarget:self];
    [view.imgPhoto.signals connect:kSignalClicked withSelector:@selector(actImagePresent) ofTarget:self];
    [view.btnVCStack.signals connect:kSignalClicked withSelector:@selector(actVCStack) ofTarget:self];
    [view.btnVStack.signals connect:kSignalClicked withSelector:@selector(actVStack) ofTarget:self];
    
    NSLocationService* tl = [NSLocationService temporary];
    tl.decodesInfo = YES;
    [tl.signals connect:kSignalLocationChanged withBlock:^(SSlot *s) {
        NSLocationInfo* li = s.data.object;
        //view.lblLBS.text = [NSString stringWithFormat:@"%f:%f %@", li.locationValue.coordinate.longitude, li.locationValue.coordinate.latitude, li.address];
        view.lblLBS.text = li.address;
    }];
    [tl fetch];
    
    // APNS
    [[NSApnsService shared].signals connect:kSignalDeviceTokenGot withBlock:^(SSlot *s) {
        NSData* da = s.data.object;
        NSString* str = [NSString stringWithData:da encoding:NSASCIIStringEncoding];
        NSLog(str, nil);
    }];
    [[NSApnsService shared] start];
}

- (void)actSSTest {
    VCPracticeSignalSlot* tmp = [VCPracticeSignalSlot temporary];
    [self.navigationController pushViewController:tmp];
}

- (void)actBm {
    VCPracticeBenchmark* tmp = [VCPracticeBenchmark temporary];
    [self.navigationController pushViewController:tmp];
}

- (void)actInfo {
    [self.navigationController pushViewController:[VCPracticeInfo temporary]];
}

- (void)actTabBar {
    VCPracticeTabbar* tmp = [VCPracticeTabbar temporary];
    [self.navigationController pushViewController:tmp];
}

- (void)actSearch {
    VCPracticeCustomSearch* tmp = [VCPracticeCustomSearch temporary];
    [self.navigationController pushViewController:tmp];
}

- (void)actTabIndex {
    VCPracticeTableIndex* tmp = [VCPracticeTableIndex temporary];
    [self.navigationController pushViewController:tmp];
}

- (void)actTable {
    VCPracticeTable* tmp = [VCPracticeTable temporary];
    [self.navigationController pushViewController:tmp];
}

- (void)actCollection {
    VCPracticeCollection* tmp = [VCPracticeCollection temporary];
    [self.navigationController pushViewController:tmp];
}

- (void)actPicker {
    UIImageLibraryPicker* pick = [UIImageLibraryPicker temporary];
    pick.limitSize = CGSizeMake(320, 320);
    pick.lockAspect = YES;
    [pick execute];
    
    [pick.signals connect:kSignalDone withBlock:^(SSlot *s) {
        VAppIndex* view = (id)self.view;
        UIImageLibraryPicker* picker = (id)s.sender;
        view.imgPhoto.imageDataSource = picker.paths.firstObject;
    }];
}

- (void)actPickers {
    UIImageLibraryPicker* pick = [UIImageLibraryPicker temporary];
    pick.limitSize = CGSizeMake(320, 320);
    pick.lockAspect = YES;
    pick.maxCount = 4;
    [pick execute];
    [pick.signals connect:kSignalDone withBlock:^(SSlot *s) {
        VAppIndex* view = (id)self.view;
        UIImageLibraryPicker* picker = (id)s.sender;
        view.imgPhoto.imageDataSource = picker.paths.firstObject;
    }];
}

- (void)actToolbox {
    [[UIAppDelegate shared].container toggle];
}

- (void)actScroll {
    [self.navigationController pushViewController:[VCPracticeScroll temporary]];
}

- (void)actScroll2 {
    [self.navigationController pushViewController:[VCPracticeSegment temporary]];
}

- (void)act2Seg {
    [self.navigationController pushViewController:[VCPractice2SegmentScroll temporary]];
}

- (void)actWidgets {
    [self.navigationController pushViewController:[VCPracticeWidgets temporary]];
}

- (void)actWebpage {
    [self.navigationController pushViewController:[VCPracticeWebpage temporary]];
}

- (void)actTypes {
    [self.navigationController pushViewController:[VCPracticeTypes temporary]];
}

- (void)actAV {
    [self.navigationController pushViewController:[VCPracticeAV temporary]];
}

- (void)actFeatures {
    [self.navigationController pushViewController:[VCPracticeFeatures temporary]];
}

- (void)actServices {
    [self.navigationController pushViewController:[VCPracticeServices temporary]];
}

- (void)act3RD {
    [self.navigationController pushViewController:[VCPractice3RD temporary]];
}

- (void)actAPPS {
    [self.navigationController pushViewController:[VCPracticesAPPS temporary]];
}

- (void)actImagePresent {
    VAppIndex* view = (id)self.view;
    UIFilesProjector* fp = [UIFilesProjector temporary];
    fp.thumbs = @[@"http://clubfiles.liba.com/2010/09/12/13/29277519.jpg",
                  @"http://img0.bdstatic.com/img/image/shouye/sywmxyct.jpg",
                  @"http://img0.bdstatic.com/img/image/shouye/jjdzh-12234607809.jpg",
                  @"http://img0.bdstatic.com/img/image/shouye/qcgqbz-9790130655.jpg"];
    fp.files = fp.thumbs;
    fp.viewSource = view.imgPhoto;
    [fp open];
}

- (void)actVCStack {
    VCPracticeStack* ctlr = [VCPracticeStack temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)actVStack {
    
}

- (void)actEffects {
    VCPracticeEffects* ctlr = [VCPracticeEffects temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)actMemory {
    VCPracticeMemory* ctlr = [VCPracticeMemory temporary];
    [self.navigationController pushViewController:ctlr];
}

- (void)act3DX {
    VCPractice3DX* ctlr = [VCPractice3DX temporary];
    [self.navigationController pushViewController:ctlr];
}

@end
