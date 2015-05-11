//
//  NPRouteResultV2.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRouteResultV2.h"
#import "NPLandmarkManager.h"

@interface NPRouteResultV2()
{

}

@end

@implementation NPRouteResultV2

+ (NPRouteResultV2 *)routeResultWithRouteParts:(NSArray *)routePartArray
{
    return [[NPRouteResultV2 alloc] initRouteResultWithRouteParts:routePartArray];
}

- (id)initRouteResultWithRouteParts:(NSArray *)routePartArray
{
    self = [super init];
    if (self) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [tempArray addObjectsFromArray:routePartArray];
        _allRoutePartsArray = tempArray;
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < tempArray.count; ++i) {
            NPRoutePart *rp = tempArray[i];
            int floor = rp.floor;
            
            if (![tempDict.allKeys containsObject:@(floor)]) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [tempDict setObject:array forKey:@(floor)];
            }
            
            NSMutableArray *array = [tempDict objectForKey:@(floor)];
            [array addObject:rp];
        }
        _allFloorRoutePartDict = tempDict;
    }
    return self;
}

- (NSArray *)getRoutePartsOnFloor:(int)floor
{
    return [_allFloorRoutePartDict objectForKey:@(floor)];
}

- (NPRoutePart *)getRoutePart:(int)index
{
    return [_allRoutePartsArray objectAtIndex:index];
}

- (NSArray *)getRouteDirectionalHint:(NPRoutePart *)rp
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NPLandmarkManager *landmarkManager = [NPLandmarkManager sharedManager];
    [landmarkManager loadLandmark:info];
    
    
}

@end
