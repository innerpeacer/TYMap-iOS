//
//  TYWebDownloader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TYWebDownloader;

@protocol TYWebDownloaderDelegate <NSObject>

- (void)TYWebDownloaderDidFinishDownloading:(TYWebDownloader *)downloader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString;
- (void)TYWebDownloaderDidFailedDownloading:(TYWebDownloader *)downloader WithApi:(NSString *)api WithError:(NSError *)error;

@end

@interface TYWebDownloader : NSObject

@property (nonatomic, weak) id<TYWebDownloaderDelegate> delegate;

- (id)initWithHostName:(NSString *)hostName;

- (void)downloadWithApi:(NSString *)api Parameters:(NSDictionary *)params;

@end

