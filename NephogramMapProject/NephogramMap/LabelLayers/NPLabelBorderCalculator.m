//
//  NPLabelBorderCalculator.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPLabelBorderCalculator.h"
#import "NPMapView.h"

#define DPI_SCALE 1.0
#define FACILITY_LOGO_SIZE 26
#define TEXT_SIZE 10
#define TEXT_OFFSET_X 5
#define TEXT_OOFSET_Y 5

@implementation NPLabelBorderCalculator

+ (NPLabelBorder *)getFacilityLabelBorder:(CGPoint)screenPoint
{
    double scale = DPI_SCALE;
    
    double halfSize = (FACILITY_LOGO_SIZE * 0.5) * scale;
    
    double xmin = screenPoint.x - halfSize;
    double ymin = screenPoint.y - halfSize;
    
    double width = halfSize * 2;
    double height = halfSize * 2;
    
    return [NPLabelBorder borderWithXmin:xmin YMin:ymin Width:width Height:height];
}

+ (NPLabelBorder *)getTextLabelBorder:(NPTextLabel *)textLabel Point:(CGPoint)screenPoint
{
    double scale = DPI_SCALE;

    double textWidth = textLabel.labelSize.width;
    double textHeight = textLabel.labelSize.height;
    
    double left = screenPoint.x - textWidth * 0.5 * scale;
//    double right = screenPoint.x + (textWidth + TEXT_OFFSET_X) * scale;
    double right = screenPoint.x + textWidth * 0.5 * scale;
    double top = screenPoint.y - textHeight * 0.5 * scale;
    double bottom = screenPoint.y + textHeight * 0.5 * scale;
    
    return [NPLabelBorder borderWithXMin:left XMax:right YMin:top YMax:bottom];
}

+ (AGSPolygon *)polygonFromCGRect:(CGRect)rect MapView:(NPMapView *)mapView
{
    double left = rect.origin.x;
    double right = rect.origin.x + rect.size.width;
    double top = rect.origin.y;
    double bottom = rect.origin.y + rect.size.height;
    
    AGSMutablePolygon *polygon = [[AGSMutablePolygon alloc] init];
    [polygon addRingToPolygon];
    
    CGPoint sp;
    AGSPoint *p;
    sp = CGPointMake(left, top);
    p = [mapView toMapPoint:sp];
    [polygon addPointToRing:p];
    sp = CGPointMake(left, bottom);
    p = [mapView toMapPoint:sp];
    [polygon addPointToRing:p];
    sp = CGPointMake(right, bottom);
    p = [mapView toMapPoint:sp];
    [polygon addPointToRing:p];
    sp = CGPointMake(right, top);
    p = [mapView toMapPoint:sp];
    [polygon addPointToRing:p];
    [polygon closePolygon];
    return polygon;
}

@end
