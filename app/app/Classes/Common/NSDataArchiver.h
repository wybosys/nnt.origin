
# ifndef __NSDATAARCHIVER_ADC9558B1D2945479AF120FC1DEE489E_H_INCLUDED
# define __NSDATAARCHIVER_ADC9558B1D2945479AF120FC1DEE489E_H_INCLUDED

@interface NSGzip : NSObject

- (NSData*)compress:(NSData*)da;
+ (NSData*)Compress:(NSData*)da;

- (NSData*)decompress:(NSData*)da;
+ (NSData*)Decompress:(NSData*)da;

@end

# endif
