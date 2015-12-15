//
//  TYRouteDataDownloader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapUser.h"

@class TYRouteDataDownloader;

@protocol TYRouteDataDownloaderDelegate <NSObject>
- (void)TYRouteDataDownloader:(TYRouteDataDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithLinkResults:(NSArray *)linkArray WithNodeResults:(NSArray *)nodeArray;
- (void)TYRouteDataDownloader:(TYRouteDataDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error;
@end

@interface TYRouteDataDownloader : NSObject

- (id)initWithUser:(TYMapUser *)user;
@property (nonatomic, weak) id<TYRouteDataDownloaderDelegate> delegate;

- (void)getAllRouteDataRecords;

@end
