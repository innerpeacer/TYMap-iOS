//
//  TYLabelBorderCalculator.h
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYLabelBorder.h"
#import "TYPoint.h"
#import "TYTextLabel.h"
#import "NPMapView.h"

@interface TYLabelBorderCalculator : NSObject

+ (AGSPolygon *)polygonFromCGRect:(CGRect)rect MapView:(NPMapView *)mapView;


+ (TYLabelBorder *)getFacilityLabelBorder:(CGPoint)screenPoint;

+ (TYLabelBorder *)getTextLabelBorder:(TYTextLabel *)textLabel Point:(CGPoint)screenPoint;
@end
