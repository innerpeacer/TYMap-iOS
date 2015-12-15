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
#import "TYMapFeatureData.h"

#import "TYCityManager.h"
#import "TYBuildingManager.h"

@interface CreatePOIDatabaseVC()
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    
    NSArray *allMapInfos;
    
    AGSGeometryEngine *engine;
    NSDictionary *allMapData;
}

- (IBAction)createPOIDatabase:(id)sender;
- (IBAction)createAllPOIDatabase:(id)sender;

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

- (void)generatePOIDatabaseForBuilding:(TYBuilding *)building MapInfo:(NSArray *)mapInfoArray
{
    NSString *dbPath = [TYMapFileManager getPOIDBPath:building];
    CreatingPOIDBAdapter *db = [[CreatingPOIDBAdapter alloc] initWithDBPath:dbPath];
    [db open];
    [db erasePOITable];
    
//    NSString *log = @"================================================\n";
//    log = [NSString stringWithFormat:@"%@Generate %@ POI", log, building.name];
//    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    NSString *log;
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:[self logTitleForBuilding:building] waitUntilDone:YES];

    for (TYMapInfo *info in mapInfoArray) {
        [self readMapDataFromDBForBuilding:building WithInfo:info];
        
        NSArray *layerNames = @[@"room", @"asset", @"facility"];
        NSArray *layerIndexs = @[@(POI_ROOM), @(POI_ASSET), @(POI_FACILITY)];
        NSArray *logNames = @[@"Room", @"Asset", @"Facility"];
        
        for (int i = 0; i < layerNames.count; ++i) {
            NSString *layerName = layerNames[i];
            NSNumber *layerIndex = layerIndexs[i];
            
            AGSFeatureSet *featureSet =  allMapData[layerName];
            NSArray *graphicsArray = featureSet.features;
//            NSLog(@"%d features", (int)graphicsArray.count);

            for (AGSGraphic *graphic in graphicsArray) {
                NSString *name = [graphic attributeForKey:@"NAME"];
                if (name == nil || ![name isKindOfClass:[NSString class]]) {
                    continue;
                }
                
                NSString *gid = [graphic attributeForKey:@"GEO_ID"];
                NSString *pid = [graphic attributeForKey:@"POI_ID"];
                NSString *bid = info.buildingID;
                NSString *fid = info.mapID;
                NSNumber *cid = [graphic attributeForKey:@"CATEGORY_ID"];
                
                AGSPoint *pos;
                if ([graphic.geometry isKindOfClass:[AGSPoint class]]) {
                    pos = (AGSPoint *)graphic.geometry;
                } else {
                    pos = [engine labelPointForPolygon:(AGSPolygon *)graphic.geometry];
                }
                
                NSNumber *color = [graphic attributeForKey:@"COLOR"];
                NSNumber *fIndex = @(info.floorNumber);
                NSString *fName = info.floorName;
                NSNumber *layer = layerIndex;
                
                [db insertPOIWithGeoID:gid poiID:pid buildingID:bid floorID:fid name:name categoryID:cid labelX:@(pos.x) labelY:@(pos.y) color:color FloorNumber:fIndex floorName:fName layer:layer];
            }
            
            log = [NSString stringWithFormat:@"\tInsert  %-7d\t %@\t POI in %@", (int)graphicsArray.count, logNames[i], info.mapID];
            [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
        }
    }
    [db close];
}

- (IBAction)createPOIDatabase:(id)sender {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(createCurrentPOIData) object:nil];
    [thread start];
}

- (IBAction)createAllPOIDatabase:(id)sender {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(createAllPOIData) object:nil];
    [thread start];
}

- (void)createAllPOIData
{
    NSArray *cityArray = [TYCityManager parseAllCities];
    for (TYCity *city in cityArray) {
        NSArray *buildingArray = [TYBuildingManager parseAllBuildings:city];
        for (TYBuilding *building in buildingArray) {
            NSArray *mapInfoArray = [TYMapInfo parseAllMapInfo:building];
            [self generatePOIDatabaseForBuilding:building MapInfo:mapInfoArray];
        }
    }
}

- (void)createCurrentPOIData
{
    [self generatePOIDatabaseForBuilding:currentBuilding MapInfo:allMapInfos];
}

- (void)readMapDataFromDBForBuilding:(TYBuilding *)building WithInfo:(TYMapInfo *)info
{
    TYMapFeatureData *featureData = [[TYMapFeatureData alloc] initWithBuilding:building];
    allMapData = [featureData getAllMapDataOnFloor:info.floorNumber];
}

- (void)updateUI:(NSString *)logString
{
    NSLog(@"%@", logString);
    [self addToLog:logString];
}

- (NSString *)logTitleForCity:(TYCity *)city
{
    NSString *title = @"================================================";
    int titleLength = (int)title.length;
    int length = (int)city.name.length * 2 + 4;
    
    NSMutableString *result = [NSMutableString string];
    [result appendString:[title substringToIndex:(titleLength-length)/2]];
    [result appendString:@"  "];
    [result appendString:city.name];
    [result appendString:@"  "];
    [result appendString:[title substringToIndex:(titleLength-length)/2]];
    return result;
}

- (NSString *)logTitleForBuilding:(TYBuilding *)building
{
    NSString *title = @"================================================";
    int titleLength = (int)title.length;
    int length = (int)building.name.length * 2 + 4;
    
    NSMutableString *result = [NSMutableString string];
    [result appendString:[title substringToIndex:(titleLength-length)/2]];
    [result appendString:@"  "];
    [result appendString:building.name];
    [result appendString:@"  "];
    [result appendString:[title substringToIndex:(titleLength-length)/2]];
    return result;
}

@end
