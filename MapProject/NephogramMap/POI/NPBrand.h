//
//  NPBrand.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/29.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NPBuilding.h"

@interface NPBrand : NSObject

@property (nonatomic, strong) NSString *poiID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic, assign) CGSize logoSize;

+ (NSArray *)parseAllBrands:(NPBuilding *)building;

@end
