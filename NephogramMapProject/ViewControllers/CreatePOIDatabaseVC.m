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

@interface CreatePOIDatabaseVC()
{
    NSString *currentBuildingID;
    
    NSArray *allMapInfos;
    
    AGSGeometryEngine *engine;
}

- (IBAction)createPOIDatabase:(id)sender;
@end

@implementation CreatePOIDatabaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentBuildingID = [NPUserDefaults getDefaultBuilding];
    self.title = currentBuildingID;

    NSString *fullPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"MapInfo_Building_%@", currentBuildingID] ofType:@"json"];
    allMapInfos = [NPMapInfo parseAllMapInfoForBuilding:currentBuildingID Path:fullPath];
    
    engine = [AGSGeometryEngine defaultGeometryEngine];
    
//    NSLog(@"%@", allMapInfos);
}

- (IBAction)createPOIDatabase:(id)sender {
    CreatingPOIDBAdapter *db = [CreatingPOIDBAdapter sharedDBAdapter:currentBuildingID];
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
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_ASSET",info.mapID] ofType:@"json"];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    return set.features;
}

- (NSArray *)loadFacilitiesWithInfo:(NPMapInfo *)info
{
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_FACILITY",info.mapID] ofType:@"json"];
    NSString *jsonString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:dict];
    return set.features;
}

@end
