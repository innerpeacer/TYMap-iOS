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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NPMapEnvironment initMapEnvironment];
    
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
    
    [NPUserDefaults setDefaultCity:@"0021"];
    [NPUserDefaults setDefaultBuilding:@"002100001"];
    [NPUserDefaults setDefaultBuilding:@"002100002"];
//    [NPUserDefaults setDefaultBuilding:@"002100004"];
//    [NPUserDefaults setDefaultBuilding:@"002199999"];
    
    
}

@end

