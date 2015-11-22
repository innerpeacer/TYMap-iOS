//
//  GenerateAllMapDBVC.m
//  MapProject
//
//  Created by innerpeacer on 15/10/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "GenerateAllMapDBVC.h"

#import <TYMapData/TYMapData.h>
#import <ArcGIS/ArcGIS.h>
#import "TYUserDefaults.h"
#import "TYMapInfo.h"
#import "TYMapInfoJsonParser.h"
#import "MapGeneratorDBAdapter.h"
#import "OriginalShpDBAdapter.h"

#import "TYCityManager.h"
#import "TYBuildingManager.h"

@interface GenerateAllMapDBVC()
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    
    NSArray *allMapInfos;
    
}
@end

@implementation GenerateAllMapDBVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(generateAllMapDB) object:nil];
    [thread start];
}

- (void)generateAllMapDB
{
    NSArray *cityArray = [TYCityManager parseAllCities];
    
    for (TYCity *city in cityArray) {
        currentCity = city;
        NSArray *buildingArray = [TYBuildingManager parseAllBuildings:city];
        for (TYBuilding *building in buildingArray) {
            currentBuilding = building;
            self.title = currentBuilding.buildingID;
            
            NSString *shpPath = [[NSBundle mainBundle] pathForResource:@"OriginalShpDB" ofType:nil];
            NSString *bundlePath = [shpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_shp.bundle", currentBuilding.buildingID]];
            NSBundle *dbBundle = [[NSBundle alloc] initWithPath:bundlePath];
            NSString *mapInfoPath = [dbBundle pathForResource:[NSString stringWithFormat:@"MapInfo_Building_%@", currentBuilding.buildingID] ofType:@"json"];
            allMapInfos = [TYMapInfoJsonParser parseAllMapInfoFromFile:mapInfoPath];
            
//            NSString *log = @"================================================\n";
            NSString *log = [self logTitleForBuilding:currentBuilding];
            log = [NSString stringWithFormat:@"%@\nGenerate Map Database for %@", log, currentBuilding.name];
            [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];

            
            MapGeneratorDBAdapter *mdb = [[MapGeneratorDBAdapter alloc] initWithBuilding:currentBuilding];
            [mdb open];
            [mdb eraseDatabase];
            [mdb insertMapInfos:allMapInfos];
            [mdb close];
            
            [self insertMapFeatures];
        }
    }
}

- (void)insertMapFeatures
{
    MapGeneratorDBAdapter *mdb = [[MapGeneratorDBAdapter alloc] initWithBuilding:currentBuilding];
    [mdb open];
    
    ShpDBType dbType[] = { SHP_DB_FLOOR, SHP_DB_ROOM, SHP_DB_ASSET, SHP_DB_FACILITY, SHP_DB_LABEL };
    NSArray *dbName = @[@"FLOOR", @"ROOM", @"ASSET", @"FACILITY", @"LABEL"];
    
    for (TYMapInfo *info in allMapInfos) {
        for (int i = 0; i < dbName.count; ++i) {
            NSString *name = dbName[i];
            ShpDBType type = dbType[i];
            
            OriginalShpDBAdapter *db = [[OriginalShpDBAdapter alloc] initWithMapInfo:info Type:type];
            [db open];
            NSArray *allRecords = [db readAllRecords];
            [db close];
            [mdb insertMapData:allRecords];
            
            NSString *log = [NSString stringWithFormat:@"\t%d\t records in %@_%@\t Inserted...", (int)allRecords.count, info.mapID, name];
            [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
        }
    }
    
    [mdb close];
}

- (void)updateUI:(NSString *)logString
{
    [self addToLog:logString];
}

- (NSString *)logTitleForBuilding:(TYBuilding *)b
{
    NSString *title = @"================================================";
    int titleLength = (int)title.length;
    int length = (int)b.name.length * 2 + 4;
    
    NSMutableString *result = [NSMutableString string];
    [result appendString:[title substringToIndex:(titleLength-length)/2]];
    [result appendString:@"  "];
    [result appendString:b.name];
    [result appendString:@"  "];
    [result appendString:[title substringToIndex:(titleLength-length)/2]];
    return result;
}


@end