//
//  TYSyncUploadingTask.m
//  MapProject
//
//  Created by innerpeacer on 15/12/17.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPSyncUploadingTask.h"

#define TY_SYNC_UPLOADING_STEP_UNKNOWN 0
#define TY_SYNC_UPLOADING_STEP_CBM 1
#define TY_SYNC_UPLOADING_STEP_SYMBOLS 2
#define TY_SYNC_UPLOADING_STEP_MAP_DATA 3
#define TY_SYNC_UPLOADING_STEP_ROUTE 4
#define TY_SYNC_UPLOADING_STEP_FINISH 100

#import "IPCBMUploader.h"
#import "IPMapDataUploader.h"
#import "IPRouteDataUploader.h"


@interface IPSyncUploadingTask() <IPCBMUploaderDelegate, IPMapDataUploaderDelegate, IPRouteDataUploaderDelegate>
{
    int uploadingStep;
    
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    NSArray *allMapInfos;
    
    NSArray *allMapDataRecords;
    NSArray *allRouteLinkRecords;
    NSArray *allRouteNodeRecords;
    
    NSArray *allFillSymbols;
    NSArray *allIconSymbols;
    
    IPCBMUploader *cbmUploader;
    IPMapDataUploader *mapUploader;
    IPRouteDataUploader *routeUploader;
}

@end

@implementation IPSyncUploadingTask

- (id)initWithUser:(TYMapCredential *)u
{
    self = [super init];
    if (self) {
        uploadingStep = TY_SYNC_UPLOADING_STEP_UNKNOWN;
        cbmUploader = [[IPCBMUploader alloc] initWithUser:u];
        cbmUploader.delegate = self;
        mapUploader = [[IPMapDataUploader alloc] initWithUser:u];
        mapUploader.delegate = self;
        routeUploader = [[IPRouteDataUploader alloc] initWithUser:u];
        routeUploader.delegate = self;
    }
    return self;
}

- (void)uploadCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray FillSymbols:(NSArray *)fillArray IconSymbols:(NSArray *)iconArray MapData:(NSArray *)mapDataArray RouteLinkData:(NSArray *)linkArray RouteNodeData:(NSArray *)nodeArray
{
    currentCity = city;
    currentBuilding = building;
    allMapInfos = mapInfoArray;
    allFillSymbols = fillArray;
    allIconSymbols = iconArray;
    allMapDataRecords = mapDataArray;
    allRouteLinkRecords = linkArray;
    allRouteNodeRecords = nodeArray;
    
    uploadingStep = TY_SYNC_UPLOADING_STEP_CBM;
    [self performUploadingStep];
}

- (void)finishUploadingStep
{
    switch (uploadingStep) {
        case TY_SYNC_UPLOADING_STEP_CBM:
            uploadingStep = TY_SYNC_UPLOADING_STEP_SYMBOLS;
            [self performUploadingStep];
            break;
            
        case TY_SYNC_UPLOADING_STEP_SYMBOLS:
            uploadingStep = TY_SYNC_UPLOADING_STEP_MAP_DATA;
            [self performUploadingStep];
            break;
            
        case TY_SYNC_UPLOADING_STEP_MAP_DATA:
            uploadingStep = TY_SYNC_UPLOADING_STEP_ROUTE;
            [self performUploadingStep];
            break;
            
        case TY_SYNC_UPLOADING_STEP_ROUTE:
            uploadingStep = TY_SYNC_UPLOADING_STEP_FINISH;
            [self notifyFinishUploading];
            break;
            
        default:
            break;
    }
    
    
}

- (void)performUploadingStep
{
    switch (uploadingStep) {
        case TY_SYNC_UPLOADING_STEP_CBM:
            [cbmUploader addCompleteCBMWithCity:currentCity Building:currentBuilding MapInfos:allMapInfos];
            break;
            
        case TY_SYNC_UPLOADING_STEP_SYMBOLS:
            [cbmUploader uploadSymbolsWithFill:allFillSymbols Icons:allIconSymbols];
            break;
            
        case TY_SYNC_UPLOADING_STEP_MAP_DATA:
            [mapUploader uploadMapDataRecords:allMapDataRecords];
            break;
            
        case TY_SYNC_UPLOADING_STEP_ROUTE:
            [routeUploader uploadRouteLinkRecords:allRouteLinkRecords NodeRecords:allRouteNodeRecords];
            break;
            
        default:
            break;
    }

}

- (void)notifyFinishUploading
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(UploadingTaskDidFinished:)]) {
        [self.delegate UploadingTaskDidFinished:self];
    }
}

- (void)notifyDidFailedUploading:(IPSyncUploadingTask *)task InStep:(int)step WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(UploadingTaskDidFailedUploading:InStep:WithError:)]) {
        [self.delegate UploadingTaskDidFailedUploading:self InStep:step WithError:error];
    }
    
}

- (void)notifyDidUpdateUploadingProcess:(IPSyncUploadingTask *)task InStep:(int)step WithDescription:(NSString *)description
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(UploadingTaskDidUpdateUploadingProcess:InStep:WithDescription:)]) {
        [self.delegate UploadingTaskDidUpdateUploadingProcess:self InStep:step WithDescription:description];
    }
}

#pragma mark -
#pragma mark Uploader Delegate
- (void)CBMUploader:(IPCBMUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyDidFailedUploading:self InStep:uploadingStep WithError:error];
}

- (void)CBMUploader:(IPCBMUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    [self notifyDidUpdateUploadingProcess:self InStep:uploadingStep WithDescription:description];
    [self finishUploadingStep];
}

- (void)MapDataUploader:(IPMapDataUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    [self notifyDidUpdateUploadingProcess:self InStep:uploadingStep WithDescription:description];
    [self finishUploadingStep];
}

- (void)MapDataUploader:(IPMapDataUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyDidFailedUploading:self InStep:uploadingStep WithError:error];
}

- (void)MapDataUploader:(IPMapDataUploader *)uploader DidUpdateUploadingProgress:(int)batchIndex WithApi:(NSString *)api WithDescription:(NSString *)description
{

}

- (void)RouteUploader:(IPRouteDataUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    [self notifyDidUpdateUploadingProcess:self InStep:uploadingStep WithDescription:description];
    [self finishUploadingStep];
}

- (void)RouteUploader:(IPRouteDataUploader *)uploader DidUpdateUploadingProgress:(int)batchIndex WithApi:(NSString *)api WithDescription:(NSString *)description
{

}

- (void)RouteUploader:(IPRouteDataUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyDidFailedUploading:self InStep:uploadingStep WithError:error];
}


@end
