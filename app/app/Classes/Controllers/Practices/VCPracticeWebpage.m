
# import "app.h"
# import "VCPracticeWebpage.h"

@implementation VCPracticeWebpage

- (void)onLoaded {
    [super onLoaded];

    NSMutableString* html = [NSMutableString string];
    [html appendString:@"<html><style type='text/css'>body {-webkit-user-select:none}</style>"];
    
    // 演示弹出原生的警告
    [html appendString:@"<button style='height:100px;width:300px;' onclick='actalert()'>ALERT</button>"];
    [html appendString:@"<script type='text/javascript'>function actalert() { window.native.Alert('Hello, World!', 'HELLO'); } </script>"];
    
    // 演示从原生接受数据
    [html appendString:@"<button style='height:100px;width:300px;' onclick='actvalue()'>VALUE</button>"];
    [html appendString:@"<script type='text/javascript'>function actvalue() { alert(window.native.Value()); } </script>"];
    
    [html appendString:@"</html>"];
    
    self.webView.scalesPageToFit = YES;
    self.webView.htmlString = html;
}

- (void)js_Alert:(NSString*)message title:(NSString*)title {
    UIAlertViewExt* al = [UIAlertViewExt temporary];
    al.title = title;
    al.message = message;
    [al addItem:@"OK"];
    [al show];
}

- (NSString*)js_Value {
    return @"Value from Native";
}

@end
