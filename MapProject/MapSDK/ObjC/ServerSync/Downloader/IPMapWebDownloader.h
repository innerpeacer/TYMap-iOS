//
//  TYWebDownloader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IPMapWebDownloader;

@protocol IPMapWebDownloaderDelegate <NSObject>

- (void)WebDownloaderDidFinishDownloading:(IPMapWebDownloader *)downloader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString;
- (void)WebDownloaderDidFailedDownloading:(IPMapWebDownloader *)downloader WithApi:(NSString *)api WithError:(NSError *)error;

@end

@interface IPMapWebDownloader : NSObject

@property (nonatomic, weak) id<IPMapWebDownloaderDelegate> delegate;

- (id)initWithHostName:(NSString *)hostName;
- (void)downloadWithApi:(NSString *)api Parameters:(NSDictionary *)params;

@end

