//
//  TYMapDataDownloader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYMapDataDownloader.h"
#import "TYMapEnviroment.h"
#import "TYWebDownloader.h"
#import "TYWebObjectConverter.h"
#import "TYMapCredential_Private.h"

@interface TYMapDataDownloader() <TYWebDownloaderDelegate>
{
    TYMapCredential *user;
    TYWebDownloader *downloader;
}

@end

@implementation TYMapDataDownloader

- (id)initWithUser:(TYMapCredential *)u
{
    self = [super init];
    if (self) {
        user = u;
        
        NSString *hostName = [TYMapEnvironment getHostName];
        NSAssert(hostName != nil, @"Host Name must not be nil!");
        downloader = [[TYWebDownloader alloc] initWithHostName:hostName];
        downloader.delegate = self;
    }
    return self;
}

- (void)getAllMapDataRecords
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValuesForKeysWithDictionary:[user buildDictionary]];
    [downloader downloadWithApi:TY_API_GET_TARGET_MAPDATA Parameters:param];
}

- (void)TYWebDownloaderDidFinishDownloading:(TYWebDownloader *)dataDownloader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString
{
    NSError *error = nil;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        [self notifyDidFailedDownloadingWithApi:api WithError:error];
        return;
    }
    
    
    BOOL success = [resultDict[TY_RESPONSE_STATUS] boolValue];
    NSString *description = resultDict[TY_RESPONSE_DESCRIPTION];
    int records = [resultDict[TY_RESPONSE_RECORDS] intValue];
    
    if (success) {
        NSArray *mapDataArray = [TYWebObjectConverter parseMapDataArray:resultDict[@"mapdatas"]];
        [self notifyDidFinishDownloadingWithApi:api WithResult:mapDataArray Records:records];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description                                                                     forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"com.ty.mapsdk" code:0 userInfo:userInfo];
        [self notifyDidFailedDownloadingWithApi:api WithError:error];
    }
    

}

- (void)TYWebDownloaderDidFailedDownloading:(TYWebDownloader *)dataDownloader WithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyDidFailedDownloadingWithApi:api WithError:error];
}

- (void)notifyDidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYMapDataDownloader:DidFailedDownloadingWithApi:WithError:)]) {
        [self.delegate TYMapDataDownloader:self DidFailedDownloadingWithApi:api WithError:error];
    }
}

- (void)notifyDidFinishDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYMapDataDownloader:DidFinishDownloadingWithApi:WithResult:Records:)]) {
        [self.delegate TYMapDataDownloader:self DidFinishDownloadingWithApi:api WithResult:resultArray Records:records];
    }
}

@end