//
//  IPSyncPOIDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/12/25.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPSyncMapDataRecord.h"

@interface IPSyncPOIDBAdapter : NSObject

- (id)initWithPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

- (BOOL)erasePOITable;
- (BOOL)insertPOIRecord:(IPSyncMapDataRecord *)record;
- (int)insertPOIRecords:(NSArray *)recordArray;

@end
