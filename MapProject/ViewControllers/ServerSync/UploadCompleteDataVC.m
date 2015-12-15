//
//  UploadCompleteDataVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "UploadCompleteDataVC.h"
#import <TYMapData/TYMapData.h>
#import "TYCityManager.h"
#import "TYBuildingManager.h"
#import "TYUserDefaults.h"
#import "TYMapInfo.h"
#import "TYWebObjectConverter.h"
#import <MKNetworkKit/MKNetworkKit.h>
#import "TYUserManager.h"

#import "TYCBMUploader.h"
#import "TYCBMDownloader.h"
#import "TYWebDownloader.h"

@interface UploadCompleteDataVC() <TYCBMUploaderDelegate, TYCBMDownloaderDelegate>
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    NSArray *allMapInfos;
    
    NSString *hostName;
    
    TYCBMUploader *dataUploader;
    TYCBMDownloader *dataDownloader;
}

- (IBAction)uploadCompleteData:(id)sender;
- (IBAction)getCompleteData:(id)sender;

@end



@implementation UploadCompleteDataVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentCity = [TYUserDefaults getDefaultCity];
    currentBuilding = [TYUserDefaults getDefaultBuilding];
    allMapInfos = [TYMapInfo parseAllMapInfo:currentBuilding];
    
    hostName = HOST_NAME;
    
    dataUploader = [[TYCBMUploader alloc] initWithUser:[TYUserManager createSuperUser:currentBuilding.buildingID]];
    dataUploader.delegate = self;
    
    dataDownloader = [[TYCBMDownloader alloc] initWithUser:[TYUserManager createTrialUser:currentBuilding.buildingID]];
    dataDownloader.delegate = self;
    
    NSLog(@"%@", currentCity);
    NSLog(@"%@", currentBuilding);
    NSLog(@"%@", allMapInfos);
}

- (void)TYCBMDownloader:(TYCBMDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    NSLog(@"TYDataDownloaderDidFailedDownloading: %@", api);
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)TYCBMDownloader:(TYCBMDownloader *)downloader DidFinishDownloadingCBMWithApi:(NSString *)api WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray
{
    [self addToLog:[NSString stringWithFormat:@"Get City: %@", city.name]];
    [self addToLog:[NSString stringWithFormat:@"Get Building: %@", building.name]];
    [self addToLog:[NSString stringWithFormat:@"Get MapInfos: %d", (int)mapInfoArray.count]];

}

- (void)TYCBMUploader:(TYCBMUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    NSLog(@"TYDataUploaderDidFailedUploading: %@", api);
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)TYCBMUploader:(TYCBMUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    [self addToLog:description];
}

- (IBAction)uploadCompleteData:(id)sender
{
    NSLog(@"uploadCompleteData");
    [self addToLog:[NSString stringWithFormat:@"======= uploadCompleteData:\n%@%@", hostName, TY_API_ADD_CBM]];
    [dataUploader addCompleteCBMWithCity:currentCity Building:currentBuilding MapInfos:allMapInfos];
}

- (IBAction)getCompleteData:(id)sender
{
    NSLog(@"getCompleteData");
    [dataDownloader getCBM];
}

@end
