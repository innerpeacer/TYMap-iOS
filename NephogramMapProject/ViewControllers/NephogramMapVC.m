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

- (void)NPMapView:(NPMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
//    NSArray *poiArray = [areaAnalysis extractAOIWithX:mappoint.x Y:mappoint.y];
//    NSLog(@"Count: %d", (int)poiArray.count);
//    NSLog(@"%@", poiArray);
    
    NSLog(@"didClickAtPoint: %f, %f", mappoint.x, mappoint.y);
    NSLog(@"Map Center: %f, %f", self.mapView.mapAnchor.x, self.mapView.mapAnchor.y);
    
//    [self.mapView translateInMapUnitByX:5 Y:5 animated:YES];
    [self.mapView translateInScreenUnitByX:50 Y:50 animated:YES];
    
}

- (void)NPMapView:(NPMapView *)mapView PoiSelected:(NSArray *)array
{

}

- (void)NPMapView:(NPMapView *)mapView didFinishLoadingFloor:(NPMapInfo *)mapInfo
{
    NSLog(@"didFinishLoadingFloor");
    
}

                   
@end
