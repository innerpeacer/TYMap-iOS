//
//  TYRouteDataDownloader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapCredential.h"

@class IPRouteDataDownloader;

@protocol IPRouteDataDownloaderDelegate <NSObject>
- (void)TYRouteDataDownloader:(IPRouteDataDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithLinkResults:(NSArray *)linkArray WithNodeResults:(NSArray *)nodeArray;
- (void)TYRouteDataDownloader:(IPRouteDataDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error;
@end

@interface IPRouteDataDownloader : NSObject

- (id)initWithUser:(TYMapCredential *)user;
@property (nonatomic, weak) id<IPRouteDataDownloaderDelegate> delegate;

- (void)getAllRouteDataRecords;

@end
