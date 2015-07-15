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

#define DEFAULT_MAP_ROOT @"Map"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSLog(@"%@", documentDirectory);
    
    [NPMapEnvironment initMapEnvironment];
    
    [NPMapEnvironment setMapLanguage:NPTraditionalChinese];
    
    [NPMapEnvironment setRootDirectoryForMapFiles:[documentDirectory stringByAppendingPathComponent:DEFAULT_MAP_ROOT]];
    [self copyMapFilesIfNeeded];
    
    [self setDefaultPlaceIfNeeded];
    
    
    return YES;
}

- (void)setDefaultPlaceIfNeeded
{
    [NPUserDefaults setDefaultCity:@"0021"];
//    [NPUserDefaults setDefaultBuilding:@"002100001"];
    [NPUserDefaults setDefaultBuilding:@"002100002"];
    [NPUserDefaults setDefaultBuilding:@"002100004"];
//    [NPUserDefaults setDefaultBuilding:@"002100005"];

//    [NPUserDefaults setDefaultBuilding:@"002188888"];
//    [NPUserDefaults setDefaultBuilding:@"002199999"];
//
//    [NPUserDefaults setDefaultCity:@"H852"];
//    [NPUserDefaults setDefaultBuilding:@"H85200001"];
//
//    [NPUserDefaults setDefaultCity:@"H852"];
//    [NPUserDefaults setDefaultBuilding:@"H85200001"];
    
//        [NPUserDefaults setDefaultCity:@"0755"];
//        [NPUserDefaults setDefaultBuilding:@"075500001"];
    
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

