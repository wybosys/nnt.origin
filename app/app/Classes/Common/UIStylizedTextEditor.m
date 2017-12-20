
# import "Common.h"
# import "UIStylizedTextEditor.h"
# import <CoreText/CoreText.h>
# import "CoreFoundation+Extension.h"

// utiliy class

@interface UIStylizedTextPosition : UITextPosition <NSCopying>

@property (nonatomic, assign) uint offset;

@end

@implementation UIStylizedTextPosition

- (id)copyWithZone:(NSZone *)zone {
    UIStylizedTextPosition* ret = [[[self class] alloc] init];
    ret.offset = self.offset;
    return ret;
}

@end

@interface UIStylizedTextRange : UITextRange <NSCopying>

@property (nonatomic, assign) NSRange range;
@property (nonatomic, readonly) UIStylizedTextPosition *position;

@end

@implementation UIStylizedTextRange

- (id)init {
    self = [super init];
    _range = NSRangeZero;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    UIStylizedTextRange* ret = [[[self class] alloc] init];
    ret.range = self.range;
    return ret;
}

- (UIStylizedTextPosition*)position {
    UIStylizedTextPosition* ret = [UIStylizedTextPosition temporary];
    ret.offset = NSMaxRange(self.range);
    return ret;
}

@end

@interface UIStylizedTextEditorTokenizer : UITextInputStringTokenizer

@end

@implementation UIStylizedTextEditorTokenizer

@end

// inner view

@interface UIStylizedTextView : UIStylizedStringView

@property (nonatomic, readonly) UICaretIdentifier* caret;

@end

@implementation UIStylizedTextView

- (void)onInit {
    [super onInit];
    
    _caret = [[UICaretIdentifier alloc] initWithZero];
    [self addSubview:_caret];
    SAFE_RELEASE(_caret);
}

- (CGRect)rectForTextRange:(UIStylizedTextRange*)range {
    CGRect ret = CGRectZero;
    CGRect rect = self.bounds;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    NSArray* lines = (NSArray*)CTFrameGetLines(frame);
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    NSUInteger idxLine = 0, olditem = 0;
    for (id each in lines)
    {
        CTLineRef line = (CTLineRef)each;
        for (id each in (NSArray*)CTLineGetGlyphRuns(line))
        {
            CTRunRef run = (CTRunRef)each;
            CFRange rgnRun = CTRunGetStringRange(run);
            
            // 查找对应的item
            for (NSUInteger i = olditem; i < self.string.items.count; ++i)
            {
                // range是否匹配
                BOOL found = range.range.location == rgnRun.location;
                
                if (found)
                { // 找到
                    olditem = i;
                    
                    CGRect rc;
                    CGFloat ascent, descent;
                    rc.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                    rc.size.height = ascent + descent;
                    
                    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, rgnRun.location, NULL);
                    rc.origin.x = origins[idxLine].x + rect.origin.x + xOffset;
                    rc.origin.y = origins[idxLine].y + rect.origin.y - descent;
                    rc.origin.y = rect.size.height - rc.size.height - rc.origin.y;
                    
                    ret = rc;
                    goto FOUND;
                }
            }
        }
        
        ++idxLine;
    }
    
FOUND:
    CFRelease(frame);
    CFRelease(framesetter);
    CGPathRelease(path);
    
    return ret;
}

- (CGRect)rectForTextPosition:(UIStylizedTextPosition*)position {
    CGRect ret = CGRectZero;
    CGRect rect = self.bounds;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    NSArray* lines = (NSArray*)CTFrameGetLines(frame);
    
    // 获得每一行的起点
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    for (uint i = 0; i < lines.count; ++i) {
        origins[i] = CGPointOffsetByPoint(origins[i], rect.origin);
    }
    
    NSUInteger idxLine = 0;
    for (id each in lines)
    {
        CTLineRef line = (CTLineRef)each;
        for (id each in (NSArray*)CTLineGetGlyphRuns(line))
        {
            CTRunRef run = (CTRunRef)each;
            CFRange rgnRun = CTRunGetStringRange(run);
            BOOL begin = position.offset == -1;
            if (begin)
                position.offset = 0;
            
            // range是否匹配
            BOOL found = CFRangeContain(rgnRun, position.offset);
            
            if (found)
            { // 找到了text区间
                // 计算映射在该text里面的位置
                int const location = position.offset - rgnRun.location;
                
                CGRect rc;
                CGFloat ascent, descent;
                rc.size.width = CTRunGetTypographicBounds(run, CFRangeMake(location, 1), &ascent, &descent, NULL);
                if (begin)
                    rc.size.width = 0;
                rc.size.height = ascent + descent;
                
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, rgnRun.location + location, NULL);
                rc.origin.x = origins[idxLine].x + xOffset;
                rc.origin.y = origins[idxLine].y - descent;
                
                // 调整坐标系
                rc.origin.y = rect.size.height - rc.size.height - rc.origin.y;
                
                ret = rc;
                goto FOUND;
            }
        }
        
        ++idxLine;
    }
    
FOUND:
    CFRelease(frame);
    CFRelease(framesetter);
    CGPathRelease(path);
    
    return ret;
}

- (NSRange)textRangeForPoint:(CGPoint)pt {
    NSRange ret = NSRangeZero;
    
    CGRect const rect = self.bounds;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    NSArray* lines = (NSArray*)CTFrameGetLines(frame);
    
    // 获得每一行的起点
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    for (uint i = 0; i < lines.count; ++i) {
        origins[i] = CGPointOffsetByPoint(origins[i], rect.origin);
    }
    
    NSUInteger idxLine = 0;
    for (id each in lines)
    {
        CTLineRef line = (CTLineRef)each;
        for (id each in (NSArray*)CTLineGetGlyphRuns(line))
        {
            CTRunRef run = (CTRunRef)each;
            CFRange rgnRun = CTRunGetStringRange(run);
            
            for (uint i = 0; i < rgnRun.length; ++i)
            {
                CGRect rc;
                CGFloat ascent, descent;
                rc.size.width = CTRunGetTypographicBounds(run, CFRangeMake(i, 1), &ascent, &descent, NULL);
                rc.size.height = ascent + descent;
                
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, rgnRun.location + i, NULL);
                rc.origin.x = origins[idxLine].x + xOffset;
                rc.origin.y = origins[idxLine].y - descent;
                
                // 调整坐标系
                rc.origin.y = rect.size.height - rc.size.height - rc.origin.y;
                
                if (CGRectContainsPoint(rc, pt)) {
                    ret = NSMakeRange(rgnRun.location + i, 1);
                    goto FOUND;
                }
            }
        }
        
        ++idxLine;
    }
    
FOUND:
    CFRelease(frame);
    CFRelease(framesetter);
    CGPathRelease(path);
    
    return ret;
}

@end

// editor class

@interface UIStylizedTextEditor ()
<UITextInput>
{
    UIStylizedTextEditorTokenizer *_tokenizer;
    UIStylizedTextRange *_selectedTextRange;
}

@property (nonatomic, readonly) UIStylizedTextView *stringView;
@property (nonatomic, assign) id<NSStylizedItemString> markedItem;

CC_WARNING_PUSH
CC_WARNING_DISABLE(-Wobjc-property-no-attribute)
@property (nonatomic, retain) UIStylizedTextRange *markedTextRange;
CC_WARNING_POP

@end

@implementation UIStylizedTextEditor

- (void)onInit {
    [super onInit];
    
    _tokenizer = [[UIStylizedTextEditorTokenizer alloc] initWithTextInput:self];
    
    UIStylizedTextView* content = [[UIStylizedTextView alloc] initWithZero];
    self.viewContent = content;
    SAFE_RELEASE(content);
    
    [content.signals connect:kSignalClicked withSelector:@selector(becomeFirstResponder) ofTarget:self];
    [content.signals connect:kSignalClicked withSelector:@selector(__cb_editor_clicked:) ofTarget:self];
}

- (void)onFin {
    ZERO_RELEASE(_tokenizer);
    ZERO_RELEASE(markedTextStyle);
    ZERO_RELEASE(_markedTextRange);
    ZERO_RELEASE(_selectedTextRange);
    [super onFin];
}

- (UIStylizedTextView*)stringView {
    return (UIStylizedTextView*)self.viewContent;
}

- (void)setDelegate:(id<UIStylizedTextEditorDelegate>)delegate {
    self.stringView.delegate = delegate;
}

- (id<UIStylizedTextEditorDelegate>)delegate {
    return (id<UIStylizedTextEditorDelegate>)self.stringView.delegate;
}

- (void)setString:(NSStylizedString*)string {
    self.stringView.string = string;
}

- (NSStylizedString*)string {
    return self.stringView.string;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    if ([self isFirstResponder])
        return YES;
    if ([super becomeFirstResponder] == NO)
        return NO;
    UIStylizedTextRange* range = [UIStylizedTextRange temporary];
    range.range = NSMakeRange(self.stringView.attributedString.length, 0);
    self.selectedTextRange = range;
    return YES;
}

- (id<NSStylizedItemString>)stringItemAfter:(id<NSStylizedItemString>)item {
    id tgt = [self.string.items nextObject:item];
    if ([tgt conformsToProtocol:@protocol(NSStylizedItemString)])
        return tgt;
    [self.string append:nil format:@""];
    tgt = self.string.items.lastObject;
    [self.string.items moveObject:tgt afterObject:item];
    return tgt;
}

- (id<NSStylizedItemString>)stringItemBefore:(id<NSStylizedItemString>)item {
    id tgt = [self.string.items nextObject:item];
    if ([tgt conformsToProtocol:@protocol(NSStylizedItemString)])
        return tgt;
    [self.string append:nil format:@""];
    tgt = self.string.items.lastObject;
    [self.string.items moveObject:tgt beforeObject:item];
    return tgt;
}

// impl proprities

@synthesize inputDelegate, markedTextStyle, selectionAffinity;
@synthesize selectedTextRange = _selectedTextRange;

- (UITextPosition*)beginningOfDocument {
    UIStylizedTextPosition* pos = [UIStylizedTextPosition temporary];
    pos.offset = 0;
    return pos;
}

- (UITextPosition*)endOfDocument {
    UIStylizedTextPosition* pos = [UIStylizedTextPosition temporary];
    pos.offset = self.stringView.attributedString.length;
    return pos;
}

@synthesize tokenizer = _tokenizer;

- (void)setSelectedTextRange:(UIStylizedTextRange *)selectedTextRange {
    PROPERTY_RETAIN(_selectedTextRange, selectedTextRange);
    
    // update caret
    UIStylizedTextPosition* pos = selectedTextRange.position;
    if (pos.offset) {
        pos.offset -= 1;
        self.stringView.caret.frame = [self caretRectForPosition:pos];
    } else {
        self.stringView.caret.positionX = self.stringView.bounds.origin.x;
    }
}

// impl delegate.

- (BOOL)hasText {
    return self.string.items.count != 0;
}

- (void)insertText:(NSString *)text {
    NSRange locrgn = NSRangeZero;
    NSRange selrgn = _selectedTextRange.range;
    selrgn.location -= 1;
    id<NSStylizedItemString> item = (id<NSStylizedItemString>)[self.string itemForTextRange:selrgn
                                                                            locationInRange:&locrgn];
    if (item == nil) {
        item = [self stringItemBefore:self.string.items.firstObject];
    } else if ([item conformsToProtocol:@protocol(NSStylizedItemString)] == NO) {
        item = [self stringItemAfter:item];
    } else if (_selectedTextRange.range.location) {
        locrgn.location += 1;
    }
    
    NSString* str = item.string;
    str = [str stringByInsertString:text atIndex:locrgn.location];
    item.string = str;
    [self.stringView reloadData];
    
    UIStylizedTextRange* range = [UIStylizedTextRange temporary];
    range.range = NSMakeRange(_selectedTextRange.range.location + text.length, 0);
    self.selectedTextRange = range;
}

- (void)deleteBackward {
    NSRange selrgn = _selectedTextRange.range;
    if (selrgn.location == 0)
        return;
    NSRange locrgn = NSRangeZero;
    if (selrgn.location)
        selrgn.location -= 1;
    id<NSStylizedItemString> item = (id<NSStylizedItemString>)[self.string itemForTextRange:selrgn
                                                                            locationInRange:&locrgn];
    locrgn.location += 1;
    
    if ([item conformsToProtocol:@protocol(NSStylizedItemString)]) {
        NSString* str = item.string;
        // 删除文字即可
        str = [str stringByRemoveInRange:NSMakeRange(locrgn.location - 1, 1)];
        if (str.length) {
            item.string = str;
        } else {
            // 如果文字删除完了，需要移除item
            [self.string removeItem:item];
        }
    } else {
        // 直接删除非文字对象
        [self.string removeItem:item];
    }
    
    // 重新加载
    [self.stringView reloadData];
    
    UIStylizedTextRange* range = [UIStylizedTextRange temporary];
    if (_selectedTextRange.range.location > 0)
        range.range = NSMakeRange(_selectedTextRange.range.location - 1, 0);
    self.selectedTextRange = range;
}

- (void)replaceRange:(UITextRange *)range withText:(NSString *)text {
    PASS;
}

- (void)unmarkText {
    NSRange selrgn = _selectedTextRange.range;
    selrgn.location += _markedTextRange.range.length;
    _selectedTextRange.range = selrgn;
    self.selectedTextRange = _selectedTextRange;
    
    self.markedTextRange = nil;
    _markedItem = nil;
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange {
    NSRange locrgn = NSRangeZero;
    NSRange selrgn = _selectedTextRange.range;
    selrgn.location -= 1;
    _markedItem = (id<NSStylizedItemString>)[self.string itemForTextRange:selrgn
                                                          locationInRange:&locrgn];
    if (_markedItem == nil) {
        _markedItem = [self stringItemBefore:self.string.items.firstObject];
    } else if ([_markedItem conformsToProtocol:@protocol(NSStylizedItemString)] == NO) {
        _markedItem = [self stringItemAfter:_markedItem];
    } else if (_selectedTextRange.range.location) {
        locrgn.location += 1;
    }
    
    if (self.markedTextRange == nil) {
        UIStylizedTextRange* range = [UIStylizedTextRange temporary];
        range.range = NSMakeRange(_selectedTextRange.range.location, markedText.length);
        self.markedTextRange = range;
        _markedItem.string = [_markedItem.string stringByInsertString:markedText atIndex:range.range.location];
    } else {
        _markedItem.string = [_markedItem.string stringByReplacingCharactersInRange:self.markedTextRange.range withString:markedText];
        UIStylizedTextRange* range = [UIStylizedTextRange temporary];
        range.range = NSMakeRange(_selectedTextRange.range.location, markedText.length);
        self.markedTextRange = range;
    }
    
    [self.stringView reloadData];
}

- (CGRect)caretRectForPosition:(UIStylizedTextPosition *)position {
    CGRect ret = CGRectZero;
    
    // 或得到该位置的字符，判断是否是换行等需要特殊处理的字符
    BOOL newline = NO, eof = NO;
    NSString* str = [self.stringView.attributedString.string substringWithRange:NSMakeRange(position.offset, 1)];
    if ([str isEqualToString:@"\n"]) {
        position.offset += 1;
        newline = YES;
        
        // 如果到文档尾部，则需要同格式换行
        if (position.offset == ((UIStylizedTextPosition*)self.endOfDocument).offset) {
            position.offset -= 1;
            eof = YES;
        }
    }
    
    ret = [self.stringView rectForTextPosition:position];
    if (!newline) {
        ret.origin.x += ret.size.width;
    } else if (eof) {
        ret.origin.x = self.stringView.bounds.origin.x;
        ret.origin.y += ret.size.height;
    }
    ret.size.width = [self.stringView.caret bestWidth];
    return ret;
}

- (CGRect)firstRectForRange:(UITextRange *)range {
    return [self.stringView rectForTextRange:(UIStylizedTextRange*)range];
}

- (NSComparisonResult)comparePosition:(UIStylizedTextPosition *)position toPosition:(UIStylizedTextPosition *)other {
    if (position.offset > other.offset)
        return NSOrderedDescending;
    else if (position.offset < other.offset)
        return NSOrderedAscending;
    return NSOrderedSame;
}

- (UITextRange*)textRangeFromPosition:(UIStylizedTextPosition *)fromPosition toPosition:(UIStylizedTextPosition *)toPosition {
    UIStylizedTextRange* ret = [UIStylizedTextRange temporary];
    ret.range = NSMakeRange(fromPosition.offset, toPosition.offset - fromPosition.offset);
    return ret;
}

- (UITextRange*)characterRangeAtPoint:(CGPoint)point {
    NSRange rgn = [self.stringView textRangeForPoint:point];
    if (NSRangeEqualToRange(rgn, NSRangeZero))
        return nil;
    UIStylizedTextRange* range = [UIStylizedTextRange temporary];
    range.range = rgn;
    return range;
}

- (UITextRange*)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction {
    return nil;
}

- (UITextPosition*)closestPositionToPoint:(CGPoint)point {
    return nil;
}

- (UITextPosition*)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range {
    return nil;
}

- (NSInteger)offsetFromPosition:(UIStylizedTextPosition *)from toPosition:(UIStylizedTextPosition *)toPosition {
    return from.offset - toPosition.offset;
}

- (UITextPosition*)positionFromPosition:(UIStylizedTextPosition *)position offset:(NSInteger)offset {
    UIStylizedTextPosition* ret = [UIStylizedTextPosition temporary];
    ret.offset = position.offset + offset;
    return ret;
}

- (UITextPosition*)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset {
    return nil;
}

- (UITextPosition*)positionWithinRange:(UITextRange *)range atCharacterOffset:(NSInteger)offset {
    return nil;
}

- (UITextPosition*)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction {
    return nil;
}

- (NSString*)textInRange:(UIStylizedTextRange *)range {
    NSString* ret = [self.stringView.attributedString.string substringWithRange:range.range fillOverflow:nil];
    return ret;
}

- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction {
    return 0;
}

- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range {
    PASS;
}

// action
- (void)__cb_editor_clicked:(SSlot*)s {
    UIView* view = (UIView*)s.sender;
    UIStylizedTextRange* range = (UIStylizedTextRange*)[self characterRangeAtPoint:view.extension.positionTouched];
    if (range) {
        range.range = NSMakeRange(range.range.location + 1, 0);
        self.selectedTextRange = range;
    } else {
        UIStylizedTextRange* range = [UIStylizedTextRange temporary];
        range.range = NSMakeRange(self.stringView.attributedString.string.length, 0);
        self.selectedTextRange = range;
    }
}

@end
