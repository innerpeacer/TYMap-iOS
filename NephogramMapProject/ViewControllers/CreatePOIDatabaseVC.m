//
//  CreatePOIDatabaseVC.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/3/10.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "CreatePOIDatabaseVC.h"
#import "CreatingPOIDBAdapter.h"
#import "NPUserDefaults.h"
#import "NPMapInfo.h"
#import <ArcGIS/ArcGIS.h>
#import "NPPoi.h"
#import "NPBuilding.h"
#import "NPMapFileManager.h"

@interface CreatePOIDatabaseVC()
{
    NPCity *currentCity;
    NPBuilding *currentBuilding;
    
    NSArray *allMapInfos;
    
    AGSGeometryEngine *engine;
}

- (IBAction)createPOIDatabase:(id)sender;
@end

@implementation CreatePOIDatabaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *cityID = [NPUserDefaults getDefaultCity];
    currentCity = [NPCity parseCity:cityID];
    
    NSString *buildingID = [NPUserDefaults getDefaultBuilding];
    currentBuilding = [NPBuilding parseBuilding:buildingID InCity:currentCity];

    self.title = currentBuilding.buildingID;

    
    allMapInfos = [NPMapInfo parseAllMapInfo:currentBuilding];
    
    engine = [AGSGeometryEngine defaultGeometryEngine];
    
    NSLog(@"%@", allMapInfos);
}

- (IBAction)createPOIDatabase:(id)sender {
    CreatingPOIDBAdapter *db = [CreatingPOIDBAdapter sharedDBAdapter:currentBuilding.buildingID];
    [db open];
    
    [db erasePOITable];
    
    for (NPMapInfo *info in allMapInfos) {
        NSArray *roomArray = [self loadRoomsWithInfo:info];
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

        
        NSArray *facilityArray = [self loadFacilitiesWithInfo:info];
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
    
    [db close];
}

- (NSArray *)loadRoomsWithInfo:(NPMapInfo *)info
{
    NSError *error = nil;
    NSString *fullPath = [NPMapFileManager getRoomLayerPath:info];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    return set.features;
}

- (NSArray *)loadFacilitiesWithInfo:(NPMapInfo *)info
{
    NSError *error = nil;
    NSString *fullPath = [NPMapFileManager getFacilityLayerPath:info];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    return set.features;
}

@end
