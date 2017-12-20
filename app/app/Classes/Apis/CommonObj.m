#import "Const.h"
#import "CommonObj.h"
#import "NetObj.h"
#if __has_feature(objc_arc)
# define ARC_MODE
# define SAFE_RELEASE(obj) {}
# define SAFE_RETAIN(obj) obj
#else
# define SAFE_RELEASE(obj) [obj release]
# define SAFE_RETAIN(obj) [obj retain]
#endif

@implementation TerminalInfo
@synthesize appid;
@synthesize channelid;
@synthesize equipmentid;
@synthesize applicationversion;
@synthesize systemversion;
@synthesize cellbrand;
@synthesize cellmodel;
@synthesize mac;


- (id)init {
    self = [super init];
    if (self) {
        appid = 0;
        channelid = 0;
        equipmentid = @"";
        applicationversion = @"";
        systemversion = @"";
        cellbrand = @"";
        cellmodel = @"";
        mac = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(equipmentid);
    SAFE_RELEASE(applicationversion);
    SAFE_RELEASE(systemversion);
    SAFE_RELEASE(cellbrand);
    SAFE_RELEASE(cellmodel);
    SAFE_RELEASE(mac);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.appid = [dict intValue:@"appid"];
	    self.channelid = [dict intValue:@"channelid"];
	    self.equipmentid = [dict strValue:@"equipmentid"];
	    self.applicationversion = [dict strValue:@"applicationversion"];
	    self.systemversion = [dict strValue:@"systemversion"];
	    self.cellbrand = [dict strValue:@"cellbrand"];
	    self.cellmodel = [dict strValue:@"cellmodel"];
	    self.mac = [dict strValue:@"mac"];

	}
}
@end;



@implementation Avatar
@synthesize accountid;
@synthesize nickname;
@synthesize level;
@synthesize atype;
@synthesize v;
@synthesize flag;


- (id)init {
    self = [super init];
    if (self) {
        accountid = 0;
        nickname = @"";
        level = 0;
        atype = 0;
        v = @"";
        flag = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(nickname);
    SAFE_RELEASE(v);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.accountid = [dict intValue:@"accountid"];
	    self.nickname = [dict strValue:@"nickname"];
	    self.level = [dict intValue:@"level"];
	    self.atype = [dict intValue:@"atype"];
	    self.v = [dict strValue:@"v"];
	    self.flag = [dict intValue:@"flag"];

	}
}
@end;



@implementation ItemShortInfo
@synthesize id_;
@synthesize itemname;
@synthesize photo;
@synthesize photo_s;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        itemname = @"";
        photo = @"";
        photo_s = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(itemname);
    SAFE_RELEASE(photo);
    SAFE_RELEASE(photo_s);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.itemname = [dict strValue:@"itemname"];
	    self.photo = [dict strValue:@"photo"];
	    self.photo_s = [dict strValue:@"photo_s"];

	}
}
@end;



@implementation ItemInfo
@synthesize id_;
@synthesize itemname;
@synthesize photo;
@synthesize photo_s;
@synthesize description;
@synthesize shortdescription;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        itemname = @"";
        photo = @"";
        photo_s = @"";
        description = @"";
        shortdescription = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(itemname);
    SAFE_RELEASE(photo);
    SAFE_RELEASE(photo_s);
    SAFE_RELEASE(description);
    SAFE_RELEASE(shortdescription);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.itemname = [dict strValue:@"itemname"];
	    self.photo = [dict strValue:@"photo"];
	    self.photo_s = [dict strValue:@"photo_s"];
	    self.description = [dict strValue:@"description"];
	    self.shortdescription = [dict strValue:@"shortdescription"];

	}
}
@end;



@implementation PageOutput
@synthesize page;
@synthesize count;
@synthesize seq;
@synthesize lastpage;


- (id)init {
    self = [super init];
    if (self) {
        page = 0;
        count = 0;
        seq = 0;
        lastpage = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.page = [dict intValue:@"page"];
	    self.count = [dict intValue:@"count"];
	    self.seq = [dict longValue:@"seq"];
	    self.lastpage = [dict intValue:@"lastpage"];

	}
}
@end;



@implementation DefaultOutput
@synthesize code;
@synthesize message;


- (id)init {
    self = [super init];
    if (self) {
        code = 0;
        message = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(message);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.code = [dict intValue:@"code"];
	    self.message = [dict strValue:@"message"];

	}
}
@end;



@implementation PageInput
@synthesize seq;


- (id)init {
    self = [super init];
    if (self) {
        seq = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.seq = [dict longValue:@"seq"];

	}
}
@end;



@implementation UserPref
@synthesize pri_msg_ntf;
@synthesize cls_msg_ntf;
@synthesize grp_msg_ntf;
@synthesize sys_msg_ntf;
@synthesize bgimg;
@synthesize messagestyle;


- (id)init {
    self = [super init];
    if (self) {
        pri_msg_ntf = 0;
        cls_msg_ntf = 0;
        grp_msg_ntf = 0;
        sys_msg_ntf = 0;
        bgimg = @"";
        messagestyle = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(bgimg);
    SAFE_RELEASE(messagestyle);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.pri_msg_ntf = [dict intValue:@"pri_msg_ntf"];
	    self.cls_msg_ntf = [dict intValue:@"cls_msg_ntf"];
	    self.grp_msg_ntf = [dict intValue:@"grp_msg_ntf"];
	    self.sys_msg_ntf = [dict intValue:@"sys_msg_ntf"];
	    self.bgimg = [dict strValue:@"bgimg"];
	    self.messagestyle = [dict strValue:@"messagestyle"];

	}
}
@end;



@implementation UserStat
@synthesize showcount;
@synthesize askcount;
@synthesize answercount;
@synthesize friendcount;
@synthesize photofeedcount;
@synthesize homecount;
@synthesize homecounttoday;
@synthesize photocount;
@synthesize newfollowercount;
@synthesize newfriendcount;
@synthesize followercount;
@synthesize followingcount;
@synthesize feedunreadcount;
@synthesize msginboxunreadcount;
@synthesize consumptionamount;
@synthesize consumptionlevel;


- (id)init {
    self = [super init];
    if (self) {
        showcount = 0;
        askcount = 0;
        answercount = 0;
        friendcount = 0;
        photofeedcount = 0;
        homecount = 0;
        homecounttoday = 0;
        photocount = 0;
        newfollowercount = 0;
        newfriendcount = 0;
        followercount = 0;
        followingcount = 0;
        feedunreadcount = 0;
        msginboxunreadcount = 0;
        consumptionamount = 0;
        consumptionlevel = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.showcount = [dict intValue:@"showcount"];
	    self.askcount = [dict intValue:@"askcount"];
	    self.answercount = [dict intValue:@"answercount"];
	    self.friendcount = [dict intValue:@"friendcount"];
	    self.photofeedcount = [dict intValue:@"upfc"];
	    self.homecount = [dict intValue:@"homecount"];
	    self.homecounttoday = [dict intValue:@"hctoday"];
	    self.photocount = [dict intValue:@"photocount"];
	    self.newfollowercount = [dict intValue:@"newflwc"];
	    self.newfriendcount = [dict intValue:@"newfrdc"];
	    self.followercount = [dict intValue:@"flwc"];
	    self.followingcount = [dict intValue:@"flwingc"];
	    self.feedunreadcount = [dict intValue:@"furc"];
	    self.msginboxunreadcount = [dict intValue:@"miurc"];
	    self.consumptionamount = [dict intValue:@"ctamount"];
	    self.consumptionlevel = [dict intValue:@"ctlevel"];

	}
}
@end;



@implementation UpdateInfo
@synthesize needupdate;
@synthesize updateurl;
@synthesize updatedesc;
@synthesize version;


- (id)init {
    self = [super init];
    if (self) {
        needupdate = 0;
        updateurl = @"";
        updatedesc = @"";
        version = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(updateurl);
    SAFE_RELEASE(updatedesc);
    SAFE_RELEASE(version);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.needupdate = [dict intValue:@"needupdate"];
	    self.updateurl = [dict strValue:@"updateurl"];
	    self.updatedesc = [dict strValue:@"updatedesc"];
	    self.version = [dict strValue:@"version"];

	}
}
@end;



@implementation UserXp
@synthesize level;
@synthesize exp;
@synthesize maxexp;


- (id)init {
    self = [super init];
    if (self) {
        level = 0;
        exp = 0;
        maxexp = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.level = [dict intValue:@"level"];
	    self.exp = [dict intValue:@"exp"];
	    self.maxexp = [dict intValue:@"maxexp"];

	}
}
@end;



@implementation ContentBody
@synthesize html;
@synthesize images;
@synthesize voice;
@synthesize appurl;


- (id)init {
    self = [super init];
    if (self) {
        html = @"";
        images = [[NSMutableArray alloc] init];
        voice = @"";
        appurl = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(html);
    SAFE_RELEASE(images);
    SAFE_RELEASE(voice);
    SAFE_RELEASE(appurl);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.html = [dict strValue:@"html"];
	    NSObject* array_images = [dict objectForKey:@"images"];
	    [images removeAllObjects];
	    if (array_images && [array_images isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_images;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSString class]])
	                [images addObject:obj];
	        
	        }
	    }self.voice = [dict strValue:@"voice"];
	    self.appurl = [dict strValue:@"appurl"];

	}
}
@end;



@implementation ContentSender
@synthesize ismaster;
@synthesize isgoodhelper;


- (id)init {
    self = [super init];
    if (self) {
        ismaster = 0;
        isgoodhelper = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.ismaster = [dict intValue:@"ismaster"];
	    self.isgoodhelper = [dict intValue:@"isgoodhelper"];

	}
}
@end;

@implementation ContentLikesItem
@synthesize mood;


- (id)init {
    self = [super init];
    if (self) {
        mood = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.mood = [dict intValue:@"mood"];

	}
}
@end;


@implementation Content
@synthesize id_;
@synthesize title;
@synthesize body;
@synthesize atid;
@synthesize at_name;
@synthesize sender;
@synthesize countcomments;
@synthesize countlikes;
@synthesize countviews;
@synthesize isliked;
@synthesize iscommented;
@synthesize floor;
@synthesize flag;
@synthesize resid;
@synthesize templateid;
@synthesize templatedata;
@synthesize currencyunitid;
@synthesize currencyuniticon;
@synthesize currency;
@synthesize likes;
@synthesize gameappurl;
@synthesize taxonomyappurl;
@synthesize updatedtime;
@synthesize createdtime;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        title = @"";
        body = [[ContentBody alloc] init];
        atid = 0;
        at_name = @"";
        sender = [[ContentSender alloc] init];
        countcomments = 0;
        countlikes = 0;
        countviews = 0;
        isliked = 0;
        iscommented = 0;
        floor = 0;
        flag = 0;
        resid = @"";
        templateid = 0;
        templatedata = @"";
        currencyunitid = 0;
        currencyuniticon = @"";
        currency = 0;
        likes = [[NSMutableArray alloc] init];
        gameappurl = @"";
        taxonomyappurl = @"";
        updatedtime = @"";
        createdtime = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(title);
    SAFE_RELEASE(body);
    SAFE_RELEASE(at_name);
    SAFE_RELEASE(sender);
    SAFE_RELEASE(resid);
    SAFE_RELEASE(templatedata);
    SAFE_RELEASE(currencyuniticon);
    SAFE_RELEASE(likes);
    SAFE_RELEASE(gameappurl);
    SAFE_RELEASE(taxonomyappurl);
    SAFE_RELEASE(updatedtime);
    SAFE_RELEASE(createdtime);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict longValue:@"id"];
	    self.title = [dict strValue:@"title"];

	    [body parse:[dict objectForKey:@"body"]];
	    self.atid = [dict intValue:@"atid"];
	    self.at_name = [dict strValue:@"at_name"];

	    [sender parse:[dict objectForKey:@"sender"]];
	    self.countcomments = [dict intValue:@"countcomments"];
	    self.countlikes = [dict intValue:@"countlikes"];
	    self.countviews = [dict intValue:@"countviews"];
	    self.isliked = [dict intValue:@"isliked"];
	    self.iscommented = [dict intValue:@"iscommented"];
	    self.floor = [dict intValue:@"floor"];
	    self.flag = [dict intValue:@"flag"];
	    self.resid = [dict strValue:@"resid"];
	    self.templateid = [dict intValue:@"templateid"];
	    self.templatedata = [dict strValue:@"templatedata"];
	    self.currencyunitid = [dict intValue:@"currencyunitid"];
	    self.currencyuniticon = [dict strValue:@"currencyuniticon"];
	    self.currency = [dict intValue:@"currency"];
	    NSObject* array_likes = [dict objectForKey:@"likes"];
	    [likes removeAllObjects];
	    if (array_likes && [array_likes isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_likes;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                ContentLikesItem* tmp = [[ContentLikesItem alloc] init];
	                [tmp parse:obj]; 
	                [likes addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }self.gameappurl = [dict strValue:@"gameappurl"];
	    self.taxonomyappurl = [dict strValue:@"taxonomyappurl"];
	    self.updatedtime = [dict strValue:@"updatedtime"];
	    self.createdtime = [dict strValue:@"createdtime"];

	}
}
@end;



@implementation PostContent
@synthesize postappurl;
@synthesize summary;
@synthesize comments;


- (id)init {
    self = [super init];
    if (self) {
        postappurl = @"";
        summary = @"";
        comments = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(postappurl);
    SAFE_RELEASE(summary);
    SAFE_RELEASE(comments);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.postappurl = [dict strValue:@"postappurl"];
	    self.summary = [dict strValue:@"summary"];
	    NSObject* array_comments = [dict objectForKey:@"comments"];
	    [comments removeAllObjects];
	    if (array_comments && [array_comments isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_comments;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                Content* tmp = [[Content alloc] init];
	                [tmp parse:obj]; 
	                [comments addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }
	}
}
@end;



@implementation Game
@synthesize id_;
@synthesize name;
@synthesize icon;
@synthesize countplayer;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        name = @"";
        icon = @"";
        countplayer = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(name);
    SAFE_RELEASE(icon);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.name = [dict strValue:@"name"];
	    self.icon = [dict strValue:@"icon"];
	    self.countplayer = [dict intValue:@"countplayer"];

	}
}
@end;



@implementation GameDetailCategory
@synthesize name;
@synthesize id_;


- (id)init {
    self = [super init];
    if (self) {
        name = @"";
        id_ = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(name);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.name = [dict strValue:@"name"];
	    self.id_ = [dict intValue:@"id"];

	}
}
@end;


@implementation GameDetail
@synthesize chargetype;
@synthesize category;
@synthesize bigicon;
@synthesize price;
@synthesize boardid;
@synthesize filesize;
@synthesize onlinetime;
@synthesize currentversion;
@synthesize downloadlink;
@synthesize introduction;


- (id)init {
    self = [super init];
    if (self) {
        chargetype = 0;
        category = [[GameDetailCategory alloc] init];
        bigicon = @"";
        price = 0.0;
        boardid = 0;
        filesize = 0;
        onlinetime = @"";
        currentversion = @"";
        downloadlink = @"";
        introduction = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(category);
    SAFE_RELEASE(bigicon);
    SAFE_RELEASE(onlinetime);
    SAFE_RELEASE(currentversion);
    SAFE_RELEASE(downloadlink);
    SAFE_RELEASE(introduction);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.chargetype = [dict intValue:@"chargetype"];

	    [category parse:[dict objectForKey:@"category"]];
	    self.bigicon = [dict strValue:@"bigicon"];
	    self.price = [dict floatValue:@"price"];
	    self.boardid = [dict intValue:@"boardid"];
	    self.filesize = [dict intValue:@"filesize"];
	    self.onlinetime = [dict strValue:@"onlinetime"];
	    self.currentversion = [dict strValue:@"currentversion"];
	    self.downloadlink = [dict strValue:@"downloadlink"];
	    self.introduction = [dict strValue:@"introduction"];

	}
}
@end;



@implementation Publisher
@synthesize accountid;
@synthesize username;
@synthesize nickname;
@synthesize avatar;
@synthesize description;
@synthesize created;


- (id)init {
    self = [super init];
    if (self) {
        accountid = 0;
        username = @"";
        nickname = @"";
        avatar = @"";
        description = @"";
        created = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(username);
    SAFE_RELEASE(nickname);
    SAFE_RELEASE(avatar);
    SAFE_RELEASE(description);
    SAFE_RELEASE(created);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.accountid = [dict intValue:@"accountid"];
	    self.username = [dict strValue:@"username"];
	    self.nickname = [dict strValue:@"nickname"];
	    self.avatar = [dict strValue:@"avatar"];
	    self.description = [dict strValue:@"description"];
	    self.created = [dict strValue:@"created"];

	}
}
@end;



@implementation PollOption
@synthesize id_;
@synthesize text;
@synthesize total;
@synthesize percent;
@synthesize vote;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        text = @"";
        total = 0;
        percent = 0.0;
        vote = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(text);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.text = [dict strValue:@"text"];
	    self.total = [dict intValue:@"total"];
	    self.percent = [dict floatValue:@"percent"];
	    self.vote = [dict intValue:@"vote"];

	}
}
@end;



@implementation ThreadAvatar
@synthesize thread;
@synthesize nickname;
@synthesize v;
@synthesize atype;
@synthesize flag;
@synthesize type;
@synthesize targetid;
@synthesize level;


- (id)init {
    self = [super init];
    if (self) {
        thread = @"";
        nickname = @"";
        v = @"";
        atype = 0;
        flag = 0;
        type = 0;
        targetid = 0;
        level = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(thread);
    SAFE_RELEASE(nickname);
    SAFE_RELEASE(v);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.thread = [dict strValue:@"thread"];
	    self.nickname = [dict strValue:@"nickname"];
	    self.v = [dict strValue:@"v"];
	    self.atype = [dict intValue:@"atype"];
	    self.flag = [dict intValue:@"flag"];
	    self.type = [dict intValue:@"type"];
	    self.targetid = [dict intValue:@"targetid"];
	    self.level = [dict intValue:@"level"];

	}
}
@end;



@implementation UserRecommended
@synthesize followercount;
@synthesize gameappurl;
@synthesize description;


- (id)init {
    self = [super init];
    if (self) {
        followercount = 0;
        gameappurl = @"";
        description = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(gameappurl);
    SAFE_RELEASE(description);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.followercount = [dict intValue:@"followercount"];
	    self.gameappurl = [dict strValue:@"gameappurl"];
	    self.description = [dict strValue:@"description"];

	}
}
@end;



@implementation LoginOutputDataThreads
@synthesize act;
@synthesize helper;
@synthesize kf;


- (id)init {
    self = [super init];
    if (self) {
        act = [[ThreadAvatar alloc] init];
        helper = [[ThreadAvatar alloc] init];
        kf = [[ThreadAvatar alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(act);
    SAFE_RELEASE(helper);
    SAFE_RELEASE(kf);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [act parse:[dict objectForKey:@"act"]];

	    [helper parse:[dict objectForKey:@"helper"]];

	    [kf parse:[dict objectForKey:@"kf"]];

	}
}
@end;

@implementation LoginOutputDataNotice
@synthesize tm;
@synthesize title;
@synthesize text;
@synthesize appurl;


- (id)init {
    self = [super init];
    if (self) {
        tm = 0;
        title = @"";
        text = @"";
        appurl = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(title);
    SAFE_RELEASE(text);
    SAFE_RELEASE(appurl);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.tm = [dict longValue:@"tm"];
	    self.title = [dict strValue:@"title"];
	    self.text = [dict strValue:@"text"];
	    self.appurl = [dict strValue:@"appurl"];

	}
}
@end;

@implementation LoginOutputData
@synthesize avatar;
@synthesize malenickname;
@synthesize femalenickname;
@synthesize defaultavatarcount;
@synthesize gender;
@synthesize xp;
@synthesize nativeplace;
@synthesize introduction;
@synthesize bindplatformlist;
@synthesize update;
@synthesize hasclass;
@synthesize status;
@synthesize inviteseq;
@synthesize prefs;
@synthesize stats;
@synthesize latestphoto;
@synthesize isthird;
@synthesize threads;
@synthesize notice;
@synthesize tm;
@synthesize screenimageurl;
@synthesize shopshow;
@synthesize idfashow;
@synthesize idfaurl;
@synthesize rtaddrs;
@synthesize splashshow;


- (id)init {
    self = [super init];
    if (self) {
        avatar = @"";
        malenickname = @"";
        femalenickname = @"";
        defaultavatarcount = 0;
        gender = 0;
        xp = [[UserXp alloc] init];
        nativeplace = @"";
        introduction = @"";
        bindplatformlist = [[NSMutableArray alloc] init];
        update = [[UpdateInfo alloc] init];
        hasclass = 0;
        status = 0;
        inviteseq = @"";
        prefs = [[UserPref alloc] init];
        stats = [[UserStat alloc] init];
        latestphoto = @"";
        isthird = 0;
        threads = [[LoginOutputDataThreads alloc] init];
        notice = [[LoginOutputDataNotice alloc] init];
        tm = 0;
        screenimageurl = @"";
        shopshow = 0;
        idfashow = 0;
        idfaurl = @"";
        rtaddrs = @"";
        splashshow = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(avatar);
    SAFE_RELEASE(malenickname);
    SAFE_RELEASE(femalenickname);
    SAFE_RELEASE(xp);
    SAFE_RELEASE(nativeplace);
    SAFE_RELEASE(introduction);
    SAFE_RELEASE(bindplatformlist);
    SAFE_RELEASE(update);
    SAFE_RELEASE(inviteseq);
    SAFE_RELEASE(prefs);
    SAFE_RELEASE(stats);
    SAFE_RELEASE(latestphoto);
    SAFE_RELEASE(threads);
    SAFE_RELEASE(notice);
    SAFE_RELEASE(screenimageurl);
    SAFE_RELEASE(idfaurl);
    SAFE_RELEASE(rtaddrs);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.avatar = [dict strValue:@"avatar"];
	    self.malenickname = [dict strValue:@"malenickname"];
	    self.femalenickname = [dict strValue:@"femalenickname"];
	    self.defaultavatarcount = [dict intValue:@"defaultavatarcount"];
	    self.gender = [dict intValue:@"gender"];

	    [xp parse:[dict objectForKey:@"xp"]];
	    self.nativeplace = [dict strValue:@"nativeplace"];
	    self.introduction = [dict strValue:@"introduction"];
	    NSObject* array_bindplatformlist = [dict objectForKey:@"bindplatformlist"];
	    [bindplatformlist removeAllObjects];
	    if (array_bindplatformlist && [array_bindplatformlist isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_bindplatformlist;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSString class]])
	                [bindplatformlist addObject:obj];
	        
	        }
	    }
	    [update parse:[dict objectForKey:@"update"]];
	    self.hasclass = [dict intValue:@"hasclass"];
	    self.status = [dict intValue:@"status"];
	    self.inviteseq = [dict strValue:@"inviteseq"];

	    [prefs parse:[dict objectForKey:@"prefs"]];

	    [stats parse:[dict objectForKey:@"stats"]];
	    self.latestphoto = [dict strValue:@"latestphoto"];
	    self.isthird = [dict intValue:@"isthird"];

	    [threads parse:[dict objectForKey:@"threads"]];

	    [notice parse:[dict objectForKey:@"notice"]];
	    self.tm = [dict longValue:@"tm"];
	    self.screenimageurl = [dict strValue:@"screenimageurl"];
	    self.shopshow = [dict intValue:@"shopshow"];
	    self.idfashow = [dict intValue:@"idfashow"];
	    self.idfaurl = [dict strValue:@"idfaurl"];
	    self.rtaddrs = [dict strValue:@"rtaddrs"];
	    self.splashshow = [dict intValue:@"splashshow"];

	}
}
@end;


@implementation LoginOutput
@synthesize code;
@synthesize message;
@synthesize data;


- (id)init {
    self = [super init];
    if (self) {
        code = 0;
        message = @"";
        data = [[LoginOutputData alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(message);
    SAFE_RELEASE(data);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.code = [dict intValue:@"code"];
	    self.message = [dict strValue:@"message"];

	    [data parse:[dict objectForKey:@"data"]];

	}
}
@end;



@implementation Message
@synthesize U;
@synthesize T;
@synthesize S;
@synthesize R;
@synthesize MT;
@synthesize CT;
@synthesize IG;
@synthesize P;


- (id)init {
    self = [super init];
    if (self) {
        U = @"";
        T = @"";
        S = 0;
        R = 0;
        MT = 0;
        CT = @"";
        IG = [[NSMutableArray alloc] init];
        P = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(U);
    SAFE_RELEASE(T);
    SAFE_RELEASE(CT);
    SAFE_RELEASE(IG);
    SAFE_RELEASE(P);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.U = [dict strValue:@"U"];
	    self.T = [dict strValue:@"T"];
	    self.S = [dict intValue:@"S"];
	    self.R = [dict intValue:@"R"];
	    self.MT = [dict intValue:@"MT"];
	    self.CT = [dict strValue:@"CT"];
	    NSObject* array_IG = [dict objectForKey:@"IG"];
	    [IG removeAllObjects];
	    if (array_IG && [array_IG isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_IG;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSNumber class]])
	                [IG addObject:obj];
	        
	        }
	    }self.P = [dict strValue:@"P"];

	}
}
@end;



@implementation MessagePayload
@synthesize CTT;
@synthesize ST;
@synthesize M;
@synthesize SD;
@synthesize SMST;
@synthesize AT;
@synthesize TA;
@synthesize AU;
@synthesize TXT;
@synthesize AL;


- (id)init {
    self = [super init];
    if (self) {
        CTT = 0;
        ST = 0;
        M = @"";
        SD = [[Avatar alloc] init];
        SMST = @"";
        AT = [[Avatar alloc] init];
        TA = [[ThreadAvatar alloc] init];
        AU = [[NSMutableArray alloc] init];
        TXT = @"";
        AL = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(M);
    SAFE_RELEASE(SD);
    SAFE_RELEASE(SMST);
    SAFE_RELEASE(AT);
    SAFE_RELEASE(TA);
    SAFE_RELEASE(AU);
    SAFE_RELEASE(TXT);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.CTT = [dict intValue:@"CTT"];
	    self.ST = [dict intValue:@"ST"];
	    self.M = [dict strValue:@"M"];

	    [SD parse:[dict objectForKey:@"SD"]];
	    self.SMST = [dict strValue:@"SMST"];

	    [AT parse:[dict objectForKey:@"AT"]];

	    [TA parse:[dict objectForKey:@"TA"]];
	    NSObject* array_AU = [dict objectForKey:@"AU"];
	    [AU removeAllObjects];
	    if (array_AU && [array_AU isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_AU;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSNumber class]])
	                [AU addObject:obj];
	        
	        }
	    }self.TXT = [dict strValue:@"TXT"];
	    self.AL = [dict intValue:@"AL"];

	}
}
@end;



@implementation ThreadMessages
@synthesize count;
@synthesize thread;
@synthesize messages;


- (id)init {
    self = [super init];
    if (self) {
        count = 0;
        thread = @"";
        messages = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(thread);
    SAFE_RELEASE(messages);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.count = [dict intValue:@"count"];
	    self.thread = [dict strValue:@"thread"];
	    NSObject* array_messages = [dict objectForKey:@"messages"];
	    [messages removeAllObjects];
	    if (array_messages && [array_messages isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_messages;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                Message* tmp = [[Message alloc] init];
	                [tmp parse:obj]; 
	                [messages addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }
	}
}
@end;



@implementation GroupXp
@synthesize level;
@synthesize exp;
@synthesize maxexp;
@synthesize total;


- (id)init {
    self = [super init];
    if (self) {
        level = 0;
        exp = 0;
        maxexp = 0;
        total = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.level = [dict intValue:@"level"];
	    self.exp = [dict intValue:@"exp"];
	    self.maxexp = [dict intValue:@"maxexp"];
	    self.total = [dict intValue:@"total"];

	}
}
@end;


@implementation Group
@synthesize id_;
@synthesize type;
@synthesize currentmembercount;
@synthesize maxmembercount;
@synthesize thread;
@synthesize xp;
@synthesize gameid;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        type = 0;
        currentmembercount = 0;
        maxmembercount = 0;
        thread = [[ThreadAvatar alloc] init];
        xp = [[GroupXp alloc] init];
        gameid = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(thread);
    SAFE_RELEASE(xp);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.type = [dict intValue:@"type"];
	    self.currentmembercount = [dict intValue:@"currentmembercount"];
	    self.maxmembercount = [dict intValue:@"maxmembercount"];

	    [thread parse:[dict objectForKey:@"thread"]];

	    [xp parse:[dict objectForKey:@"xp"]];
	    self.gameid = [dict intValue:@"gameid"];

	}
}
@end;



@implementation GroupDetailAdminsItem
@synthesize role;


- (id)init {
    self = [super init];
    if (self) {
        role = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.role = [dict intValue:@"role"];

	}
}
@end;

@implementation GroupDetailCheckingame
@synthesize boss;
@synthesize checked;


- (id)init {
    self = [super init];
    if (self) {
        boss = [[Avatar alloc] init];
        checked = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(boss);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [boss parse:[dict objectForKey:@"boss"]];
	    self.checked = [dict intValue:@"checked"];

	}
}
@end;


@implementation GroupDetail
@synthesize games;
@synthesize parentid;
@synthesize introduction;
@synthesize admins;
@synthesize checkingame;


- (id)init {
    self = [super init];
    if (self) {
        games = [[NSMutableArray alloc] init];
        parentid = 0;
        introduction = @"";
        admins = [[NSMutableArray alloc] init];
        checkingame = [[GroupDetailCheckingame alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(games);
    SAFE_RELEASE(introduction);
    SAFE_RELEASE(admins);
    SAFE_RELEASE(checkingame);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    NSObject* array_games = [dict objectForKey:@"games"];
	    [games removeAllObjects];
	    if (array_games && [array_games isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_games;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                Game* tmp = [[Game alloc] init];
	                [tmp parse:obj]; 
	                [games addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }self.parentid = [dict intValue:@"parentid"];
	    self.introduction = [dict strValue:@"introduction"];
	    NSObject* array_admins = [dict objectForKey:@"admins"];
	    [admins removeAllObjects];
	    if (array_admins && [array_admins isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_admins;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                GroupDetailAdminsItem* tmp = [[GroupDetailAdminsItem alloc] init];
	                [tmp parse:obj]; 
	                [admins addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }
	    [checkingame parse:[dict objectForKey:@"checkingame"]];

	}
}
@end;



@implementation Act
@synthesize type;
@synthesize id_;
@synthesize user;
@synthesize joins;
@synthesize me_join;
@synthesize title;
@synthesize image;
@synthesize desc;


- (id)init {
    self = [super init];
    if (self) {
        type = 0;
        id_ = 0;
        user = [[Avatar alloc] init];
        joins = 0;
        me_join = 0;
        title = @"";
        image = @"";
        desc = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(user);
    SAFE_RELEASE(title);
    SAFE_RELEASE(image);
    SAFE_RELEASE(desc);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.type = [dict intValue:@"type"];
	    self.id_ = [dict intValue:@"id"];

	    [user parse:[dict objectForKey:@"user"]];
	    self.joins = [dict intValue:@"joins"];
	    self.me_join = [dict intValue:@"me_join"];
	    self.title = [dict strValue:@"title"];
	    self.image = [dict strValue:@"image"];
	    self.desc = [dict strValue:@"desc"];

	}
}
@end;



@implementation FeedItem
@synthesize sender;
@synthesize attendercount;
@synthesize countlikes;
@synthesize countcomments;
@synthesize info;
@synthesize title;
@synthesize icon;
@synthesize summary;
@synthesize tag;
@synthesize tourl;
@synthesize fromurl;
@synthesize createdtime;


- (id)init {
    self = [super init];
    if (self) {
        sender = [[Avatar alloc] init];
        attendercount = 0;
        countlikes = 0;
        countcomments = 0;
        info = @"";
        title = @"";
        icon = @"";
        summary = @"";
        tag = @"";
        tourl = @"";
        fromurl = @"";
        createdtime = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(sender);
    SAFE_RELEASE(info);
    SAFE_RELEASE(title);
    SAFE_RELEASE(icon);
    SAFE_RELEASE(summary);
    SAFE_RELEASE(tag);
    SAFE_RELEASE(tourl);
    SAFE_RELEASE(fromurl);
    SAFE_RELEASE(createdtime);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [sender parse:[dict objectForKey:@"sender"]];
	    self.attendercount = [dict intValue:@"attendercount"];
	    self.countlikes = [dict intValue:@"countlikes"];
	    self.countcomments = [dict intValue:@"countcomments"];
	    self.info = [dict strValue:@"info"];
	    self.title = [dict strValue:@"title"];
	    self.icon = [dict strValue:@"icon"];
	    self.summary = [dict strValue:@"summary"];
	    self.tag = [dict strValue:@"tag"];
	    self.tourl = [dict strValue:@"tourl"];
	    self.fromurl = [dict strValue:@"fromurl"];
	    self.createdtime = [dict strValue:@"createdtime"];

	}
}
@end;



@implementation FeedTimelineItemPub
@synthesize title;
@synthesize icon;
@synthesize summary;
@synthesize viewcount;
@synthesize viewappurl;


- (id)init {
    self = [super init];
    if (self) {
        title = @"";
        icon = @"";
        summary = @"";
        viewcount = 0;
        viewappurl = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(title);
    SAFE_RELEASE(icon);
    SAFE_RELEASE(summary);
    SAFE_RELEASE(viewappurl);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.title = [dict strValue:@"title"];
	    self.icon = [dict strValue:@"icon"];
	    self.summary = [dict strValue:@"summary"];
	    self.viewcount = [dict intValue:@"viewcount"];
	    self.viewappurl = [dict strValue:@"viewappurl"];

	}
}
@end;



@implementation FeedTimelineItem
@synthesize sender;
@synthesize type;
@synthesize post;
@synthesize pub;
@synthesize postcost;
@synthesize gamepost;
@synthesize usershare;
@synthesize gamegift;
@synthesize gameactivity;
@synthesize createdtime;
@synthesize updatedtime;


- (id)init {
    self = [super init];
    if (self) {
        sender = [[ThreadAvatar alloc] init];
        type = 0;
        post = [[PostContent alloc] init];
        pub = [[FeedTimelineItemPub alloc] init];
        postcost = [[FeedTimelineItemPub alloc] init];
        gamepost = [[FeedTimelineItemPub alloc] init];
        usershare = [[FeedTimelineItemPub alloc] init];
        gamegift = [[FeedTimelineItemPub alloc] init];
        gameactivity = [[FeedTimelineItemPub alloc] init];
        createdtime = @"";
        updatedtime = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(sender);
    SAFE_RELEASE(post);
    SAFE_RELEASE(pub);
    SAFE_RELEASE(postcost);
    SAFE_RELEASE(gamepost);
    SAFE_RELEASE(usershare);
    SAFE_RELEASE(gamegift);
    SAFE_RELEASE(gameactivity);
    SAFE_RELEASE(createdtime);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [sender parse:[dict objectForKey:@"sender"]];
	    self.type = [dict intValue:@"type"];

	    [post parse:[dict objectForKey:@"post"]];

	    [pub parse:[dict objectForKey:@"pub"]];

	    [postcost parse:[dict objectForKey:@"postcost"]];

	    [gamepost parse:[dict objectForKey:@"gamepost"]];

	    [usershare parse:[dict objectForKey:@"usershare"]];

	    [gamegift parse:[dict objectForKey:@"gamegift"]];

	    [gameactivity parse:[dict objectForKey:@"gameactivity"]];
	    self.createdtime = [dict strValue:@"createdtime"];
	    self.updatedtime = [dict intValue:@"updatedtime"];

	}
}
@end;



@implementation ShopItem
@synthesize category;
@synthesize id_;
@synthesize gameid;
@synthesize no;
@synthesize title;
@synthesize icon;
@synthesize image;
@synthesize wealth;
@synthesize totalcount;
@synthesize remains;
@synthesize content;
@synthesize bought;
@synthesize isfree;
@synthesize discount;
@synthesize discountwealth;
@synthesize isnew;
@synthesize starttime;
@synthesize endtime;
@synthesize validtime;
@synthesize lifetime;
@synthesize annotation;
@synthesize user_level;
@synthesize soldcount;


- (id)init {
    self = [super init];
    if (self) {
        category = 0;
        id_ = 0;
        gameid = 0;
        no = @"";
        title = @"";
        icon = @"";
        image = @"";
        wealth = 0;
        totalcount = 0;
        remains = 0;
        content = @"";
        bought = 0;
        isfree = 0;
        discount = 0;
        discountwealth = 0;
        isnew = 0;
        starttime = @"";
        endtime = @"";
        validtime = @"";
        lifetime = 0;
        annotation = @"";
        user_level = 0;
        soldcount = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(no);
    SAFE_RELEASE(title);
    SAFE_RELEASE(icon);
    SAFE_RELEASE(image);
    SAFE_RELEASE(content);
    SAFE_RELEASE(starttime);
    SAFE_RELEASE(endtime);
    SAFE_RELEASE(validtime);
    SAFE_RELEASE(annotation);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.category = [dict intValue:@"category"];
	    self.id_ = [dict intValue:@"id"];
	    self.gameid = [dict intValue:@"gameid"];
	    self.no = [dict strValue:@"no"];
	    self.title = [dict strValue:@"title"];
	    self.icon = [dict strValue:@"icon"];
	    self.image = [dict strValue:@"image"];
	    self.wealth = [dict intValue:@"wealth"];
	    self.totalcount = [dict intValue:@"totalcount"];
	    self.remains = [dict intValue:@"remains"];
	    self.content = [dict strValue:@"content"];
	    self.bought = [dict intValue:@"bought"];
	    self.isfree = [dict intValue:@"isfree"];
	    self.discount = [dict intValue:@"discount"];
	    self.discountwealth = [dict intValue:@"discountwealth"];
	    self.isnew = [dict intValue:@"isnew"];
	    self.starttime = [dict strValue:@"starttime"];
	    self.endtime = [dict strValue:@"endtime"];
	    self.validtime = [dict strValue:@"validtime"];
	    self.lifetime = [dict intValue:@"lifetime"];
	    self.annotation = [dict strValue:@"annotation"];
	    self.user_level = [dict intValue:@"user_level"];
	    self.soldcount = [dict intValue:@"soldcount"];

	}
}
@end;


   	id annotationObj;



@implementation ShopItemAnnotationGift
@synthesize price;
@synthesize usage;


- (id)init {
    self = [super init];
    if (self) {
        price = @"";
        usage = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(price);
    SAFE_RELEASE(usage);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.price = [dict strValue:@"price"];
	    self.usage = [dict strValue:@"usage"];

	}
}
@end;



@implementation ShopItemAnnotationBubble
@synthesize spec;


- (id)init {
    self = [super init];
    if (self) {
        spec = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(spec);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.spec = [dict strValue:@"spec"];

	}
}
@end;



@implementation ShopItemAnnotationSmiley
@synthesize smileys;


- (id)init {
    self = [super init];
    if (self) {
        smileys = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(smileys);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    NSObject* array_smileys = [dict objectForKey:@"smileys"];
	    [smileys removeAllObjects];
	    if (array_smileys && [array_smileys isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_smileys;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSString class]])
	                [smileys addObject:obj];
	        
	        }
	    }
	}
}
@end;



@implementation ShopUserItem
@synthesize id_;
@synthesize category;
@synthesize itemid;
@synthesize title;
@synthesize icon;
@synthesize createdtime;
@synthesize validtime;
@synthesize sender;
@synthesize code;
@synthesize wealth;
@synthesize no;
@synthesize spec;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        category = 0;
        itemid = 0;
        title = @"";
        icon = @"";
        createdtime = @"";
        validtime = @"";
        sender = [[Avatar alloc] init];
        code = @"";
        wealth = 0;
        no = @"";
        spec = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(title);
    SAFE_RELEASE(icon);
    SAFE_RELEASE(createdtime);
    SAFE_RELEASE(validtime);
    SAFE_RELEASE(sender);
    SAFE_RELEASE(code);
    SAFE_RELEASE(no);
    SAFE_RELEASE(spec);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.category = [dict intValue:@"category"];
	    self.itemid = [dict intValue:@"itemid"];
	    self.title = [dict strValue:@"title"];
	    self.icon = [dict strValue:@"icon"];
	    self.createdtime = [dict strValue:@"createdtime"];
	    self.validtime = [dict strValue:@"validtime"];

	    [sender parse:[dict objectForKey:@"sender"]];
	    self.code = [dict strValue:@"code"];
	    self.wealth = [dict intValue:@"wealth"];
	    self.no = [dict strValue:@"no"];
	    self.spec = [dict strValue:@"spec"];

	}
}
@end;



@implementation ShopItemAdmin
@synthesize category;
@synthesize gameid;
@synthesize title;
@synthesize no;
@synthesize content;
@synthesize image;
@synthesize icon;
@synthesize starttime;
@synthesize endtime;
@synthesize validtime;
@synthesize wealth;
@synthesize price;
@synthesize source;
@synthesize publisher;
@synthesize usage;
@synthesize user_level;
@synthesize group_level;
@synthesize annotation;
@synthesize orderno;
@synthesize discount;


- (id)init {
    self = [super init];
    if (self) {
        category = 0;
        gameid = 0;
        title = @"";
        no = @"";
        content = @"";
        image = @"";
        icon = @"";
        starttime = @"";
        endtime = @"";
        validtime = @"";
        wealth = 0;
        price = @"";
        source = @"";
        publisher = @"";
        usage = @"";
        user_level = 0;
        group_level = 0;
        annotation = @"";
        orderno = 0;
        discount = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(title);
    SAFE_RELEASE(no);
    SAFE_RELEASE(content);
    SAFE_RELEASE(image);
    SAFE_RELEASE(icon);
    SAFE_RELEASE(starttime);
    SAFE_RELEASE(endtime);
    SAFE_RELEASE(validtime);
    SAFE_RELEASE(price);
    SAFE_RELEASE(source);
    SAFE_RELEASE(publisher);
    SAFE_RELEASE(usage);
    SAFE_RELEASE(annotation);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.category = [dict intValue:@"category"];
	    self.gameid = [dict intValue:@"gameid"];
	    self.title = [dict strValue:@"title"];
	    self.no = [dict strValue:@"no"];
	    self.content = [dict strValue:@"content"];
	    self.image = [dict strValue:@"image"];
	    self.icon = [dict strValue:@"icon"];
	    self.starttime = [dict strValue:@"starttime"];
	    self.endtime = [dict strValue:@"endtime"];
	    self.validtime = [dict strValue:@"validtime"];
	    self.wealth = [dict intValue:@"wealth"];
	    self.price = [dict strValue:@"price"];
	    self.source = [dict strValue:@"source"];
	    self.publisher = [dict strValue:@"publisher"];
	    self.usage = [dict strValue:@"usage"];
	    self.user_level = [dict intValue:@"user_level"];
	    self.group_level = [dict intValue:@"group_level"];
	    self.annotation = [dict strValue:@"annotation"];
	    self.orderno = [dict intValue:@"orderno"];
	    self.discount = [dict intValue:@"discount"];

	}
}
@end;



@implementation ShopItemAdminUpdate
@synthesize id_;
@synthesize category;
@synthesize gameid;
@synthesize title;
@synthesize no;
@synthesize content;
@synthesize image;
@synthesize icon;
@synthesize starttime;
@synthesize endtime;
@synthesize validtime;
@synthesize wealth;
@synthesize price;
@synthesize source;
@synthesize publisher;
@synthesize usage;
@synthesize user_level;
@synthesize group_level;
@synthesize annotation;
@synthesize orderno;
@synthesize discount;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        category = 0;
        gameid = 0;
        title = @"";
        no = @"";
        content = @"";
        image = @"";
        icon = @"";
        starttime = @"";
        endtime = @"";
        validtime = @"";
        wealth = 0;
        price = @"";
        source = @"";
        publisher = @"";
        usage = @"";
        user_level = 0;
        group_level = 0;
        annotation = @"";
        orderno = 0;
        discount = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(title);
    SAFE_RELEASE(no);
    SAFE_RELEASE(content);
    SAFE_RELEASE(image);
    SAFE_RELEASE(icon);
    SAFE_RELEASE(starttime);
    SAFE_RELEASE(endtime);
    SAFE_RELEASE(validtime);
    SAFE_RELEASE(price);
    SAFE_RELEASE(source);
    SAFE_RELEASE(publisher);
    SAFE_RELEASE(usage);
    SAFE_RELEASE(annotation);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.category = [dict intValue:@"category"];
	    self.gameid = [dict intValue:@"gameid"];
	    self.title = [dict strValue:@"title"];
	    self.no = [dict strValue:@"no"];
	    self.content = [dict strValue:@"content"];
	    self.image = [dict strValue:@"image"];
	    self.icon = [dict strValue:@"icon"];
	    self.starttime = [dict strValue:@"starttime"];
	    self.endtime = [dict strValue:@"endtime"];
	    self.validtime = [dict strValue:@"validtime"];
	    self.wealth = [dict intValue:@"wealth"];
	    self.price = [dict strValue:@"price"];
	    self.source = [dict strValue:@"source"];
	    self.publisher = [dict strValue:@"publisher"];
	    self.usage = [dict strValue:@"usage"];
	    self.user_level = [dict intValue:@"user_level"];
	    self.group_level = [dict intValue:@"group_level"];
	    self.annotation = [dict strValue:@"annotation"];
	    self.orderno = [dict intValue:@"orderno"];
	    self.discount = [dict intValue:@"discount"];

	}
}
@end;



@implementation UserActionParamsItem
@synthesize k;
@synthesize v;


- (id)init {
    self = [super init];
    if (self) {
        k = @"";
        v = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(k);
    SAFE_RELEASE(v);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.k = [dict strValue:@"k"];
	    self.v = [dict strValue:@"v"];

	}
}
@end;


@implementation UserAction
@synthesize action;
@synthesize params;


- (id)init {
    self = [super init];
    if (self) {
        action = @"";
        params = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(action);
    SAFE_RELEASE(params);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.action = [dict strValue:@"action"];
	    NSObject* array_params = [dict objectForKey:@"params"];
	    [params removeAllObjects];
	    if (array_params && [array_params isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_params;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                UserActionParamsItem* tmp = [[UserActionParamsItem alloc] init];
	                [tmp parse:obj]; 
	                [params addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }
	}
}
@end;



@implementation GameTaxonomy
@synthesize id_;
@synthesize user;
@synthesize gameid;
@synthesize gamename;
@synthesize gameboardresid;
@synthesize term;
@synthesize boardstyle;
@synthesize description;
@synthesize icon;
@synthesize cashicon;
@synthesize price;
@synthesize currency;
@synthesize countcontent;
@synthesize countopinion;
@synthesize updatetime;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        user = [[Avatar alloc] init];
        gameid = 0;
        gamename = @"";
        gameboardresid = @"";
        term = @"";
        boardstyle = 0;
        description = @"";
        icon = @"";
        cashicon = @"";
        price = @"";
        currency = @"";
        countcontent = 0;
        countopinion = 0;
        updatetime = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(user);
    SAFE_RELEASE(gamename);
    SAFE_RELEASE(gameboardresid);
    SAFE_RELEASE(term);
    SAFE_RELEASE(description);
    SAFE_RELEASE(icon);
    SAFE_RELEASE(cashicon);
    SAFE_RELEASE(price);
    SAFE_RELEASE(currency);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];

	    [user parse:[dict objectForKey:@"user"]];
	    self.gameid = [dict intValue:@"gameid"];
	    self.gamename = [dict strValue:@"gamename"];
	    self.gameboardresid = [dict strValue:@"gameboardresid"];
	    self.term = [dict strValue:@"term"];
	    self.boardstyle = [dict intValue:@"boardstyle"];
	    self.description = [dict strValue:@"description"];
	    self.icon = [dict strValue:@"icon"];
	    self.cashicon = [dict strValue:@"cashicon"];
	    self.price = [dict strValue:@"price"];
	    self.currency = [dict strValue:@"currency"];
	    self.countcontent = [dict intValue:@"countcontent"];
	    self.countopinion = [dict intValue:@"countopinion"];
	    self.updatetime = [dict intValue:@"updatetime"];

	}
}
@end;



@implementation GameTaxonomyOpinion
@synthesize id_;
@synthesize opinion;
@synthesize count;
@synthesize isagree;
@synthesize color;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        opinion = @"";
        count = 0;
        isagree = 0;
        color = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(opinion);
    SAFE_RELEASE(color);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.opinion = [dict strValue:@"opinion"];
	    self.count = [dict intValue:@"count"];
	    self.isagree = [dict intValue:@"isagree"];
	    self.color = [dict strValue:@"color"];

	}
}
@end;



@implementation GameTaxonomyDetailPoll
@synthesize id_;
@synthesize resid;
@synthesize title;
@synthesize endtime;
@synthesize createdtime;
@synthesize votecount;
@synthesize hasjoin;
@synthesize imgs;
@synthesize postid;
@synthesize multi;
@synthesize user;
@synthesize options;
@synthesize opinioncount;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        resid = @"";
        title = @"";
        endtime = @"";
        createdtime = @"";
        votecount = 0;
        hasjoin = 0;
        imgs = [[NSMutableArray alloc] init];
        postid = 0;
        multi = 0;
        user = [[Avatar alloc] init];
        options = [[NSMutableArray alloc] init];
        opinioncount = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(resid);
    SAFE_RELEASE(title);
    SAFE_RELEASE(endtime);
    SAFE_RELEASE(createdtime);
    SAFE_RELEASE(imgs);
    SAFE_RELEASE(user);
    SAFE_RELEASE(options);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.resid = [dict strValue:@"resid"];
	    self.title = [dict strValue:@"title"];
	    self.endtime = [dict strValue:@"endtime"];
	    self.createdtime = [dict strValue:@"createdtime"];
	    self.votecount = [dict intValue:@"votecount"];
	    self.hasjoin = [dict intValue:@"hasjoin"];
	    NSObject* array_imgs = [dict objectForKey:@"imgs"];
	    [imgs removeAllObjects];
	    if (array_imgs && [array_imgs isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_imgs;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSString class]])
	                [imgs addObject:obj];
	        
	        }
	    }self.postid = [dict intValue:@"postid"];
	    self.multi = [dict intValue:@"multi"];

	    [user parse:[dict objectForKey:@"user"]];
	    NSObject* array_options = [dict objectForKey:@"options"];
	    [options removeAllObjects];
	    if (array_options && [array_options isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_options;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                PollOption* tmp = [[PollOption alloc] init];
	                [tmp parse:obj]; 
	                [options addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }self.opinioncount = [dict intValue:@"opinioncount"];

	}
}
@end;


@implementation GameTaxonomyDetail
@synthesize bgicon;
@synthesize opinions;
@synthesize poll;


- (id)init {
    self = [super init];
    if (self) {
        bgicon = @"";
        opinions = [[NSMutableArray alloc] init];
        poll = [[GameTaxonomyDetailPoll alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(bgicon);
    SAFE_RELEASE(opinions);
    SAFE_RELEASE(poll);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.bgicon = [dict strValue:@"bgicon"];
	    NSObject* array_opinions = [dict objectForKey:@"opinions"];
	    [opinions removeAllObjects];
	    if (array_opinions && [array_opinions isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_opinions;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                GameTaxonomyOpinion* tmp = [[GameTaxonomyOpinion alloc] init];
	                [tmp parse:obj]; 
	                [opinions addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }
	    [poll parse:[dict objectForKey:@"poll"]];

	}
}
@end;



@implementation Template
@synthesize id_;
@synthesize engineversion;
@synthesize version;
@synthesize templatetype;
@synthesize gameid;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        engineversion = @"";
        version = @"";
        templatetype = @"";
        gameid = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(engineversion);
    SAFE_RELEASE(version);
    SAFE_RELEASE(templatetype);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.engineversion = [dict strValue:@"engineversion"];
	    self.version = [dict strValue:@"version"];
	    self.templatetype = [dict strValue:@"templatetype"];
	    self.gameid = [dict intValue:@"gameid"];

	}
}
@end;



@implementation TemplateUserdata
@synthesize templatedata;


- (id)init {
    self = [super init];
    if (self) {
        templatedata = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(templatedata);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.templatedata = [dict strValue:@"templatedata"];

	}
}
@end;



@implementation TemplateDetail
@synthesize layouts;
@synthesize createdtime;
@synthesize updatedtime;


- (id)init {
    self = [super init];
    if (self) {
        layouts = @"";
        createdtime = @"";
        updatedtime = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(layouts);
    SAFE_RELEASE(createdtime);
    SAFE_RELEASE(updatedtime);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.layouts = [dict strValue:@"layouts"];
	    self.createdtime = [dict strValue:@"createdtime"];
	    self.updatedtime = [dict strValue:@"updatedtime"];

	}
}
@end;



@implementation GameUchomeCurrencyItem
@synthesize icon;
@synthesize currency;


- (id)init {
    self = [super init];
    if (self) {
        icon = @"";
        currency = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(icon);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.icon = [dict strValue:@"icon"];
	    self.currency = [dict intValue:@"currency"];

	}
}
@end;


@implementation GameUchome
@synthesize match;
@synthesize countcomments;
@synthesize countposts;
@synthesize countconsumption;
@synthesize currency;
@synthesize templates;


- (id)init {
    self = [super init];
    if (self) {
        match = 0;
        countcomments = 0;
        countposts = 0;
        countconsumption = 0;
        currency = [[NSMutableArray alloc] init];
        templates = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(currency);
    SAFE_RELEASE(templates);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.match = [dict intValue:@"match"];
	    self.countcomments = [dict intValue:@"countcomments"];
	    self.countposts = [dict intValue:@"countposts"];
	    self.countconsumption = [dict intValue:@"countconsumption"];
	    NSObject* array_currency = [dict objectForKey:@"currency"];
	    [currency removeAllObjects];
	    if (array_currency && [array_currency isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_currency;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                GameUchomeCurrencyItem* tmp = [[GameUchomeCurrencyItem alloc] init];
	                [tmp parse:obj]; 
	                [currency addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }NSObject* array_templates = [dict objectForKey:@"templates"];
	    [templates removeAllObjects];
	    if (array_templates && [array_templates isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_templates;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                TemplateUserdata* tmp = [[TemplateUserdata alloc] init];
	                [tmp parse:obj]; 
	                [templates addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }
	}
}
@end;



@implementation HomeNews
@synthesize post;
@synthesize sender;
@synthesize id_;
@synthesize resid;
@synthesize gameid;
@synthesize gamename;
@synthesize taxonomyname;
@synthesize title;
@synthesize viewcount;
@synthesize imgurl;
@synthesize updatedtime;


- (id)init {
    self = [super init];
    if (self) {
        post = [[Content alloc] init];
        sender = [[Avatar alloc] init];
        id_ = 0;
        resid = @"";
        gameid = 0;
        gamename = @"";
        taxonomyname = @"";
        title = @"";
        viewcount = 0;
        imgurl = @"";
        updatedtime = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(post);
    SAFE_RELEASE(sender);
    SAFE_RELEASE(resid);
    SAFE_RELEASE(gamename);
    SAFE_RELEASE(taxonomyname);
    SAFE_RELEASE(title);
    SAFE_RELEASE(imgurl);
    SAFE_RELEASE(updatedtime);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [post parse:[dict objectForKey:@"post"]];

	    [sender parse:[dict objectForKey:@"sender"]];
	    self.id_ = [dict intValue:@"id"];
	    self.resid = [dict strValue:@"resid"];
	    self.gameid = [dict intValue:@"gameid"];
	    self.gamename = [dict strValue:@"gamename"];
	    self.taxonomyname = [dict strValue:@"taxonomyname"];
	    self.title = [dict strValue:@"title"];
	    self.viewcount = [dict intValue:@"viewcount"];
	    self.imgurl = [dict strValue:@"imgurl"];
	    self.updatedtime = [dict strValue:@"updatedtime"];

	}
}
@end;



@implementation UserMsginbox
@synthesize id_;
@synthesize sender;
@synthesize type;
@synthesize content;
@synthesize postsummary;
@synthesize postimage;
@synthesize postappurl;
@synthesize createdtime;
@synthesize updatedtime;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        sender = [[Avatar alloc] init];
        type = 0;
        content = @"";
        postsummary = @"";
        postimage = @"";
        postappurl = @"";
        createdtime = @"";
        updatedtime = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(sender);
    SAFE_RELEASE(content);
    SAFE_RELEASE(postsummary);
    SAFE_RELEASE(postimage);
    SAFE_RELEASE(postappurl);
    SAFE_RELEASE(createdtime);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];

	    [sender parse:[dict objectForKey:@"sender"]];
	    self.type = [dict intValue:@"type"];
	    self.content = [dict strValue:@"content"];
	    self.postsummary = [dict strValue:@"postsummary"];
	    self.postimage = [dict strValue:@"postimage"];
	    self.postappurl = [dict strValue:@"postappurl"];
	    self.createdtime = [dict strValue:@"createdtime"];
	    self.updatedtime = [dict intValue:@"updatedtime"];

	}
}
@end;



@implementation PostConsumptionContent
@synthesize game;


- (id)init {
    self = [super init];
    if (self) {
        game = [[Game alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(game);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [game parse:[dict objectForKey:@"game"]];

	}
}
@end;



@implementation ConsumptionXp
@synthesize currency;
@synthesize currentcurrency;
@synthesize currentxp;
@synthesize currentname;
@synthesize nextxp;
@synthesize nextname;
@synthesize diff;
@synthesize level;


- (id)init {
    self = [super init];
    if (self) {
        currency = 0;
        currentcurrency = 0;
        currentxp = 0;
        currentname = @"";
        nextxp = 0;
        nextname = @"";
        diff = 0;
        level = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(currentname);
    SAFE_RELEASE(nextname);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.currency = [dict intValue:@"currency"];
	    self.currentcurrency = [dict intValue:@"currentcurrency"];
	    self.currentxp = [dict intValue:@"currentxp"];
	    self.currentname = [dict strValue:@"currentname"];
	    self.nextxp = [dict intValue:@"nextxp"];
	    self.nextname = [dict strValue:@"nextname"];
	    self.diff = [dict intValue:@"diff"];
	    self.level = [dict intValue:@"level"];

	}
}
@end;



@implementation GroupUserJoinedMsg
@synthesize joineduser;


- (id)init {
    self = [super init];
    if (self) {
        joineduser = [[Avatar alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(joineduser);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [joineduser parse:[dict objectForKey:@"joineduser"]];

	}
}
@end;



@implementation GroupInviteUsersMsg
@synthesize inviter;
@synthesize invitees;


- (id)init {
    self = [super init];
    if (self) {
        inviter = [[Avatar alloc] init];
        invitees = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(inviter);
    SAFE_RELEASE(invitees);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [inviter parse:[dict objectForKey:@"inviter"]];
	    NSObject* array_invitees = [dict objectForKey:@"invitees"];
	    [invitees removeAllObjects];
	    if (array_invitees && [array_invitees isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_invitees;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                Avatar* tmp = [[Avatar alloc] init];
	                [tmp parse:obj]; 
	                [invitees addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }
	}
}
@end;



@implementation GroupBanUserMsg
@synthesize banedbyuser;
@synthesize baneduser;


- (id)init {
    self = [super init];
    if (self) {
        banedbyuser = [[Avatar alloc] init];
        baneduser = [[Avatar alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(banedbyuser);
    SAFE_RELEASE(baneduser);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [banedbyuser parse:[dict objectForKey:@"banedbyuser"]];

	    [baneduser parse:[dict objectForKey:@"baneduser"]];

	}
}
@end;



@implementation GroupUserQuitMsg
@synthesize quituser;


- (id)init {
    self = [super init];
    if (self) {
        quituser = [[Avatar alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(quituser);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [quituser parse:[dict objectForKey:@"quituser"]];

	}
}
@end;



@implementation PostNewCommentMsg
@synthesize title;
@synthesize postresid;
@synthesize boardid;
@synthesize commentresid;
@synthesize comment;
@synthesize commentuser;
@synthesize postuser;
@synthesize createtime;
@synthesize atid;


- (id)init {
    self = [super init];
    if (self) {
        title = @"";
        postresid = @"";
        boardid = 0;
        commentresid = @"";
        comment = @"";
        commentuser = [[Avatar alloc] init];
        postuser = [[Avatar alloc] init];
        createtime = 0;
        atid = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(title);
    SAFE_RELEASE(postresid);
    SAFE_RELEASE(commentresid);
    SAFE_RELEASE(comment);
    SAFE_RELEASE(commentuser);
    SAFE_RELEASE(postuser);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.title = [dict strValue:@"title"];
	    self.postresid = [dict strValue:@"postresid"];
	    self.boardid = [dict intValue:@"boardid"];
	    self.commentresid = [dict strValue:@"commentresid"];
	    self.comment = [dict strValue:@"comment"];

	    [commentuser parse:[dict objectForKey:@"commentuser"]];

	    [postuser parse:[dict objectForKey:@"postuser"]];
	    self.createtime = [dict intValue:@"createtime"];
	    self.atid = [dict intValue:@"atid"];

	}
}
@end;



@implementation PostNewStatusMsg
@synthesize title;
@synthesize boardid;
@synthesize postresid;


- (id)init {
    self = [super init];
    if (self) {
        title = @"";
        boardid = 0;
        postresid = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(title);
    SAFE_RELEASE(postresid);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.title = [dict strValue:@"title"];
	    self.boardid = [dict intValue:@"boardid"];
	    self.postresid = [dict strValue:@"postresid"];

	}
}
@end;



@implementation FriendInviteMsg
@synthesize inviter;
@synthesize resid;
@synthesize status;


- (id)init {
    self = [super init];
    if (self) {
        inviter = [[Avatar alloc] init];
        resid = @"";
        status = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(inviter);
    SAFE_RELEASE(resid);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [inviter parse:[dict objectForKey:@"inviter"]];
	    self.resid = [dict strValue:@"resid"];
	    self.status = [dict intValue:@"status"];

	}
}
@end;



@implementation GeneralUserMsg
@synthesize user;


- (id)init {
    self = [super init];
    if (self) {
        user = [[Avatar alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(user);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [user parse:[dict objectForKey:@"user"]];

	}
}
@end;



@implementation GeneralThreadAvatarMsg
@synthesize threadavatar;


- (id)init {
    self = [super init];
    if (self) {
        threadavatar = [[ThreadAvatar alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(threadavatar);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [threadavatar parse:[dict objectForKey:@"threadavatar"]];

	}
}
@end;



@implementation GroupApplyMsg
@synthesize applier;
@synthesize resid;
@synthesize group;
@synthesize status;


- (id)init {
    self = [super init];
    if (self) {
        applier = [[Avatar alloc] init];
        resid = @"";
        group = [[Group alloc] init];
        status = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(applier);
    SAFE_RELEASE(resid);
    SAFE_RELEASE(group);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [applier parse:[dict objectForKey:@"applier"]];
	    self.resid = [dict strValue:@"resid"];

	    [group parse:[dict objectForKey:@"group"]];
	    self.status = [dict intValue:@"status"];

	}
}
@end;



@implementation GeneralGroupMsg
@synthesize group;


- (id)init {
    self = [super init];
    if (self) {
        group = [[Group alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(group);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [group parse:[dict objectForKey:@"group"]];

	}
}
@end;



@implementation GroupInfoCmdMsgGroup
@synthesize master;
@synthesize boss;
@synthesize allownotification;


- (id)init {
    self = [super init];
    if (self) {
        master = @"";
        boss = @"";
        allownotification = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(master);
    SAFE_RELEASE(boss);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.master = [dict strValue:@"master"];
	    self.boss = [dict strValue:@"boss"];
	    self.allownotification = [dict intValue:@"allownotification"];

	}
}
@end;


@implementation GroupInfoCmdMsg
@synthesize group;


- (id)init {
    self = [super init];
    if (self) {
        group = [[GroupInfoCmdMsgGroup alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(group);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    [group parse:[dict objectForKey:@"group"]];

	}
}
@end;



@implementation TitleMsg
@synthesize title;


- (id)init {
    self = [super init];
    if (self) {
        title = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(title);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.title = [dict strValue:@"title"];

	}
}
@end;



@implementation XpChangedMsg
@synthesize level;
@synthesize exp;
@synthesize maxexp;
@synthesize oldlevel;
@synthesize oldexp;
@synthesize oldmaxexp;
@synthesize xp;
@synthesize action;
@synthesize alert;


- (id)init {
    self = [super init];
    if (self) {
        level = 0;
        exp = 0;
        maxexp = 0;
        oldlevel = 0;
        oldexp = 0;
        oldmaxexp = 0;
        xp = 0;
        action = @"";
        alert = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(action);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.level = [dict intValue:@"level"];
	    self.exp = [dict intValue:@"exp"];
	    self.maxexp = [dict intValue:@"maxexp"];
	    self.oldlevel = [dict intValue:@"oldlevel"];
	    self.oldexp = [dict intValue:@"oldexp"];
	    self.oldmaxexp = [dict intValue:@"oldmaxexp"];
	    self.xp = [dict intValue:@"xp"];
	    self.action = [dict strValue:@"action"];
	    self.alert = [dict intValue:@"alert"];

	}
}
@end;



@implementation BadgeInfoCmdMsg
@synthesize type;
@synthesize timestamp;
@synthesize count;
@synthesize thread;


- (id)init {
    self = [super init];
    if (self) {
        type = 0;
        timestamp = 0;
        count = 0;
        thread = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(thread);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.type = [dict intValue:@"type"];
	    self.timestamp = [dict intValue:@"timestamp"];
	    self.count = [dict intValue:@"count"];
	    self.thread = [dict strValue:@"thread"];

	}
}
@end;



@implementation FriendListFriendsItem
@synthesize isfriend;


- (id)init {
    self = [super init];
    if (self) {
        isfriend = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.isfriend = [dict intValue:@"isfriend"];

	}
}
@end;


@implementation FriendList
@synthesize page;
@synthesize count;
@synthesize seq;
@synthesize lastpage;
@synthesize friends;


- (id)init {
    self = [super init];
    if (self) {
        page = 0;
        count = 0;
        seq = 0;
        lastpage = 0;
        friends = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(friends);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.page = [dict intValue:@"page"];
	    self.count = [dict intValue:@"count"];
	    self.seq = [dict longValue:@"seq"];
	    self.lastpage = [dict intValue:@"lastpage"];
	    NSObject* array_friends = [dict objectForKey:@"friends"];
	    [friends removeAllObjects];
	    if (array_friends && [array_friends isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_friends;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                FriendListFriendsItem* tmp = [[FriendListFriendsItem alloc] init];
	                [tmp parse:obj]; 
	                [friends addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }
	}
}
@end;



@implementation PubList
@synthesize subscribercount;
@synthesize desc;
@synthesize isadded;


- (id)init {
    self = [super init];
    if (self) {
        subscribercount = 0;
        desc = @"";
        isadded = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(desc);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
    [super parse:obj];
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.subscribercount = [dict intValue:@"subscribercount"];
	    self.desc = [dict strValue:@"desc"];
	    self.isadded = [dict intValue:@"isadded"];

	}
}
@end;



@implementation GameListItem
@synthesize id_;
@synthesize name;
@synthesize icon;
@synthesize level;
@synthesize urlschema;
@synthesize packagename;
@synthesize flag;
@synthesize countplayer;
@synthesize countposts;
@synthesize hasclass;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        name = @"";
        icon = @"";
        level = 0;
        urlschema = @"";
        packagename = @"";
        flag = 0;
        countplayer = 0;
        countposts = 0;
        hasclass = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(name);
    SAFE_RELEASE(icon);
    SAFE_RELEASE(urlschema);
    SAFE_RELEASE(packagename);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.name = [dict strValue:@"name"];
	    self.icon = [dict strValue:@"icon"];
	    self.level = [dict intValue:@"level"];
	    self.urlschema = [dict strValue:@"urlschema"];
	    self.packagename = [dict strValue:@"packagename"];
	    self.flag = [dict intValue:@"flag"];
	    self.countplayer = [dict intValue:@"countplayer"];
	    self.countposts = [dict intValue:@"countposts"];
	    self.hasclass = [dict intValue:@"hasclass"];

	}
}
@end;



@implementation PhotoItem
@synthesize id_;
@synthesize photo;
@synthesize voice;
@synthesize unread;
@synthesize countlikes;
@synthesize countcomments;
@synthesize isliked;
@synthesize createdtime;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        photo = @"";
        voice = @"";
        unread = 0;
        countlikes = 0;
        countcomments = 0;
        isliked = 0;
        createdtime = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(photo);
    SAFE_RELEASE(voice);
    SAFE_RELEASE(createdtime);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.photo = [dict strValue:@"photo"];
	    self.voice = [dict strValue:@"voice"];
	    self.unread = [dict intValue:@"unread"];
	    self.countlikes = [dict intValue:@"countlikes"];
	    self.countcomments = [dict intValue:@"countcomments"];
	    self.isliked = [dict intValue:@"isliked"];
	    self.createdtime = [dict strValue:@"createdtime"];

	}
}
@end;



@implementation PhotoCommentItem
@synthesize id_;
@synthesize comment;
@synthesize voice;
@synthesize floor;
@synthesize sender;
@synthesize createdtime;


- (id)init {
    self = [super init];
    if (self) {
        id_ = 0;
        comment = @"";
        voice = @"";
        floor = 0;
        sender = [[Avatar alloc] init];
        createdtime = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(comment);
    SAFE_RELEASE(voice);
    SAFE_RELEASE(sender);
    SAFE_RELEASE(createdtime);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.id_ = [dict intValue:@"id"];
	    self.comment = [dict strValue:@"comment"];
	    self.voice = [dict strValue:@"voice"];
	    self.floor = [dict intValue:@"floor"];

	    [sender parse:[dict objectForKey:@"sender"]];
	    self.createdtime = [dict strValue:@"createdtime"];

	}
}
@end;



@implementation BusinessLinkApp
@synthesize title;
@synthesize summary;
@synthesize avatar;
@synthesize createdtime;
@synthesize img;
@synthesize voice;
@synthesize linkurl;
@synthesize fromurl;


- (id)init {
    self = [super init];
    if (self) {
        title = @"";
        summary = @"";
        avatar = @"";
        createdtime = 0;
        img = @"";
        voice = @"";
        linkurl = @"";
        fromurl = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(title);
    SAFE_RELEASE(summary);
    SAFE_RELEASE(avatar);
    SAFE_RELEASE(img);
    SAFE_RELEASE(voice);
    SAFE_RELEASE(linkurl);
    SAFE_RELEASE(fromurl);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.title = [dict strValue:@"title"];
	    self.summary = [dict strValue:@"summary"];
	    self.avatar = [dict strValue:@"avatar"];
	    self.createdtime = [dict intValue:@"createdtime"];
	    self.img = [dict strValue:@"img"];
	    self.voice = [dict strValue:@"voice"];
	    self.linkurl = [dict strValue:@"linkurl"];
	    self.fromurl = [dict strValue:@"fromurl"];

	}
}
@end;



@implementation BusinessPubAppArticlesItem
@synthesize resid;
@synthesize title;
@synthesize content;
@synthesize image_url;
@synthesize url;


- (id)init {
    self = [super init];
    if (self) {
        resid = @"";
        title = @"";
        content = @"";
        image_url = @"";
        url = @"";

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(resid);
    SAFE_RELEASE(title);
    SAFE_RELEASE(content);
    SAFE_RELEASE(image_url);
    SAFE_RELEASE(url);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.resid = [dict strValue:@"resid"];
	    self.title = [dict strValue:@"title"];
	    self.content = [dict strValue:@"content"];
	    self.image_url = [dict strValue:@"image_url"];
	    self.url = [dict strValue:@"url"];

	}
}
@end;


@implementation BusinessPubApp
@synthesize article_count;
@synthesize articles;


- (id)init {
    self = [super init];
    if (self) {
        article_count = 0;
        articles = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    SAFE_RELEASE(articles);

    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.article_count = [dict intValue:@"article_count"];
	    NSObject* array_articles = [dict objectForKey:@"articles"];
	    [articles removeAllObjects];
	    if (array_articles && [array_articles isKindOfClass:[NSArray class]]) {
	        NSArray *array = (NSArray*)array_articles;
	        for (int i = 0; i < [array count]; i++) {
	            NSObject* obj = [array objectAtIndex:i];
	            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	                BusinessPubAppArticlesItem* tmp = [[BusinessPubAppArticlesItem alloc] init];
	                [tmp parse:obj]; 
	                [articles addObject:tmp];
	                SAFE_RELEASE(tmp);
	            }    
	        
	        }
	    }
	}
}
@end;



@implementation TargetInterviewData
@synthesize gameid;
@synthesize accountid;


- (id)init {
    self = [super init];
    if (self) {
        gameid = 0;
        accountid = 0;

    }
    return self;
}

- (void)dealloc {
#ifndef ARC_MODE
    [super dealloc];
#endif
}

- (void)parse:(NSObject*)obj {
	if (obj && [obj isKindOfClass:[NSDictionary class]]) {
	    NSDictionary* dict = (NSDictionary*)obj;

	    self.gameid = [dict intValue:@"gameid"];
	    self.accountid = [dict intValue:@"accountid"];

	}
}
@end;


