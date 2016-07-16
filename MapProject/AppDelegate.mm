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

#import "IPXEncryption.hpp"
#import "IPEncryption.h"
#import "IPXMemory.h"
#import "IPMD5Utils.h"
#import "IPXMD5.hpp"

#import "MapLicenseGenerator.h"
#import "IPLicenseValidation.h"
#import "LicenseManager.h"
#import "IPMapDBAdapter.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
//    NSLog(@"bundleID: %@", bundleID);
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"%@", documentDirectory);
    
    [TYMapEnvironment initMapEnvironment];
    [TYMapEnvironment setHostName:HOST_NAME];

    [TYMapEnvironment setRootDirectoryForMapFiles:[documentDirectory stringByAppendingPathComponent:DEFAULT_MAP_ROOT]];

    [self copyMapFilesIfNeeded];
    [self setDefaultPlaceIfNeeded];
    
    return YES;
}

- (void)setDefaultPlaceIfNeeded
{
    if ([TYUserDefaults getDefaultBuilding] == nil) {
        [TYUserDefaults setDefaultCity:@"0010"];
        [TYUserDefaults setDefaultBuilding:@"00100003"];
    }
}

- (void)copyMapFilesIfNeeded
{
    NSString *targetRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *sourceRootDir = [[NSBundle mainBundle] pathForResource:DEFAULT_MAP_ROOT ofType:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *md5 = [defaults objectForKey:@"md5"];
    
    NSString *currentMD5 = [IPMD5Utils md5ForDirectory:sourceRootDir];
    
    if (md5 != nil && [md5 isEqualToString:currentMD5]) {
//        NSLog(@"File Not Changed");
    } else {
        [defaults setObject:currentMD5 forKey:@"md5"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager removeItemAtPath:targetRootDir error:&error];
        if (error) {
//            NSLog(@"Error: %@", [error localizedDescription]);
        }
        
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
        NSLog(@"地图文件发生改变, 删除旧文件并重新拷贝地图文件");

    }
}

@end
