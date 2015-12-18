//
//  TYRouteDataUploader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYRouteDataUploader.h"
#import "TYWebUploader.h"
#import "TYWebObjectConverter.h"
#import "TYMapEnviroment.h"
#import "TYMapCredential_Private.h"

#define DEFAULT_RECORD_LIMIT_PER_UPLOAD 1500

@interface TYRouteDataUploader() <TYWebUploaderDelegate>
{
    TYMapCredential *user;
    TYWebUploader *uploader;
    
    NSMutableArray *batchedRouteDataRecords;
    NSMutableArray *isLinkbatchTypeArray;
    int batchIndex;
}

@end

@implementation TYRouteDataUploader

- (id)initWithUser:(TYMapCredential *)u
{
    self = [super init];
    if (self) {
        user = u;
        _recordLimitPerUpload = DEFAULT_RECORD_LIMIT_PER_UPLOAD;
        
        batchedRouteDataRecords = [NSMutableArray array];
        isLinkbatchTypeArray = [NSMutableArray array];
        
        NSString *hostName = [TYMapEnvironment getHostName];
        NSAssert(hostName != nil, @"Host Name must not be nil!");

        uploader = [[TYWebUploader alloc] initWithHostName:hostName];
        uploader.delegate = self;
    }
    return self;
}

- (void)uploadRouteLinkRecords:(NSArray *)linkRecords NodeRecords:(NSArray *)nodeRecords
{
    [self prepareBatchedRouteLinkRecords:linkRecords NodeRecords:nodeRecords];
    
    batchIndex = 0;
    if (batchIndex < batchedRouteDataRecords.count) {
        [self uploadRouteRecordsWithIndex:batchIndex];
    }
}

- (void)prepareBatchedRouteLinkRecords:(NSArray *)linkRecords NodeRecords:(NSArray *)nodeRecords
{
    [batchedRouteDataRecords removeAllObjects];
    isLinkbatchTypeArray = [NSMutableArray array];
    
    int linkBatchNumber = (int)(linkRecords.count / _recordLimitPerUpload) + 1;
    if (linkRecords.count % _recordLimitPerUpload == 0) {
        linkBatchNumber = (int)(linkRecords.count / _recordLimitPerUpload);
    }
    
    NSLog(@"All Links: %d", (int)linkRecords.count);
    for (int i = 0; i < linkBatchNumber; ++i) {
        NSMutableArray *array = [NSMutableArray array];
        int start = i * _recordLimitPerUpload;
        int end = (int)MIN((i+1) * _recordLimitPerUpload, linkRecords.count);
        for (int j = start; j < end; ++j) {
            [array addObject:linkRecords[j]];
        }
        
        [batchedRouteDataRecords addObject:array];
        [isLinkbatchTypeArray addObject:@(YES)];
        NSLog(@"[%d, %d]", start, end);
    }
    
    int nodeBatchNumber = (int)(nodeRecords.count / _recordLimitPerUpload) + 1;
    if (nodeRecords.count % _recordLimitPerUpload == 0) {
        nodeBatchNumber = (int)(nodeRecords.count / _recordLimitPerUpload);
    }
    
    NSLog(@"All Nodes: %d", (int)nodeRecords.count);
    for (int i = 0; i < nodeBatchNumber; ++i) {
        NSMutableArray *array = [NSMutableArray array];
        int start = i * _recordLimitPerUpload;
        int end = (int)MIN((i+1) * _recordLimitPerUpload, nodeRecords.count);
        for (int j = start; j < end; ++j) {
            [array addObject:nodeRecords[j]];
        }
        
        [batchedRouteDataRecords addObject:array];
        [isLinkbatchTypeArray addObject:@(NO)];
        NSLog(@"[%d, %d]", start, end);
    }
 }

- (void)uploadRouteRecordsWithIndex:(int)index
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValuesForKeysWithDictionary:[user buildDictionary]];
    param[@"first"] = (index == 0) ? @(YES) : @(NO);
    
    NSArray *dataArray = batchedRouteDataRecords[index];
    BOOL isLinkBatchType = [isLinkbatchTypeArray[index] boolValue];
    
    NSMutableDictionary *routeDataDict = [NSMutableDictionary dictionary];
    if (isLinkBatchType) {
        routeDataDict[@"links"] = [TYWebObjectConverter prepareRouteLinkObjectArray:dataArray];
    } else {
        routeDataDict[@"nodes"] = [TYWebObjectConverter prepareRouteNodeObjectArray:dataArray];
    }
    param[@"routedatas"] = [TYWebObjectConverter prepareJsonString:routeDataDict];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"Data Length: %d", (int)data.length);
    [uploader uploadWithApi:TY_API_UPLOAD_ROUTE_DATA Parameters:param];
}

- (void)TYWebUploaderDidFailedUploading:(TYWebUploader *)uploader WithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyDidFailedUploadingWithApi:api WithError:error];
}

- (void)TYWebUploaderDidFinishUploading:(TYWebUploader *)uploader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString
{
    NSError *error = nil;
    
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        [self notifyDidFailedUploadingWithApi:api WithError:error];
        return;
    }
    
    BOOL success = [resultDict[TY_RESPONSE_STATUS] boolValue];
    NSString *description = resultDict[TY_RESPONSE_DESCRIPTION];
    
    if (success) {
        [self notifyDidUpdateUploadingProgress:batchIndex WithApi:api WithDescription:description];
        
        batchIndex++;
        if (batchIndex < batchedRouteDataRecords.count) {
            [self uploadRouteRecordsWithIndex:batchIndex];
        } else {
            NSString *finishUploading = @"路网数据上传完毕!";
            [self notifyDidFinishUploadingWithApi:api WithDescription:finishUploading];
        }
        
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description                                                                     forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"com.ty.mapsdk" code:0 userInfo:userInfo];
        [self notifyDidFailedUploadingWithApi:api WithError:error];
    }
}

- (void)notifyDidUpdateUploadingProgress:(int)progress WithApi:(NSString *)api WithDescription:(NSString *)description
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYRouteUploader:DidUpdateUploadingProgress:WithApi:WithDescription:)]){
        [self.delegate TYRouteUploader:self DidUpdateUploadingProgress:progress WithApi:api WithDescription:description];
    }
}

- (void)notifyDidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYRouteUploader:DidFailedUploadingWithApi:WithError:)]) {
        [self.delegate TYRouteUploader:self DidFailedUploadingWithApi:api WithError:error];
    }
}

- (void)notifyDidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYRouteUploader:DidFinishUploadingWithApi:WithDescription:)]) {
        [self.delegate TYRouteUploader:self DidFinishUploadingWithApi:api WithDescription:description];
    }
}

@end
