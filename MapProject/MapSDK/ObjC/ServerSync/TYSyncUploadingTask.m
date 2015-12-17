//
//  TYSyncUploadingTask.m
//  MapProject
//
//  Created by innerpeacer on 15/12/17.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYSyncUploadingTask.h"

//#define TY_SYNC_UPLOADING_STEP_CBM @"City-Building-MapInfos"
//#define TY_SYNC_UPLOADING_STEP_SYMBOLS @"Symbols"
//#define TY_SYNC_UPLOADING_STEP_MAP_DATA @"MapData"
//#define TY_SYNC_UPLOADING_STEP_ROUTE @"RouteData"

#define TY_SYNC_UPLOADING_STEP_UNKNOWN 0
#define TY_SYNC_UPLOADING_STEP_CBM 1
#define TY_SYNC_UPLOADING_STEP_SYMBOLS 2
#define TY_SYNC_UPLOADING_STEP_MAP_DATA 3
#define TY_SYNC_UPLOADING_STEP_ROUTE 4
#define TY_SYNC_UPLOADING_STEP_FINISH 100

#import "TYCBMUploader.h"
#import "TYMapDataUploader.h"
#import "TYRouteDataUploader.h"


@interface TYSyncUploadingTask() <TYCBMUploaderDelegate, TYMapDataUploaderDelegate, TYRouteDataUploaderDelegate>
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
    
    TYCBMUploader *cbmUploader;
    TYMapDataUploader *mapUploader;
    TYRouteDataUploader *routeUploader;
}

@end

@implementation TYSyncUploadingTask

- (id)initWithUser:(TYMapUser *)u
{
    self = [super init];
    if (self) {
        uploadingStep = TY_SYNC_UPLOADING_STEP_UNKNOWN;
        cbmUploader = [[TYCBMUploader alloc] initWithUser:u];
        cbmUploader.delegate = self;
        mapUploader = [[TYMapDataUploader alloc] initWithUser:u];
        mapUploader.delegate = self;
        routeUploader = [[TYRouteDataUploader alloc] initWithUser:u];
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
            [self notifyDidFinishUploading];
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

- (void)notifyDidFinishUploading
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYUploadingTaskDidFinished:)]) {
        [self.delegate TYUploadingTaskDidFinished:self];
    }
}

- (void)notifyDidFailedUploading:(TYSyncUploadingTask *)task InStep:(int)step WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYUploadingTaskDidFailedUploading:InStep:WithError:)]) {
        [self.delegate TYUploadingTaskDidFailedUploading:self InStep:step WithError:error];
    }
    
}

- (void)notifyDidUpdateUploadingProcess:(TYSyncUploadingTask *)task InStep:(int)step WithDescription:(NSString *)description
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYUploadingTaskDidUpdateUploadingProcess:InStep:WithDescription:)]) {
        [self.delegate TYUploadingTaskDidUpdateUploadingProcess:self InStep:step WithDescription:description];
    }
}

#pragma mark -
#pragma mark Uploader Delegate
- (void)TYCBMUploader:(TYCBMUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyDidFailedUploading:self InStep:uploadingStep WithError:error];
}

- (void)TYCBMUploader:(TYCBMUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    [self notifyDidUpdateUploadingProcess:self InStep:uploadingStep WithDescription:description];
    [self finishUploadingStep];
}

- (void)TYMapDataUploader:(TYMapDataUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    [self notifyDidUpdateUploadingProcess:self InStep:uploadingStep WithDescription:description];
    [self finishUploadingStep];
}

- (void)TYMapDataUploader:(TYMapDataUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyDidFailedUploading:self InStep:uploadingStep WithError:error];
}

- (void)TYMapDataUploader:(TYMapDataUploader *)uploader DidUpdateUploadingProgress:(int)batchIndex WithApi:(NSString *)api WithDescription:(NSString *)description
{

}

- (void)TYRouteUploader:(TYRouteDataUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    [self notifyDidUpdateUploadingProcess:self InStep:uploadingStep WithDescription:description];
    [self finishUploadingStep];
}

- (void)TYRouteUploader:(TYRouteDataUploader *)uploader DidUpdateUploadingProgress:(int)batchIndex WithApi:(NSString *)api WithDescription:(NSString *)description
{

}

- (void)TYRouteUploader:(TYRouteDataUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyDidFailedUploading:self InStep:uploadingStep WithError:error];
}


@end
