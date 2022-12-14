//
//  TYMapDataUploader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPMapDataUploader.h"
#import "IPMapWebUploader.h"
#import "IPMapWebObjectConverter.h"
#import "TYMapEnviroment.h"

#define DEFAULT_RECORD_LIMIT_PER_UPLOAD 1000

@interface IPMapDataUploader() <IPMapWebUploaderDelegate>
{
    TYMapCredential *user;
    IPMapWebUploader *uploader;
    
    NSMutableArray *batchedMapDataRecords;
    int batchIndex;
}

@end

@implementation IPMapDataUploader

- (id)initWithUser:(TYMapCredential *)u
{
    self = [super init];
    if (self) {
        user = u;
        _recordLimitPerUpload = DEFAULT_RECORD_LIMIT_PER_UPLOAD;
        
        batchedMapDataRecords = [NSMutableArray array];
        
        NSString *hostName = [TYMapEnvironment getHostName];
        NSAssert(hostName != nil, @"Host Name must not be nil!");
        
        uploader = [[IPMapWebUploader alloc] initWithHostName:hostName];
        uploader.delegate = self;
    }
    return self;
}

- (void)uploadMapDataRecords:(NSArray *)records
{
    [self prepareBatchedMapDataRecords:records];
    
    batchIndex = 0;
    if (batchIndex < batchedMapDataRecords.count) {
        [self uploadMapDataWithIndex:batchIndex];
    }
}

- (void)prepareBatchedMapDataRecords:(NSArray *)records
{
    [batchedMapDataRecords removeAllObjects];

    int batchNumber = (int)(records.count / _recordLimitPerUpload) + 1;
    if (records.count % _recordLimitPerUpload == 0) {
        batchNumber = (int)(records.count / _recordLimitPerUpload);
    }
    
    NSLog(@"All Records: %d", (int)records.count);
    batchedMapDataRecords = [NSMutableArray array];
    for (int i = 0; i < batchNumber; ++i) {
        NSMutableArray *array = [NSMutableArray array];
        int start = i * _recordLimitPerUpload;
        int end = (int)MIN((i+1) * _recordLimitPerUpload, records.count);
        for (int j = start; j < end; ++j) {
            [array addObject:records[j]];
        }
        [batchedMapDataRecords addObject:array];
        NSLog(@"[%d, %d]", start, end);
        NSLog(@"Count: %d", (int)array.count);
    }
}

- (void)uploadMapDataWithIndex:(int)index
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValuesForKeysWithDictionary:[user buildDictionary]];
    param[@"first"] = (index == 0) ? @(YES) : @(NO);
    
    NSArray *dataArray = [batchedMapDataRecords objectAtIndex:index];
    param[@"mapdatas"] = [IPMapWebObjectConverter prepareJsonString:[IPMapWebObjectConverter prepareMapDataObjectArray:dataArray]];
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"Data Length: %d", (int)data.length);
    [uploader uploadWithApi:TY_API_UPLOAD_MAP_DATA Parameters:param];
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
    
    BOOL success = [resultDict[TY_RESPONSE_STATUS] boolValue];
    NSString *description = resultDict[TY_RESPONSE_DESCRIPTION];
    
    if (success) {        
        [self notifyUploadingProgress:batchIndex WithApi:api WithDescription:description];
        
        batchIndex++;
        if (batchIndex < batchedMapDataRecords.count) {
            [self uploadMapDataWithIndex:batchIndex];
        } else {
            NSString *finishUploading = @"地图数据上传完毕!";
            [self notifyUploadingWithApi:api WithDescription:finishUploading];
        }
        
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description                                                                     forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"com.ty.mapsdk" code:0 userInfo:userInfo];
        [self notifyFailedUploadingWithApi:api WithError:error];
    }
}

- (void)notifyUploadingProgress:(int)progress WithApi:(NSString *)api WithDescription:(NSString *)responseString
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(MapDataUploader:DidUpdateUploadingProgress:WithApi:WithDescription:)]){
        [self.delegate MapDataUploader:self DidUpdateUploadingProgress:batchIndex WithApi:api WithDescription:responseString];
        NSLog(@"%@", responseString);
    }
}

- (void)notifyFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(MapDataUploader:DidFailedUploadingWithApi:WithError:)]) {
        [self.delegate MapDataUploader:self DidFailedUploadingWithApi:api WithError:error];
    }
}

- (void)notifyUploadingWithApi:(NSString *)api WithDescription:(NSString *)responseString
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(MapDataUploader:DidFinishUploadingWithApi:WithDescription:)]) {
        [self.delegate MapDataUploader:self DidFinishUploadingWithApi:api WithDescription:responseString];
    }
}


@end
