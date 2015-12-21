//
//  IPSyncMapDataRecord.h
//  MapProject
//
//  Created by innerpeacer on 15/11/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPSyncMapDataRecord : NSObject

@property (nonatomic, strong) NSString *objectID;
@property (nonatomic, strong) NSData *geometryData;
@property (nonatomic, strong) NSString *geoID;
@property (nonatomic, strong) NSString *poiID;
@property (nonatomic, strong) NSString *floorID;
@property (nonatomic, strong) NSString *buildingID;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) int symbolID;
@property (nonatomic, assign) int floorNumber;
@property (nonatomic, strong) NSString *floorName;
@property (nonatomic, assign) double shapeLength;
@property (nonatomic, assign) double shapeArea;
@property (nonatomic, assign) double labelX;
@property (nonatomic, assign) double labelY;
@property (nonatomic, assign) int layer;
@property (nonatomic, assign) int levelMax;
@property (nonatomic, assign) int levelMin;

+ (IPSyncMapDataRecord *)parseMapDataRecord:(NSDictionary *)recordObject;
+ (NSDictionary *)buildMapDataObject:(IPSyncMapDataRecord *)record;

@end
