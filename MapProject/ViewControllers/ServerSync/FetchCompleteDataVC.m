
//
//  FetchCompleteDataVC.m
//  MapProject
//
//  Created by innerpeacer on 15/12/17.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "FetchCompleteDataVC.h"
#import "TYSyncDataManager.h"
#import "TYUserManager.h"
#import "TYUserDefaults.h"
#import "TYMapEnviroment.h"

@interface FetchCompleteDataVC()
{
    TYSyncDataManager *dataManager;
    TYBuilding *currentBuilding;

}

- (IBAction)fetchData:(id)sender;

@end

@implementation FetchCompleteDataVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentBuilding = [TYUserDefaults getDefaultBuilding];

    NSString *testRoot = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Test"];
    dataManager = [[TYSyncDataManager alloc] initWithUser:[TYUserManager createSuperUser:currentBuilding.buildingID] RootDirectory:testRoot];

//    dataManager = [[TYSyncDataManager alloc] initWithUser:[TYUserManager createSuperUser:@"00100003"] RootDirectory:[TYMapEnvironment getRootDirectoryForMapFiles]];
}

- (IBAction)fetchData:(id)sender
{
    NSLog(@"fetchData");
    [dataManager fetchData];
}

@end
