//
//  TYSyncMapDataDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/11/26.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYSyncMapDataRecord.h"
#import "TYMapInfo.h"

@interface TYSyncMapDataDBAdapter : NSObject

- (id)initWithPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

- (BOOL)eraseMapInfoTable;
- (BOOL)insertMapInfo:(TYMapInfo *)mapInfo;
- (int)insertMapInfos:(NSArray *)mapInfos;
- (BOOL)updateMapInfo:(TYMapInfo *)mapInfo;
- (void)updateMapInfos:(NSArray *)mapInfos;
- (BOOL)deleteMapInfo:(NSString *)mapID;
- (NSArray *)getAllMapInfos;

- (BOOL)eraseMapDataTable;
- (BOOL)insertMapDataRecord:(TYSyncMapDataRecord *)record;
- (int)insertMapDataRecords:(NSArray *)records;
- (BOOL)updateMapDataRecord:(TYSyncMapDataRecord *)record;
- (void)updateMapDataRecords:(NSArray *)records;
- (BOOL)deleteMapDataRecord:(NSString *)geoID;
- (NSArray *)getAllRecords;



@end
