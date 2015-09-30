//
//  ShpRouteDataGroup.h
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

@interface ShpRouteDataGroup : NSObject

@property (nonatomic, strong) NSArray *nodeArray;
@property (nonatomic, strong) NSArray *virtualNodeArray;
@property (nonatomic, strong) NSArray *junctionNodeArray;

@property (nonatomic, strong) NSArray *linkArray;
@property (nonatomic, strong) NSArray *virtualLinkArray;

- (id)initWithBuilding:(TYBuilding *)building;

@end
