
#import "app.h"
#import "VCPracticeAddressBook.h"
#import "NSSystemFeatures.h"

@interface VPABItem ()

@property (nonatomic, retain) NSAddressBookContact* contact;
@property (nonatomic, readonly) UILabelExt *lblName, *lblPhone;

@end

@implementation VPABItem

- (void)onInit {
    [super onInit];
    
    [self addSubview:BLOCK_RETURN({
        _lblName = [UILabelExt temporary];
        _lblName.textFont = [UIFont boldSystemFontOfSize:16];
        _lblName.textColor = [UIColor blackColor];
        return _lblName;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _lblPhone = [UILabelExt temporary];
        _lblPhone.textFont = [UIFont systemFontOfSize:12];
        _lblPhone.textColor = [UIColor blackColor];
        return _lblPhone;
    })];
    
    self.paddingEdge = CGPaddingMake(10, 10, 10, 10);
    self.backgroundColor = [UIColor whiteColor];
    
    [self.signals connect:kSignalClicked withBlock:^(SSlot *s) {
        UIActionSheetExt* as = [UIActionSheetExt temporary];
        [[as addItem:@"CALL"].signals connect:kSignalClicked withSelector:@selector(actDia) ofTarget:self];
        [[as addItem:@"SMS"].signals connect:kSignalClicked withSelector:@selector(actSMS) ofTarget:self];
        [as show];
    }];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIHBox* box = [UIHBox boxWithRect:rect];
    [box addFlex:1 toView:_lblName];
    [box addPixel:_lblPhone.bestWidth toView:_lblPhone];
    [box apply];
}

- (void)updateData {
    [super updateData];
    
    _lblName.text = _contact.nickname;
    _lblPhone.text = [_contact.phones.firstObject secondObject];
    
    [self setNeedsLayout];
}

- (void)actDia {
    NSDialPhone* ctlr = [NSDialPhone temporary];
    [ctlr dial:_contact.primaryPhone];
}

- (void)actSMS {
    NSComposeSMS* ctlr = [NSComposeSMS temporary];
    [ctlr sendText:@"ABCDEFG" to:_contact.primaryPhone];
}

@end

@interface VCPracticeAddressBook ()

@property (nonatomic, retain) NSArray* contacts;

@end

@implementation VCPracticeAddressBook

- (void)onInit {
    [super onInit];
    self.classForItem = [VPABItem class];
}

- (void)onFin {
    ZERO_RELEASE(_contacts);
    [super onFin];
}

- (void)onLoaded {
    [super onLoaded];
    self.view.backgroundColor = [UIColor whiteColor];
    self.contacts = [[NSAddressBook shared] allContacts];
}

- (NSInteger)tableViewExt:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (CGFloat)tableViewExt:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableViewExt:(UITableViewExt *)tableView cell:(UITableViewCellExt *)cell item:(VPABItem *)item atIndexPath:(NSIndexPath *)indexPath {
    item.contact = [self.contacts objectAtIndex:indexPath.row def:nil];
    cell.paddingEdge = CGPaddingMake(10, 0, 10, 10);
}

@end
