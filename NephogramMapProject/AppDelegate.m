//
//  AppDelegate.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "AppDelegate.h"
#import "NPUserDefaults.h"

#import "NPMapEnviroment.h"
#import "NPPoi.h"

@implementation AppDelegate

#define DEFAULT_MAP_ROOT @"Nephogram/Map"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSLog(@"%@", documentDirectory);
    
    [NPMapEnvironment initMapEnvironment];
    [NPMapEnvironment setRootDirectoryForMapFiles:[documentDirectory stringByAppendingPathComponent:DEFAULT_MAP_ROOT]];
    [self copyMapFilesIfNeeded];
    
    [self setDefaultPlaceIfNeeded];
    
    return YES;
}

- (void)setDefaultPlaceIfNeeded
{
    NSString *defaultCityID = [NPUserDefaults getDefaultCity];
    if (defaultCityID == nil) {
        [NPUserDefaults setDefaultCity:@"0021"];
    }
    
    NSString *defaultBuildingID = [NPUserDefaults getDefaultBuilding];
    if (defaultBuildingID == nil) {
        [NPUserDefaults setDefaultBuilding:@"00210003"];
    }
    
//    [NPUserDefaults setDefaultCity:@"0021"];
    [NPUserDefaults setDefaultCity:@"H852"];

    [NPUserDefaults setDefaultBuilding:@"002100001"];
    [NPUserDefaults setDefaultBuilding:@"002100002"];
//    [NPUserDefaults setDefaultBuilding:@"H85200001"];

//    [NPUserDefaults setDefaultBuilding:@"002100004"];
//    [NPUserDefaults setDefaultBuilding:@"002188888"];
//    [NPUserDefaults setDefaultBuilding:@"002199999"];
    
}

- (void)copyMapFilesIfNeeded
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *targetRootDir = [NPMapEnvironment getRootDirectoryForMapFiles];
    NSString *sourceRootDir = [[NSBundle mainBundle] pathForResource:@"NephogramMapResource" ofType:nil];
    
    NSDirectoryEnumerator *enumerator;
    enumerator = [fileManager enumeratorAtPath:sourceRootDir];
    NSString *name;
    while (name= [enumerator nextObject]) {
        NSString *sourcePath = [sourceRootDir stringByAppendingPathComponent:name];
        NSString *targetPath = [targetRootDir stringByAppendingPathComponent:name];
        NSString *pathExtension = sourcePath.pathExtension;
        
        if (pathExtension.length > 0) {
            [fileManager copyItemAtPath:sourcePath toPath:targetPath error:nil];
        } else {
            [fileManager createDirectoryAtPath:targetPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

@end

