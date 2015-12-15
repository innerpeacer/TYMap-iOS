//
//  TYWebUploader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TYWebUploader;

@protocol TYWebUploaderDelegate <NSObject>

- (void)TYWebUploaderDidFinishUploading:(TYWebUploader *)uploader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString;
- (void)TYWebUploaderDidFailedUploading:(TYWebUploader *)uploader WithApi:(NSString *)api WithError:(NSError *)error;

@end

@interface TYWebUploader : NSObject

@property (nonatomic, weak) id<TYWebUploaderDelegate> delegate;

- (id)initWithHostName:(NSString *)hostName;
- (void)uploadWithApi:(NSString *)api Parameters:(NSDictionary *)params;

@end
