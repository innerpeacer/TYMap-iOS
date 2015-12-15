//
//  TYSyncMapRouteDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/11/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYSyncRouteRecord.h"

@interface TYSyncMapRouteDBAdapter : NSObject

- (id)initWithPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

- (void)eraseRouteDataTable;

- (BOOL)eraseRouteNodeTable;
- (BOOL)insertRouteNodeRecord:(TYSyncRouteNodeRecord *)record;
- (int)insertRouteNodeRecords:(NSArray *)records;
- (BOOL)updateRouteNodeRecord:(TYSyncRouteNodeRecord *)record;
- (void)updateRouteNodeRecords:(NSArray *)records;
- (BOOL)deleteRouteNodeRecord:(int)nodeID;
- (NSArray *)getAllRouteNodeRecords;

- (BOOL)eraseRouteLinkTable;
- (BOOL)insertRouteLinkRecord:(TYSyncRouteLinkRecord *)record;
- (int)insertRouteLinkRecords:(NSArray *)records;
- (BOOL)updateRouteLinkRecord:(TYSyncRouteLinkRecord *)record;
- (void)updateRouteLinkRecords:(NSArray *)records;
- (BOOL)deleteRouteLinkRecord:(int)linkID;
- (NSArray *)getAllRouteLinkRecords;

@end
