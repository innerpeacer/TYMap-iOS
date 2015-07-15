//
//  NPArcGISDrawer.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPArcGISDrawer.h"

@implementation NPArcGISDrawer

+ (void)drawPoint:(TYPoint *)p AtLayer:(TYGraphicsLayer *)layer WithColor:(UIColor *)color
{
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:color];
    sms.size = CGSizeMake(5, 5);
    sms.style = AGSSimpleMarkerSymbolStyleCircle;
    [layer addGraphic:[AGSGraphic graphicWithGeometry:p symbol:sms attributes:nil]];
}

+ (void)drawPoint:(TYPoint *)p AtLayer:(TYGraphicsLayer *)layer WithColor:(UIColor *)color Size:(CGSize)size
{
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:color];
    sms.size = size;
    sms.style = AGSSimpleMarkerSymbolStyleCircle;
    [layer addGraphic:[AGSGraphic graphicWithGeometry:p symbol:sms attributes:nil]];
    
}

+ (void)drawPoint:(TYPoint *)p AtLayer:(TYGraphicsLayer *)layer WithBuffer1:(double)buffer1 Buffer2:(double)buffer2
{
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    
    AGSPolygon *buf1 = [engine bufferGeometry:p byDistance:buffer1];
    AGSSimpleFillSymbol *sfs1 = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5] outlineColor:[UIColor blackColor]];
    [layer addGraphic:[AGSGraphic graphicWithGeometry:buf1 symbol:sfs1 attributes:nil]];
    
    AGSPolygon *buf2 = [engine bufferGeometry:p byDistance:buffer2];
    AGSSimpleFillSymbol *sfs2 = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5] outlineColor:[UIColor blackColor]];
    [layer addGraphic:[AGSGraphic graphicWithGeometry:buf2 symbol:sfs2 attributes:nil]];
    
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    sms.size = CGSizeMake(8, 8);
    sms.style = AGSSimpleMarkerSymbolStyleCircle;
    [layer addGraphic:[AGSGraphic graphicWithGeometry:p symbol:sms attributes:nil]];
}

+ (void)drawLineFrom:(TYPoint *)start To:(TYPoint *)end AtLayer:(TYGraphicsLayer *)layer WithColor:(UIColor *)color Width:(CGFloat)width spatialReference:(TYSpatialReference *)spatialReference
{
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc] initWithSpatialReference:spatialReference];
    [polyline addPathToPolyline];
    
    [polyline addPointToPath:start];
    [polyline addPointToPath:end];
    
    AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:color width:width];
    
    [layer addGraphic:[AGSGraphic graphicWithGeometry:polyline symbol:sls attributes:nil]];
}

+ (void)drawString:(NSString *)s Position:(TYPoint *)point AtLayer:(TYGraphicsLayer *)layer WithColor:(UIColor *)color
{
    AGSTextSymbol *ts = [AGSTextSymbol textSymbolWithText:s color:color];
    [layer addGraphic:[AGSGraphic graphicWithGeometry:point symbol:ts attributes:nil]];
}

+ (void)drawCircleCenterAt:(TYPoint *)center Radius:(double)r AtLayer:(TYGraphicsLayer *)layer WithColor:(UIColor *)color
{
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:color];
    sms.outline = nil;
    sms.size = CGSizeMake(r * 2, r * 2);
    sms.style = AGSSimpleMarkerSymbolStyleCircle;
    [layer addGraphic:[AGSGraphic graphicWithGeometry:center symbol:sms attributes:nil]];
}

+ (void)drawPictureSymbol:(TYPictureMarkerSymbol *)pms At:(TYPoint *)point AtLayer:(TYGraphicsLayer *)layer
{
    [layer addGraphic:[AGSGraphic graphicWithGeometry:point symbol:pms attributes:nil]];
}

+ (void)drawPolygon:(NSArray *)points AtLayer:(TYGraphicsLayer *)layer Color:(UIColor *)color spatialReference:(TYSpatialReference *)spatialReference
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

