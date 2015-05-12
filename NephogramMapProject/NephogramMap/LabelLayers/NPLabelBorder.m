//
//  NPLabelBorder.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPLabelBorder.h"

#define PROTECT_INTERVAL_X 2
#define PROTECT_INTERVAL_Y 2

@interface NPLabelBorder()
{

}
@end

@implementation NPLabelBorder

+ (NPLabelBorder *)borderWithXMin:(double)xmin XMax:(double)xmax YMin:(double)ymin YMax:(double)ymax
{
    double width = xmax - xmin;
    double height = ymax - ymin;
    return [[NPLabelBorder alloc] initWithRect:CGRectMake(xmin, ymin, width, height)];
}

+ (NPLabelBorder *)borderWithXmin:(double)xmin YMin:(double)ymin Width:(double)w Height:(double)h
{
    return [[NPLabelBorder alloc] initWithRect:CGRectMake(xmin, ymin, w, h)];
}

- (id)initWithRect:(CGRect)r
{
    self = [super init];
    if (self) {
        _border = r;
    }
    return self;
}

+ (BOOL)CheckIntersect:(NPLabelBorder *)border1 WithBorder:(NPLabelBorder *)border2
{
//    return CGRectIntersectsRect(border1.border, border2.border);

    CGRect bufferRect = CGRectMake(border1.border.origin.x - PROTECT_INTERVAL_X, border1.border.origin.y - PROTECT_INTERVAL_Y, border1.border.size.width + PROTECT_INTERVAL_X * 2, border1.border.size.height + PROTECT_INTERVAL_X * 2);
    return CGRectIntersectsRect(bufferRect, border2.border);

}

@end
