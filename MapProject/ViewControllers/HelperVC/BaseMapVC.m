//
//  BaseMapVC.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "BaseMapVC.h"

#import "TYUserDefaults.h"
#import "TYRenderingScheme.h"
#import "TYGeometryEngine.h"

#import "LicenseGenerator.h"

@interface BaseMapVC()
{
    int currentIndex;
}

@end

@implementation BaseMapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_allMapInfos.count == 1) {
        currentIndex = 0;
        _currentMapInfo = [_allMapInfos objectAtIndex:0];
        
        [self initMap];
        self.title = _currentMapInfo.floorName;
    }
    
    if (_allMapInfos.count > 1) {
        
        currentIndex = 0;
        _currentMapInfo = [_allMapInfos objectAtIndex:0];
        
        for (int i = 0; i < _allMapInfos.count; ++i) {
            TYMapInfo *info = [_allMapInfos objectAtIndex:i];
            if (info.floorNumber == 7) {
                currentIndex = i;
                _currentMapInfo = info;
                break;
            }
        }
        
        [self initFloorSegment];
        [self initMap];
        self.title = _currentMapInfo.floorName;
    }
}

- (void)initFloorSegment
{
    NSMutableArray *floorStringArray = [[NSMutableArray alloc] init];
    for (TYMapInfo *mapInfo in _allMapInfos) {
        [floorStringArray addObject:mapInfo.floorName];
    }
    
    _floorSegment = [[UISegmentedControl alloc] initWithItems:floorStringArray];
    
    double screenWidth = self.view.frame.size.width;
    double xOffset = 20;
    double yOffset = 80;
    double height = 30;
    _floorSegment.frame = CGRectMake(xOffset, yOffset, screenWidth - xOffset * 2, height);
    _floorSegment.tintColor = [UIColor blueColor];
    _floorSegment.selectedSegmentIndex = currentIndex;
    
    [_floorSegment addTarget:self action:@selector(floorChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_floorSegment];
}

- (IBAction)floorChanged:(id)sender
{
    UISegmentedControl *control = (UISegmentedControl *)sender;
    currentIndex = (int)control.selectedSegmentIndex;
    _currentMapInfo = [_allMapInfos objectAtIndex:currentIndex];
    self.title = _currentMapInfo.floorName;
    [self.mapView setFloorWithInfo:_currentMapInfo];
}

- (void)initMap
{
    [self.mapView initMapViewWithBuilding:_currentBuilding UserID:TRIAL_USER_ID License:[LicenseGenerator generateLicenseForUserID:TRIAL_USER_ID Building:_currentBuilding.buildingID ExpiredDate:TRIAL_EXPRIED_DATE]];
//    [self.mapView initMapViewWithBuilding:_currentBuilding UserID:TRIAL_USER_ID License:[LicenseGenerator generateLicenseForUserID:TRIAL_USER_ID Building:@"00210100" ExpiredDate:TRIAL_EXPRIED_DATE]];

    self.mapView.mapDelegate = self;
    
    [self.mapView setFloorWithInfo:_currentMapInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToZooming:) name:@"AGSMapViewDidEndZoomingNotification" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.mapView = nil;
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    //    NSLog(@"didClickAtPoint");
}

- (void)TYMapView:(TYMapView *)mapView PoiSelected:(NSArray *)array
{
    
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
//    NSLog(@"Floor %@ did Loaded", mapInfo.floorName);
}

- (void)TYMapViewDidLoad:(TYMapView *)mapView
{
//    NSLog(@"TYMapViewDidLoad:");
}

- (void)respondToZooming:(NSNotification *)notification
{

}

@end

