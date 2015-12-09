//
//  OriginalShpRecord.h
//  MapProject
//
//  Created by innerpeacer on 15/10/23.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OriginalShpRecord : NSObject

@property (nonatomic, strong) NSNumber *objectID;
@property (nonatomic, strong) NSData *geometryData;
@property (nonatomic, strong) NSString *geoID;
@property (nonatomic, strong) NSString *poiID;
@property (nonatomic, strong) NSString *floorID;
@property (nonatomic, strong) NSString *buildingID;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *symbolID;
@property (nonatomic, strong) NSNumber *floorNumber;
@property (nonatomic, strong) NSString *floorName;
@property (nonatomic, strong) NSNumber *shapeLength;
@property (nonatomic, strong) NSNumber *shapeArea;
@property (nonatomic, strong) NSNumber *labelX;
@property (nonatomic, strong) NSNumber *labelY;
@property (nonatomic, strong) NSNumber *layer;
@property (nonatomic, strong) NSNumber *levelMax;
@property (nonatomic, strong) NSNumber *levelMin;

@end
