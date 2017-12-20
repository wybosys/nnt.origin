#define API_VERSION                     1  // 
#define ACTION_QKX_ROLL                 @"qkx_roll"  // 穷开心摇一摇
#define ACTION_QKX_SAVE_RECORD          @"qkx_save"  // 穷开心保存图
#define BIG_CLASS_GAME_ID               10000000  // 
#define BUSINESS_IMG                    @"file.img"  // 图片，仅适用于srv的url
#define BUSINESS_VOICE                  @"file.voice"  // 语音，仅适用于srv的url
#define BUSINESS_LINK                   @"link"  // 通用的链接
#define BUSINESS_POLL                   @"poll"  // 投票业务
#define BUSINESS_GOTO                   @"goto"  // 可跳转的链接，支持子业务，如goto.www, goto.webview，goto app的data部分需包含一个title信息，默认的title是uid
#define BUSINESS_WWW                    @"www"  // 通过外部浏览器打开的链接
#define BUSINESS_WEBVIEW                @"webview"  // 通过内部webview打开的链接
#define BUSINESS_GROUP                  @"group"  // 群组业务
#define BUSINESS_BOARD                  @"board"  // 板块业务
#define BUSINESS_POST                   @"post"  // 帖子业务
#define BUSINESS_SIGN                   @"sign"  // 签名卡业务
#define BUSINESS_PUB                    @"pub"  // 公共账号卡片
#define TARGET_NONE                     @"none"  // 只显示来自，不跳转, uid=null title=title, data=null
#define TARGET_WWW                      @"www"  // 外部浏览器, uid=null, title=title(option), data=string({"url":"www.game.com"})
#define TARGET_WEBVIEW                  @"webview"  // 内部浏览器, uid=null, title=title(option), data=string({"share":1,"url":"www.game.com"}), share=1, 表示显示分享按钮，具体参见：WEBVIEW_TYPE
#define TARGET_BOARD                    @"board"  // 游戏板块, uid=gameid, title=gamename
#define TARGET_BOARD_SPEND              @"board_spend"  // 曝消费板块消费点里诶包页面, uid=gameid, title=gamename
#define TARGET_BOARD_SPEND_TAXONOMY     @"board_spend_taxonomy"  // 曝消费版块的消费点页面, uid=taxonomyid, title=taxonomyname
#define TARGET_BOARD_HELP_VIEW          @"board_help_view"  // 求帮忙板块, uid=resid, title=标题, data=null
#define TARGET_BOARD_SHOW_VIEW          @"board_show_view"  // 游戏秀板块, uid=resid, title=标题, data=null
#define TARGET_BOARD_SPEND_VIEW         @"board_spend_view"  // 曝消费板块帖子详细页面, uid=resid, title=标题, data=null
#define TARGET_ACT                      @"act"  // 活动中心
#define TARGET_ACT_POLL                 @"act_poll"  // 投票活动 data=string({'id'=>123,'type'=>1,'accountid'=>123,'joins'=>0,'title'=>'abc','image'=>'abc.png','desc'=>''})
#define TARGET_ACT_COMPLAIN             @"act_complain"  // 吐槽活动 同投票
#define TARGET_ACT_SBQ                  @"act_sbq"  // 伤不起活动 同投票
#define TARGET_PUB_HOME                 @"pubhome"  // 公众账号主页, uid=pubid, title=标题, data={"thread":""}
#define TARGET_PUB_ARTICLE              @"pubarticle"  // 公众帐号详细页面, uid=resid, title=标题, data={"url":""}
#define TARGET_PRIVILEGE                @"privilege"  // 特权中心， uid=null, title=null, data=null
#define TARGET_SHOP_GIFT                @"shopitem"  // 商品的详细页面， uid=itemid, title=itemname, data={"category":""}
#define TARGET_SHOP                     @"shop"  // 商城， uid=0, title=商城, data=null
#define TARGET_INTERVIEW                @"interview"  // 采访问答， uid=questionid, title=标题, data=string({"gameid"=>123, "accounitd"=> 123456})
#define TARGET_GAMECARD                 @"gamecard"  // 游戏名片的跳转， uid=null, title=标题, data=string({"accountid"=>123, gameid=>123})
#define TEMPLATE_REFTYPE_POST           @"posts"  // 模版引用类型： post表
#define TEMPLATE_REFTYPE_USERTEMPLATE   @"usertemplatedatas"  // 模版引用类型： usertemplatedatas表
#define TEMPLATE_TYPE_POST              @"post"  // 发帖模板
#define TEMPLATE_TYPE_USERGAME          @"usergame"  // 用户游戏模版

#define MESSAGE_SUBTYPE_CHAT            1  // 消息子类型: 聊天消息
#define MESSAGE_SUBTYPE_TITLE           1001  // 消息子类型: 只带消息文案title的json消息
#define MESSAGE_SUBTYPE_XP_CHANGED_CMD  2001  // 消息子类型: 经验值变动
#define MESSAGE_SUBTYPE_GROUP_INFO_CMD  2002  // 消息子类型: 群组信息指令消息，不显示，仅用于更新群组的信息
#define MESSAGE_SUBTYPE_BADGE_INFO_CMD  2003  // 消息子类型: 计数badge信息消息，用于显示红点或数字提示，如照片feed
#define MESSAGE_SUBTYPE_GROUP_SYS_INVITE_USERS  8001  // 消息子类型: 邀请用户加入群组
#define MESSAGE_SUBTYPE_GROUP_SYS_BAN_USER  8002  // 消息子类型: 删除群组用户
#define MESSAGE_SUBTYPE_GROUP_SYS_USER_QUIT  8003  // 消息子类型: 群组用户主动退群
#define MESSAGE_SUBTYPE_GROUP_SYS_USER_JOINED  8004  // 消息子类型: 群组用户加入
#define MESSAGE_SUBTYPE_GROUP_APPLY     8005  // 消息子类型: 加群申请
#define MESSAGE_SUBTYPE_GROUP_AGREE     8006  // 消息子类型: 同意加群申请
#define MESSAGE_SUBTYPE_GROUP_DECLINE   8007  // 消息子类型: 拒绝加群申请
#define MESSAGE_SUBTYPE_GROUP_MONITOR_ELECTED  8008  // 消息子类型: 用户成为班长
#define MESSAGE_SUBTYPE_GROUP_ADMIN_ELECTED  8009  // 消息子类型: 用户成为班委
#define MESSAGE_SUBTYPE_GROUP_UPGRADE_TO_CLASS  8010  // 消息子类型: 预备班升级成正式班
#define MESSAGE_SUBTYPE_GROUP_UPDATE_NAME  8011  // 消息子类型: 修改群组名
#define MESSAGE_SUBTYPE_GROUP_UPDATE_AVATAR  8012  // 消息子类型: 修改群组头像
#define MESSAGE_SUBTYPE_GROUP_UPDATE_INTRO  8013  // 消息子类型: 修改群组公告
#define MESSAGE_SUBTYPE_GROUP_USER_BE_THE_BOSS  8014  // 消息子类型: 用户成为大魔王
#define MESSAGE_SUBTYPE_GROUP_SUBSCRIBE_GAME  8015  // 消息子类型: 关注游戏, 目前为普通文本消息，无需特殊处理，本subtype保留
#define MESSAGE_SUBTYPE_POST_NEW_COMMENT  8101  // 消息子类型: 帖子新评论
#define MESSAGE_SUBTYPE_POST_GEM        8102  // 消息子类型: 帖子被加精, 目前为普通文本消息，无需特殊处理，本subtype保留
#define MESSAGE_SUBTYPE_POST_TOP        8103  // 消息子类型: 帖子被置顶, 目前为普通文本消息，无需特殊处理，本subtype保留
#define MESSAGE_SUBTYPE_POST_DELETE     8104  // 消息子类型: 帖子被删除, 目前为普通文本消息，无需特殊处理，本subtype保留
#define MESSAGE_SUBTYPE_POST_HOT        8107  // 消息子类型: 帖子被推荐为热贴，目前为普通文本消息，无需特殊处理，本subtype保留
#define MESSAGE_SUBTYPE_POST_FREE       8108  // 消息子类型: 帖子被推荐为免单，目前为普通文本消息，无需特殊处理，本subtype保留
#define MESSAGE_SUBTYPE_POST_COST       8109  // 消息子类型: 帖子被推荐为花钱那些事，目前为普通文本消息，无需特殊处理，本subtype保留
#define MESSAGE_SUBTYPE_INVITE_CODE_BE_FRIEND_INVITER  8105  // 消息子类型: 用户注册使用邀请码后邀请者收到的消息, 目前为普通文本消息，无需特殊处理，本subtype保留
#define MESSAGE_SUBTYPE_INVITE_CODE_BE_FRIEND_INVITEE  8106  // 消息子类型: 用户注册使用邀请码后被邀请者收到的消息, 目前为普通文本消息，无需特殊处理，本subtype保留
#define MESSAGE_SUBTYPE_FRIEND_INVITE   8201  // 消息子类型: 好友申请
#define MESSAGE_SUBTYPE_FRIEND_AGREE    8202  // 消息子类型: 同意好友申请
#define MESSAGE_SUBTYPE_FRIEND_DECLINE  8203  // 消息子类型: 拒绝好友申请
#define MESSAGE_SUBTYPE_FRIEND_DELETE   8204  // 消息子类型: 删除好友
#define MESSAGE_SUBTYPE_GAMECARD_INVITE  8301  // 消息子类型: 游戏名片邀请
#define MESSAGE_SUBTYPE_ACT             9000  // 消息子类型: 活动类型，只用于服务器端，注意:客户端使用的contenttype是appurl，不是json

#define SYS_ACCOUNTS_SYS_MESSAGE_ACCOUNT  2  // : 系统消息账号，消息依托业务的thread，信息在主页不独立展示，如：用户退群
#define SYS_ACCOUNTS_SYS_CMD_ACCOUNT    3  // : 系统指令账号，专有的thread通道，信息在主页不独立展示，如：有版本更新、通信录有变化
#define SYS_ACCOUNTS_SYS_ANNOUNCE_PUBLISHER  4  // : 系统公告公共账号
#define SYS_ACCOUNTS_SYS_ACTIVITY_PUBLISHER  5  // : 活动公共账号
#define SYS_ACCOUNTS_SYS_POST_UPDATE_NOTIFY  6  // : 帖子更新通知账号
#define SYS_ACCOUNTS_SYS_SNS_UPDATE_NOTIFY  7  // : 好友关系更新通知账号
#define SYS_ACCOUNTS_SYS_HELPER         8  // : 帮主(游戏达人)消息通知账号
#define SYS_ACCOUNTS_SYS_EDITOR_ACCOUNT  60  // : 板块编辑的管理账号
#define SYS_ACCOUNTS_SYS_MAX_ACCOUNTID  100  // : 系统消息保留账号的最大值
#define SYS_ACCOUNTS_MAX_RESERVED_ACCOUNTID  1000  // : 保留账号的最大值, SYS_MAX_ACCOUNTID-SYS_MAX_ACCOUNTID之间的号有别于低于SYS_MAX_ACCOUNTID的特殊系统账号，除发送消息有特权外其它均当普通用户用的保留用账号
#define SYS_ACCOUNTS_SYS_SERVICES       201  // : 与玩家互动的助手号，目前用于客服和对新进群组的用户自动提问
#define SYS_ACCOUNTS_SYS_MAX_RESERVED_PUB_ACCOUNTID  300  // : 系统保留的公众账号的最大ID，在此ID范围内的公众账号不需要订阅，所有用户都可以收到推送

#define WEBVIEW_TYPE_SHARE              1  // : 

#define FEED_TIMELINE_TYPE_NONE         0  // : 
#define FEED_TIMELINE_TYPE_PUBLISHER    1  // : 公众帐号文章
#define FEED_TIMELINE_TYPE_POST_TAXONOMY  2  // : 曝消费里面的帖子
#define FEED_TIMELINE_TYPE_POST_USER    3  // : 用户动态里面发布的帖子
#define FEED_TIMELINE_TYPE_POST_COST    4  // : 花钱那些事
#define FEED_TIMELINE_TYPE_GAME_POST    5  // : 游戏热帖推荐, 以游戏的名字去推送
#define FEED_TIMELINE_TYPE_USER_SHARE   6  // : 用户分享
#define FEED_TIMELINE_TYPE_GAME_ACTIVITY  7  // : 游戏活动，本质是推送一个帖子，也是以游戏的名字去推送
#define FEED_TIMELINE_TYPE_GAME_GIFT    8  // : 游戏礼包的推送， 以游戏的名字去推送

#define USER_MSGINBOX_TYPE_TEXT         1  // : 文字类型
#define USER_MSGINBOX_TYPE_LIKE         2  // : 用户赞的类型

#define AUTOUPDATE_NONE                 0  // : 
#define AUTOUPDATE_NORMAL               1  // : 
#define AUTOUPDATE_FORCE                2  // : 

#define NOTIFY_TYPE_NONE                0  // : 
#define NOTIFY_TYPE_ATME                1  // : 
#define NOTIFY_TYPE_ALL                 2  // : 

#define AVATAR_TYPE_USER                1  // : 用户
#define AVATAR_TYPE_PUB                 2  // : 公众账号
#define AVATAR_TYPE_GROUP               3  // : 班级群组
#define AVATAR_TYPE_GAME                4  // : 游戏

#define POST_LIST_TYPE_NORMAL           0  // : 
#define POST_LIST_TYPE_NOCOMMENTED      1  // : 
#define POST_LIST_TYPE_GEM              2  // : 

#define BOARD_SHOW                      5  // : 
#define BOARD_HELP                      6  // : 
#define BOARD_SPEND                     7  // : 爆消费
#define BOARD_CONSUMPTION               8  // : 认证消费

#define BOARD_STYLE_TAXONOMY            1  // : 消费点风格
#define BOARD_STYLE_FORUM               2  // : 自由讨论区风格

#define GENDER_UNKONWN                  2  // : 未知
#define GENDER_MALE                     1  // : 男
#define GENDER_FEMALE                   0  // : 女

#define FILE_TYPE_IMAGE                 1  // : 图片
#define FILE_TYPE_VOICE                 2  // : 声音

#define FILE_UPLOAD_TYPE_NORMAL         0  // : 普通类型，不做特殊处理
#define FILE_UPLOAD_TYPE_VOICE          1  // : 声音
#define FILE_UPLOAD_TYPE_IMAGE_AVATAR   2  // : 头像
#define FILE_UPLOAD_TYPE_IMAGE_BOARD    3  // : 帖子相关的图片
#define FILE_UPLOAD_TYPE_IMAGE_BGIMG    4  // : 背景图片
#define FILE_UPLOAD_TYPE_IMAGE_MESSAGE  5  // : 消息中的图片
#define FILE_UPLOAD_TYPE_IMAGE_MAX      5  // : 最大的id

#define FRIEND_RELATION_STRANGER        0  // : 不是好友
#define FRIEND_RELATION_FRIEND          1  // : 是好友
#define FRIEND_RELATION_SELF            2  // : 本人

#define ONLINE_STATUS_ONLINE            1  // 是否在线: 在线
#define ONLINE_STATUS_OFFLINE           0  // 是否在线: 离线

#define MESSAGE_DIRECTION_OUT           1  // 消息方向: 发出消息
#define MESSAGE_DIRECTION_IN            0  // 消息方向: 收到消息

#define LOGCLICK_TYPE_REGISTRATION_TIME_START  16  // : 注册开始时间类型
#define LOGCLICK_TYPE_REGISTRATION_TIME_END  1  // : 注册结束时间类型
#define LOGCLICK_TYPE_COMPLETE_PROFILE_TIME_START  2  // : 修改资料开始
#define LOGCLICK_TYPE_COMPLETE_PROFILE_TIME_END  3  // : 修改资料结束
#define LOGCLICK_TYPE_CHANGED_PROFILE_TIMES  4  // : 修改过资料
#define LOGCLICK_TYPE_ENTER_FROM_SPLASH_TIMES  5  // : 从宣传页进入
#define LOGCLICK_TYPE_ENTER_FROM_GAMECHOOSEN_TIMES  6  // : 从第一次选择感兴趣的游戏进入
#define LOGCLICK_TYPE_ANNOUNCEMENT_LINK_CLICKS  7  // : 公告被点击次数
#define LOGCLICK_TYPE_ANNOUNCEMENT_KNOWBUTTON_CLICKS  8  // : “我知道”按钮点击次数
#define LOGCLICK_TYPE_HOMESLIDER_CLICKS  9  // : 首页轮播图的点击次数， json里面要额外带上id
#define LOGCLICK_TYPE_SEARCH_GAME_ONCLIENT_TIMES  10  // : 客户端游戏搜索次数
#define LOGCLICK_TYPE_SEARCH_GAME_ONSERVER_TIMES  11  // : 服务端游戏搜索次数
#define LOGCLICK_TYPE_APP_RUN_TIME_START  12  // : 程序运行开始时间
#define LOGCLICK_TYPE_APP_RUN_TIME_END  13  // : 程序运行结束时间
#define LOGCLICK_TYPE_APP_OPEN_FROM_DESKTOP_TIMES  14  // : 桌面打开app
#define LOGCLICK_TYPE_APP_OPEN_FROM_NOTIFYCENTER_TIMES  15  // : 通知中心打开app
#define LOGCLICK_TYPE_QUIT_ON_ANNOUNCEMENT_TIMES  100  // : 在公告界面退出程序
#define LOGCLICK_TYPE_QUIT_ON_HOME_TIMES  101  // : 首页退出
#define LOGCLICK_TYPE_QUIT_ON_RECOMMENDED_GAMES_TIMES  102  // : 推荐游戏退出
#define LOGCLICK_TYPE_QUIT_ON_FEED_TIMES  103  // : 动态页面退出
#define LOGCLICK_TYPE_QUIT_ON_MESSAGE_TIMES  104  // : 消息页退出
#define LOGCLICK_TYPE_QUIT_ON_MORE_TIMES  105  // : 更多页面退出
#define LOGCLICK_TYPE_QUIT_ON_GAMEVIEW_TIMES  106  // : 游戏板块首页退出
#define LOGCLICK_TYPE_QUIT_ON_TAXONOMYVIEW_TIMES  108  // : 消费点页面退出
#define LOGCLICK_TYPE_QUIT_ON_CONTENT_TIMES  109  // : 详细页退出
#define LOGCLICK_TYPE_QUIT_ON_TAXONOMY_PLAYERS_TIMES  110  // : 正在玩的小伙伴页面
#define LOGCLICK_TYPE_QUIT_ON_GROUPVIEW_TIMES  111  // : 查看我的班级页面
#define LOGCLICK_TYPE_QUIT_ON_FRIEND_FRINED_TIMES  112  // : 我的好友页面
#define LOGCLICK_TYPE_QUIT_ON_FRIEND_FOLLOWING_TIMES  113  // : 我的关注页面
#define LOGCLICK_TYPE_QUIT_ON_FRIEND_FOLLOWER_TIMES  114  // : 我的粉丝页面
#define LOGCLICK_TYPE_QUIT_ON_HOMECENTER_TIMES  115  // : 我的个人中心页面
#define LOGCLICK_TYPE_QUIT_ON_OHTERCENTER_TIMES  116  // : 他人中心页面
#define LOGCLICK_TYPE_QUIT_ON_SHOPHOME_TIMES  117  // : 商城首页
#define LOGCLICK_TYPE_QUIT_ON_ITEMHOME_TIMES  118  // : 礼包中心首页
#define LOGCLICK_TYPE_QUIT_ON_ITEMVIEW_TIMES  119  // : 礼包详细页面
#define LOGCLICK_TYPE_QUIT_ON_HOTITEM_TIMES  120  // : 热卖商品页面
#define LOGCLICK_TYPE_QUIT_ON_CHAT_TIMES  121  // : 私人聊天页面
#define LOGCLICK_TYPE_QUIT_ON_CHATGROUP_TIMES  122  // : 群组聊天页面

#define CONTENT_FLAG_LIKE               1  // 内容flag中各位段的定义: 
#define CONTENT_FLAG_GEM                2  // 内容flag中各位段的定义: 
#define CONTENT_FLAG_RECOGNISE          4  // 内容flag中各位段的定义: 
#define CONTENT_FLAG_TOP                8  // 内容flag中各位段的定义: 
#define CONTENT_FLAG_FAVORIT            16  // 内容flag中各位段的定义: 
#define CONTENT_FLAG_TRANSPARENT        32  // 内容flag中各位段的定义: 
#define CONTENT_FLAG_FORBID             64  // 内容flag中各位段的定义: 
#define CONTENT_FLAG_FREECHARGE         128  // 内容flag中各位段的定义: 

#define GROUP_JOIN_STATUS_FIRSTJOIN     0  // : 首次加入
#define GROUP_JOIN_STATUS_JOINEDCURRENTGAME  1  // : 本游戏加入了班
#define GROUP_JOIN_STATUS_JOINEDOTHERGAME  2  // : 加入了其他游戏的班

#define SEARCH_TARGET_USER              1  // : 
#define SEARCH_TARGET_GROUP             2  // : 
#define SEARCH_TARGET_PUB               3  // : 

#define VIP_TYPE_VIP0                   0  // vip类型: 不是vip
#define VIP_TYPE_VIP1                   1  // vip类型: 是vip1
#define VIP_TYPE_VIP2                   2  // vip类型: 是vip2

#define USER_KIND_NORMAL                0  // 用户类型: 普通用户
#define USER_KIND_HOST                  5  // 用户类型: 是版主用户

#define RELATIONSHIP_NO                 0  // 好友关系: 尚无关系
#define RELATIONSHIP_SELF               1  // 好友关系: 自己
#define RELATIONSHIP_FOLLOWING          2  // 好友关系: 已关注
#define RELATIONSHIP_FOLLOWED           3  // 好友关系: 被关注
#define RELATIONSHIP_FRIEND             4  // 好友关系: 好友
#define RELATIONSHIP_BLOCKED            9  // 好友关系: 黑名单用户

#define GROUP_TYPE_NORMAL               1  // 群组类型: 常规自建群组
#define GROUP_TYPE_TEMP                 2  // 群组类型: 游戏临时小组，班级的前身
#define GROUP_TYPE_CLASS                3  // 群组类型: 班级群组
#define GROUP_TYPE_CHANNEL              4  // 群组类型: 子频道

#define COMPLAIN_STATUS_CREATED         0  // 吐槽状态: 未解决
#define COMPLAIN_STATUS_PROCESSING      1  // 吐槽状态: 解决中
#define COMPLAIN_STATUS_RESOLVED        2  // 吐槽状态: 已解决
#define COMPLAIN_STATUS_UNRESOLVED      3  // 吐槽状态: 已结束(未解决)

#define THREAD_TYPE_PRIVATE             0  // thread会话类型: 私聊thread
#define THREAD_TYPE_PUB_SYS             110  // thread会话类型: 系统公共账号thread
#define THREAD_TYPE_PUB_PUB             120  // thread会话类型: 普通公共账号thread
#define THREAD_TYPE_GROUP_BASE          200  // thread会话类型: group的基值，仅用于根据groupType计算threadtype
#define THREAD_TYPE_GROUP_NORMAL        210  // thread会话类型: 常规自建群组thread
#define THREAD_TYPE_GROUP_TEMP          220  // thread会话类型: 游戏临时小组，班级的前身thread
#define THREAD_TYPE_GROUP_CLASS         230  // thread会话类型: 班级群组
#define THREAD_TYPE_GROUP_CHANNEL       240  // thread会话类型: 群组子频道
#define THREAD_TYPE_GAME                300  // thread会话类型: 游戏类型，目的是为了兼容动态里面用游戏名字来发动态

#define MESSAGE_TYPE_SYS                1  // 消息类型: 系统消息
#define MESSAGE_TYPE_GROUP              2  // 消息类型: 群组消息
#define MESSAGE_TYPE_PUBLIC             3  // 消息类型: 公共账号信息
#define MESSAGE_TYPE_PRIVATE            4  // 消息类型: 私信

#define MESSAGE_ALARM_TYPE_NORMAL       0  // 消息提醒类型: 不是指定受众(根据AU判定)时也展示文案，是否提醒根据设置项决定
#define MESSAGE_ALARM_TYPE_FORCE        1  // 消息提醒类型: 强制提醒，不管设置如何都展示和提醒
#define MESSAGE_ALARM_TYPE_DISPLAY      2  // 消息提醒类型: 不是指定受众(根据AU判定)时只展示文案
#define MESSAGE_ALARM_TYPE_PASSIVE      3  // 消息提醒类型: 不是指定受众(根据AU判定)时不提醒&不展示文案

#define MESSAGE_CONTENTTYPE_TEXT        1  // 消息内容类型: 单文本
#define MESSAGE_CONTENTTYPE_APP_URL     2  // 消息内容类型: 自定义URL
#define MESSAGE_CONTENTTYPE_IMG         3  // 消息内容类型: 图片
#define MESSAGE_CONTENTTYPE_VOICE       4  // 消息内容类型: 语音
#define MESSAGE_CONTENTTYPE_SMILEY      5  // 消息内容类型: 表情
#define MESSAGE_CONTENTTYPE_JSON        6  // 消息内容类型: JSON编码的数据
#define MESSAGE_CONTENTTYPE_HTML        7  // 消息内容类型: HTML代码

#define ACT_TYPE_POLL                   1  // 活动类型: 投票
#define ACT_TYPE_COMPLAIN               2  // 活动类型: 吐槽
#define ACT_TYPE_SBQ                    3  // 活动类型: 伤不起

#define GROUP_ROLE_NOTMEMBER            -1  // 群组用户角色: 不是成员，数据库中无此类记录，仅用于api数据
#define GROUP_ROLE_MEMBER               0  // 群组用户角色: 普通成员
#define GROUP_ROLE_ADMIN                5  // 群组用户角色: 管理人员
#define GROUP_ROLE_MONITOR              9  // 群组用户角色: 班长，正式班有, 自建群群主也是这个角色

#define SHOP_ITEM_CATEGORY_GAME_GIFT    1  // 商品类型: 游戏礼包
#define SHOP_ITEM_CATEGORY_GITF         2  // 商品类型: 普通商品
#define SHOP_ITEM_CATEGORY_SMILEY       3  // 商品类型: 表情
#define SHOP_ITEM_CATEGORY_BUBBLE       4  // 商品类型: 聊天泡泡
#define SHOP_ITEM_CATEGORY_CONSUMPTION_PRIZE  5  // 商品类型: 认证消费奖品
#define SHOP_ITEM_CATEGORY_PRIZE        6  // 商品类型: 普通游戏发奖

#define BADGE_TYPE_PHOTO_FEED           1  // 计数Badge类型: 用户照片新feed计数
#define BADGE_TYPE_INTERVIEW_INVITE     2  // 计数Badge类型: 被邀请回答问题badge通知
#define BADGE_TYPE_TIMELINE             3  // 计数Badge类型: 动态未读计数
#define BADGE_TYPE_MSGINBOX             4  // 计数Badge类型: @我的消息未读计数
#define BADGE_TYPE_NEWFOLLOWER          5  // 计数Badge类型: 新粉丝未读计数
#define BADGE_TYPE_NEWFRIEND            6  // 计数Badge类型: 新好友计数

#define TAXONOMY_TYPES_CATEGORY         0  // : 主题分类
#define TAXONOMY_TYPES_TAG              1  // : 常规标签
#define TAXONOMY_TYPES_SPEND            2  // : 游戏的消费点
#define TAXONOMY_TYPES_CONSUMPTION      3  // : 认证消费

#define INVITE_STATUS_INIT              0  // 申请状态: 未处理
#define INVITE_STATUS_AGREED            1  // 申请状态: 已通过
#define INVITE_STATUS_DECLINED          2  // 申请状态: 已拒绝

#define GAME_ITEM_FLAG_HOT              1  // : 
#define GAME_ITEM_FLAG_ACT              2  // : 
#define GAME_ITEM_FLAG_GIFT             4  // : 
#define GAME_ITEM_FLAG_CORP             8  // : 
#define GAME_ITEM_FLAG_DOC              16  // : 
#define GAME_ITEM_FLAG_OPEN             32  // : 是否开放
#define GAME_ITEM_FLAG_RECOMMENDED      64  // : 是否推荐

#define GAME_ITEM_LEVEL_HOT             1  // : 热点游戏
#define GAME_ITEM_LEVEL_COMMON          2  // : 普通游戏
#define GAME_ITEM_LEVEL_NOTPOPULAR      3  // : 冷门游戏



#define API_USER_LOGOUT                  @"user/logout"
#define API_USER_LOGIN                   @"user/login"
#define API_USER_REGISTER                @"user/register"
#define API_USER_VERSION                 @"user/version"
#define API_USER_SETDEVICETOKEN          @"user/setdevicetoken"
#define API_USER_CHANGEPASSWORD          @"user/changepassword"
#define API_USER_UPDATENEWPASSWORD       @"user/updatenewpassword"
#define API_USER_FINDPASSWORD            @"user/findpassword"
#define API_USER_TLOGIN                  @"user/tlogin"
#define API_USER_TBIND                   @"user/tbind"
#define API_USER_TUNBIND                 @"user/tunbind"
#define API_USER_CHANGEPROFILE           @"user/changeprofile"
#define API_USER_SETINVITESEQ            @"user/setinviteseq"
#define API_USER_SETPREFERENCE           @"user/setpreference"
#define API_USER_GETPREFERENCE           @"user/getpreference"
#define API_USER_SSOLOGIN                @"user/ssologin"
#define API_USER_SSOBIND                 @"user/ssobind"
#define API_USER_GETMESSAGESTYLES        @"user/getmessagestyles"
#define API_USER_GETREFRESHINFO          @"user/getrefreshinfo"
#define API_USER_REPORTACTION            @"user/reportaction"
#define API_UC_ADDFAVORITE               @"uc/addfavorite"
#define API_UC_FAVORITELIST              @"uc/favoritelist"
#define API_UC_ADDFAVORITEGAME           @"uc/addfavoritegame"
#define API_UC_ADDFAVORITEGAMES          @"uc/addfavoritegames"
#define API_UC_FAVORITEGAMELIST          @"uc/favoritegamelist"
#define API_UC_HOME                      @"uc/home"
#define API_UC_MYBOARDSTAT               @"uc/myboardstat"
#define API_UC_POSTS                     @"uc/posts"
#define API_UC_ANSWERS                   @"uc/answers"
#define API_UC_CONTACTS                  @"uc/contacts"
#define API_UC_FAVORITEGAMES             @"uc/favoritegames"
#define API_UC_GROUPS                    @"uc/groups"
#define API_UC_ACTS                      @"uc/acts"
#define API_UC_TRANSFERACT               @"uc/transferact"
#define API_UC_INVITECARD                @"uc/invitecard"
#define API_UC_NAMECARD                  @"uc/namecard"
#define API_UC_MESSAGEINBOX              @"uc/messageinbox"
#define API_UC_CLEANMESSAGEINBOX         @"uc/cleanmessageinbox"
#define API_FRIEND_INVITE                @"friend/invite"
#define API_FRIEND_FOLLOW                @"friend/follow"
#define API_FRIEND_AGREE                 @"friend/agree"
#define API_FRIEND_DELETE                @"friend/delete"
#define API_FRIEND_FOLLOWINGLIST         @"friend/followinglist"
#define API_FRIEND_FOLLOWERLIST          @"friend/followerlist"
#define API_FRIEND_FRIENDLIST            @"friend/friendlist"
#define API_FRIEND_RECOMMENDED           @"friend/recommended"
#define API_FRIEND_RECOMMENDEDUSER       @"friend/recommendeduser"
#define API_FRIEND_CANCELRECOMMENDEDUSER   @"friend/cancelrecommendeduser"
#define API_FRIEND_SEARCH                @"friend/search"
#define API_FRIEND_SEARCHTHIRD           @"friend/searchthird"
#define API_PUB_HISTORY                  @"pub/history"
#define API_PUB_SUBSCRIBE                @"pub/subscribe"
#define API_PUB_VIEW                     @"pub/view"
#define API_PUB_SETPREFERENCE            @"pub/setpreference"
#define API_PUB_SEARCH                   @"pub/search"
#define API_FORWARD_TRANSFER             @"forward/transfer"
#define API_FORWARD_TRANSFERM            @"forward/transferM"
#define API_FORWARD_FEEDSHARE            @"forward/feedshare"
#define API_FORWARD_SEND                 @"forward/send"
#define API_FORWARD_TRANSFERLOG          @"forward/transferlog"
#define API_BOARD_APPLYMASTER            @"board/applymaster"
#define API_BOARD_APPROVEMASTER          @"board/approvemaster"
#define API_BOARD_GEMLIST                @"board/gemlist"
#define API_BOARD_LIKE                   @"board/like"
#define API_BOARD_LIKELIST               @"board/likelist"
#define API_BOARD_TRANSPARENT            @"board/transparent"
#define API_BOARD_FORBID                 @"board/forbid"
#define API_BOARD_REPORT                 @"board/report"
#define API_BOARD_GEM                    @"board/gem"
#define API_BOARD_TOP                    @"board/top"
#define API_BOARD_RECOGNISE              @"board/recognise"
#define API_BOARD_SEARCH                 @"board/search"
#define API_BOARD_ENTERCLASS             @"board/enterclass"
#define API_BOARD_CLASSLIST              @"board/classlist"
#define API_POST_CREATE                  @"post/create"
#define API_POST_REVIEW                  @"post/review"
#define API_POST_VIEW                    @"post/view"
#define API_POST_LIST                    @"post/list"
#define API_POST_DELETE                  @"post/delete"
#define API_POST_SEARCH                  @"post/search"
#define API_POST_QUESTIONQUEUE           @"post/questionqueue"
#define API_COMMENT_CREATE               @"comment/create"
#define API_COMMENT_VIEW                 @"comment/view"
#define API_COMMENT_LIST                 @"comment/list"
#define API_COMMENT_DELETE               @"comment/delete"
#define API_SUBCOMMENT_CREATE            @"subcomment/create"
#define API_SUBCOMMENT_VIEW              @"subcomment/view"
#define API_SUBCOMMENT_LIST              @"subcomment/list"
#define API_SUBCOMMENT_DELETE            @"subcomment/delete"
#define API_FILE_UPLOAD                  @"file/upload"
#define API_FILE_REPORTERR               @"file/reporterr"
#define API_MESSAGE_GETLIST              @"message/getlist"
#define API_MESSAGE_SEND                 @"message/send"
#define API_MESSAGE_THREADAVATARS        @"message/threadavatars"
#define API_MESSAGE_REPORT               @"message/report"
#define API_MESSAGE_CREATEMESSAGETHREAD   @"message/createmessagethread"
#define API_GROUP_SEARCH                 @"group/search"
#define API_GROUP_VIEW                   @"group/view"
#define API_GROUP_GETSUBSCRIBEDGAMES     @"group/getsubscribedgames"
#define API_GROUP_SUBGROUPS              @"group/subgroups"
#define API_GROUP_CREATE                 @"group/create"
#define API_GROUP_MEMBERS                @"group/members"
#define API_GROUP_UPDATE                 @"group/update"
#define API_GROUP_SUBSCRIBEGAMES         @"group/subscribegames"
#define API_GROUP_UPGRADE                @"group/upgrade"
#define API_GROUP_INVITEUSERS            @"group/inviteusers"
#define API_GROUP_APPLY                  @"group/apply"
#define API_GROUP_AGREE                  @"group/agree"
#define API_GROUP_BANUSER                @"group/banuser"
#define API_GROUP_QUIT                   @"group/quit"
#define API_GROUP_TRANSFERMONITOR        @"group/transfermonitor"
#define API_GROUP_SETADMIN               @"group/setadmin"
#define API_GROUP_JOINGAMEGROUP          @"group/joingamegroup"
#define API_GROUP_CHECKINFIGHTBOSS       @"group/checkinfightboss"
#define API_GROUP_PREFERENCES            @"group/preferences"
#define API_GROUP_UPDATEPREFERENCES      @"group/updatepreferences"
#define API_GROUP_GETLATESTFEED          @"group/getlatestfeed"
#define API_GAME_SELECT                  @"game/select"
#define API_GAME_DELETEHISTORY           @"game/deletehistory"
#define API_GAME_SEARCH                  @"game/search"
#define API_GAME_LIST                    @"game/list"
#define API_GAME_VIEW                    @"game/view"
#define API_GAME_BOARDINFO               @"game/boardinfo"
#define API_GAME_USERHISTORYLIST         @"game/userhistorylist"
#define API_GAME_USERFAVORITELIST        @"game/userfavoritelist"
#define API_GAME_REPORT                  @"game/report"
#define API_FEED_LIST                    @"feed/list"
#define API_FEED_USERFEEDS               @"feed/userfeeds"
#define API_FEED_TIMELINE                @"feed/timeline"
#define API_FEED_MYTIMELINE              @"feed/mytimeline"
#define API_PHOTO_ADD                    @"photo/add"
#define API_PHOTO_REMOVE                 @"photo/remove"
#define API_PHOTO_SETVOICE               @"photo/setvoice"
#define API_PHOTO_LIST                   @"photo/list"
#define API_PHOTO_VIEW                   @"photo/view"
#define API_PHOTO_LIKE                   @"photo/like"
#define API_PHOTO_COMMENT                @"photo/comment"
#define API_PHOTO_REMOVECOMMENT          @"photo/removecomment"
#define API_PHOTO_COMMENTLIST            @"photo/commentlist"
#define API_PHOTO_LIKELIST               @"photo/likelist"
#define API_PHOTO_FEEDLIST               @"photo/feedlist"
#define API_PHOTO_REPORT                 @"photo/report"
#define API_RANKING_TOPGAMES             @"ranking/topgames"
#define API_RANKING_TOPBOARDS            @"ranking/topboards"
#define API_RANKING_TOPHELPERS           @"ranking/tophelpers"
#define API_RANKING_RECOMMENDPUBLICS     @"ranking/recommendpublics"
#define API_RANKING_GOODHELPERS          @"ranking/goodhelpers"
#define API_POLL_CREATE                  @"poll/create"
#define API_POLL_VIEW                    @"poll/view"
#define API_POLL_VOTE                    @"poll/vote"
#define API_COMPLAIN_CREATE              @"complain/create"
#define API_COMPLAIN_VIEW                @"complain/view"
#define API_COMPLAIN_SIGN                @"complain/sign"
#define API_PRIVILEGE_INDEX              @"privilege/index"
#define API_PRIVILEGE_VIEW               @"privilege/view"
#define API_PRIVILEGE_GETGAMECODE        @"privilege/getgamecode"
#define API_PRIVILEGE_GOTITEMS           @"privilege/gotitems"
#define API_INTERVIEW_INDEX              @"interview/index"
#define API_INTERVIEW_INVITE             @"interview/invite"
#define API_INTERVIEW_ANSWER             @"interview/answer"
#define API_INTERVIEW_GAMES              @"interview/games"
#define API_INTERVIEW_PRIZE              @"interview/prize"
#define API_SHOP_VIEW                    @"shop/view"
#define API_SHOP_CATEGORY                @"shop/category"
#define API_SHOP_ITEMVIEW                @"shop/itemview"
#define API_SHOP_BUYITEM                 @"shop/buyitem"
#define API_SHOP_USERITEMS               @"shop/useritems"
#define API_SHOP_USERITEMDELETE          @"shop/useritemdelete"
#define API_TAXONOMY_SUGGEST             @"taxonomy/suggest"
#define API_TAXONOMY_VIEW                @"taxonomy/view"
#define API_TAXONOMY_POSTS               @"taxonomy/posts"
#define API_OPINION_CREATE               @"opinion/create"
#define API_OPINION_UP                   @"opinion/up"
#define API_OPINION_LIST                 @"opinion/list"
#define API_HOME_LIST                    @"home/list"
#define API_HOME_HOME                    @"home/home"
#define API_HOME_COUNTER                 @"home/counter"
#define API_FREECHARGE_LIST              @"freecharge/list"
#define API_HOMENEWS_LIST                @"homenews/list"
#define API_REPUTATION_INCR              @"reputation/incr"
#define API_USERGAMEDATA_CREATE          @"usergamedata/create"
#define API_USERGAMEDATA_GETITEM         @"usergamedata/getitem"
#define API_USERGAMEDATA_LISTBYGAME      @"usergamedata/listbygame"
#define API_USERGAMEDATA_LISTBYUSER      @"usergamedata/listbyuser"
#define API_TEMPLATE_GETITEM             @"template/getitem"
#define API_TEMPLATE_FIELDS              @"template/fields"
#define API_VERSION_CHECK                @"version/check"
#define API_USERLOGCLICK_LOG             @"userlogclick/log"
#define API_USERLOGCLICK_MLOG            @"userlogclick/mlog"
#define API_CONSUMPTION_LIST             @"consumption/list"
#define API_CONSUMPTION_USERLIST         @"consumption/userlist"
#define API_CONSUMPTION_CREATE           @"consumption/create"
#define API_CONSUMPTION_TEMPLATE         @"consumption/template"
