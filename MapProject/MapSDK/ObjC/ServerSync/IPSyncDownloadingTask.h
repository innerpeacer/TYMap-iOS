//
//  TYSyncDownloadingTask.h
//  MapProject
//
//  Created by innerpeacer on 15/12/17.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapCredential.h"
#import <TYMapData/TYMapData.h>

@class IPSyncDownloadingTask;

@protocol IPSyncDownloadingTaskDelegate <NSObject>

- (void)DownloadingTaskDidFinished:(IPSyncDownloadingTask *)task WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray FillSymbols:(NSArray *)fillArray IconSymbols:(NSArray *)iconArray MapData:(NSArray *)mapDataArray RouteLinkData:(NSArray *)linkArray RouteNodeData:(NSArray *)nodeArray;
- (void)DownloadingTaskDidFailedDownloading:(IPSyncDownloadingTask *)task InStep:(int)step WithError:(NSError *)error;
- (void)DownloadingTaskDidUpdateDownloadingProcess:(IPSyncDownloadingTask *)task InStep:(int)step WithDescription:(NSString *)description;

@end

@interface IPSyncDownloadingTask : NSObject

@property (nonatomic, weak) id<IPSyncDownloadingTaskDelegate> delegate;

- (id)initWithUser:(TYMapCredential *)u;
- (void)featchData;

@end
