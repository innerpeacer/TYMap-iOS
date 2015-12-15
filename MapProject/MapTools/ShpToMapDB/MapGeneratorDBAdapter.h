//
//  MapGeneratorDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/10/23.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

@interface MapGeneratorDBAdapter : NSObject

- (id)initWithBuilding:(TYBuilding *)building;

- (BOOL)open;
- (BOOL)close;

- (void)eraseDatabase;

- (void)insertMapInfos:(NSArray *)mapInfoArray;
- (void)insertMapData:(NSArray *)mapDataArray;

- (void)insertFillSymbols:(NSArray *)symbolArray;
- (void)insertIconSymbols:(NSArray *)symbolArray;

//- (void)insertFloorRecords:(NSArray *)floorRecordArray;
//- (void)insertRoomRecords:(NSArray *)roomRecordArray;
//- (void)insertAssetRecords:(NSArray *)assetRecordArray;
//- (void)insertFacilityRecords:(NSArray *)facilityRecordArray;

@end
