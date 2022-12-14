//
//  TYRouteDataUploader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPRouteDataUploader.h"
#import "IPMapWebUploader.h"
#import "IPMapWebObjectConverter.h"
#import "TYMapEnviroment.h"

#define DEFAULT_RECORD_LIMIT_PER_UPLOAD 1500

@interface IPRouteDataUploader() <IPMapWebUploaderDelegate>
{
    TYMapCredential *user;
    IPMapWebUploader *uploader;
    
    NSMutableArray *batchedRouteDataRecords;
    NSMutableArray *isLinkbatchTypeArray;
    int batchIndex;
}

@end

@implementation IPRouteDataUploader

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

        uploader = [[IPMapWebUploader alloc] initWithHostName:hostName];
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
        routeDataDict[@"links"] = [IPMapWebObjectConverter prepareRouteLinkObjectArray:dataArray];
    } else {
        routeDataDict[@"nodes"] = [IPMapWebObjectConverter prepareRouteNodeObjectArray:dataArray];
    }
    param[@"routedatas"] = [IPMapWebObjectConverter prepareJsonString:routeDataDict];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"Data Length: %d", (int)data.length);
    [uploader uploadWithApi:TY_API_UPLOAD_ROUTE_DATA Parameters:param];
}

- (void)WebUploaderDidFailedUploading:(IPMapWebUploader *)uploader WithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyFailedUploadingWithApi:api WithError:error];
}

- (void)WebUploaderDidFinishUploading:(IPMapWebUploader *)uploader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString
{
    NSError *error = nil;
    
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        [self notifyFailedUploadingWithApi:api WithError:error];
        return;
    }
    
    NSLog(@"Route Response: %@", responseString);
    BOOL success = [resultDict[TY_RESPONSE_STATUS] boolValue];
    NSString *description = resultDict[TY_RESPONSE_DESCRIPTION];
    
    if (success) {
        [self notifyUploadingProgress:batchIndex WithApi:api WithDescription:description];
        
        batchIndex++;
        if (batchIndex < batchedRouteDataRecords.count) {
            [self uploadRouteRecordsWithIndex:batchIndex];
        } else {
            NSString *finishUploading = @"路网数据上传完毕!";
            [self notifyUploadingWithApi:api WithDescription:finishUploading];
        }
        
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description                                                                     forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"com.ty.mapsdk" code:0 userInfo:userInfo];
        [self notifyFailedUploadingWithApi:api WithError:error];
    }
}

- (void)notifyUploadingProgress:(int)progress WithApi:(NSString *)api WithDescription:(NSString *)description
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(RouteUploader:DidUpdateUploadingProgress:WithApi:WithDescription:)]){
        [self.delegate RouteUploader:self DidUpdateUploadingProgress:progress WithApi:api WithDescription:description];
    }
}

- (void)notifyFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(RouteUploader:DidFailedUploadingWithApi:WithError:)]) {
        [self.delegate RouteUploader:self DidFailedUploadingWithApi:api WithError:error];
    }
}

- (void)notifyUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(RouteUploader:DidFinishUploadingWithApi:WithDescription:)]) {
        [self.delegate RouteUploader:self DidFinishUploadingWithApi:api WithDescription:description];
    }
}

@end
