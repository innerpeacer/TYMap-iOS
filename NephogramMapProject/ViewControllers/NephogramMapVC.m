//
//  NephogramMapVC.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NephogramMapVC.h"
#import "NPAreaAnalysis.h"


@interface NephogramMapVC()
{
    NPAreaAnalysis *areaAnalysis;
}

@end

@implementation NephogramMapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AOI" ofType:@"json"];
    areaAnalysis = [[NPAreaAnalysis alloc] initWithPath:path];
    
}

int count = 0;
int tIndex = 0;

- (void)NPMapView:(NPMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"didClickAtPoint: %f, %f", mappoint.x, mappoint.y);
    
//    NPPoi *poi = [self.mapView extractRoomPoiOnCurrentFloorWithX:mappoint.x Y:mappoint.y];
    NPPoi *poi = [self.mapView extractRoomPoiOnCurrentFloorWithX:-16368300.428107699 Y:409.32691143034884];
    NSLog(@"%@", poi);
}

- (void)NPMapView:(NPMapView *)mapView PoiSelected:(NSArray *)array
{
//    NSLog(@"PoiSelected: %@", array);
}

- (void)NPMapView:(NPMapView *)mapView didFinishLoadingFloor:(NPMapInfo *)mapInfo
{
    NSLog(@"didFinishLoadingFloor");
    
}

                   
@end
