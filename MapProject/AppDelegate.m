//
//  AppDelegate.m
//  MapProject
//
//  Created by innerpeacer on 15/2/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "AppDelegate.h"
#import "TYUserDefaults.h"

#import "TYMapEnviroment.h"
#import "TYPoi.h"

@implementation AppDelegate

#define DEFAULT_MAP_ROOT @"Map"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSLog(@"%@", documentDirectory);
    
    
    NSString *pathMapEncrypted = [[NSBundle mainBundle] pathForResource:@"MapEncrypted" ofType:nil];
    
    [TYMapEnvironment initMapEnvironment];
    
    [TYMapEnvironment setEncryptionEnabled:NO];
    
#if TARGET_IPHONE_SIMULATOR
    [TYMapEnvironment setMapLanguage:TYTraditionalChinese];
#elif TARGET_OS_IPHONE
    
#endif
    
    [TYMapEnvironment setRootDirectoryForMapFiles:[documentDirectory stringByAppendingPathComponent:DEFAULT_MAP_ROOT]];
    [self copyMapFilesIfNeeded];

//    [TYMapEnvironment setRootDirectoryForMapFiles:pathMapEncrypted];

    
    [self setDefaultPlaceIfNeeded];
    
    
    return YES;
}

- (void)setDefaultPlaceIfNeeded
{
    [TYUserDefaults setDefaultCity:@"0021"];
//    [TYUserDefaults setDefaultBuilding:@"002100001"];
//    [TYUserDefaults setDefaultBuilding:@"002100002"];
//    [TYUserDefaults setDefaultBuilding:@"002100004"];
    [TYUserDefaults setDefaultBuilding:@"002100005"];

//    [TYUserDefaults setDefaultBuilding:@"002188888"];
//    [TYUserDefaults setDefaultBuilding:@"002199999"];
//
//    [TYUserDefaults setDefaultCity:@"H852"];
//    [TYUserDefaults setDefaultBuilding:@"H85200001"];
//
//    [TYUserDefaults setDefaultCity:@"H852"];
//    [TYUserDefaults setDefaultBuilding:@"H85200001"];
//    
//        [TYUserDefaults setDefaultCity:@"0755"];
//        [TYUserDefaults setDefaultBuilding:@"075500001"];
    
    
    [TYUserDefaults setDefaultCity:@"0452"];
    [TYUserDefaults setDefaultBuilding:@"045200001"];

    
}

- (void)copyMapFilesIfNeeded
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *targetRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *sourceRootDir = [[NSBundle mainBundle] pathForResource:@"MapResource" ofType:nil];
    
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

