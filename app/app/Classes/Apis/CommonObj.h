//终端信息
@interface TerminalInfo : NSObject
//应用ID 
@property(nonatomic, assign) int appid;
//渠道ID 
@property(nonatomic, assign) int channelid;
//设备ID 
@property(nonatomic, retain) NSString* equipmentid;
//应用版本 
@property(nonatomic, retain) NSString* applicationversion;
//系统版本 
@property(nonatomic, retain) NSString* systemversion;
// 
@property(nonatomic, retain) NSString* cellbrand;
// 
@property(nonatomic, retain) NSString* cellmodel;
//mac地址 
@property(nonatomic, retain) NSString* mac;


- (void)parse:(NSObject*)obj;
@end;


//用户头像信息
@interface Avatar : NSObject
//用户账户ID 
@property(nonatomic, assign) int accountid;
//昵称 
@property(nonatomic, retain) NSString* nickname;
//等级 
@property(nonatomic, assign) int level;
// AVATAR_TYPE_USER(1):用户, AVATAR_TYPE_PUB(2):公众账号, AVATAR_TYPE_GROUP(3):班级群组, AVATAR_TYPE_GAME(4):游戏, 
@property(nonatomic, assign) int atype;
//avatar的校验号 
@property(nonatomic, retain) NSString* v;
//头像标志 
@property(nonatomic, assign) int flag;


- (void)parse:(NSObject*)obj;
@end;


//道具简单信息
@interface ItemShortInfo : NSObject
//道具ID 
@property(nonatomic, assign) int id_;
//道具名称 
@property(nonatomic, retain) NSString* itemname;
//道具图片 
@property(nonatomic, retain) NSString* photo;
//道具图片缩略图 
@property(nonatomic, retain) NSString* photo_s;


- (void)parse:(NSObject*)obj;
@end;


//道具详细信息
@interface ItemInfo : NSObject
//道具id 
@property(nonatomic, assign) int id_;
//道具名称 
@property(nonatomic, retain) NSString* itemname;
//道具图片url 
@property(nonatomic, retain) NSString* photo;
//道具缩略图url 
@property(nonatomic, retain) NSString* photo_s;
//道具详细描述 
@property(nonatomic, retain) NSString* description;
//道具简述 
@property(nonatomic, retain) NSString* shortdescription;


- (void)parse:(NSObject*)obj;
@end;


//
@interface PageOutput : NSObject
//当前页数 
@property(nonatomic, assign) int page;
//当前页条数 
@property(nonatomic, assign) int count;
//查询序列，翻页都是基于同一个序列号 
@property(nonatomic, assign) long seq;
//是否是最后一页。0：不是最后一页  1：已经到了最后一页 
@property(nonatomic, assign) int lastpage;


- (void)parse:(NSObject*)obj;
@end;


//默认输出
@interface DefaultOutput : NSObject
//返回码  0：成功 
@property(nonatomic, assign) int code;
//返回结果描述 
@property(nonatomic, retain) NSString* message;


- (void)parse:(NSObject*)obj;
@end;


//分页查询输入
@interface PageInput : NSObject
//查询的基准序列号，填入上一次查询的返回值 
@property(nonatomic, assign) long seq;


- (void)parse:(NSObject*)obj;
@end;


//
@interface UserPref : NSObject
//私信通知 
@property(nonatomic, assign) int pri_msg_ntf;
//班级通知 
@property(nonatomic, assign) int cls_msg_ntf;
//群组通知 
@property(nonatomic, assign) int grp_msg_ntf;
//系统通知 
@property(nonatomic, assign) int sys_msg_ntf;
//自定义背景图 
@property(nonatomic, retain) NSString* bgimg;
//聊天泡泡信息 
@property(nonatomic, retain) NSString* messagestyle;


- (void)parse:(NSObject*)obj;
@end;


//
@interface UserStat : NSObject
// 
@property(nonatomic, assign) int showcount;
// 
@property(nonatomic, assign) int askcount;
// 
@property(nonatomic, assign) int answercount;
// 
@property(nonatomic, assign) int friendcount;
// 
@property(nonatomic, assign) int photofeedcount;
//访问个人中心的总人数 
@property(nonatomic, assign) int homecount;
//今天个人中心的访问人数 
@property(nonatomic, assign) int homecounttoday;
// 
@property(nonatomic, assign) int photocount;
//新的粉丝数 
@property(nonatomic, assign) int newfollowercount;
//新的好友数 
@property(nonatomic, assign) int newfriendcount;
//粉丝数 
@property(nonatomic, assign) int followercount;
//关注数 
@property(nonatomic, assign) int followingcount;
//动态未读计数 
@property(nonatomic, assign) int feedunreadcount;
//个人消息未读计数 
@property(nonatomic, assign) int msginboxunreadcount;
//个人认证的消费总金额 
@property(nonatomic, assign) int consumptionamount;
//个人认证的总金额 
@property(nonatomic, assign) int consumptionlevel;


- (void)parse:(NSObject*)obj;
@end;


//
@interface UpdateInfo : NSObject
// AUTOUPDATE_NONE(0):, AUTOUPDATE_NORMAL(1):, AUTOUPDATE_FORCE(2):, 
@property(nonatomic, assign) int needupdate;
// 
@property(nonatomic, retain) NSString* updateurl;
// 
@property(nonatomic, retain) NSString* updatedesc;
//当前最新版本号 
@property(nonatomic, retain) NSString* version;


- (void)parse:(NSObject*)obj;
@end;


//
@interface UserXp : NSObject
//经验等级 
@property(nonatomic, assign) int level;
//当前级别的经验值 
@property(nonatomic, assign) int exp;
//当前级别的经验值上限 
@property(nonatomic, assign) int maxexp;


- (void)parse:(NSObject*)obj;
@end;


//
@interface ContentBody : NSObject
//富文本内容 
@property(nonatomic, retain) NSString* html;
//图片url 
@property(nonatomic, retain) NSMutableArray* images; //NSString*
//语音链接 
@property(nonatomic, retain) NSString* voice;
//app链接 
@property(nonatomic, retain) NSString* appurl;


- (void)parse:(NSObject*)obj;
@end;


//
@interface ContentSender : Avatar
// 
@property(nonatomic, assign) int ismaster;
// 
@property(nonatomic, assign) int isgoodhelper;


- (void)parse:(NSObject*)obj;
@end;

//
@interface ContentLikesItem : Avatar
// 
@property(nonatomic, assign) int mood;


- (void)parse:(NSObject*)obj;
@end;

//帖子内容
@interface Content : NSObject
// 
@property(nonatomic, assign) long id_;
//标题，只用于post中 
@property(nonatomic, retain) NSString* title;
// 
@property(nonatomic, readonly) ContentBody* body;
// 
@property(nonatomic, assign) int atid;
// 
@property(nonatomic, retain) NSString* at_name;
// 
@property(nonatomic, readonly) ContentSender* sender;
//评论数, 二级评论中不使用该字段 
@property(nonatomic, assign) int countcomments;
//喜欢数, 二级评论中不使用该字段 
@property(nonatomic, assign) int countlikes;
//浏览数 
@property(nonatomic, assign) int countviews;
// 
@property(nonatomic, assign) int isliked;
// 
@property(nonatomic, assign) int iscommented;
// 
@property(nonatomic, assign) int floor;
//bit 0:是否赞,1:是否加精,2:是否认可,3:是否置顶,4:是否收藏,5:是否透明,6:是否禁言 CONTENT_FLAG_LIKE(1):, CONTENT_FLAG_GEM(2):, CONTENT_FLAG_RECOGNISE(4):, CONTENT_FLAG_TOP(8):, CONTENT_FLAG_FAVORIT(16):, CONTENT_FLAG_TRANSPARENT(32):, CONTENT_FLAG_FORBID(64):, CONTENT_FLAG_FREECHARGE(128):, 
@property(nonatomic, assign) int flag;
//resid，唯一标识该资源 
@property(nonatomic, retain) NSString* resid;
//模版id 
@property(nonatomic, assign) int templateid;
//模版数据 
@property(nonatomic, retain) NSString* templatedata;
//货币单位id 
@property(nonatomic, assign) int currencyunitid;
//货币单位icon 
@property(nonatomic, retain) NSString* currencyuniticon;
//货币金额 
@property(nonatomic, assign) int currency;
// 
@property(nonatomic, retain) NSMutableArray* likes; //ContentLikesItem
//游戏appurl 
@property(nonatomic, retain) NSString* gameappurl;
//消费点appurl 
@property(nonatomic, retain) NSString* taxonomyappurl;
// 
@property(nonatomic, retain) NSString* updatedtime;
// 
@property(nonatomic, retain) NSString* createdtime;


- (void)parse:(NSObject*)obj;
@end;


//
@interface PostContent : Content
//帖子跳转的appurl 
@property(nonatomic, retain) NSString* postappurl;
//摘要，用于帖子转发使用 
@property(nonatomic, retain) NSString* summary;
// 
@property(nonatomic, retain) NSMutableArray* comments; //Content


- (void)parse:(NSObject*)obj;
@end;


//
@interface Game : NSObject
// 
@property(nonatomic, assign) int id_;
// 
@property(nonatomic, retain) NSString* name;
// 
@property(nonatomic, retain) NSString* icon;
// 
@property(nonatomic, assign) int countplayer;


- (void)parse:(NSObject*)obj;
@end;


//
@interface GameDetailCategory : NSObject
//游戏分类名称 
@property(nonatomic, retain) NSString* name;
//游戏分类id 
@property(nonatomic, assign) int id_;


- (void)parse:(NSObject*)obj;
@end;

//
@interface GameDetail : Game
//收费类型 1-收费、2-限免、3-免费 
@property(nonatomic, assign) int chargetype;
// 
@property(nonatomic, readonly) GameDetailCategory* category;
// 
@property(nonatomic, retain) NSString* bigicon;
//游戏收费价格, 只收费游戏有值，其它为0 
@property(nonatomic, assign) float price;
//游戏板块id，0时表示尚没有板块 
@property(nonatomic, assign) int boardid;
//游戏文件大小 
@property(nonatomic, assign) int filesize;
//上架时间 
@property(nonatomic, retain) NSString* onlinetime;
//当前版本号 
@property(nonatomic, retain) NSString* currentversion;
//下载链接 
@property(nonatomic, retain) NSString* downloadlink;
//游戏介绍文本 
@property(nonatomic, retain) NSString* introduction;


- (void)parse:(NSObject*)obj;
@end;


//
@interface Publisher : NSObject
// 
@property(nonatomic, assign) int accountid;
//邮箱 
@property(nonatomic, retain) NSString* username;
// 
@property(nonatomic, retain) NSString* nickname;
// 
@property(nonatomic, retain) NSString* avatar;
// 
@property(nonatomic, retain) NSString* description;
//注册时间 
@property(nonatomic, retain) NSString* created;


- (void)parse:(NSObject*)obj;
@end;


//
@interface PollOption : NSObject
//选项ID 
@property(nonatomic, assign) int id_;
//选项文字 
@property(nonatomic, retain) NSString* text;
//投票人数(投票后) 
@property(nonatomic, assign) int total;
//比例(投票后) 
@property(nonatomic, assign) float percent;
//自己是否选择 0: 未选择 1: 选择 
@property(nonatomic, assign) int vote;


- (void)parse:(NSObject*)obj;
@end;


//thread头像信息
@interface ThreadAvatar : NSObject
//会话thread 
@property(nonatomic, retain) NSString* thread;
//会话显示名称 
@property(nonatomic, retain) NSString* nickname;
//avatar的校验号 
@property(nonatomic, retain) NSString* v;
// AVATAR_TYPE_USER(1):用户, AVATAR_TYPE_PUB(2):公众账号, AVATAR_TYPE_GROUP(3):班级群组, AVATAR_TYPE_GAME(4):游戏, 
@property(nonatomic, assign) int atype;
//头像标志 
@property(nonatomic, assign) int flag;
// THREAD_TYPE_PRIVATE(0):私聊thread, THREAD_TYPE_PUB_SYS(110):系统公共账号thread, THREAD_TYPE_PUB_PUB(120):普通公共账号thread, THREAD_TYPE_GROUP_BASE(200):group的基值，仅用于根据groupType计算threadtype, THREAD_TYPE_GROUP_NORMAL(210):常规自建群组thread, THREAD_TYPE_GROUP_TEMP(220):游戏临时小组，班级的前身thread, THREAD_TYPE_GROUP_CLASS(230):班级群组, THREAD_TYPE_GROUP_CHANNEL(240):群组子频道, THREAD_TYPE_GAME(300):游戏类型，目的是为了兼容动态里面用游戏名字来发动态, 
@property(nonatomic, assign) int type;
//thread关联的目标id，type为GROUP相关时为group的resid，PUB和PRIVATE时为accountid 
@property(nonatomic, assign) int targetid;
//等级 
@property(nonatomic, assign) int level;


- (void)parse:(NSObject*)obj;
@end;


//
@interface UserRecommended : ThreadAvatar
//粉丝数 
@property(nonatomic, assign) int followercount;
//来自的游戏 
@property(nonatomic, retain) NSString* gameappurl;
//几个字的描述 
@property(nonatomic, retain) NSString* description;


- (void)parse:(NSObject*)obj;
@end;


//
@interface LoginOutputDataThreads : NSObject
//活动中心的thread 
@property(nonatomic, readonly) ThreadAvatar* act;
//求助速递的thread 
@property(nonatomic, readonly) ThreadAvatar* helper;
//客服的thread 
@property(nonatomic, readonly) ThreadAvatar* kf;


- (void)parse:(NSObject*)obj;
@end;

//
@interface LoginOutputDataNotice : NSObject
// 
@property(nonatomic, assign) long tm;
// 
@property(nonatomic, retain) NSString* title;
// 
@property(nonatomic, retain) NSString* text;
//跳转链接 
@property(nonatomic, retain) NSString* appurl;


- (void)parse:(NSObject*)obj;
@end;

//
@interface LoginOutputData : Avatar
// 
@property(nonatomic, retain) NSString* avatar;
// 
@property(nonatomic, retain) NSString* malenickname;
// 
@property(nonatomic, retain) NSString* femalenickname;
//默认的avatar头像数目 
@property(nonatomic, assign) int defaultavatarcount;
// GENDER_UNKONWN(2):未知, GENDER_MALE(1):男, GENDER_FEMALE(0):女, 
@property(nonatomic, assign) int gender;
// 
@property(nonatomic, readonly) UserXp* xp;
// 
@property(nonatomic, retain) NSString* nativeplace;
// 
@property(nonatomic, retain) NSString* introduction;
// 
@property(nonatomic, retain) NSMutableArray* bindplatformlist; //NSString*
// 
@property(nonatomic, readonly) UpdateInfo* update;
// 
@property(nonatomic, assign) int hasclass;
// 
@property(nonatomic, assign) int status;
// 
@property(nonatomic, retain) NSString* inviteseq;
// 
@property(nonatomic, readonly) UserPref* prefs;
// 
@property(nonatomic, readonly) UserStat* stats;
// 
@property(nonatomic, retain) NSString* latestphoto;
// 
@property(nonatomic, assign) int isthird;
// 
@property(nonatomic, readonly) LoginOutputDataThreads* threads;
// 
@property(nonatomic, readonly) LoginOutputDataNotice* notice;
//时间戳，用于校准时间 
@property(nonatomic, assign) long tm;
//loading page 图片 
@property(nonatomic, retain) NSString* screenimageurl;
//1 - 显示商城， 0 - 否 
@property(nonatomic, assign) int shopshow;
//1 - 显示积分墙， 0 - 否 
@property(nonatomic, assign) int idfashow;
//积分墙显示地址 
@property(nonatomic, retain) NSString* idfaurl;
//socket通道的地址，ip:port的形式，多个地址以逗号分隔 
@property(nonatomic, retain) NSString* rtaddrs;
//1表示显示， 0 表示不显示 
@property(nonatomic, assign) int splashshow;


- (void)parse:(NSObject*)obj;
@end;

//登录输出
@interface LoginOutput : NSObject
// 
@property(nonatomic, assign) int code;
// 
@property(nonatomic, retain) NSString* message;
// 
@property(nonatomic, readonly) LoginOutputData* data;


- (void)parse:(NSObject*)obj;
@end;


//
@interface Message : NSObject
//消息id 
@property(nonatomic, retain) NSString* U;
//消息会话id 
@property(nonatomic, retain) NSString* T;
//发送者accountid 
@property(nonatomic, assign) int S;
//接收者accountid 
@property(nonatomic, assign) int R;
// MESSAGE_TYPE_SYS(1):系统消息, MESSAGE_TYPE_GROUP(2):群组消息, MESSAGE_TYPE_PUBLIC(3):公共账号信息, MESSAGE_TYPE_PRIVATE(4):私信, 
@property(nonatomic, assign) int MT;
//消息创建时间 
@property(nonatomic, retain) NSString* CT;
//忽略此消息的用户列表，仅适用于系统&群广播时的特定消息 
@property(nonatomic, retain) NSMutableArray* IG; //int
//JSON or msgpack编码的pyload数据, 数据参考MESSAGE_PAYLOAD定义 
@property(nonatomic, retain) NSString* P;


- (void)parse:(NSObject*)obj;
@end;


//
@interface MessagePayload : NSObject
// MESSAGE_CONTENTTYPE_TEXT(1):单文本, MESSAGE_CONTENTTYPE_APP_URL(2):自定义URL, MESSAGE_CONTENTTYPE_IMG(3):图片, MESSAGE_CONTENTTYPE_VOICE(4):语音, MESSAGE_CONTENTTYPE_SMILEY(5):表情, MESSAGE_CONTENTTYPE_JSON(6):JSON编码的数据, MESSAGE_CONTENTTYPE_HTML(7):HTML代码, 
@property(nonatomic, assign) int CTT;
// MESSAGE_SUBTYPE_CHAT(1):聊天消息, MESSAGE_SUBTYPE_TITLE(1001):只带消息文案title的json消息, MESSAGE_SUBTYPE_XP_CHANGED_CMD(2001):经验值变动, MESSAGE_SUBTYPE_GROUP_INFO_CMD(2002):群组信息指令消息，不显示，仅用于更新群组的信息, MESSAGE_SUBTYPE_BADGE_INFO_CMD(2003):计数badge信息消息，用于显示红点或数字提示，如照片feed, MESSAGE_SUBTYPE_GROUP_SYS_INVITE_USERS(8001):邀请用户加入群组, MESSAGE_SUBTYPE_GROUP_SYS_BAN_USER(8002):删除群组用户, MESSAGE_SUBTYPE_GROUP_SYS_USER_QUIT(8003):群组用户主动退群, MESSAGE_SUBTYPE_GROUP_SYS_USER_JOINED(8004):群组用户加入, MESSAGE_SUBTYPE_GROUP_APPLY(8005):加群申请, MESSAGE_SUBTYPE_GROUP_AGREE(8006):同意加群申请, MESSAGE_SUBTYPE_GROUP_DECLINE(8007):拒绝加群申请, MESSAGE_SUBTYPE_GROUP_MONITOR_ELECTED(8008):用户成为班长, MESSAGE_SUBTYPE_GROUP_ADMIN_ELECTED(8009):用户成为班委, MESSAGE_SUBTYPE_GROUP_UPGRADE_TO_CLASS(8010):预备班升级成正式班, MESSAGE_SUBTYPE_GROUP_UPDATE_NAME(8011):修改群组名, MESSAGE_SUBTYPE_GROUP_UPDATE_AVATAR(8012):修改群组头像, MESSAGE_SUBTYPE_GROUP_UPDATE_INTRO(8013):修改群组公告, MESSAGE_SUBTYPE_GROUP_USER_BE_THE_BOSS(8014):用户成为大魔王, MESSAGE_SUBTYPE_GROUP_SUBSCRIBE_GAME(8015):关注游戏, 目前为普通文本消息，无需特殊处理，本subtype保留, MESSAGE_SUBTYPE_POST_NEW_COMMENT(8101):帖子新评论, MESSAGE_SUBTYPE_POST_GEM(8102):帖子被加精, 目前为普通文本消息，无需特殊处理，本subtype保留, MESSAGE_SUBTYPE_POST_TOP(8103):帖子被置顶, 目前为普通文本消息，无需特殊处理，本subtype保留, MESSAGE_SUBTYPE_POST_DELETE(8104):帖子被删除, 目前为普通文本消息，无需特殊处理，本subtype保留, MESSAGE_SUBTYPE_POST_HOT(8107):帖子被推荐为热贴，目前为普通文本消息，无需特殊处理，本subtype保留, MESSAGE_SUBTYPE_POST_FREE(8108):帖子被推荐为免单，目前为普通文本消息，无需特殊处理，本subtype保留, MESSAGE_SUBTYPE_POST_COST(8109):帖子被推荐为花钱那些事，目前为普通文本消息，无需特殊处理，本subtype保留, MESSAGE_SUBTYPE_INVITE_CODE_BE_FRIEND_INVITER(8105):用户注册使用邀请码后邀请者收到的消息, 目前为普通文本消息，无需特殊处理，本subtype保留, MESSAGE_SUBTYPE_INVITE_CODE_BE_FRIEND_INVITEE(8106):用户注册使用邀请码后被邀请者收到的消息, 目前为普通文本消息，无需特殊处理，本subtype保留, MESSAGE_SUBTYPE_FRIEND_INVITE(8201):好友申请, MESSAGE_SUBTYPE_FRIEND_AGREE(8202):同意好友申请, MESSAGE_SUBTYPE_FRIEND_DECLINE(8203):拒绝好友申请, MESSAGE_SUBTYPE_FRIEND_DELETE(8204):删除好友, MESSAGE_SUBTYPE_GAMECARD_INVITE(8301):游戏名片邀请, MESSAGE_SUBTYPE_ACT(9000):活动类型，只用于服务器端，注意:客户端使用的contenttype是appurl，不是json, 
@property(nonatomic, assign) int ST;
//消息体 
@property(nonatomic, retain) NSString* M;
//发送者AVATAR信息 
@property(nonatomic, readonly) Avatar* SD;
//发送者的语音泡泡样式，如: 01512007_160x130_x78y68，三段分布表示资源编号、宽高、xy上的拉伸点(2x右侧图的，左侧图根据宽高计算)，对应的资源文件有8个，分别是01512007_160x130_x78y68_l.png、 _l_s.png、 _r.png、_r_s.png和相应的四个.9.png文件 
@property(nonatomic, retain) NSString* SMST;
//被at用户 
@property(nonatomic, readonly) Avatar* AT;
//thread基本信息 
@property(nonatomic, readonly) ThreadAvatar* TA;
//指定的提醒的用户，没有时表所有相关的用户。通常消息收到的人都提醒和展示，但是部分消息如群组的通知消息，所有人都能收到但只部分受众用户才提醒，而非AU里的用户需要根据AL来判断是否展示文案 
@property(nonatomic, retain) NSMutableArray* AU; //int
//预览显示文本, 用于列表页预览时优先显示，没有时再解析M 
@property(nonatomic, retain) NSString* TXT;
// MESSAGE_ALARM_TYPE_NORMAL(0):不是指定受众(根据AU判定)时也展示文案，是否提醒根据设置项决定, MESSAGE_ALARM_TYPE_FORCE(1):强制提醒，不管设置如何都展示和提醒, MESSAGE_ALARM_TYPE_DISPLAY(2):不是指定受众(根据AU判定)时只展示文案, MESSAGE_ALARM_TYPE_PASSIVE(3):不是指定受众(根据AU判定)时不提醒&不展示文案, 
@property(nonatomic, assign) int AL;


- (void)parse:(NSObject*)obj;
@end;


//
@interface ThreadMessages : NSObject
//该thread下新消息总数 
@property(nonatomic, assign) int count;
//消息会话id 
@property(nonatomic, retain) NSString* thread;
// 
@property(nonatomic, retain) NSMutableArray* messages; //Message


- (void)parse:(NSObject*)obj;
@end;


//
@interface GroupXp : NSObject
//经验等级 
@property(nonatomic, assign) int level;
//当前级别的经验值 
@property(nonatomic, assign) int exp;
//当前级别的经验值上限 
@property(nonatomic, assign) int maxexp;
//经验总值 
@property(nonatomic, assign) int total;


- (void)parse:(NSObject*)obj;
@end;

//
@interface Group : NSObject
//群组id 
@property(nonatomic, assign) int id_;
//群组类型 
@property(nonatomic, assign) int type;
//当前群组用户数 
@property(nonatomic, assign) int currentmembercount;
//群组最大用户数 
@property(nonatomic, assign) int maxmembercount;
// 
@property(nonatomic, readonly) ThreadAvatar* thread;
//班级经验值，预备班和班级属性 
@property(nonatomic, readonly) GroupXp* xp;
//班级创建时的游戏id 
@property(nonatomic, assign) int gameid;


- (void)parse:(NSObject*)obj;
@end;


//
@interface GroupDetailAdminsItem : Avatar
//管理员角色 
@property(nonatomic, assign) int role;


- (void)parse:(NSObject*)obj;
@end;

//
@interface GroupDetailCheckingame : NSObject
//签到游戏的大魔王用户 
@property(nonatomic, readonly) Avatar* boss;
//是否已签到 0：尚未签到 1：已签到 
@property(nonatomic, assign) int checked;


- (void)parse:(NSObject*)obj;
@end;

//
@interface GroupDetail : Group
//关注的游戏，预备班只有默认的一个 
@property(nonatomic, retain) NSMutableArray* games; //Game
//游戏子频道时对应的父级群组 
@property(nonatomic, assign) int parentid;
//群组介绍 
@property(nonatomic, retain) NSString* introduction;
//群组管理人员 
@property(nonatomic, retain) NSMutableArray* admins; //GroupDetailAdminsItem
// 
@property(nonatomic, readonly) GroupDetailCheckingame* checkingame;


- (void)parse:(NSObject*)obj;
@end;


//
@interface Act : NSObject
//类型 ACT_TYPE_POLL(1):投票, ACT_TYPE_COMPLAIN(2):吐槽, ACT_TYPE_SBQ(3):伤不起, 
@property(nonatomic, assign) int type;
//活动ID 
@property(nonatomic, assign) int id_;
// 
@property(nonatomic, readonly) Avatar* user;
//参与人数 
@property(nonatomic, assign) int joins;
//自己是否已参与 
@property(nonatomic, assign) int me_join;
//标题 
@property(nonatomic, retain) NSString* title;
//图片 
@property(nonatomic, retain) NSString* image;
//描述 
@property(nonatomic, retain) NSString* desc;


- (void)parse:(NSObject*)obj;
@end;


//
@interface FeedItem : NSObject
// 
@property(nonatomic, readonly) Avatar* sender;
//参与人数 
@property(nonatomic, assign) int attendercount;
//喜欢数 
@property(nonatomic, assign) int countlikes;
//评论数 
@property(nonatomic, assign) int countcomments;
// 
@property(nonatomic, retain) NSString* info;
// 
@property(nonatomic, retain) NSString* title;
// 
@property(nonatomic, retain) NSString* icon;
// 
@property(nonatomic, retain) NSString* summary;
// 
@property(nonatomic, retain) NSString* tag;
// 
@property(nonatomic, retain) NSString* tourl;
// 
@property(nonatomic, retain) NSString* fromurl;
// 
@property(nonatomic, retain) NSString* createdtime;


- (void)parse:(NSObject*)obj;
@end;


//
@interface FeedTimelineItemPub : NSObject
//标题 
@property(nonatomic, retain) NSString* title;
//图片 
@property(nonatomic, retain) NSString* icon;
//摘要 
@property(nonatomic, retain) NSString* summary;
//浏览数 
@property(nonatomic, assign) int viewcount;
//跳转appurl 
@property(nonatomic, retain) NSString* viewappurl;


- (void)parse:(NSObject*)obj;
@end;


//
@interface FeedTimelineItem : NSObject
//动态的发布者，如果是公众帐号，需要加蓝V标志 
@property(nonatomic, readonly) ThreadAvatar* sender;
// FEED_TIMELINE_TYPE_NONE(0):, FEED_TIMELINE_TYPE_PUBLISHER(1):公众帐号文章, FEED_TIMELINE_TYPE_POST_TAXONOMY(2):曝消费里面的帖子, FEED_TIMELINE_TYPE_POST_USER(3):用户动态里面发布的帖子, FEED_TIMELINE_TYPE_POST_COST(4):花钱那些事, FEED_TIMELINE_TYPE_GAME_POST(5):游戏热帖推荐, 以游戏的名字去推送, FEED_TIMELINE_TYPE_USER_SHARE(6):用户分享, FEED_TIMELINE_TYPE_GAME_ACTIVITY(7):游戏活动，本质是推送一个帖子，也是以游戏的名字去推送, FEED_TIMELINE_TYPE_GAME_GIFT(8):游戏礼包的推送， 以游戏的名字去推送, 
@property(nonatomic, assign) int type;
// 
@property(nonatomic, readonly) PostContent* post;
// 
@property(nonatomic, readonly) FeedTimelineItemPub* pub;
// 
@property(nonatomic, readonly) FeedTimelineItemPub* postcost;
// 
@property(nonatomic, readonly) FeedTimelineItemPub* gamepost;
// 
@property(nonatomic, readonly) FeedTimelineItemPub* usershare;
// 
@property(nonatomic, readonly) FeedTimelineItemPub* gamegift;
// 
@property(nonatomic, readonly) FeedTimelineItemPub* gameactivity;
//动态的创建时间 
@property(nonatomic, retain) NSString* createdtime;
//动态的更新时间，一般跟创建时间一致 
@property(nonatomic, assign) int updatedtime;


- (void)parse:(NSObject*)obj;
@end;


//商品信息
@interface ShopItem : NSObject
// SHOP_ITEM_CATEGORY_GAME_GIFT(1):游戏礼包, SHOP_ITEM_CATEGORY_GITF(2):普通商品, SHOP_ITEM_CATEGORY_SMILEY(3):表情, SHOP_ITEM_CATEGORY_BUBBLE(4):聊天泡泡, SHOP_ITEM_CATEGORY_CONSUMPTION_PRIZE(5):认证消费奖品, SHOP_ITEM_CATEGORY_PRIZE(6):普通游戏发奖, 
@property(nonatomic, assign) int category;
//商品id 
@property(nonatomic, assign) int id_;
//关联的游戏id 
@property(nonatomic, assign) int gameid;
//商品内部编号,如泡泡01512007 
@property(nonatomic, retain) NSString* no;
//商品名 
@property(nonatomic, retain) NSString* title;
//商品小图标 
@property(nonatomic, retain) NSString* icon;
//商品大图 
@property(nonatomic, retain) NSString* image;
//消耗财富值 
@property(nonatomic, assign) int wealth;
//总数，-1 表示没上限 
@property(nonatomic, assign) int totalcount;
//剩余，-1 表示没上限 
@property(nonatomic, assign) int remains;
//商品描述 
@property(nonatomic, retain) NSString* content;
//是否已购买，0 未购买，1 已购买 
@property(nonatomic, assign) int bought;
//是否免费，0 收费，1 免费 
@property(nonatomic, assign) int isfree;
//折扣信息，默认为100表示原价，8.5折对应的数值为85 
@property(nonatomic, assign) int discount;
//折扣后的价格 
@property(nonatomic, assign) int discountwealth;
//是否新品，0 老商品 1 新品 
@property(nonatomic, assign) int isnew;
//上架时间 
@property(nonatomic, retain) NSString* starttime;
//结束时间(下架时间)，-1 表没有时间限制 
@property(nonatomic, retain) NSString* endtime;
//商品有效时间, -1 表没有时间限制 
@property(nonatomic, retain) NSString* validtime;
//剩余有效时间， 单位秒，0表示已经没有剩余时间. 
@property(nonatomic, assign) int lifetime;
//json编码的SHOP_ITEM_ANNOTATION_XXX, XXX包括GIFT、GAME_GIFT、SMILEY、BUBBLE 
@property(nonatomic, retain) NSString* annotation;
//用户等级 
@property(nonatomic, assign) int user_level;
//已有多少用户购买/领取 
@property(nonatomic, assign) int soldcount;


- (void)parse:(NSObject*)obj;
@end;


//特卖商品特有的信息
@interface ShopItemAnnotationGift : NSObject
//商品相应的RMB价值 
@property(nonatomic, retain) NSString* price;
//使用说明 
@property(nonatomic, retain) NSString* usage;


- (void)parse:(NSObject*)obj;
@end;


//泡泡商品特有的信息
@interface ShopItemAnnotationBubble : NSObject
//泡泡的编码规格，对应于以前的messagestyles的file字段，如：01512007_4a3f30_160x130_x78y68 
@property(nonatomic, retain) NSString* spec;


- (void)parse:(NSObject*)obj;
@end;


//表情商品特有的信息
@interface ShopItemAnnotationSmiley : NSObject
//表情URL 
@property(nonatomic, retain) NSMutableArray* smileys; //NSString*


- (void)parse:(NSObject*)obj;
@end;


//用户拥有的商品信息
@interface ShopUserItem : NSObject
//用户的商品id 
@property(nonatomic, assign) int id_;
// SHOP_ITEM_CATEGORY_GAME_GIFT(1):游戏礼包, SHOP_ITEM_CATEGORY_GITF(2):普通商品, SHOP_ITEM_CATEGORY_SMILEY(3):表情, SHOP_ITEM_CATEGORY_BUBBLE(4):聊天泡泡, SHOP_ITEM_CATEGORY_CONSUMPTION_PRIZE(5):认证消费奖品, SHOP_ITEM_CATEGORY_PRIZE(6):普通游戏发奖, 
@property(nonatomic, assign) int category;
//商品id 
@property(nonatomic, assign) int itemid;
//商品名 
@property(nonatomic, retain) NSString* title;
//商品小图标 
@property(nonatomic, retain) NSString* icon;
//什么时候获取到的 
@property(nonatomic, retain) NSString* createdtime;
//商品有效时间, -1 表没有时间限制 
@property(nonatomic, retain) NSString* validtime;
//有时表商品是别人送的 
@property(nonatomic, readonly) Avatar* sender;
//激活码, GAME_GIFT & GITF有 
@property(nonatomic, retain) NSString* code;
// 
@property(nonatomic, assign) int wealth;
//商品内部编号 
@property(nonatomic, retain) NSString* no;
//泡泡的编码规格 
@property(nonatomic, retain) NSString* spec;


- (void)parse:(NSObject*)obj;
@end;


//
@interface ShopItemAdmin : NSObject
//分类id 
@property(nonatomic, assign) int category;
//游戏id 
@property(nonatomic, assign) int gameid;
//标题 
@property(nonatomic, retain) NSString* title;
//序号 
@property(nonatomic, retain) NSString* no;
//内容 
@property(nonatomic, retain) NSString* content;
//大图 
@property(nonatomic, retain) NSString* image;
//小图 
@property(nonatomic, retain) NSString* icon;
//开始时间 
@property(nonatomic, retain) NSString* starttime;
//结束时间 
@property(nonatomic, retain) NSString* endtime;
//有效期 
@property(nonatomic, retain) NSString* validtime;
//财富值 
@property(nonatomic, assign) int wealth;
//价格 
@property(nonatomic, retain) NSString* price;
//来源 
@property(nonatomic, retain) NSString* source;
//发布商 
@property(nonatomic, retain) NSString* publisher;
//用法 
@property(nonatomic, retain) NSString* usage;
//用户等级 
@property(nonatomic, assign) int user_level;
//群组等级 
@property(nonatomic, assign) int group_level;
//附加信息 
@property(nonatomic, retain) NSString* annotation;
//排序 
@property(nonatomic, assign) int orderno;
//打折信息, 默认100 
@property(nonatomic, assign) int discount;


- (void)parse:(NSObject*)obj;
@end;


//
@interface ShopItemAdminUpdate : NSObject
//当前记录id 
@property(nonatomic, assign) int id_;
//分类id 
@property(nonatomic, assign) int category;
//游戏id 
@property(nonatomic, assign) int gameid;
//标题 
@property(nonatomic, retain) NSString* title;
//序号 
@property(nonatomic, retain) NSString* no;
//内容 
@property(nonatomic, retain) NSString* content;
//大图 
@property(nonatomic, retain) NSString* image;
//小图 
@property(nonatomic, retain) NSString* icon;
//开始时间 
@property(nonatomic, retain) NSString* starttime;
//结束时间 
@property(nonatomic, retain) NSString* endtime;
//有效期 
@property(nonatomic, retain) NSString* validtime;
//财富值 
@property(nonatomic, assign) int wealth;
//价格 
@property(nonatomic, retain) NSString* price;
//来源 
@property(nonatomic, retain) NSString* source;
//发布商 
@property(nonatomic, retain) NSString* publisher;
//用法 
@property(nonatomic, retain) NSString* usage;
//用户等级 
@property(nonatomic, assign) int user_level;
//群组等级 
@property(nonatomic, assign) int group_level;
//附加信息 
@property(nonatomic, retain) NSString* annotation;
//排序 
@property(nonatomic, assign) int orderno;
//打折信息, 默认100 
@property(nonatomic, assign) int discount;


- (void)parse:(NSObject*)obj;
@end;


//
@interface UserActionParamsItem : NSObject
//参数key 
@property(nonatomic, retain) NSString* k;
//参数value 
@property(nonatomic, retain) NSString* v;


- (void)parse:(NSObject*)obj;
@end;

//
@interface UserAction : NSObject
//action见ACTION_xxx相关的常量定义 
@property(nonatomic, retain) NSString* action;
// 
@property(nonatomic, retain) NSMutableArray* params; //UserActionParamsItem


- (void)parse:(NSObject*)obj;
@end;


//
@interface GameTaxonomy : NSObject
// 
@property(nonatomic, assign) int id_;
//创建用户 
@property(nonatomic, readonly) Avatar* user;
// 
@property(nonatomic, assign) int gameid;
// 
@property(nonatomic, retain) NSString* gamename;
// 
@property(nonatomic, retain) NSString* gameboardresid;
//消费点名称 
@property(nonatomic, retain) NSString* term;
//板块样式 BOARD_STYLE_TAXONOMY(1):消费点风格, BOARD_STYLE_FORUM(2):自由讨论区风格, 
@property(nonatomic, assign) int boardstyle;
//消费点介绍 
@property(nonatomic, retain) NSString* description;
//消费点自定义icon 
@property(nonatomic, retain) NSString* icon;
//消费点货币单位小图标 
@property(nonatomic, retain) NSString* cashicon;
//消费点价格 
@property(nonatomic, retain) NSString* price;
//货币 
@property(nonatomic, retain) NSString* currency;
//话题、讨论数 
@property(nonatomic, assign) int countcontent;
//态度数 
@property(nonatomic, assign) int countopinion;
//最近更新时间 
@property(nonatomic, assign) int updatetime;


- (void)parse:(NSObject*)obj;
@end;


//
@interface GameTaxonomyOpinion : NSObject
// 
@property(nonatomic, assign) int id_;
//快速观点 
@property(nonatomic, retain) NSString* opinion;
//用户响应此观点的次数 
@property(nonatomic, assign) int count;
//是否同意此观点 
@property(nonatomic, assign) int isagree;
//类css的RGB值，可用于定义颜色 
@property(nonatomic, retain) NSString* color;


- (void)parse:(NSObject*)obj;
@end;


//
@interface GameTaxonomyDetailPoll : NSObject
//投票ID 
@property(nonatomic, assign) int id_;
//资源ID 
@property(nonatomic, retain) NSString* resid;
//投票标题 
@property(nonatomic, retain) NSString* title;
//结束时间 
@property(nonatomic, retain) NSString* endtime;
//创建时间 
@property(nonatomic, retain) NSString* createdtime;
//参与人数 
@property(nonatomic, assign) int votecount;
//是否已投票 0:否 1:是 
@property(nonatomic, assign) int hasjoin;
//图片 
@property(nonatomic, retain) NSMutableArray* imgs; //NSString*
//帖子ID 
@property(nonatomic, assign) int postid;
//是否多项选择 0:否 1:是 
@property(nonatomic, assign) int multi;
//创建用户 
@property(nonatomic, readonly) Avatar* user;
// 
@property(nonatomic, retain) NSMutableArray* options; //PollOption
//参与总人数 
@property(nonatomic, assign) int opinioncount;


- (void)parse:(NSObject*)obj;
@end;

//
@interface GameTaxonomyDetail : GameTaxonomy
//消费点背景图 
@property(nonatomic, retain) NSString* bgicon;
// 
@property(nonatomic, retain) NSMutableArray* opinions; //GameTaxonomyOpinion
// 
@property(nonatomic, readonly) GameTaxonomyDetailPoll* poll;


- (void)parse:(NSObject*)obj;
@end;


//
@interface Template : NSObject
//模版id 
@property(nonatomic, assign) int id_;
//解析引擎版本号 
@property(nonatomic, retain) NSString* engineversion;
//版本号 
@property(nonatomic, retain) NSString* version;
//模版的类型，比如是用户模版，还是发别模版，还是针对某个taxonomy下的模版 
@property(nonatomic, retain) NSString* templatetype;
//游戏id 
@property(nonatomic, assign) int gameid;


- (void)parse:(NSObject*)obj;
@end;


//
@interface TemplateUserdata : Template
//用户提交的模板数据 
@property(nonatomic, retain) NSString* templatedata;


- (void)parse:(NSObject*)obj;
@end;


//
@interface TemplateDetail : Template
//模版布局数据 
@property(nonatomic, retain) NSString* layouts;
//创建时间 
@property(nonatomic, retain) NSString* createdtime;
//更新时间 
@property(nonatomic, retain) NSString* updatedtime;


- (void)parse:(NSObject*)obj;
@end;


//
@interface GameUchomeCurrencyItem : NSObject
//货币icon url地址 
@property(nonatomic, retain) NSString* icon;
//货币金额 
@property(nonatomic, assign) int currency;


- (void)parse:(NSObject*)obj;
@end;

//
@interface GameUchome : Game
//是否我也在玩, 1:是 0:否 
@property(nonatomic, assign) int match;
//用户在该游戏的评论数 
@property(nonatomic, assign) int countcomments;
//用户在该游戏下的发帖数 
@property(nonatomic, assign) int countposts;
//认证的总金额, 为0的时候不显示 
@property(nonatomic, assign) int countconsumption;
// 
@property(nonatomic, retain) NSMutableArray* currency; //GameUchomeCurrencyItem
//模板layout的基础数据，不包含详细layout数据, 详细layout需要通过template/getitem接口返回 
@property(nonatomic, retain) NSMutableArray* templates; //TemplateUserdata


- (void)parse:(NSObject*)obj;
@end;


//
@interface HomeNews : NSObject
// 
@property(nonatomic, readonly) Content* post;
// 
@property(nonatomic, readonly) Avatar* sender;
// 
@property(nonatomic, assign) int id_;
//帖子的resid 
@property(nonatomic, retain) NSString* resid;
//游戏id 
@property(nonatomic, assign) int gameid;
//游戏名字 
@property(nonatomic, retain) NSString* gamename;
//消费点名字 
@property(nonatomic, retain) NSString* taxonomyname;
//标题 
@property(nonatomic, retain) NSString* title;
//多少人觉得有用 
@property(nonatomic, assign) int viewcount;
//图片地址 
@property(nonatomic, retain) NSString* imgurl;
//更新时间 
@property(nonatomic, retain) NSString* updatedtime;


- (void)parse:(NSObject*)obj;
@end;


//
@interface UserMsginbox : NSObject
//这条用户消息的id 
@property(nonatomic, assign) int id_;
// 
@property(nonatomic, readonly) Avatar* sender;
// USER_MSGINBOX_TYPE_TEXT(1):文字类型, USER_MSGINBOX_TYPE_LIKE(2):用户赞的类型, 
@property(nonatomic, assign) int type;
//评论的详细内容 
@property(nonatomic, retain) NSString* content;
//主题的摘要，没有图片的时候显示 
@property(nonatomic, retain) NSString* postsummary;
//帖子的首图 
@property(nonatomic, retain) NSString* postimage;
//帖子的跳转链接 
@property(nonatomic, retain) NSString* postappurl;
// 
@property(nonatomic, retain) NSString* createdtime;
// 
@property(nonatomic, assign) int updatedtime;


- (void)parse:(NSObject*)obj;
@end;


//
@interface PostConsumptionContent : PostContent
// 
@property(nonatomic, readonly) Game* game;


- (void)parse:(NSObject*)obj;
@end;


//
@interface ConsumptionXp : NSObject
//当前认证的总金额 
@property(nonatomic, assign) int currency;
//当前等级内的金额 
@property(nonatomic, assign) int currentcurrency;
//当前等级起点金额 
@property(nonatomic, assign) int currentxp;
//当前等级名字 
@property(nonatomic, retain) NSString* currentname;
//下一级起点金额 
@property(nonatomic, assign) int nextxp;
//下一级等级名字 
@property(nonatomic, retain) NSString* nextname;
//当前差值 
@property(nonatomic, assign) int diff;
//当前等级 
@property(nonatomic, assign) int level;


- (void)parse:(NSObject*)obj;
@end;


//群组用户加入
@interface GroupUserJoinedMsg : NSObject
//加入群组的用户 
@property(nonatomic, readonly) Avatar* joineduser;


- (void)parse:(NSObject*)obj;
@end;


//群组邀请好友消息体
@interface GroupInviteUsersMsg : NSObject
//邀请者 
@property(nonatomic, readonly) Avatar* inviter;
//被邀请者用户 
@property(nonatomic, retain) NSMutableArray* invitees; //Avatar


- (void)parse:(NSObject*)obj;
@end;


//群组踢人消息体
@interface GroupBanUserMsg : NSObject
//踢人的用户 
@property(nonatomic, readonly) Avatar* banedbyuser;
//被踢的用户 
@property(nonatomic, readonly) Avatar* baneduser;


- (void)parse:(NSObject*)obj;
@end;


//群组用户主动退出消息体
@interface GroupUserQuitMsg : NSObject
//主动退出用户 
@property(nonatomic, readonly) Avatar* quituser;


- (void)parse:(NSObject*)obj;
@end;


//帖子评论更新消息体
@interface PostNewCommentMsg : NSObject
//帖子标题 
@property(nonatomic, retain) NSString* title;
//帖子resid 
@property(nonatomic, retain) NSString* postresid;
//板块id 
@property(nonatomic, assign) int boardid;
//评论的resid 
@property(nonatomic, retain) NSString* commentresid;
//评论简要 
@property(nonatomic, retain) NSString* comment;
// 
@property(nonatomic, readonly) Avatar* commentuser;
//文章作者 
@property(nonatomic, readonly) Avatar* postuser;
//评论时间 
@property(nonatomic, assign) int createtime;
//被at的用户id，被at的用户也会收到评论通知 
@property(nonatomic, assign) int atid;


- (void)parse:(NSObject*)obj;
@end;


//帖子状态更新消息体，包括POST_GEM，POST_TOP，POST_DELETE等
@interface PostNewStatusMsg : NSObject
//帖子标题 
@property(nonatomic, retain) NSString* title;
//板块id 
@property(nonatomic, assign) int boardid;
//帖子resid 
@property(nonatomic, retain) NSString* postresid;


- (void)parse:(NSObject*)obj;
@end;


//好友申请
@interface FriendInviteMsg : NSObject
//邀请者 
@property(nonatomic, readonly) Avatar* inviter;
//邀请动作的resid 
@property(nonatomic, retain) NSString* resid;
// INVITE_STATUS_INIT(0):未处理, INVITE_STATUS_AGREED(1):已通过, INVITE_STATUS_DECLINED(2):已拒绝, 
@property(nonatomic, assign) int status;


- (void)parse:(NSObject*)obj;
@end;


//通用的只包含消息相关用户的消息，包括：GROUP_AGREE、GROUP_MONITOR_ELECTED, GROUP_ADMIN_ELECTED_MSG、GROUP_USER_BE_THE_BOSS等
@interface GeneralUserMsg : NSObject
//消息相关的用户信息，通常是和接受者有互动的用户 
@property(nonatomic, readonly) Avatar* user;


- (void)parse:(NSObject*)obj;
@end;


//通用的只包含threadavatar的消息，包括：FRIEND_AGREE，FRIEND_DELETE，FRIEND_DECLINE等
@interface GeneralThreadAvatarMsg : NSObject
//消息相关的threadavatar信息，通常是和接受者有互动的用户的threadavatar，thread可用于直接会话或更新通信录 
@property(nonatomic, readonly) ThreadAvatar* threadavatar;


- (void)parse:(NSObject*)obj;
@end;


//群组申请
@interface GroupApplyMsg : NSObject
//申请者 
@property(nonatomic, readonly) Avatar* applier;
//邀请动作的resid 
@property(nonatomic, retain) NSString* resid;
// 
@property(nonatomic, readonly) Group* group;
// INVITE_STATUS_INIT(0):未处理, INVITE_STATUS_AGREED(1):已通过, INVITE_STATUS_DECLINED(2):已拒绝, 
@property(nonatomic, assign) int status;


- (void)parse:(NSObject*)obj;
@end;


//通用的只包含群组的消息，包括：GROUP_UPGRADE_TO_CLASS、GROUP_UPDATE_NAME、GROUP_UPDATE_AVATAR、GROUP_UPDATE_INTRO等
@interface GeneralGroupMsg : NSObject
//消息相关的群组信息 
@property(nonatomic, readonly) Group* group;


- (void)parse:(NSObject*)obj;
@end;


//
@interface GroupInfoCmdMsgGroup : Group
//班长或组长 
@property(nonatomic, retain) NSString* master;
//大魔王 
@property(nonatomic, retain) NSString* boss;
// 
@property(nonatomic, assign) int allownotification;


- (void)parse:(NSObject*)obj;
@end;

//群组信息指令消息，不显示，仅用于更新群组的信息
@interface GroupInfoCmdMsg : NSObject
// 
@property(nonatomic, readonly) GroupInfoCmdMsgGroup* group;


- (void)parse:(NSObject*)obj;
@end;


//json格式的纯文案消息
@interface TitleMsg : NSObject
//消息内部显示文案 
@property(nonatomic, retain) NSString* title;


- (void)parse:(NSObject*)obj;
@end;


//经验值变动信息
@interface XpChangedMsg : NSObject
//当前级别 
@property(nonatomic, assign) int level;
//当前级别的经验值 
@property(nonatomic, assign) int exp;
//当前级别的经验上限 
@property(nonatomic, assign) int maxexp;
//原级别 
@property(nonatomic, assign) int oldlevel;
//原级别经验值 
@property(nonatomic, assign) int oldexp;
//原级别的经验上限 
@property(nonatomic, assign) int oldmaxexp;
//变化的经验值 
@property(nonatomic, assign) int xp;
//触发经验值变化的动作 
@property(nonatomic, retain) NSString* action;
//是否弹窗展示 
@property(nonatomic, assign) int alert;


- (void)parse:(NSObject*)obj;
@end;


//badge指令消息，用于显示红点或数字提示
@interface BadgeInfoCmdMsg : NSObject
// BADGE_TYPE_PHOTO_FEED(1):用户照片新feed计数, BADGE_TYPE_INTERVIEW_INVITE(2):被邀请回答问题badge通知, BADGE_TYPE_TIMELINE(3):动态未读计数, BADGE_TYPE_MSGINBOX(4):@我的消息未读计数, BADGE_TYPE_NEWFOLLOWER(5):新粉丝未读计数, BADGE_TYPE_NEWFRIEND(6):新好友计数, 
@property(nonatomic, assign) int type;
//计数更新的时间 
@property(nonatomic, assign) int timestamp;
//计数 
@property(nonatomic, assign) int count;
//计数关联的消息会话thread，若有可用于客户端自动拉取对应的thread的内容，暂无 
@property(nonatomic, retain) NSString* thread;


- (void)parse:(NSObject*)obj;
@end;


//
@interface FriendListFriendsItem : ThreadAvatar
//好友双向关系 
@property(nonatomic, assign) int isfriend;


- (void)parse:(NSObject*)obj;
@end;

//
@interface FriendList : NSObject
//当前页数 
@property(nonatomic, assign) int page;
//当前页条数 
@property(nonatomic, assign) int count;
//查询序列，翻页都是基于同一个序列号 
@property(nonatomic, assign) long seq;
//是否是最后一页。0：不是最后一页  1：已经到了最后一页 
@property(nonatomic, assign) int lastpage;
// 
@property(nonatomic, retain) NSMutableArray* friends; //FriendListFriendsItem


- (void)parse:(NSObject*)obj;
@end;


//
@interface PubList : ThreadAvatar
// 
@property(nonatomic, assign) int subscribercount;
// 
@property(nonatomic, retain) NSString* desc;
// 
@property(nonatomic, assign) int isadded;


- (void)parse:(NSObject*)obj;
@end;


//
@interface GameListItem : NSObject
// 
@property(nonatomic, assign) int id_;
// 
@property(nonatomic, retain) NSString* name;
// 
@property(nonatomic, retain) NSString* icon;
// GAME_ITEM_LEVEL_HOT(1):热点游戏, GAME_ITEM_LEVEL_COMMON(2):普通游戏, GAME_ITEM_LEVEL_NOTPOPULAR(3):冷门游戏, 
@property(nonatomic, assign) int level;
// 
@property(nonatomic, retain) NSString* urlschema;
// 
@property(nonatomic, retain) NSString* packagename;
// GAME_ITEM_FLAG_HOT(1):, GAME_ITEM_FLAG_ACT(2):, GAME_ITEM_FLAG_GIFT(4):, GAME_ITEM_FLAG_CORP(8):, GAME_ITEM_FLAG_DOC(16):, GAME_ITEM_FLAG_OPEN(32):是否开放, GAME_ITEM_FLAG_RECOMMENDED(64):是否推荐, 
@property(nonatomic, assign) int flag;
// 
@property(nonatomic, assign) int countplayer;
// 
@property(nonatomic, assign) int countposts;
// 
@property(nonatomic, assign) int hasclass;


- (void)parse:(NSObject*)obj;
@end;


//
@interface PhotoItem : NSObject
// 
@property(nonatomic, assign) int id_;
// 
@property(nonatomic, retain) NSString* photo;
// 
@property(nonatomic, retain) NSString* voice;
// 
@property(nonatomic, assign) int unread;
// 
@property(nonatomic, assign) int countlikes;
// 
@property(nonatomic, assign) int countcomments;
// 
@property(nonatomic, assign) int isliked;
// 
@property(nonatomic, retain) NSString* createdtime;


- (void)parse:(NSObject*)obj;
@end;


//
@interface PhotoCommentItem : NSObject
// 
@property(nonatomic, assign) int id_;
// 
@property(nonatomic, retain) NSString* comment;
// 
@property(nonatomic, retain) NSString* voice;
// 
@property(nonatomic, assign) int floor;
// 
@property(nonatomic, readonly) Avatar* sender;
// 
@property(nonatomic, retain) NSString* createdtime;


- (void)parse:(NSObject*)obj;
@end;


//应用内转发链接
@interface BusinessLinkApp : NSObject
//标题 
@property(nonatomic, retain) NSString* title;
//摘要 
@property(nonatomic, retain) NSString* summary;
//链接小图，可能是链接发起者的用户头像，也可能是文章中提取出来的图片 
@property(nonatomic, retain) NSString* avatar;
//创建时间 
@property(nonatomic, assign) int createdtime;
//图片url地址 
@property(nonatomic, retain) NSString* img;
//语音url地址 
@property(nonatomic, retain) NSString* voice;
//链接原地址，goto类型的app url，如帖子的url app://goto.post?uid=1 
@property(nonatomic, retain) NSString* linkurl;
//链接来源的app url地址，goto类型的app url，如板块的url app://goto.board?uid=1&data=... 
@property(nonatomic, retain) NSString* fromurl;


- (void)parse:(NSObject*)obj;
@end;


//
@interface BusinessPubAppArticlesItem : NSObject
// 
@property(nonatomic, retain) NSString* resid;
// 
@property(nonatomic, retain) NSString* title;
// 
@property(nonatomic, retain) NSString* content;
// 
@property(nonatomic, retain) NSString* image_url;
// 
@property(nonatomic, retain) NSString* url;


- (void)parse:(NSObject*)obj;
@end;

//
@interface BusinessPubApp : NSObject
// 
@property(nonatomic, assign) int article_count;
// 
@property(nonatomic, retain) NSMutableArray* articles; //BusinessPubAppArticlesItem


- (void)parse:(NSObject*)obj;
@end;


//
@interface TargetInterviewData : NSObject
//游戏id 
@property(nonatomic, assign) int gameid;
//用户id 
@property(nonatomic, assign) int accountid;


- (void)parse:(NSObject*)obj;
@end;

