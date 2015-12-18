//
//  TYWebDownloader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//


#import "TYWebDownloader.h"
#import <MKNetworkKit/MKNetworkKit.h>

@interface TYWebDownloader()
{
    NSString *apiHostName;
}

@end

@implementation TYWebDownloader

- (id)initWithHostName:(NSString *)hostName
{
    self = [super init];
    if (self) {
        apiHostName = hostName;
    }
    return self;
}

- (void)downloadWithApi:(NSString *)api Parameters:(NSDictionary *)params
{
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:apiHostName];
    MKNetworkOperation *op = [engine operationWithPath:api params:params httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(TYWebDownloaderDidFinishDownloading:WithApi:WithResponseData:ResponseString:)]) {
            [self.delegate TYWebDownloaderDidFinishDownloading:self WithApi:api WithResponseData:[operation responseData] ResponseString:[operation responseString]];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(TYWebDownloaderDidFailedDownloading:WithApi:WithError:)]) {
            [self.delegate TYWebDownloaderDidFailedDownloading:self WithApi:api WithError:error];
        }
    }];
    [engine enqueueOperation:op];
    
}

@end
