//
//  TYWebUploader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IPMapWebUploader;

@protocol IPMapWebUploaderDelegate <NSObject>

- (void)WebUploaderDidFinishUploading:(IPMapWebUploader *)uploader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString;
- (void)WebUploaderDidFailedUploading:(IPMapWebUploader *)uploader WithApi:(NSString *)api WithError:(NSError *)error;

@end

@interface IPMapWebUploader : NSObject

@property (nonatomic, weak) id<IPMapWebUploaderDelegate> delegate;

- (id)initWithHostName:(NSString *)hostName;
- (void)uploadWithApi:(NSString *)api Parameters:(NSDictionary *)params;

@end
