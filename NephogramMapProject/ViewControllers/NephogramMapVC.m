//
//  NephogramMapVC.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NephogramMapVC.h"

@interface NephogramMapVC()
{

}

@end

@implementation NephogramMapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.highlightPOIOnSelection = YES;
    
}

- (void)CAMapView:(NPMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"%f, %f", mappoint.x, mappoint.y);
    
}

- (void)CAMapView:(NPMapView *)mapView PoiSelected:(NSArray *)array
{
    //    NSLog(@"PoiSelected: %@", array);
}

@end
