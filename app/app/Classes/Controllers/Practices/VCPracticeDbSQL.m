
# import "app.h"
# import "VCPracticeDbSQL.h"
# import "DBConfig.h"
# import "DBSqlite.h"
# import "FileSystem+Extension.h"
# import "DbPracticeTypes.h"
# import "VCPracticeWidgets.h"

@interface VPracticeDbSQL : UIViewExt

@property (nonatomic, readonly) UITextFieldExt *inpName, *inpSQL;

@property (nonatomic, readonly) VPracticeButton *btnInit;
@property (nonatomic, readonly) VPracticeButton
*btnSQL,
*btnGetUser,
*btnGetAvatar,
*btnGetJoin,
*btnBenchmark
;

@end

@implementation VPracticeDbSQL

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _inpName = [UITextFieldExt temporary];
        _inpName.borderStyle = UITextBorderStyleBezel;
        _inpName.placeholder = @"NAME";
        return _inpName;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnInit = [VPracticeButton temporary];
        _btnInit.text = @"INIT";
        return _btnInit;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _inpSQL = [UITextFieldExt temporary];
        _inpSQL.borderStyle = UITextBorderStyleBezel;
        _inpSQL.placeholder = @"SQL";
        _inpSQL.text = [[NSStorageExt shared] getStringForKey:@"db::sql::test::query" def:@""];
        return _inpSQL;
    })];

    [self addSubview:BLOCK_RETURN({
        _btnSQL = [VPracticeButton temporary];
        _btnSQL.text = @"QUERY SQL";
        [_btnSQL.signals connect:kSignalClicked withBlock:^(SSlot *s) {
            [[NSStorageExt shared] setString:_inpSQL.text forKey:@"db::sql::test::query"];
        }];
        return _btnSQL;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnGetUser = [VPracticeButton temporary];
        _btnGetUser.text = @"GET USER";
        return _btnGetUser;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnGetAvatar = [VPracticeButton temporary];
        _btnGetAvatar.text = @"GET AVATAR";
        return _btnGetAvatar;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnGetJoin = [VPracticeButton temporary];
        _btnGetJoin.text = @"GET JOIN";
        return _btnGetJoin;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnBenchmark = [VPracticeButton temporary];
        _btnBenchmark.text = @"Benchmark";
        return _btnBenchmark;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_inpName];
    [box addPixel:30 toView:_btnInit];
    [box addPixel:30 toView:_inpSQL];
    [box addPixel:30 toView:_btnSQL];
    [box addPixel:30 toView:_btnGetUser];
    [box addPixel:30 toView:_btnGetAvatar];
    [box addPixel:30 toView:_btnGetJoin];
    [box addPixel:30 toView:_btnBenchmark];
    [box apply];
}

@end

@interface VCPracticeDbSQL ()

@property (nonatomic, retain) DBSqlite *db;
@property (nonatomic, retain) DBScheme *dbuser;
@property (nonatomic, readonly) NSPerformanceSuit* ps;

@end

@implementation VCPracticeDbSQL

- (void)onInit {
    [super onInit];
    self.title = @"DB - SQL";
    self.hidesBottomBarWhenPushed = YES;
    self.classForView = [VPracticeDbSQL class];
    
    _ps = [[NSPerformanceSuit alloc] init];
}

- (void)onLoaded {
    [super onLoaded];
    
    // 初始化数据库
    DBConfig* dbc = [DBConfig temporary];
    dbc.path = [[FSApplication shared] pathWritable:@"test.sqlite.db"];
    self.db = [DBSqlite temporary];
    [self.db open:dbc];
    
    // 连接db
    self.dbuser = [self.db openScheme:@"users"];
    [self.dbuser.signals connect:kSignalDBSchemeChanged withBlock:^(SSlot *s) {
        LOG("TABLE: USERS CHANGED");
    }];
    
    VPracticeDbSQL* view = (id)self.view;
    [view.btnInit.signals connect:kSignalClicked withSelector:@selector(actInit) ofTarget:self];
    [view.btnSQL.signals connect:kSignalClicked withSelector:@selector(actQuerySQL) ofTarget:self];
    [view.btnGetUser.signals connect:kSignalClicked withSelector:@selector(actGetUser) ofTarget:self];
    [view.btnGetAvatar.signals connect:kSignalClicked withSelector:@selector(actGetAvatar) ofTarget:self];
    [view.btnGetJoin.signals connect:kSignalClicked withSelector:@selector(actGetJoin) ofTarget:self];
    [view.btnBenchmark.signals connect:kSignalClicked withSelector:@selector(actBenchmark) ofTarget:self];
}

- (void)actInit {
    NSArray* users = @[@"A", @"B", @"C", @"D", @"E", @"F"];

    DBScheme* dbusers = [self.db openScheme:@"users"];
    for (NSString* each in users) {
        DbUser *user = [DbUser temporary];
        user.name.value = each;
        if ([dbusers fetchObject:user] == NO) {
            user.gender.value = [NSBoolean Random].boolValue;
            user.address.value = [each stringBySelfAppendingCount:[NSRandom valueBoundary:5 To:15]];
            [dbusers addObject:user];
        }
    }
    
    NSArray* avatars = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K"];

    DBScheme* dbavts = [self.db openScheme:@"avatars"];
    for (NSString* each in avatars) {
        DbAvatar *da = [DbAvatar temporary];
        da.name.value = each;
        if ([dbavts fetchObject:da] == NO) {
            da.avatar.value = [NSString stringWithFormat:@"avatar://%@", [each stringBySelfAppendingCount:[NSRandom valueBoundary:1 To:10]]];
            [dbavts addObject:da];
        }
    }

    [self.db commit];
}

- (void)actQuerySQL {
    VPracticeDbSQL* view = (id)self.view;
    NSString* sql = view.inpSQL.text;
    DBScheme* dbs = [self.db openScheme:@""];
    NSArray* da = [dbs query:[SqlClause SQL:sql]];
    LOG(da.description.UTF8String);
}

- (void)actGetUser {
    VPracticeDbSQL* view = (id)self.view;
    
    DBScheme* dbs = [self.db openScheme:@"users"];
    DbUser* du = [DbUser temporary];
    du.name.value = view.inpName.text;
    if ([dbs fetchObject:du] == NO) {
        [UIHud Text:@"NOT FOUND"];
        return;
    }
    
    LOG(du.description.UTF8String);
}

- (void)actGetAvatar {
    VPracticeDbSQL* view = (id)self.view;
    
    DBScheme* dbs = [self.db openScheme:@"avatars"];
    DbAvatar* da = [DbAvatar temporary];
    da.name.value = view.inpName.text;
    if ([dbs fetchObject:da] == NO) {
        [UIHud Text:@"NOT FOUND"];
        return;
    }
    
    LOG(da.description.UTF8String);
}

- (void)actGetJoin {
    DBScheme* dbs = [self.db openScheme:@"users"];
    
    // 名称为D的或者gender=1的
    DbUser* rd = [DbUser temporary];
    rd.name.value = @"B";
    rd.address.value = @"BBBBBB";
    DbUser* rg = [DbUser temporary];
    rg.gender.value = 0;
    DbUser* rf = [DbUser temporary];
    rf.name.value = @"F";
    
    [dbs filters:[[DBFilter match:rd ors:rg] ors:rf]];
    
    // 获得结果
    NSArray* users = [dbs getObjects:[DbUser class]];
    for (DbUser* ur in users) {
        LOG(ur.description.UTF8String);
    }
}

- (void)actBenchmark {
    [_ps measure:@"10w string add" block:^{
        DBSqlite* db = [DBSqlite dbWithConfig:[DBConfig tempFile:@"test.db"]];
        DBScheme* dbs = [db openScheme:@"test"];
        for (int i = 0; i < 100000; ++i) {
            DbSimple* ds = [DbSimple temporary];
            ds.value.value = [NSString RandomString:10];
            [dbs addObject:ds];
        }
        [dbs commit];
        [db close];
    }];
    
    [_ps measure:@"10w string read" block:^{
        DBSqlite* db = [DBSqlite dbWithConfig:[DBConfig tempFile:@"test.db"]];
        DBScheme* dbs = [db openScheme:@"test"];
        for (int i = 0; i < 100000; ++i) {
            DbSimple* ds = [DbSimple temporary];
            if ([dbs fetchObject:ds atIndex:i] == NO)
                FATAL("Sqlite 保存数据失败");
        }
        [dbs commit];
        [db close];
    }];
    
    [_ps measure:@"10w string delete" block:^{
        DBSqlite* db = [DBSqlite dbWithConfig:[DBConfig tempFile:@"test.db"]];
        DBScheme* dbs = [db openScheme:@"test"];
        for (int i = 0; i < 100000; ++i) {
            DbSimple* ds = [DbSimple temporary];
            if ([dbs fetchObject:ds atIndex:0] == NO)
                FATAL("Sqlite 删除数据失败");
            [dbs removeObject:ds];
        }
        [dbs commit];
        [db close];
    }];
    
    [_ps start];
}

@end
