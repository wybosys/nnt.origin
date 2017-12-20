
# ifndef __RTECONTENTMESSAGELIST_99423BF331624EC2972DE2BC78E250BB_H_INCLUDED
# define __RTECONTENTMESSAGELIST_99423BF331624EC2972DE2BC78E250BB_H_INCLUDED

# import "RTExchangeObject.h"

@interface RTEContentMessageList : RTExchangeObject {
    NSMutableArray* _messages;
}

@property (nonatomic, readonly, retain) NSArray* messages;

@end

enum { RTE_CONTENTMESSAGELIST = 2 };

# endif
