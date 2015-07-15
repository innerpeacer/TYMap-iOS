//
//  NPLabelBorder.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NPLabelBorder : NSObject

@property (nonatomic, readonly) CGRect border;

+ (BOOL)CheckIntersect:(NPLabelBorder *)border1 WithBorder:(NPLabelBorder *)border2;


+ (NPLabelBorder *)borderWithXMin:(double)xmin XMax:(double)xmax YMin:(double)ymin YMax:(double)ymax;
+ (NPLabelBorder *)borderWithXmin:(double)xmin YMin:(double)ymin Width:(double)w Height:(double)h;

@end
