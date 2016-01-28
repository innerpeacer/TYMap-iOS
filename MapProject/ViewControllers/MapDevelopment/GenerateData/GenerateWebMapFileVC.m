//
//  GenerateWebMapFileVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/2.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "GenerateWebMapFileVC.h"
#import <TYMapData/TYMapData.h>
#import "TYUserDefaults.h"
#import "TYMapInfo.h"

#import "IPMapDBAdapter.h"
#import "IPMapFileManager.h"
#import "TYMapEnviroment.h"
#import "IPMapFeatureData.h"
#import "TYRenderingScheme.h"
#import "WebMapFields.h"
#import "WebMapObjectBuilder.h"
#import "WebSymbolDBAdpater.h"
#import "WebMapBuilder.h"

#define WEB_MAP_ROOT @"WebMap"

@interface GenerateWebMapFileVC() <WebMapBuilderDelegate>
{
    NSFileManager *fileManager;
    NSString *webMapFileDir;
    
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    
    WebMapBuilder *mapBuilder;
}

@end

@implementation GenerateWebMapFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    fileManager = [NSFileManager defaultManager];
    currentCity = [TYUserDefaults getDefaultCity];
    currentBuilding = [TYUserDefaults getDefaultBuilding];
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    webMapFileDir = [documentDirectory stringByAppendingPathComponent:WEB_MAP_ROOT];
    
    mapBuilder = [[WebMapBuilder alloc] initWithCity:currentCity Building:currentBuilding WithWebRoot:webMapFileDir];
    mapBuilder.delegate = self;
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(createWebMapFileForCurrentBuilding) object:nil];
    [thread start];
    
}

- (void)createWebMapFileForCurrentBuilding
{
    [mapBuilder buildWebMap];
}

- (void)WebMapBuilder:(WebMapBuilder *)builder processUpdated:(NSString *)process
{
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:process waitUntilDone:YES];
}

- (void)updateUI:(NSString *)logString
{
    [self addToLog:logString];
}

@end
