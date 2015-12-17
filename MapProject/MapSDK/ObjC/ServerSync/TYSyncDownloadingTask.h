//
//  TYSyncDownloadingTask.h
//  MapProject
//
//  Created by innerpeacer on 15/12/17.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapUser.h"
#import <TYMapData/TYMapData.h>

@class TYSyncDownloadingTask;

@protocol TySyncDownloadingTaskDelegate <NSObject>

- (void)TYDownloadingTaskDidFinished:(TYSyncDownloadingTask *)task WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray FillSymbols:(NSArray *)fillArray IconSymbols:(NSArray *)iconArray MapData:(NSArray *)mapDataArray RouteLinkData:(NSArray *)linkArray RouteNodeData:(NSArray *)nodeArray;
- (void)TYDownloadingTaskDidFailedDownloading:(TYSyncDownloadingTask *)task InStep:(int)step WithError:(NSError *)error;
- (void)TYDownloadingTaskDidUpdateDownloadingProcess:(TYSyncDownloadingTask *)task InStep:(int)step WithDescription:(NSString *)description;

@end

@interface TYSyncDownloadingTask : NSObject

@property (nonatomic, weak) id<TySyncDownloadingTaskDelegate> delegate;

- (id)initWithUser:(TYMapUser *)u;
- (void)featchData;

@end
