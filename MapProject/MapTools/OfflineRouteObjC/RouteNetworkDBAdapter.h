//
//  RouteNetworkDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/9/30.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>
#import "RouteNetworkDataset.h"

@interface RouteNetworkDBAdapter : NSObject

- (id)initWithBuilding:(TYBuilding *)building;

- (BOOL)open;
- (BOOL)close;

- (RouteNetworkDataset *)readRouteNetworkDataset;
- (NSArray *)getLinks;
- (NSArray *)getNodes;

@end


