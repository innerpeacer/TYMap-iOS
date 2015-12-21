//
//  TYSyncUploadingTask.h
//  MapProject
//
//  Created by innerpeacer on 15/12/17.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapCredential.h"
#import <TYMapData/TYMapData.h>

@class IPSyncUploadingTask;
@protocol IPSyncUploadingTaskDelegate <NSObject>

- (void)TYUploadingTaskDidFinished:(IPSyncUploadingTask *)task;
- (void)TYUploadingTaskDidFailedUploading:(IPSyncUploadingTask *)task InStep:(int)step WithError:(NSError *)error;
- (void)TYUploadingTaskDidUpdateUploadingProcess:(IPSyncUploadingTask *)task InStep:(int)step WithDescription:(NSString *)description;

@end

@interface IPSyncUploadingTask : NSObject

@property (nonatomic, weak) id<IPSyncUploadingTaskDelegate> delegate;

- (id)initWithUser:(TYMapCredential *)u;
- (void)uploadCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray FillSymbols:(NSArray *)fillArray IconSymbols:(NSArray *)iconArray MapData:(NSArray *)mapDataArray RouteLinkData:(NSArray *)linkArray RouteNodeData:(NSArray *)nodeArray;

@end