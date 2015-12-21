//
//  TYLabelBorder.h
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IPLabelBorder : NSObject

@property (nonatomic, readonly) CGRect border;

+ (BOOL)CheckIntersect:(IPLabelBorder *)border1 WithBorder:(IPLabelBorder *)border2;


+ (IPLabelBorder *)borderWithXMin:(double)xmin XMax:(double)xmax YMin:(double)ymin YMax:(double)ymax;
+ (IPLabelBorder *)borderWithXmin:(double)xmin YMin:(double)ymin Width:(double)w Height:(double)h;

@end
