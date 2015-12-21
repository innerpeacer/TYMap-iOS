//
//  TYBrand.h
//  MapProject
//
//  Created by innerpeacer on 15/5/29.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TYMapData/TYMapData.h>

@interface IPBrand : NSObject

@property (nonatomic, strong) NSString *poiID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic, assign) CGSize logoSize;

+ (NSArray *)parseAllBrands:(TYBuilding *)building;

@end
