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
#import "OriginalSymbolDBAdapter.h"
#import "TYMapEnviroment.h"
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

    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(generateMapDB) object:nil];
    [thread start];
}

- (void)generateMapDB
{
    NSString *shpPath = [[NSBundle mainBundle] pathForResource:@"OriginalShpDB" ofType:nil];
    NSString *bundlePath = [shpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_shp.bundle", currentBuilding.buildingID]];
    NSBundle *dbBundle = [[NSBundle alloc] initWithPath:bundlePath];
    NSString *mapInfoPath = [dbBundle pathForResource:[NSString stringWithFormat:@"MapInfo_Building_%@", currentBuilding.buildingID] ofType:@"json"];
    allMapInfos = [TYMapInfoJsonParser parseAllMapInfoFromFile:mapInfoPath];
    
    NSString *log = [self logTitleForBuilding:currentBuilding];
    log = [NSString stringWithFormat:@"%@\nGenerate Map Database for %@", log, currentBuilding.name];
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    
    NSString *buildingDir = [TYMapEnvironment getBuildingDirectory:currentBuilding];
    if (![[NSFileManager defaultManager] fileExistsAtPath:buildingDir isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:buildingDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    MapGeneratorDBAdapter *mdb = [[MapGeneratorDBAdapter alloc] initWithBuilding:currentBuilding];
    [mdb open];
    [mdb eraseDatabase];
    [mdb insertMapInfos:allMapInfos];
    [mdb close];
    
    [self insertMapFeatures];
    [self insertMapSymbols];
}

- (void)insertMapSymbols
{
    MapGeneratorDBAdapter *mdb = [[MapGeneratorDBAdapter alloc] initWithBuilding:currentBuilding];
    [mdb open];
    
    NSString *shpPath = [[NSBundle mainBundle] pathForResource:@"OriginalShpDB" ofType:nil];
    NSString *bundlePath = [shpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_shp.bundle", currentBuilding.buildingID]];
    NSBundle *dbBundle = [[NSBundle alloc] initWithPath:bundlePath];
    NSString *dbPath = [dbBundle pathForResource:[NSString stringWithFormat:@"%@_SYMBOL", currentBuilding.buildingID] ofType:@"db"];
    OriginalSymbolDBAdapter *odb = [[OriginalSymbolDBAdapter alloc] initWithPath:dbPath];
    
    [odb open];
    
    NSString *log;
    NSArray *fillArray = [odb getAllFillSymbols];
    NSArray *iconArray = [odb getAllIconSymbols];
    
    [mdb insertFillSymbols:fillArray];
    log = [NSString stringWithFormat:@"\t%d\t fill symbols \t Inserted...", (int)fillArray.count];
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    
    [mdb insertIconSymbols:iconArray];
    log = [NSString stringWithFormat:@"\t%d\t icon symbols \t Inserted...", (int)iconArray.count];
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    
    [odb close];
    [mdb close];
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
