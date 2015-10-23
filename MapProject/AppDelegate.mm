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
#import "MD5.hpp"

#import "LicenseGenerator.h"
#import "TYLicenseValidation.h"
#import "LicenseManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSLog(@"bundleID: %@", bundleID);
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"%@", documentDirectory);
    
    [TYMapEnvironment initMapEnvironment];
    [EnviromentManager switchToOriginal];

    [self copyMapFilesIfNeeded];
    [self setDefaultPlaceIfNeeded];
    
    
    
    return YES;
}

- (void)setDefaultPlaceIfNeeded
{
    if ([TYUserDefaults getDefaultBuilding] == nil) {
//        [TYUserDefaults setDefaultCity:@"0021"];
//        [TYUserDefaults setDefaultBuilding:@"00210100"];
        [TYUserDefaults setDefaultCity:@"0532"];
        [TYUserDefaults setDefaultBuilding:@"05320001"];
    }
}

//- (void)copyMapFiles
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    NSString *targetRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
//    NSString *sourceRootDir = [[NSBundle mainBundle] pathForResource:DEFAULT_MAP_ROOT ofType:nil];
//    
//    NSDirectoryEnumerator *enumerator;
//    enumerator = [fileManager enumeratorAtPath:sourceRootDir];
//    NSString *name;
//    while (name= [enumerator nextObject]) {
//        NSString *sourcePath = [sourceRootDir stringByAppendingPathComponent:name];
//        NSString *targetPath = [targetRootDir stringByAppendingPathComponent:name];
//        NSString *pathExtension = sourcePath.pathExtension;
//        
//        if (pathExtension.length > 0) {
//            [fileManager copyItemAtPath:sourcePath toPath:targetPath error:nil];
//        } else {
//            [fileManager createDirectoryAtPath:targetPath withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//    }
//}

- (void)copyMapFilesIfNeeded
{
    NSString *targetRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];
    NSString *sourceRootDir = [[NSBundle mainBundle] pathForResource:DEFAULT_MAP_ROOT ofType:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *md5 = [defaults objectForKey:@"md5"];
    
    NSString *currentMD5 = [MD5Utils md5ForDirectory:sourceRootDir];
    
//    NSLog(@"MD5 Defaults: %@", md5);
//    NSLog(@"MD5 Files: %@", currentMD5);
    
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

        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"地图文件发生改变" message:@"删除旧文件并重新拷贝地图文件" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//        NSLog(@"File Changed");
        
        NSLog(@"地图文件发生改变, 删除旧文件并重新拷贝地图文件");

    }
}

@end
