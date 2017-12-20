
# ifndef __NSTYPES_DB_63F4724C187045148E270AC473917BA3_H_INCLUDED
# define __NSTYPES_DB_63F4724C187045148E270AC473917BA3_H_INCLUDED

@protocol DBObject <NSObject>

- (NSArray*)dbcolumns;
+ (NSArray*)DBColumns;

@end

@interface DBObject : NSObjectExt <DBObject>

@end

@interface NSObject (db)

- (NSArray*)dbcolumns;
+ (NSArray*)DBColumns;

@property (nonatomic, assign) int dbid;
@property (nonatomic, retain) id dbidobj;

- (BOOL)dbEqual:(NSObject<DBObject>*)obj;

@end

typedef enum {
    DBColumnTypeBlob = 1,
    DBColumnTypeInteger = 2,
    DBColumnTypeReal = 3,
    DBColumnTypeText = 4,
} DBColumnType;

@interface DBColumnObject : NSUsed

@property (nonatomic, copy) NSString *name, *path;
@property (nonatomic, assign) DBColumnType type;
@property (nonatomic, assign) int length, decimals;
@property (nonatomic, assign) bool autoincrement;
@property (nonatomic, assign) bool primarykey;
@property (nonatomic, assign) bool nullable;
@property (nonatomic, assign) bool unique;
@property (nonatomic, copy) NSString* defaultv;

- (void)clear;

@end

# define DBCOLUMNTYPE_DECL(Name, Value, Prop) \
@interface DBColumn##Name : DBColumnObject \
@property (nonatomic, Prop) Value value; \
- (BOOL)isEqualToValue:(DBColumn##Name*)obj; \
@end

DBCOLUMNTYPE_DECL(String, NSString*, copy);
DBCOLUMNTYPE_DECL(Integer, NSInteger, assign);
DBCOLUMNTYPE_DECL(Float, float, assign);
DBCOLUMNTYPE_DECL(Double, double, assign);

@interface DBColumnString (value)

- (NSString*)stringValue;

@end

@interface DBColumnInteger (value)

- (int)intValue;
- (NSInteger)integerValue;
- (NSUInteger)unsignedIntegerValue;

@end

@interface DBColumnFloat (value)

- (float)floatValue;
- (double)doubleValue;

@end

@interface DBColumnDouble (value)

- (float)floatValue;
- (double)doubleValue;

@end

# endif
