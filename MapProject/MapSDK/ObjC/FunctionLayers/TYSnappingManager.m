//
//  TYSnappingManager.m
//  MapProject
//
//  Created by innerpeacer on 2016/11/25.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import "TYSnappingManager.h"
#import "TYMapEnviroment.h"
#import "TYMapInfo.h"

@interface TYSnappingManager()
{
    NSMutableDictionary *routeGeometries;
}

@end
@implementation TYSnappingManager

-(id)initWithBuilding:(TYBuilding *)building MapInfo:(NSArray *)mapInfoArray
{
    self = [super init];
    if (self) {
        routeGeometries = [[NSMutableDictionary alloc] init];
        
        NSError *error = nil;
        
        NSString *buildingDir = [TYMapEnvironment getBuildingDirectory:building];
        NSString *snappingPath = [buildingDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Snapping.json", building.buildingID]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:snappingPath]) {
            NSData *data = [NSData dataWithContentsOfFile:snappingPath];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (error) {
                NSLog(@"Error: %@", [error localizedDescription]);
            }
            
            for (NSString *mapID in json.allKeys) {
//                NSLog(@"%@", mapID);
                TYMapInfo *targetInfo = nil;
                for (TYMapInfo *info in mapInfoArray) {
                    if ([info.mapID isEqualToString:mapID]) {
                        targetInfo = info;
                        break;
                    }
                }
                
                if (targetInfo) {
                    AGSFeatureSet *featureSet = [[AGSFeatureSet alloc] initWithJSON:json[mapID]];
                    AGSGraphic *graphic = featureSet.features[0];
                    [routeGeometries setObject:graphic.geometry forKey:@(targetInfo.floorNumber)];
                }
            }
//            NSLog(@"routeGeometries");
//            NSLog(@"%@", routeGeometries);
        } else {
            NSLog(@"Snapping File Not Exist: %@", snappingPath);
        }

    }
    return self;
}

- (AGSPoint *)getSnappedPoint:(TYLocalPoint *)location
{
    AGSPoint *point = [AGSPoint pointWithX:location.x y:location.y spatialReference:nil];
    AGSGeometry *geometry = routeGeometries[@(location.floor)];
    if (geometry) {
       AGSProximityResult *pr = [[AGSGeometryEngine defaultGeometryEngine] nearestCoordinateInGeometry:geometry toPoint:point];
        return pr.point;
    }
    return point;
}

- (AGSProximityResult *)getSnappedResult:(TYLocalPoint *)location
{
    AGSPoint *point = [AGSPoint pointWithX:location.x y:location.y spatialReference:nil];
    AGSGeometry *geometry = routeGeometries[@(location.floor)];
    if (geometry) {
        AGSProximityResult *pr = [[AGSGeometryEngine defaultGeometryEngine] nearestCoordinateInGeometry:geometry toPoint:point];
        return pr;
    }
    return nil;
}

- (AGSProximityResult *)getSnappedVertexResult:(TYLocalPoint *)location
{
    AGSPoint *point = [AGSPoint pointWithX:location.x y:location.y spatialReference:nil];
    AGSGeometry *geometry = routeGeometries[@(location.floor)];
    if (geometry) {
        AGSProximityResult *pr = [[AGSGeometryEngine defaultGeometryEngine] nearestVertexInGeometry:geometry toPoint:point];
        return pr;
    }
    return nil;
}

- (NSDictionary *)getRouteGeometries
{
    return routeGeometries;
}

@end
