//
//  TYMapDataDownloader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPMapDataDownloader.h"
#import "TYMapEnviroment.h"
#import "IPMapWebDownloader.h"
#import "IPMapWebObjectConverter.h"
#import "IPMapApi.h"

@interface IPMapDataDownloader() <IPMapWebDownloaderDelegate>
{
    TYMapCredential *user;
    IPMapWebDownloader *downloader;
}

@end

@implementation IPMapDataDownloader

- (id)initWithUser:(TYMapCredential *)u
{
    self = [super init];
    if (self) {
        user = u;
        
        NSString *hostName = [TYMapEnvironment getHostName];
        NSAssert(hostName != nil, @"Host Name must not be nil!");
        downloader = [[IPMapWebDownloader alloc] initWithHostName:hostName];
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

- (void)WebDownloaderDidFinishDownloading:(IPMapWebDownloader *)dataDownloader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString
{
    NSError *error = nil;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        [self notifyFailedDownloadingWithApi:api WithError:error];
        return;
    }
    
    
    BOOL success = [resultDict[TY_RESPONSE_STATUS] boolValue];
    NSString *description = resultDict[TY_RESPONSE_DESCRIPTION];
    int records = [resultDict[TY_RESPONSE_RECORDS] intValue];
    
    if (success) {
        NSArray *mapDataArray = [IPMapWebObjectConverter parseMapDataArray:resultDict[@"mapdatas"]];
        [self notifyDownloadingWithApi:api WithResult:mapDataArray Records:records];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description                                                                     forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"com.ty.mapsdk" code:0 userInfo:userInfo];
        [self notifyFailedDownloadingWithApi:api WithError:error];
    }
    

}

- (void)WebDownloaderDidFailedDownloading:(IPMapWebDownloader *)dataDownloader WithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyFailedDownloadingWithApi:api WithError:error];
}

- (void)notifyFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(MapDataDownloader:DidFailedDownloadingWithApi:WithError:)]) {
        [self.delegate MapDataDownloader:self DidFailedDownloadingWithApi:api WithError:error];
    }
}

- (void)notifyDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(MapDataDownloader:DidFinishDownloadingWithApi:WithResult:Records:)]) {
        [self.delegate MapDataDownloader:self DidFinishDownloadingWithApi:api WithResult:resultArray Records:records];
    }
}

@end