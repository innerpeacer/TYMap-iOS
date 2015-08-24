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
    
//    [self testJson];
    
    return YES;
}

- (void)testJson
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"00210100F10" ofType:@"data"];
    NSError *error = nil;
    NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return;
    }

    AGSSBJsonParser *parser = [[AGSSBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString];
//    NSLog(@"%@", dict);
    
    AGSFeatureSet *set = [[AGSFeatureSet alloc] initWithJSON:[dict objectForKey:@"room"]];
    NSLog(@"%@", set);
    NSArray *allGraphics = set.features;
    for (AGSGraphic *graphic in allGraphics) {
        NSLog(@"%@", graphic);
    }

}

- (void)setDefaultPlaceIfNeeded
{
    if ([TYUserDefaults getDefaultBuilding] == nil) {
        [TYUserDefaults setDefaultCity:@"0021"];
        [TYUserDefaults setDefaultBuilding:@"00210100"];
    }
    
//    [TYUserDefaults setDefaultCity:@"0021"];
//    [TYUserDefaults setDefaultBuilding:@"002100001"];
//    [TYUserDefaults setDefaultBuilding:@"002100002"];
//    [TYUserDefaults setDefaultBuilding:@"002100004"];
//    [TYUserDefaults setDefaultBuilding:@"002100005"];
//        [TYUserDefaults setDefaultBuilding:@"002100006"];
//            [TYUserDefaults setDefaultBuilding:@"00210100"];

    
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

