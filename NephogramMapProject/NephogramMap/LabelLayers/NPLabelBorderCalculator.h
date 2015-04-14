//
//  NPLabelBorderCalculator.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPLabelBorder.h"
#import "NPPoint.h"
#import "NPTextLabel.h"
#import "NPMapView.h"

@interface NPLabelBorderCalculator : NSObject

+ (AGSPolygon *)polygonFromCGRect:(CGRect)rect MapView:(NPMapView *)mapView;


+ (NPLabelBorder *)getFacilityLabelBorder:(CGPoint)screenPoint;

+ (NPLabelBorder *)getTextLabelBorder:(NPTextLabel *)textLabel Point:(CGPoint)screenPoint;
@end
