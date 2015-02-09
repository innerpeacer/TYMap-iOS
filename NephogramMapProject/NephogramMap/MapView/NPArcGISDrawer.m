//
//  NPArcGISDrawer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPArcGISDrawer.h"

@implementation NPArcGISDrawer

+ (void)drawPoint:(AGSPoint *)p AtLayer:(AGSGraphicsLayer *)layer WithColor:(UIColor *)color
{
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:color];
    sms.size = CGSizeMake(5, 5);
    sms.style = AGSSimpleMarkerSymbolStyleCircle;
    [layer addGraphic:[AGSGraphic graphicWithGeometry:p symbol:sms attributes:nil]];
}

+ (void)drawPoint:(AGSPoint *)p AtLayer:(AGSGraphicsLayer *)layer WithColor:(UIColor *)color Size:(CGSize)size
{
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:color];
    sms.size = size;
    sms.style = AGSSimpleMarkerSymbolStyleCircle;
    [layer addGraphic:[AGSGraphic graphicWithGeometry:p symbol:sms attributes:nil]];
    
}

+ (void)drawLineFrom:(AGSPoint *)start To:(AGSPoint *)end AtLayer:(AGSGraphicsLayer *)layer WithColor:(UIColor *)color Width:(CGFloat)width spatialReference:(AGSSpatialReference *)spatialReference
{
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] initWithSpatialReference:spatialReference];
    [polyline addPathToPolyline];
    
    [polyline addPointToPath:start];
    [polyline addPointToPath:end];
    
    AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:color width:width];
    
    [layer addGraphic:[AGSGraphic graphicWithGeometry:polyline symbol:sls attributes:nil]];
}

+ (void)drawString:(NSString *)s Position:(AGSPoint *)point AtLayer:(AGSGraphicsLayer *)layer WithColor:(UIColor *)color
{
    AGSTextSymbol *ts = [AGSTextSymbol textSymbolWithText:s color:color];
    [layer addGraphic:[AGSGraphic graphicWithGeometry:point symbol:ts attributes:nil]];
}

+ (void)drawCircleCenterAt:(AGSPoint *)center Radius:(double)r AtLayer:(AGSGraphicsLayer *)layer WithColor:(UIColor *)color
{
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:color];
    sms.outline = nil;
    sms.size = CGSizeMake(r * 2, r * 2);
    sms.style = AGSSimpleMarkerSymbolStyleCircle;
    [layer addGraphic:[AGSGraphic graphicWithGeometry:center symbol:sms attributes:nil]];
}

+ (void)drawPictureSymbol:(AGSPictureMarkerSymbol *)pms At:(AGSPoint *)point AtLayer:(AGSGraphicsLayer *)layer
{
    [layer addGraphic:[AGSGraphic graphicWithGeometry:point symbol:pms attributes:nil]];
}

+ (void)drawPolygon:(NSArray *)points AtLayer:(AGSGraphicsLayer *)layer Color:(UIColor *)color spatialReference:(AGSSpatialReference *)spatialReference
{
    AGSMutablePolygon *polygon = [[AGSMutablePolygon alloc] initWithSpatialReference:spatialReference];
    [polygon addRingToPolygon];
    
    for (AGSPoint *p in points) {
        [polygon addPointToRing:p];
    }
    
    AGSSimpleFillSymbol *sfs = [AGSSimpleFillSymbol simpleFillSymbolWithColor:color outlineColor:color];
    [layer addGraphic:[AGSGraphic graphicWithGeometry:polygon symbol:sfs attributes:nil]];
}

@end

