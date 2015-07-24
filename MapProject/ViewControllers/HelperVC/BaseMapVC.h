//
//  BaseMapVC.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYMapView.h"
#include "TYBuilding.h"
#include "TYCity.h"

@interface BaseMapVC : UIViewController <TYMapViewDelegate>

@property (weak, nonatomic) IBOutlet TYMapView *mapView;
@property (strong, nonatomic) TYMapInfo *currentMapInfo;
@property (strong, nonatomic) TYCity *currentCity;
@property (strong, nonatomic) TYBuilding *currentBuilding;

@property (strong, nonatomic) NSArray *allMapInfos;
@property (strong, nonatomic) UISegmentedControl *floorSegment;

- (IBAction)floorChanged:(id)sender;

@end
