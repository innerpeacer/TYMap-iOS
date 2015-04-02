//
//  BaseMapVC.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPMapView.h"

@interface BaseMapVC : UIViewController <NPMapViewDelegate>

@property (weak, nonatomic) IBOutlet NPMapView *mapView;
@property (strong, nonatomic) NPMapInfo *currentMapInfo;
@property (strong, nonatomic) NSString *currentBuildingID;
@property (strong, nonatomic) NSArray *allMapInfos;

@property (strong, nonatomic) UISegmentedControl *floorSegment;

- (IBAction)floorChanged:(id)sender;

@end
