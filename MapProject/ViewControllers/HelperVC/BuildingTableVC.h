//
//  BuildingTableVC.h
//  MapProject
//
//  Created by innerpeacer on 15/7/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYCity.h"
#import "TYBuilding.h"

@interface BuildingTableVC : UITableViewController

@property (nonatomic,strong) TYCity *currentCity;
@property (nonatomic, strong) NSArray *buildingArray;

@end
