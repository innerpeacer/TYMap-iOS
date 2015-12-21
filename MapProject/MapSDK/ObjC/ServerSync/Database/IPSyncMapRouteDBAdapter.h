//
//  IPSyncMapRouteDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/11/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPSyncRouteRecord.h"

@interface IPSyncMapRouteDBAdapter : NSObject

- (id)initWithPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

- (void)eraseRouteDataTable;

//- (BOOL)eraseRouteNodeTable;
- (BOOL)insertRouteNodeRecord:(IPSyncRouteNodeRecord *)record;
- (int)insertRouteNodeRecords:(NSArray *)records;
- (BOOL)updateRouteNodeRecord:(IPSyncRouteNodeRecord *)record;
- (void)updateRouteNodeRecords:(NSArray *)records;
- (BOOL)deleteRouteNodeRecord:(int)nodeID;
- (NSArray *)getAllRouteNodeRecords;

//- (BOOL)eraseRouteLinkTable;
- (BOOL)insertRouteLinkRecord:(IPSyncRouteLinkRecord *)record;
- (int)insertRouteLinkRecords:(NSArray *)records;
- (BOOL)updateRouteLinkRecord:(IPSyncRouteLinkRecord *)record;
- (void)updateRouteLinkRecords:(NSArray *)records;
- (BOOL)deleteRouteLinkRecord:(int)linkID;
- (NSArray *)getAllRouteLinkRecords;

@end
