//
//  BaseMapVC.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "BaseMapVC.h"

#import "NPUserDefaults.h"
#import "NPRenderingScheme.h"

@interface BaseMapVC()
{
    int currentIndex;
}

@end

@implementation BaseMapVC

- (void)viewDidLoad
{
    _currentBuildingID = [NPUserDefaults getDefaultBuilding];
    
    _allMapInfos = [NPMapInfo parseAllMapInfoForBuilding:_currentBuildingID];
    
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
            NPMapInfo *info = [_allMapInfos objectAtIndex:i];
            if ([info.floorName isEqualToString:@"F1"]) {
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
    for (NPMapInfo *mapInfo in _allMapInfos) {
        [floorStringArray addObject:mapInfo.floorName];
    }
    
    _floorSegment = [[UISegmentedControl alloc] initWithItems:floorStringArray];
    _floorSegment.frame = CGRectMake(20.0, 80.0, 280.0, 30.0);
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
    NSString *buildingID = [NPUserDefaults getDefaultBuilding];
    self.mapView.buildingID = buildingID;
    
    self.mapView.layerDelegate = self;
    
    NSString *renderingFile = [[NSBundle mainBundle] pathForResource:@"RenderingScheme" ofType:@"json"];
    NPRenderingScheme *renderingScheme = [[NPRenderingScheme alloc] initWithPath:renderingFile];
    [self.mapView initMapViewWithRenderScheme:renderingScheme];
    self.mapView.mapDelegate = self;
    
    [self.mapView setFloorWithInfo:_currentMapInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToZooming:) name:@"AGSMapViewDidEndZoomingNotification" object:nil];
}

- (void)viewDidUnload
{
    self.mapView = nil;
}

- (void)CAMapView:(NPMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    //    NSLog(@"didClickAtPoint");
    
}

- (void)CAMapView:(NPMapView *)mapView PoiSelected:(NSArray *)array
{
    
}

- (void)respondToZooming:(NSNotification *)notification
{
    
}

@end

