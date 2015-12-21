//
//  TYRouteDataDownloader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPRouteDataDownloader.h"
#import "TYMapEnviroment.h"
#import "IPWebDownloader.h"
#import "IPWebObjectConverter.h"
#import "TYMapCredential_Private.h"

@interface IPRouteDataDownloader() <IPWebDownloaderDelegate>
{
    TYMapCredential *user;
    IPWebDownloader *downloader;
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
        
        downloader = [[IPWebDownloader alloc] initWithHostName:hostName];
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

- (void)TYWebDownloaderDidFailedDownloading:(IPWebDownloader *)downloader WithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyDidFailedDownloadingWithApi:api WithError:error];
}

- (void)TYWebDownloaderDidFinishDownloading:(IPWebDownloader *)downloader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSArray *routeLinkArray = [IPWebObjectConverter parseRouteLinkArray:dict[@"routedatas"][@"links"]];
    NSArray *routeNodeArray = [IPWebObjectConverter parseRouteNodeArray:dict[@"routedatas"][@"nodes"]];
    [self notifyDidFinishDownloadingWithApi:api WithLinkResults:routeLinkArray WithNodeResults:routeNodeArray];
}

- (void)notifyDidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYRouteDataDownloader:DidFailedDownloadingWithApi:WithError:)]) {
        [self.delegate TYRouteDataDownloader:self DidFailedDownloadingWithApi:api WithError:error];
    }
}

- (void)notifyDidFinishDownloadingWithApi:(NSString *)api WithLinkResults:(NSArray *)linkArray WithNodeResults:(NSArray *)nodeArray
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYRouteDataDownloader:DidFinishDownloadingWithApi:WithLinkResults:WithNodeResults:)]) {
        [self.delegate TYRouteDataDownloader:self DidFinishDownloadingWithApi:api WithLinkResults:linkArray WithNodeResults:nodeArray];
    }
}

@end
