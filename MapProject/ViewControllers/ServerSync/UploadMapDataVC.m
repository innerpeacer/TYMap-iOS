//
//  UploadMapDataVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/16.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "UploadMapDataVC.h"
#import <TYMapData/TYMapData.h>
#import "TYUserDefaults.h"
#import "IPMapFileManager.h"
#import "IPSyncMapDataDBAdapter.h"
#import "IPWebObjectConverter.h"
#import "TYUserManager.h"
#import <MKNetworkKit/MKNetworkKit.h>
#import "IPSyncMapDataDBAdapter.h"
#import "IPMapDataUploader.h"
#import "IPMapDataDownloader.h"

#define DEFAULT_RECORD_LIMIT_PER_UPLOAD 1500

@interface UploadMapDataVC() <IPMapDataUploaderDelegate, IPMapDataDownloaderDelegate>
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    NSArray *allMapInfos;
    
    NSString *hostName;
    
    NSArray *allMapDataRecords;
    
    IPMapDataUploader *mapUploader;
    IPMapDataDownloader *mapDownloader;
}

- (IBAction)uploadMapData:(id)sender;
- (IBAction)getMapData:(id)sender;

@end

@implementation UploadMapDataVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentCity = [TYUserDefaults getDefaultCity];
    currentBuilding = [TYUserDefaults getDefaultBuilding];
    allMapInfos = [TYMapInfo parseAllMapInfo:currentBuilding];
    
    hostName = HOST_NAME;
    
    mapUploader = [[IPMapDataUploader alloc] initWithUser:[TYUserManager createSuperUser:currentBuilding.buildingID]];
    mapUploader.delegate = self;
    mapDownloader = [[IPMapDataDownloader alloc] initWithUser:[TYUserManager createTrialUser:currentBuilding.buildingID]];
    mapDownloader.delegate = self;
    
    NSString *dbPath = [IPMapFileManager getMapDataDBPath:currentBuilding];
    IPSyncMapDataDBAdapter *db = [[IPSyncMapDataDBAdapter alloc] initWithPath:dbPath];
    [db open];
    allMapDataRecords = [db getAllRecords];
    [db close];
}

- (void)MapDataUploader:(IPMapDataUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    [self addToLog:description];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"完成" message:description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)MapDataUploader:(IPMapDataUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    NSLog(@"TYDataUploaderDidFailedUploading: %@", api);
    [self addToLog:[NSString stringWithFormat:@"TYMapDataUploader:DidFailedUploadingWithApi: %@", api]];
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)MapDataUploader:(IPMapDataUploader *)uploader DidUpdateUploadingProgress:(int)batchIndex WithApi:(NSString *)api WithDescription:(NSString *)description
{
    NSString *progress = [NSString stringWithFormat:@"Batch %d: %@", batchIndex, description];
    [self addToLog:progress];
}

- (void)MapDataDownloader:(IPMapDataDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    NSLog(@"TYDataDownloaderDidFailedDownloading: %@", api);
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)MapDataDownloader:(IPMapDataDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records
{
    [self addToLog:[NSString stringWithFormat:@"Records: %d", records]];
    [self addToLog:[NSString stringWithFormat:@"Get %d MapDataRecords From Server", (int)resultArray.count]];
}

- (void)getAllMapData
{
    [self addToLog:[NSString stringWithFormat:@"======= getMapData:\n%@%@", hostName, TY_API_GET_TARGET_MAPDATA]];
    [mapDownloader getAllMapDataRecords];
}

- (IBAction)uploadMapData:(id)sender
{
    NSLog(@"uploadMapData");
    [mapUploader uploadMapDataRecords:allMapDataRecords];
}

- (IBAction)getMapData:(id)sender
{
    NSLog(@"getMapData");
    [self getAllMapData];
}

@end
