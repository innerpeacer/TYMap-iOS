//
//  TYLabelBorderCalculator.h
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPLabelBorder.h"
#import "IPTextLabel.h"
#import "TYMapView.h"

@interface IPLabelBorderCalculator : NSObject

+ (AGSPolygon *)polygonFromCGRect:(CGRect)rect MapView:(TYMapView *)mapView;


+ (IPLabelBorder *)getFacilityLabelBorder:(CGPoint)screenPoint;

+ (IPLabelBorder *)getTextLabelBorder:(IPTextLabel *)textLabel Point:(CGPoint)screenPoint;
@end
