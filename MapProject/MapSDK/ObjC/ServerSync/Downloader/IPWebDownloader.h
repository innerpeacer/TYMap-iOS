//
//  TYWebDownloader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IPWebDownloader;

@protocol IPWebDownloaderDelegate <NSObject>

- (void)WebDownloaderDidFinishDownloading:(IPWebDownloader *)downloader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString;
- (void)WebDownloaderDidFailedDownloading:(IPWebDownloader *)downloader WithApi:(NSString *)api WithError:(NSError *)error;

@end

@interface IPWebDownloader : NSObject

@property (nonatomic, weak) id<IPWebDownloaderDelegate> delegate;

- (id)initWithHostName:(NSString *)hostName;
- (void)downloadWithApi:(NSString *)api Parameters:(NSDictionary *)params;

@end

