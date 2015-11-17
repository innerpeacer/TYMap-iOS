#import "TYPointConverter.h"

@implementation TYPointConverter

static NSData *headData;

+(NSData *)getHeadData
{
    if (headData == nil) {
        Byte headByte[] = {1, 1, 0, 0, 128};
        headData = [NSData dataWithBytes:headByte length:5];
    }
    return headData;
}

+ (NSData *)dataFromX:(double)x Y:(double)y Z:(double)z
{
    NSData *head = [TYPointConverter getHeadData];
    NSMutableData *data = [NSMutableData dataWithData:head];
    double xyz[]= {x, y, z};
    
//    NSLog(@"dataFromX:(double)x Y:(double)y Z:(double)z");
    
    NSData *xyzData = [NSData dataWithBytes:(const void *)xyz length:sizeof(xyz)];
    [data appendData:xyzData];
    return data;
}

+ (double *)xyzFromNSData:(NSData *)data
{
    NSData *subData = [data subdataWithRange:NSMakeRange(5, 24)];
    return (double *)[subData bytes];
}

@end
