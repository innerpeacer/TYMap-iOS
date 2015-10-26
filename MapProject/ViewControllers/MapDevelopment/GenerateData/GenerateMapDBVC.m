//
//  GenerateMapDBVC.m
//  MapProject
//
//  Created by innerpeacer on 15/10/23.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "GenerateMapDBVC.h"

#import <TYMapData/TYMapData.h>
#import <ArcGIS/ArcGIS.h>
#import "TYUserDefaults.h"
#import "TYMapInfo.h"
#import "TYMapInfoJsonParser.h"

#import "MapGeneratorDBAdapter.h"
#import "OriginalShpDBAdapter.h"

@interface GenerateMapDBVC()
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    
    NSArray *allMapInfos;
    
}
@end

@implementation GenerateMapDBVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentCity = [TYUserDefaults getDefaultCity];
    currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.title = currentBuilding.buildingID;

    NSString *shpPath = [[NSBundle mainBundle] pathForResource:@"OriginalShpDB" ofType:nil];
    NSString *bundlePath = [shpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_shp.bundle", currentBuilding.buildingID]];
    NSBundle *dbBundle = [[NSBundle alloc] initWithPath:bundlePath];
    NSString *mapInfoPath = [dbBundle pathForResource:[NSString stringWithFormat:@"MapInfo_Building_%@", currentBuilding.buildingID] ofType:@"json"];
    allMapInfos = [TYMapInfoJsonParser parseAllMapInfoFromFile:mapInfoPath];
//    NSLog(@"%@", allMapInfos);
    
    [self addToLog:[NSString stringWithFormat:@"Generate Map Database for %@", currentBuilding.buildingID]];
    
    MapGeneratorDBAdapter *mdb = [[MapGeneratorDBAdapter alloc] initWithBuilding:currentBuilding];
    [mdb open];
    [mdb eraseDatabase];
    [mdb insertMapInfos:allMapInfos];
    [mdb close];
    
//    [self insertMapFeatures];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(insertMapFeatures) userInfo:nil repeats:NO];

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
            [self addToLog:[NSString stringWithFormat:@"%d\t records in %@_%@\t Inserted...", (int)allRecords.count, info.mapID, name]];
        }
    }
    
    [mdb close];
}

@end
