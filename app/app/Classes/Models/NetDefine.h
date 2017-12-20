
# ifndef __NETDEFINED_56502DD261D74E37901C020CFCDF74D9_H_INCLUDED
# define __NETDEFINED_56502DD261D74E37901C020CFCDF74D9_H_INCLUDED

enum {
    SITE_MODE_PRIVATE,
    SITE_MODE_PUBLIC,
    
    PUBLISH_MODE_ON,
    PUBLISH_MODE_OFF,
};

// 站点模式
extern int SITE_MODE;
extern int PUBLISH_MODE;

# define CONNECTION_SITE_PRIVATE ""
# define CONNECTION_SITE_PUBLIC ""

extern NSString* SERVER_URL();
extern NSString* DEV_PREFIX();
extern NSString* COMMON_USER_AVATAR(int type, int idr, NSString* v);

# define AVATAR_MAKE_DEFAULTURL(type, idx) [NSString stringWithFormat:@"http://f.hdurl.me/s/img/avatar/%@_%02d.png", type, idx]

#endif
