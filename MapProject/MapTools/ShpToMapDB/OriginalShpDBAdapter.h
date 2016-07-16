//
//  OriginalShpDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/10/23.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapInfo.h"

typedef enum {
    SHP_DB_UNKNOWN = 0,
    SHP_DB_FLOOR = 1,
    SHP_DB_ROOM = 2,
    SHP_DB_ASSET = 3,
    SHP_DB_FACILITY = 4,
    SHP_DB_LABEL = 5,
    SHP_DB_SHADE = 6
} ShpDBType;

@interface OriginalShpDBAdapter : NSObject

- (id)initWithMapInfo:(TYMapInfo *)info Type:(ShpDBType)type;

- (NSArray *)readAllRecords;

- (BOOL)open;
- (BOOL)close;

@property (nonatomic, readonly) ShpDBType dbType;

@end
