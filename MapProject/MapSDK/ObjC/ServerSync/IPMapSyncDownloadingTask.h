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

@class IPMapSyncDownloadingTask;

@protocol IPMapSyncDownloadingTaskDelegate <NSObject>

- (void)DownloadingTaskDidFinished:(IPMapSyncDownloadingTask *)task WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray FillSymbols:(NSArray *)fillArray IconSymbols:(NSArray *)iconArray MapData:(NSArray *)mapDataArray RouteLinkData:(NSArray *)linkArray RouteNodeData:(NSArray *)nodeArray;
- (void)DownloadingTaskDidFailedDownloading:(IPMapSyncDownloadingTask *)task InStep:(int)step WithError:(NSError *)error;
- (void)DownloadingTaskDidUpdateDownloadingProcess:(IPMapSyncDownloadingTask *)task InStep:(int)step WithDescription:(NSString *)description;

@end

@interface IPMapSyncDownloadingTask : NSObject

@property (nonatomic, weak) id<IPMapSyncDownloadingTaskDelegate> delegate;

- (id)initWithUser:(TYMapCredential *)u;
- (void)featchData;

@end
