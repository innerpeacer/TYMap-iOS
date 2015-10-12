//
//  BuildingRouteDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>
#import "TYBuildingLink.h"
#import "TYBuildingNode.h"

@interface BuildingRouteDBAdapter : NSObject

- (id)initWithBuilding:(TYBuilding *)building;

- (BOOL)open;
- (BOOL)close;

- (BOOL)insertLink:(TYBuildingLink *)link;
- (BOOL)insertNode:(TYBuildingNode *)node;

- (BOOL)eraseRouteLinkTable;
- (BOOL)eraseRouteNodeTable;

@end
