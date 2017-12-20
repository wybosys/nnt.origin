
# import "app.h"
# import "VCPracticeBenchmark.h"
# import "VCPracticeWidgets.h"
# include <map>
# include <vector>
# include <list>
# include <unordered_map>

class CNumber
{
public:
    
    CNumber(int v)
    {
        d.i = v;
    }
    
    union
    {
        int i;
    } d;
};

@interface VPracticeBenchmark : UIViewExt

@property (nonatomic, retain) VPracticeButton
*btnCXX,
*btnObjc
;

@end

@implementation VPracticeBenchmark

- (void)onInit {
    [super onInit];
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:BLOCK_RETURN({
        _btnCXX = [VPracticeButton temporary];
        _btnCXX.text = @"CXX STL";
        return _btnCXX;
    })];
    
    [self addSubview:BLOCK_RETURN({
        _btnObjc = [VPracticeButton temporary];
        _btnObjc.text = @"OBJC Types";
        return _btnObjc;
    })];
}

- (void)onLayout:(CGRect)rect {
    [super onLayout:rect];
    
    UIVBox* box = [UIVBox boxWithRect:rect withSpacing:5];
    [box addPixel:30 toView:_btnCXX];
    [box addPixel:30 toView:_btnObjc];
    [box apply];
}

@end

@interface VCPracticeBenchmark ()
{
    ::std::vector<CNumber> vec;
    ::std::list<CNumber> list;
    ::std::map<int, ::std::string> map;
    ::std::unordered_map<int, ::std::string> hmap;
    
    NSMutableArray* ocarr;
}

@property (nonatomic, readonly) NSPerformanceSuit* ps;

@end

@implementation VCPracticeBenchmark

- (void)onInit {
    [super onInit];
    self.title = @"Benchmark";
    self.hidesBottomBarWhenPushed = YES;
    self.classForView = [VPracticeBenchmark class];
    
    _ps = [[NSPerformanceSuit alloc] init];
    
    ocarr = [NSMutableArray new];
}

- (void)onLoaded {
    [super onLoaded];
    
    VPracticeBenchmark* view = (id)self.view;
    [view.btnCXX.signals connect:kSignalClicked withSelector:@selector(actCXX) ofTarget:self];
    [view.btnObjc.signals connect:kSignalClicked withSelector:@selector(actOjbc) ofTarget:self];
}

- (void)actCXX {
    [_ps measure:@"vector 100w add" block:^{
        for (int i = 0; i < 1000000; ++i) {
            vec.push_back(i);
        }
    }];
    
    [_ps measure:@"vector 100w read" block:^{
        for (int i = 0; i < 1000000; ++i) {
            //vec.at(i);
        }
    }];
    
    [_ps measure:@"vector 1w del" block:^{
        for (int i = 0; i < 10000; ++i) {
            vec.erase(vec.begin() + i);
        }
        vec.clear();
    }];
    
    [_ps measure:@"list 100w add" block:^{
        for (int i = 0; i < 1000000; ++i) {
            list.push_back(i);
        }
    }];
    
    [_ps measure:@"list 100w read" block:^{
        for (int i = 0; i < 1000000; ++i) {
            
        }
    }];
    
    [_ps measure:@"list clear" block:^{
        list.clear();
    }];
    
    [_ps measure:@"map 100w add" block:^{
        for (int i = 0; i < 1000000; ++i) {
            map[i] = "ABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFG";
        }
    }];
    
    [_ps measure:@"hashmap 100w add" block:^{
        for (int i = 0; i < 1000000; ++i) {
            hmap[i] = "ABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFG";
        }
    }];
    
    [_ps measure:@"map 100w find" block:^{
        for (int i = 0; i < 1000000; ++i) {
            auto iter = map.find(i);
            if (iter == map.end())
                FATAL("");
        }
    }];
    
    [_ps measure:@"hashmap 100w find" block:^{
        for (int i = 0; i < 1000000; ++i) {
            auto iter = hmap.find(i);
            if (iter == hmap.end())
                FATAL("");
        }
    }];
    
    [_ps measure:@"map 100w del" block:^{
        for (int i = 0; i < 1000000; ++i) {
            map.erase(i);
        }
        if (map.size() != 0)
            FATAL("");
    }];
    
    [_ps measure:@"hashmap 100w del" block:^{
        for (int i = 0; i < 1000000; ++i) {
            hmap.erase(i);
        }
        if (hmap.size() != 0)
            FATAL("");
    }];
    
    [_ps start];
}

- (void)actOjbc {
    [_ps measure:@"objc array 100w add" block:^{
        for (int i = 0; i < 1000000; ++i) {
            [ocarr addObject:@(i)];
        }
    }];
    
    [_ps measure:@"objc array 100w read" block:^{
        for (int i = 0; i < 1000000; ++i) {
            [ocarr objectAtIndex:i];
        }
    }];
    
    [_ps measure:@"objc array 1w del" block:^{
        for (int i = 0; i < 10000; ++i) {
            [ocarr removeObjectAtIndex:i];
        }
        [ocarr removeAllObjects];
    }];
    
    [_ps start];
}

@end
