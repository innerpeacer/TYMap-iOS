//
//  CityBuildingTableVC.h
//  MapProject
//
//  Created by innerpeacer on 15/8/7.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TYMapData/TYMapData.h>
#import "RATreeView.h"

@protocol CityBuildingTableVCDelegate <NSObject>

- (void)didSelectBuilding:(TYBuilding *)building City:(TYCity *)city;

@end

@interface CityBuildingTableVC : UIViewController

@property (nonatomic, strong) NSArray *cityArray;
@property (nonatomic, strong) NSArray *buildingArray;

@property (nonatomic, weak) id<CityBuildingTableVCDelegate> delegate;
@property (nonatomic, weak) IBOutlet RATreeView *treeView;

- (void)reloadData;

@end
