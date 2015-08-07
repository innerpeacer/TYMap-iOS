//
//  MapTableVC.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseControllerTableVC.h"
#import "TYCity.h"
#import "TYBuilding.h"

@interface MapDevVC : BaseControllerTableVC

@property (nonatomic, strong) TYCity *currentCity;
@property (nonatomic, strong) TYBuilding *currentBuilding;

@end
