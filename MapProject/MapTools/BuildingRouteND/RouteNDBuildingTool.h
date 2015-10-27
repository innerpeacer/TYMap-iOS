//
//  RouteNDBuildingTool.h
//  MapProject
//
//  Created by innerpeacer on 15/9/30.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

@class RouteNDBuildingTool;

@protocol RouteNDBuildingToolDelegate <NSObject>

@optional
- (void)RouteNDBuilingTool:(RouteNDBuildingTool *)tool buildingProcess:(NSString *)process;

@end

@interface RouteNDBuildingTool : NSObject

- (id)initWithBuilding:(TYBuilding *)building;

- (void)buildRouteNetworkDataset;

@property (nonatomic, weak) id<RouteNDBuildingToolDelegate> delegate;

@end
