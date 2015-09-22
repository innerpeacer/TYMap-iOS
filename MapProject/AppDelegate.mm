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
#import "TYLicenseManager.h"

@implementation AppDelegate

NSArray *DataArray = @[
  @{@"userID": @"4e13f85911a44a75adccaccf8eb96c9c", @"buildingID": @"00210001", @"key": @"2ca52346ef70cke47afoaf5a8996bf4f"},
  @{@"userID": @"4e13f85911a44a75adccaccf8eb96c9c", @"buildingID": @"00210002", @"key": @"e5123655dae138656f4n15fcdca50176"},
   @{@"userID": @"4e13f85911a44a75adccaccf8eb96c9c", @"buildingID": @"00210003", @"key": @"eb28552e94gj5:27k36577b`59f7a434"},
  ];


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"%@", documentDirectory);
    
    [TYMapEnvironment initMapEnvironment];
    [EnviromentManager switchToOriginal];

    [self copyMapFilesIfNeeded];
    [self setDefaultPlaceIfNeeded];
    
//    NSLog(@"==================================");
    [self generateLicenses];
//    NSLog(@"==================================");
    [self checkLicenses];
    
    return YES;
}

- (void)checkLicenses
{
    for (NSDictionary *dict in DataArray) {
        NSString *userID = [dict objectForKey:@"userID"];
        NSString *buildingID = [dict objectForKey:@"buildingID"];
        NSString *license = [dict objectForKey:@"key"];
        
//        NSLog(@"%@, %@, %@", userID, buildingID, license);
        
        TYBuilding *building = [[TYBuilding alloc] init];
        building.buildingID = buildingID;
        
        NSDate *date = [TYLicenseManager evaluateLicenseWithUserID:userID License:license Building:building];
        if ([TYLicenseManager checkValidityWithUserID:userID License:license Building:building]) {
//            NSLog(@"Valid License");
        } else {
//            NSLog(@"Not Valid License");
        }
//        NSLog(@"Date: %@", date);
        break;
    }
}

- (void)generateLicenses
{
    NSString *userID = @"4e13f85911a44a75adccaccf8eb96c9c";
    NSString *buildingID = @"00210001";
    NSString *expiredDate = @"20170101";
    
    [LicenseGenerator generateLicenseForUserID:userID Building:buildingID ExpiredDate:expiredDate];
    [LicenseGenerator generateLicenseForUserID:userID Building:@"00210002" ExpiredDate:expiredDate];
    [LicenseGenerator generateLicenseForUserID:userID Building:@"00210003" ExpiredDate:expiredDate];
}

- (void)setDefaultPlaceIfNeeded
{
    if ([TYUserDefaults getDefaultBuilding] == nil) {
//        [TYUserDefaults setDefaultCity:@"0021"];
//        [TYUserDefaults setDefaultBuilding:@"00210100"];
        [TYUserDefaults setDefaultCity:@"0020"];
        [TYUserDefaults setDefaultBuilding:@"00200001"];
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
            NSLog(@"Error: %@", [error localizedDescription]);
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

        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"地图文件发生改变" message:@"删除旧文件并重新拷贝地图文件" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        NSLog(@"File Changed");
    }
}

@end
