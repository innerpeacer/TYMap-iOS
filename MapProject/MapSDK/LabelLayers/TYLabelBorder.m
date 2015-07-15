//
//  TYLabelBorder.m
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYLabelBorder.h"

#define PROTECT_INTERVAL_X 0
#define PROTECT_INTERVAL_Y 0

@interface TYLabelBorder()
{

}
@end

@implementation TYLabelBorder

+ (TYLabelBorder *)borderWithXMin:(double)xmin XMax:(double)xmax YMin:(double)ymin YMax:(double)ymax
{
    double width = xmax - xmin;
    double height = ymax - ymin;
    return [[TYLabelBorder alloc] initWithRect:CGRectMake(xmin, ymin, width, height)];
}

+ (TYLabelBorder *)borderWithXmin:(double)xmin YMin:(double)ymin Width:(double)w Height:(double)h
{
    return [[TYLabelBorder alloc] initWithRect:CGRectMake(xmin, ymin, w, h)];
}

- (id)initWithRect:(CGRect)r
{
    self = [super init];
    if (self) {
        _border = r;
    }
    return self;
}

+ (BOOL)CheckIntersect:(TYLabelBorder *)border1 WithBorder:(TYLabelBorder *)border2
{
    return CGRectIntersectsRect(border1.border, border2.border);

//    CGRect bufferRect = CGRectMake(border1.border.origin.x - PROTECT_INTERVAL_X, border1.border.origin.y - PROTECT_INTERVAL_Y, border1.border.size.width + PROTECT_INTERVAL_X * 2, border1.border.size.height + PROTECT_INTERVAL_Y * 2);
//    return CGRectIntersectsRect(bufferRect, border2.border);

}

@end
