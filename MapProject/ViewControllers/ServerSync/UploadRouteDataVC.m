//
//  UploadRouteDataVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/16.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "UploadRouteDataVC.h"
#import <TYMapData/TYMapData.h>
#import "TYUserDefaults.h"
#import "TYMapFileManager.h"
#import "MapLicenseGenerator.h"
#import "TYSyncMapRouteDBAdapter.h"
#import "TYMapEnviroment.h"
#import <MKNetworkKit/MKNetworkKit.h>
#import "TYUserManager.h"
#import "TYRouteDataUploader.h"
#import "TYRouteDataDownloader.h"

@interface UploadRouteDataVC() <TYRouteDataUploaderDelegate, TYRouteDataDownloaderDelegate>
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    
    NSString *hostName;
    NSArray *allRouteLinkRecords;
    NSArray *allRouteNodeRecords;
    
    TYRouteDataUploader *routeUploader;
    TYRouteDataDownloader *routeDownloader;
}

- (IBAction)uploadRouteData:(id)sender;
- (IBAction)getRouteData:(id)sender;
@end

@implementation UploadRouteDataVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentCity = [TYUserDefaults getDefaultCity];
    currentBuilding = [TYUserDefaults getDefaultBuilding];
    
    hostName = [TYMapEnvironment getHostName];
    
    routeUploader = [[TYRouteDataUploader alloc] initWithUser:[TYUserManager createSuperUser:currentBuilding.buildingID]];
    routeUploader.delegate = self;
    routeDownloader = [[TYRouteDataDownloader alloc] initWithUser:[TYUserManager createTrialUser:currentBuilding.buildingID]];
    routeDownloader.delegate = self;
    
    NSString *dbPath = [TYMapFileManager getMapDataDBPath:currentBuilding];
    TYSyncMapRouteDBAdapter *db = [[TYSyncMapRouteDBAdapter alloc] initWithPath:dbPath];
    [db open];
    allRouteLinkRecords = [db getAllRouteLinkRecords];
    allRouteNodeRecords = [db getAllRouteNodeRecords];
    [db close];
    NSLog(@"%d Links and %d Nodes", (int)allRouteLinkRecords.count, (int)allRouteNodeRecords.count);
}

- (void)TYRouteUploader:(TYRouteDataUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    [self addToLog:description];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"完成" message:description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)TYRouteUploader:(TYRouteDataUploader *)uploader DidUpdateUploadingProgress:(int)batchIndex WithApi:(NSString *)api WithDescription:(NSString *)description
{
    NSString *progress = [NSString stringWithFormat:@"Batch %d: %@", batchIndex, description];
    [self addToLog:progress];
}

- (void)TYRouteUploader:(TYRouteDataUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    NSLog(@"TYRouteUploaderDidFailedUploading: %@", api);
    [self addToLog:[NSString stringWithFormat:@"TYRouteUploader:DidFailedUploadingWithApi: %@", api]];
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)TYRouteDataDownloader:(TYRouteDataDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithLinkResults:(NSArray *)linkArray WithNodeResults:(NSArray *)nodeArray
{
    [self addToLog:[NSString stringWithFormat:@"Get %d links and %d nodes From Server", (int)linkArray.count, (int)nodeArray.count]];
}

- (void)TYRouteDataDownloader:(TYRouteDataDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    NSLog(@"TYDataDownloaderDidFailedDownloading: %@", api);
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)getAllRouteData
{
    [self addToLog:[NSString stringWithFormat:@"======= getRouteData:\n%@%@", hostName, TY_API_GET_TARGET_ROUTE_DATA]];
    [routeDownloader getAllRouteDataRecords];
}

- (IBAction)uploadRouteData:(id)sender
{
    NSLog(@"uploadRouteData");
    [routeUploader uploadRouteLinkRecords:allRouteLinkRecords NodeRecords:allRouteNodeRecords];
}

- (IBAction)getRouteData:(id)sender
{
    NSLog(@"getRouteData");
    [self getAllRouteData];
}

@end
