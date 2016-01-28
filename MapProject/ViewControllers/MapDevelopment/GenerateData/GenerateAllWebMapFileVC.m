//
//  GenerateAllWebMapFileVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/2.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "GenerateAllWebMapFileVC.h"
#import <TYMapData/TYMapData.h>
#import "TYUserDefaults.h"
#import "TYMapInfo.h"

#import "IPMapDBAdapter.h"
#import "IPMapFileManager.h"
#import "TYMapEnviroment.h"
#import "IPMapFeatureData.h"

#import "WebMapBuilder.h"

#define WEB_MAP_ROOT @"WebMap"

@interface GenerateAllWebMapFileVC() <WebMapBuilderDelegate>
{
    NSFileManager *fileManager;
    NSString *webMapFileDir;
    
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    WebMapBuilder *currentBuilder;
}

@end

@implementation GenerateAllWebMapFileVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    fileManager = [NSFileManager defaultManager];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(createAllWebMapFiles) object:nil];
    [thread start];
}



- (void)createAllWebMapFiles
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    webMapFileDir = [documentDirectory stringByAppendingPathComponent:WEB_MAP_ROOT];
    NSLog(@"%@", webMapFileDir);
    NSString *log = @"================================================";
//    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];

    IPMapDBAdapter *db = [[IPMapDBAdapter alloc] initWithPath:[IPMapFileManager getMapDBPath]];
    [db open];
    NSArray *allCityArray = [db getAllCities];
    for (TYCity *city in allCityArray) {
        NSString *cityDir = [webMapFileDir stringByAppendingPathComponent:city.cityID];
        NSString *buildingJsonPath = [cityDir stringByAppendingPathComponent:[NSString stringWithFormat:@"Buildings_City_%@.json", city.cityID]];

        [self performSelectorOnMainThread:@selector(updateUI:) withObject:[self logTitleForCity:city] waitUntilDone:YES];
        NSArray *allBuildings = [db getAllBuildings:city];
        for (TYBuilding *building in allBuildings) {
            log = @"================================================";
            
            currentBuilder = [[WebMapBuilder alloc] initWithCity:city Building:building WithWebRoot:webMapFileDir];
            currentBuilder.delegate = self;
            [currentBuilder buildWebMap];
        }
        [WebMapBuilder generateBuildingJsonWithCity:city Buildings:allBuildings WithRoot:webMapFileDir];
        log = [NSString stringWithFormat:@"Create File: \t%@", buildingJsonPath.lastPathComponent];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];
    }
    [WebMapBuilder generateCityJson:allCityArray WithRoot:webMapFileDir];
    NSString *cityJsonPath = [webMapFileDir stringByAppendingPathComponent:@"Cities.json"];
    log = [NSString stringWithFormat:@"Create File: \t%@", cityJsonPath.lastPathComponent];
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:log waitUntilDone:YES];

    [db close];
}

- (void)WebMapBuilder:(WebMapBuilder *)builder processUpdated:(NSString *)process
{
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:process waitUntilDone:YES];
}

- (void)updateUI:(NSString *)logString
{
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
