//
//  TYMapDataDownloader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapCredential.h"

@class IPMapDataDownloader;

@protocol IPMapDataDownloaderDelegate  <NSObject>

- (void)TYMapDataDownloader:(IPMapDataDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records;
- (void)TYMapDataDownloader:(IPMapDataDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error;

@end

@interface IPMapDataDownloader : NSObject

- (id)initWithUser:(TYMapCredential *)user;

@property (nonatomic, weak) id <IPMapDataDownloaderDelegate> delegate;

- (void)getAllMapDataRecords;

@end
