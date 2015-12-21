//
//  TYMapDataUploader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapCredential.h"

@class IPMapDataUploader;
@protocol IPMapDataUploaderDelegate <NSObject>

- (void)TYMapDataUploader:(IPMapDataUploader *)uploader DidUpdateUploadingProgress:(int)batchIndex WithApi:(NSString *)api WithDescription:(NSString *)description;
- (void)TYMapDataUploader:(IPMapDataUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description;
- (void)TYMapDataUploader:(IPMapDataUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error;

@end

@interface IPMapDataUploader : NSObject

- (id)initWithUser:(TYMapCredential *)user;
@property (nonatomic, assign) int recordLimitPerUpload;
@property (nonatomic, weak) id<IPMapDataUploaderDelegate> delegate;

- (void)uploadMapDataRecords:(NSArray *)records;

@end
