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
#import "EnviromentManager.h"

#import "IPEncryption.hpp"
#import "TYEncryption.h"
#import "IPMemory.h"
#import "MD5Utils.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"%@", documentDirectory);

    [TYMapEnvironment initMapEnvironment];
    
    [self copyMapFilesIfNeeded];
    [self setDefaultPlaceIfNeeded];
    
    [self testEncryption];
    
    return YES;
}

- (void)testEncryption
{

    NSString *str = @"Hello World!你好";
    NSLog(@"%@", str);
    NSLog(@"%@", [MD5Utils md5:str]);
    
    
}

- (void)setDefaultPlaceIfNeeded
{
    if ([TYUserDefaults getDefaultBuilding] == nil) {
        [TYUserDefaults setDefaultCity:@"0021"];
        [TYUserDefaults setDefaultBuilding:@"00210100"];
    }
    
}

- (void)copyMapFilesIfNeeded
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [EnviromentManager switchToOriginal];
    NSString *targetRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *sourceRootDir = [[NSBundle mainBundle] pathForResource:DEFAULT_MAP_ROOT ofType:nil];
    
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

