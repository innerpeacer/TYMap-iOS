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
    
//    self.mapView.highlightPOIOnSelection = YES;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AOI" ofType:@"json"];
    areaAnalysis = [[NPAreaAnalysis alloc] initWithPath:path];
    
}

- (void)NPMapView:(NPMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
//    NSLog(@"%f, %f", mappoint.x, mappoint.y);
// 
//    NSLog(@"%f", self.mapView.resolution);
//    
//    NPPoi *poi = [self.mapView extractRoomPoiOnCurrentFloorWithX:mappoint.x Y:mappoint.y];
//    NSLog(@"%@", poi.poiID);
//    [self.mapView highlightPoi:poi];
    
    NSArray *poiArray = [areaAnalysis extractAOIWithX:mappoint.x Y:mappoint.y];
    NSLog(@"Count: %d", (int)poiArray.count);
    NSLog(@"%@", poiArray);
}

- (void)NPMapView:(NPMapView *)mapView PoiSelected:(NSArray *)array
{
//    NSLog(@"PoiSelected: %@", array);
//    
//    if (array.count > 0) {
//        NPPoi *poi = array[0];
//        
//        NSLog(@"%@", poi);
//        
//        NPPoi *apoi = [self.mapView getPoiOnCurrentFloorWithPoiID:poi.poiID layer:poi.layer];
//        NSLog(@"%@", apoi);
//    }
}

- (void)NPMapView:(NPMapView *)mapView didFinishLoadingFloor:(NPMapInfo *)mapInfo
{
    NSLog(@"didFinishLoadingFloor");
    
}

                   
@end
