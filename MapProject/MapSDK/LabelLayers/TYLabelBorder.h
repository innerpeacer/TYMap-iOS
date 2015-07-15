//
//  TYLabelBorder.h
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TYLabelBorder : NSObject

@property (nonatomic, readonly) CGRect border;

+ (BOOL)CheckIntersect:(TYLabelBorder *)border1 WithBorder:(TYLabelBorder *)border2;


+ (TYLabelBorder *)borderWithXMin:(double)xmin XMax:(double)xmax YMin:(double)ymin YMax:(double)ymax;
+ (TYLabelBorder *)borderWithXmin:(double)xmin YMin:(double)ymin Width:(double)w Height:(double)h;

@end
