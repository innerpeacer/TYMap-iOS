//
//  SelectBuildingVC.h
//  MapProject
//
//  Created by innerpeacer on 15/8/7.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "CityBuildingTableVC.h"

@class SelectBuildingVC;

@protocol SelectBuildingVCDelegate <NSObject>

- (void)SelectBuildingVC:(SelectBuildingVC *)controller didSelectBuliding:(TYBuilding *)building City:(TYCity *)city;

@end

@interface SelectBuildingVC : CityBuildingTableVC

@property (nonatomic, weak) id<SelectBuildingVCDelegate> selectDelegate;

@end
