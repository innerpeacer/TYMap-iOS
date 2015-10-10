//
//  CreatePOIDatabaseVC.m
//  MapProject
//
//  Created by innerpeacer on 15/3/10.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "CreatePOIDatabaseVC.h"
#import "CreatingPOIDBAdapter.h"
#import "TYUserDefaults.h"
#import "TYMapInfo.h"
#import <ArcGIS/ArcGIS.h>
#import "TYPoi.h"
#import <TYMapData/TYMapData.h>
#import "TYMapFileManager.h"

@interface CreatePOIDatabaseVC()
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    
    NSArray *allMapInfos;
    
    AGSGeometryEngine *engine;
    NSDictionary *allMapData;
}

- (IBAction)createPOIDatabase:(id)sender;
@end

@implementation CreatePOIDatabaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentCity = [TYUserDefaults getDefaultCity];
    currentBuilding = [TYUserDefaults getDefaultBuilding];

    self.title = currentBuilding.buildingID;

    
    allMapInfos = [TYMapInfo parseAllMapInfo:currentBuilding];
    
    engine = [AGSGeometryEngine defaultGeometryEngine];
    
    NSLog(@"%@", allMapInfos);
}

- (IBAction)createPOIDatabase:(id)sender {
    CreatingPOIDBAdapter *db = [CreatingPOIDBAdapter sharedDBAdapter:currentBuilding.buildingID];
    [db open];
    
    [db erasePOITable];
    
    for (TYMapInfo *info in allMapInfos) {
//        NSArray *roomArray = [self loadRoomsWithInfo:info];
        [self loadMapDataWithInfo:info];
        
        AGSFeatureSet *roomFeatureSet = [[AGSFeatureSet alloc] initWithJSON:allMapData[@"room"]];
        NSArray *roomArray = roomFeatureSet.features;
        [self addToLog:[NSString stringWithFormat:@"Begin %@", info.mapID]];
        
        for (AGSGraphic *graphic in roomArray) {
            NSString *name = [graphic attributeForKey:@"NAME"];
            if (name != nil && [name isKindOfClass:[NSString class]]) {

            } else {
                continue;
            }

            NSString *gid = [graphic attributeForKey:@"GEO_ID"];
            NSString *pid = [graphic attributeForKey:@"POI_ID"];
            NSString *bid = [graphic attributeForKey:@"BUILDING_ID"];
            NSString *fid = [graphic attributeForKey:@"FLOOR_ID"];
            NSNumber *cid = [graphic attributeForKey:@"CATEGORY_ID"];
            
            AGSPoint *pos = [engine labelPointForPolygon:(AGSPolygon *)graphic.geometry];
            
            NSNumber *color = [graphic attributeForKey:@"COLOR"];
            NSNumber *fIndex = [graphic attributeForKey:@"FLOOR_INDEX"];
            NSString *fName = [graphic attributeForKey:@"FLOOR_NAME"];
            NSNumber *layer = @(POI_ROOM);

            [db insertPOIWithGeoID:gid poiID:pid buildingID:bid floorID:fid name:name categoryID:cid labelX:@(pos.x) labelY:@(pos.y) color:color floorIndex:fIndex floorName:fName layer:layer];
        }
        [self addToLog:[NSString stringWithFormat:@"End %@: Insert %d Room POI", info.mapID, (int)roomArray.count]];
        
        // ============================================================
        NSObject *assetObject = allMapData[@"asset"];
        if (![assetObject isKindOfClass:[NSString class]]) {
            AGSFeatureSet *assetFeatureSet = [[AGSFeatureSet alloc] initWithJSON:allMapData[@"asset"]];
            NSArray *assetArray = assetFeatureSet.features;
            [self addToLog:[NSString stringWithFormat:@"Begin %@", info.mapID]];
            
            for (AGSGraphic *graphic in assetArray) {
                NSString *name = [graphic attributeForKey:@"NAME"];
                if (name != nil && [name isKindOfClass:[NSString class]]) {
                    
                } else {
                    continue;
                }
                
                NSString *gid = [graphic attributeForKey:@"GEO_ID"];
                NSString *pid = [graphic attributeForKey:@"POI_ID"];
                NSString *bid = [graphic attributeForKey:@"BUILDING_ID"];
                NSString *fid = [graphic attributeForKey:@"FLOOR_ID"];
                NSNumber *cid = [graphic attributeForKey:@"CATEGORY_ID"];
                
                AGSPoint *pos = [engine labelPointForPolygon:(AGSPolygon *)graphic.geometry];
                
                NSNumber *color = [graphic attributeForKey:@"COLOR"];
                NSNumber *fIndex = [graphic attributeForKey:@"FLOOR_INDEX"];
                NSString *fName = [graphic attributeForKey:@"FLOOR_NAME"];
                NSNumber *layer = @(POI_ASSET);
                
                [db insertPOIWithGeoID:gid poiID:pid buildingID:bid floorID:fid name:name categoryID:cid labelX:@(pos.x) labelY:@(pos.y) color:color floorIndex:fIndex floorName:fName layer:layer];
            }
            [self addToLog:[NSString stringWithFormat:@"End %@: Insert %d Asset POI", info.mapID, (int)assetArray.count]];
        }
        
        // ============================================================

        NSLog(@"%@", allMapData[@"facility"]);
        if ([allMapData[@"facility"] isKindOfClass:[NSString class]]) {
            continue;
        } else {
            AGSFeatureSet *facilityFeatureSet = [[AGSFeatureSet alloc] initWithJSON:allMapData[@"facility"]];
            
            NSArray *facilityArray = facilityFeatureSet.features;
            [self addToLog:[NSString stringWithFormat:@"Begin %@", info.mapID]];
            
            for (AGSGraphic *graphic in facilityArray) {
                
                NSString *name = [graphic attributeForKey:@"NAME"];
                if (name != nil && [name isKindOfClass:[NSString class]]) {
                    
                } else {
                    continue;
                }
                
                NSString *gid = [graphic attributeForKey:@"GEO_ID"];
                NSString *pid = [graphic attributeForKey:@"POI_ID"];
                NSString *bid = [graphic attributeForKey:@"BUILDING_ID"];
                NSString *fid = [graphic attributeForKey:@"FLOOR_ID"];
                NSNumber *cid = [graphic attributeForKey:@"CATEGORY_ID"];
                
                AGSPoint *pos = (AGSPoint *)graphic.geometry;
                
                NSNumber *color = [graphic attributeForKey:@"COLOR"];
                NSNumber *fIndex = [graphic attributeForKey:@"FLOOR_INDEX"];
                NSString *fName = [graphic attributeForKey:@"FLOOR_NAME"];
                NSNumber *layer = @(POI_FACILITY);
                
                [db insertPOIWithGeoID:gid poiID:pid buildingID:bid floorID:fid name:name categoryID:cid labelX:@(pos.x) labelY:@(pos.y) color:color floorIndex:fIndex floorName:fName layer:layer];
            }
            [self addToLog:[NSString stringWithFormat:@"End %@: Insert %d Facility POI", info.mapID, (int)facilityArray.count]];
        }


    }
    [db close];
}

- (void)loadMapDataWithInfo:(TYMapInfo *)info
{
    NSError *error = nil;
    NSString *fullPath = [TYMapFileManager getMapDataPath:info];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    allMapData = [parser objectWithString:jsonString];
}

//- (NSArray *)loadRoomsWithInfo:(TYMapInfo *)info
//{
//    NSError *error = nil;
//    NSString *fullPath = [TYMapFileManager getRoomLayerPath:info];
//    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
//    
//    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
//    NSDictionary *dict = [parser objectWithString:jsonString];
//    
//    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
//    return set.features;
//}
//
//- (NSArray *)loadFacilitiesWithInfo:(TYMapInfo *)info
//{
//    NSError *error = nil;
//    NSString *fullPath = [TYMapFileManager getFacilityLayerPath:info];
//    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
//    
//    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
//    NSDictionary *dict = [parser objectWithString:jsonString];
//    
//    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
//    return set.features;
//}

@end
