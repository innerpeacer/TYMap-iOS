//
//  TYWebUploader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IPWebUploader;

@protocol IPWebUploaderDelegate <NSObject>

- (void)TYWebUploaderDidFinishUploading:(IPWebUploader *)uploader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString;
- (void)TYWebUploaderDidFailedUploading:(IPWebUploader *)uploader WithApi:(NSString *)api WithError:(NSError *)error;

@end

@interface IPWebUploader : NSObject

@property (nonatomic, weak) id<IPWebUploaderDelegate> delegate;

- (id)initWithHostName:(NSString *)hostName;
- (void)uploadWithApi:(NSString *)api Parameters:(NSDictionary *)params;

@end
