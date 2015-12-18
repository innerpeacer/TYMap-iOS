//
//  TYMapDataDownloader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapCredential.h"

@class TYMapDataDownloader;

@protocol TYMapDataDownloaderDelegate  <NSObject>

- (void)TYMapDataDownloader:(TYMapDataDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records;
- (void)TYMapDataDownloader:(TYMapDataDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error;

@end

@interface TYMapDataDownloader : NSObject

- (id)initWithUser:(TYMapCredential *)user;

@property (nonatomic, weak) id <TYMapDataDownloaderDelegate> delegate;

- (void)getAllMapDataRecords;

@end
