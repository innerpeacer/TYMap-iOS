//
//  TYRouteDataUploader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapCredential.h"

@class  IPRouteDataUploader;

@protocol IPRouteDataUploaderDelegate <NSObject>

- (void)TYRouteUploader:(IPRouteDataUploader *)uploader DidUpdateUploadingProgress:(int)batchIndex WithApi:(NSString *)api WithDescription:(NSString *)description;
- (void)TYRouteUploader:(IPRouteDataUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description;
- (void)TYRouteUploader:(IPRouteDataUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error;

@end

@interface IPRouteDataUploader : NSObject

- (id)initWithUser:(TYMapCredential *)user;
@property (nonatomic, assign) int recordLimitPerUpload;
@property (nonatomic, weak) id<IPRouteDataUploaderDelegate> delegate;

- (void)uploadRouteLinkRecords:(NSArray *)linkRecords NodeRecords:(NSArray *)nodeRecords;

@end
