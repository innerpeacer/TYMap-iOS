#import <Foundation/Foundation.h>

@interface TYPointConverter : NSObject

+ (NSData *)dataFromX:(double)x Y:(double)y Z:(double)z;
+ (double *)xyzFromNSData:(NSData *)data;

@end
