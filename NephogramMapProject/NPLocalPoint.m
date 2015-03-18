#import "NPLocalPoint.h"

@implementation NPLocalPoint

+ (NPLocalPoint *)pointWithX:(double)x Y:(double)y
{
    return [[NPLocalPoint alloc] initWithX:x Y:y Floor:1];
}

+ (NPLocalPoint *)pointWithX:(double)x Y:(double)y Floor:(int)f
{
    return [[NPLocalPoint alloc] initWithX:x Y:y Floor:f];
}

- (id)initWithX:(double)x Y:(double)y Floor:(int)f
{
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
        _floor = f;
    }
    return self;
}

- (double)distanceWith:(NPLocalPoint *)p
{
//    if (self.floor != p.floor) {
//        return LARGE_DISTANCE;
//    }
    return sqrt((_x-p.x)*(_x-p.x)+(_y-p.y)*(_y-p.y));
}

+ (double)distanceBetween:(NPLocalPoint *)p1 and:(NPLocalPoint *)p2
{
    return [p1 distanceWith:p2];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"LocalPoint-[(%f, %f) in floor %d]", _x, _y, _floor];
}

@end
