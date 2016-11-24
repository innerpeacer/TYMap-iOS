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

#import <MKNetworkKit/MKNetworkKit.h>

@implementation AppDelegate

- (void)testLicense
{
    NSString *buildingID = @"WD010012";
    NSString *date = @"20170630";
    NSString *userID = TRIAL_USER_ID;
    NSString *license = [MapLicenseGenerator generateBase64License40ForUserID:userID Building:buildingID ExpiredDate:date];
    NSLog(@"License: %@", license);
    
    TYBuilding *building = [[TYBuilding alloc] init];
    building.buildingID = buildingID;
    BOOL success = [IPLicenseValidation checkValidityWithUserID:userID License:license Building:building];
    NSLog(@"Success: %d", success);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
//    NSLog(@"bundleID: %@", bundleID);
    [self testLicense];
    
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"%@", documentDirectory);
    
    [TYMapEnvironment initMapEnvironment];
    [TYMapEnvironment setHostName:HOST_NAME];

    [TYMapEnvironment setRootDirectoryForMapFiles:[documentDirectory stringByAppendingPathComponent:DEFAULT_MAP_ROOT]];

    [self copyMapFilesIfNeeded];
    [self setDefaultPlaceIfNeeded];
    
    [self testPost];
    
    return YES;
}

- (void)testPost
{
    NSLog(@"testPost");
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"localhost:8112"];
    MKNetworkOperation *op = [engine operationWithPath:@"/BrtBeaconLBSServer/testServlet" params:@{} httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"%@", operation.responseString);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"%@", completedOperation.responseString);
        NSLog(@"%@", [error localizedDescription]);
        
    }];
    [engine enqueueOperation:op];
}


- (void)setDefaultPlaceIfNeeded
{
    if ([TYUserDefaults getDefaultBuilding] == nil) {
        [TYUserDefaults setDefaultCity:@"0021"];
        [TYUserDefaults setDefaultBuilding:@"00210025"];
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
