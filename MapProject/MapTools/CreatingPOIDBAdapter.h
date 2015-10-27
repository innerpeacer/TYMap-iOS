//
//  CreatingPOIDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/3/10.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreatingPOIDBAdapter : NSObject

- (id)initWithDBPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

- (BOOL)erasePOITable;

- (BOOL)insertPOIWithGeoID:(NSString *)gid poiID:(NSString *)pid buildingID:(NSString *)bid floorID:(NSString *)fid name:(NSString *)name categoryID:(NSNumber *)cid labelX:(NSNumber *)x labelY:(NSNumber *)y color:(NSNumber *)color FloorNumber:(NSNumber *)fIndex floorName:(NSString *)fName layer:(NSNumber *)layer;
@end
