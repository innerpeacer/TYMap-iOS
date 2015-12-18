//
//  TYMapDataUploader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapCredential.h"

@class TYMapDataUploader;
@protocol TYMapDataUploaderDelegate <NSObject>

- (void)TYMapDataUploader:(TYMapDataUploader *)uploader DidUpdateUploadingProgress:(int)batchIndex WithApi:(NSString *)api WithDescription:(NSString *)description;
- (void)TYMapDataUploader:(TYMapDataUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description;
- (void)TYMapDataUploader:(TYMapDataUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error;

@end

@interface TYMapDataUploader : NSObject

- (id)initWithUser:(TYMapCredential *)user;
@property (nonatomic, assign) int recordLimitPerUpload;
@property (nonatomic, weak) id<TYMapDataUploaderDelegate> delegate;

- (void)uploadMapDataRecords:(NSArray *)records;

@end
