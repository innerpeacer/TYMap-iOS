
//
//  FetchCompleteDataVC.m
//  MapProject
//
//  Created by innerpeacer on 15/12/17.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "FetchCompleteDataVC.h"
#import "TYMapDataManager.h"
#import "TYUserManager.h"
#import "TYUserDefaults.h"
#import "TYMapEnviroment.h"

@interface FetchCompleteDataVC() <TYMapDataManagerDelegate>
{
    TYMapDataManager *dataManager;
    TYBuilding *currentBuilding;

}

- (IBAction)fetchData:(id)sender;

@end

@implementation FetchCompleteDataVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentBuilding = [TYUserDefaults getDefaultBuilding];

    TYMapCredential *user = [TYUserManager createTrialUser:currentBuilding.buildingID];
    dataManager = [[TYMapDataManager alloc] initWithUserID:user.userID BuildingID:currentBuilding.buildingID License:user.license];
    dataManager.delegate = self;
}

- (IBAction)fetchData:(id)sender
{
    NSLog(@"fetchData");
    [dataManager fetchMapData];
}

- (void)TYMapDataManagerDidFailedFetchingData:(TYMapDataManager *)manager WithError:(NSError *)error
{
    
}

- (void)TYMapDataManagerDidFinishFetchingData:(TYMapDataManager *)manager
{
    [self addToLog:@"Finish Fetch Data"];
}

@end
