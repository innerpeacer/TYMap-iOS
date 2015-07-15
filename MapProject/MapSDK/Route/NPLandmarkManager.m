//
//  TYLandMarkManager.m
//  MapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPLandmarkManager.h"
#import "TYMapFileManager.h"
#import <ArcGIS/ArcGIS.h>

@interface NPLandmarkManager()
{
    NSMutableArray *allLandmarks;
    int currentFloor;
}

@end

@implementation NPLandmarkManager

static NPLandmarkManager *manager;

+ (NPLandmarkManager *)sharedManager
{
    if (manager == nil) {
        manager = [[NPLandmarkManager alloc] init];
    }
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        currentFloor = 0;
        allLandmarks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadLandmark:(TYMapInfo *)info
{
    [allLandmarks removeAllObjects];
    currentFloor = info.floorNumber;
    
    NSString *path = [TYMapFileManager getLandmarkJsonPath:info];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {

        NSError *error = nil;
        NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];

        AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
        NSDictionary *dict = [parser objectWithString:jsonString];
        
        AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
        NSArray *allGraphics = set.features;
        
        for (AGSGraphic *g in allGraphics) {
            NSString *name = [g attributeForKey:@"NAME"];
            AGSPoint *pos = (AGSPoint *)g.geometry;
            NPLocalPoint *location = [NPLocalPoint pointWithX:pos.x Y:pos.y Floor:currentFloor];
            
            NPLandmark *landmark = [[NPLandmark alloc] init];
            landmark.name = name;
            landmark.location = location;
            
            [allLandmarks addObject:landmark];
        }
    }
}

- (NPLandmark *)searchLandmark:(NPLocalPoint *)location Tolerance:(double)tolerance
{
    if (location.floor != currentFloor) {
        return nil;
    }
    
    for (NPLandmark *landmark in allLandmarks) {
        NPLocalPoint *lp = landmark.location;
        
        double distance = [lp distanceWith:location];
        if (distance < tolerance) {
            return landmark;
        }
    }
    
    return nil;
}

@end
