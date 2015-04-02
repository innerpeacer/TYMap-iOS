//
//  NPArcGISDrawer.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NPPoint.h"
#import "NPGraphicsLayer.h"
#import "NPSpatialReference.h"
#import "NPPictureMarkerSymbol.h"

@interface NPArcGISDrawer : NSObject

+ (void)drawPoint:(NPPoint *)p AtLayer:(NPGraphicsLayer *)layer WithColor:(UIColor *)color;

+ (void)drawPoint:(NPPoint *)p AtLayer:(NPGraphicsLayer *)layer WithColor:(UIColor *)color Size:(CGSize)size;

+ (void)drawPoint:(NPPoint *)p AtLayer:(NPGraphicsLayer *)layer WithBuffer1:(double)buffer1 Buffer2:(double)buffer2;

+ (void)drawLineFrom:(NPPoint *)start To:(NPPoint *)end AtLayer:(NPGraphicsLayer *)layer WithColor:(UIColor *)color Width:(CGFloat)width spatialReference:(NPSpatialReference *)spatialReference;
+ (void)drawString:(NSString *)s Position:(NPPoint *)point AtLayer:(NPGraphicsLayer *)layer WithColor:(UIColor *)color;
+ (void)drawCircleCenterAt:(NPPoint *)center Radius:(double)r AtLayer:(NPGraphicsLayer *)layer WithColor:(UIColor *)color;
+ (void)drawPictureSymbol:(NPPictureMarkerSymbol *)pms At:(NPPoint *)point AtLayer:(NPGraphicsLayer *)layer;

+ (void)drawPolygon:(NSArray *)points AtLayer:(NPGraphicsLayer *)layer Color:(UIColor *)color spatialReference:(NPSpatialReference *)spatialReference;


@end