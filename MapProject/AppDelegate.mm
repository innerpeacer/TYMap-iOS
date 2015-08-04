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
#import "IPMemery.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"%@", documentDirectory);

    [TYMapEnvironment initMapEnvironment];
    
    [self copyMapFilesIfNeeded];
    [self setDefaultPlaceIfNeeded];
        
    return YES;
}

- (void)testEncryption
{
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"002100001F04_FLOOR" ofType:@"json"];
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *eFile = [documentDirectory stringByAppendingPathComponent:@"Encrypted.json"];
    
    NSString *str = @"Hello World!你好";
//    NSString *str = @"Hello World!";

    NSLog(@"%@", str);
    {
        NSLog(@"==== ObjC ==> ");
        NSLog(@"%@", [TYEncryption encryptString:str]);
    }
    
    {
        NSLog(@"==== C++ ==> ");
        NSLog(@"%s", encryptString([str UTF8String]).c_str());
        
        encryptFile([file UTF8String], [eFile UTF8String]);
    }
}

- (void)setDefaultPlaceIfNeeded
{
    [TYUserDefaults setDefaultCity:@"0021"];
    [TYUserDefaults setDefaultBuilding:@"002100001"];
    [TYUserDefaults setDefaultBuilding:@"002100002"];
//    [TYUserDefaults setDefaultBuilding:@"002100004"];
//    [TYUserDefaults setDefaultBuilding:@"002100005"];
        [TYUserDefaults setDefaultBuilding:@"002100006"];
            [TYUserDefaults setDefaultBuilding:@"00210100"];

    
    //    [TYUserDefaults setDefaultBuilding:@"002188888"];
    //    [TYUserDefaults setDefaultBuilding:@"002199999"];
    //
//        [TYUserDefaults setDefaultCity:@"H852"];
//        [TYUserDefaults setDefaultBuilding:@"H85200001"];
    //
    //    [TYUserDefaults setDefaultCity:@"H852"];
    //    [TYUserDefaults setDefaultBuilding:@"H85200001"];
    //
//            [TYUserDefaults setDefaultCity:@"0755"];
//            [TYUserDefaults setDefaultBuilding:@"075500001"];
    
    
//    [TYUserDefaults setDefaultCity:@"0452"];
//    [TYUserDefaults setDefaultBuilding:@"04520001"];
    
//    [TYUserDefaults setDefaultCity:@"0571"];
//    [TYUserDefaults setDefaultBuilding:@"05710001"];
    
    
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

