//
//  TYWebDownloader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//


#import "IPWebDownloader.h"
#import <MKNetworkKit/MKNetworkKit.h>

@interface IPWebDownloader()
{
    NSString *apiHostName;
}

@end

@implementation IPWebDownloader

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
        if (self.delegate && [self.delegate respondsToSelector:@selector(WebDownloaderDidFinishDownloading:WithApi:WithResponseData:ResponseString:)]) {
            [self.delegate WebDownloaderDidFinishDownloading:self WithApi:api WithResponseData:[operation responseData] ResponseString:[operation responseString]];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(WebDownloaderDidFailedDownloading:WithApi:WithError:)]) {
            [self.delegate WebDownloaderDidFailedDownloading:self WithApi:api WithError:error];
        }
    }];
    [engine enqueueOperation:op];
    
}

@end
