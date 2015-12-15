//
//  TYRouteDataUploader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapUser.h"

@class  TYRouteDataUploader;

@protocol TYRouteDataUploaderDelegate <NSObject>

- (void)TYRouteUploader:(TYRouteDataUploader *)uploader DidUpdateUploadingProgress:(int)batchIndex WithApi:(NSString *)api WithDescription:(NSString *)description;
- (void)TYRouteUploader:(TYRouteDataUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description;
- (void)TYRouteUploader:(TYRouteDataUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error;

@end

@interface TYRouteDataUploader : NSObject

- (id)initWithUser:(TYMapUser *)user;
@property (nonatomic, assign) int recordLimitPerUpload;
@property (nonatomic, weak) id<TYRouteDataUploaderDelegate> delegate;

- (void)uploadRouteLinkRecords:(NSArray *)linkRecords NodeRecords:(NSArray *)nodeRecords;

@end
