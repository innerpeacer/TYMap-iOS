//
//  TYRouteDataDownloader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPRouteDataDownloader.h"
#import "TYMapEnviroment.h"
#import "IPMapWebDownloader.h"
#import "IPMapWebObjectConverter.h"
#import "TYMapCredential_Private.h"
#import "IPMapApi.h"

@interface IPRouteDataDownloader() <IPMapWebDownloaderDelegate>
{
    TYMapCredential *user;
    IPMapWebDownloader *downloader;
}

@end

@implementation IPRouteDataDownloader

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

- (void)getAllRouteDataRecords
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValuesForKeysWithDictionary:[user buildDictionary]];
    [downloader downloadWithApi:TY_API_GET_TARGET_ROUTE_DATA Parameters:param];
}

- (void)WebDownloaderDidFailedDownloading:(IPMapWebDownloader *)downloader WithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyFailedDownloadingWithApi:api WithError:error];
}

- (void)WebDownloaderDidFinishDownloading:(IPMapWebDownloader *)downloader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSArray *routeLinkArray = [IPMapWebObjectConverter parseRouteLinkArray:dict[@"routedatas"][@"links"]];
    NSArray *routeNodeArray = [IPMapWebObjectConverter parseRouteNodeArray:dict[@"routedatas"][@"nodes"]];
    [self notifyDownloadingWithApi:api WithLinkResults:routeLinkArray WithNodeResults:routeNodeArray];
}

- (void)notifyFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(RouteDataDownloader:DidFailedDownloadingWithApi:WithError:)]) {
        [self.delegate RouteDataDownloader:self DidFailedDownloadingWithApi:api WithError:error];
    }
}

- (void)notifyDownloadingWithApi:(NSString *)api WithLinkResults:(NSArray *)linkArray WithNodeResults:(NSArray *)nodeArray
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(RouteDataDownloader:DidFinishDownloadingWithApi:WithLinkResults:WithNodeResults:)]) {
        [self.delegate RouteDataDownloader:self DidFinishDownloadingWithApi:api WithLinkResults:linkArray WithNodeResults:nodeArray];
    }
}

@end
