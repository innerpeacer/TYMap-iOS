//
//  MRParams.h
//  MapProject
//
//  Created by innerpeacer on 2017/11/8.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@class MRSuperLink;
@class MRSuperNode;

@interface MRParams : NSObject

@property (nonatomic, strong) AGSPoint *startPoint;
@property (nonatomic, strong) AGSPoint *endPoint;
@property (nonatomic, strong) NSArray *stopPoints;

- (void)addStop:(AGSPoint *)stop;
- (int)stopCount;
- (AGSPoint *)getStopPoint:(int)i;
- (NSDictionary *)getCombinations;

- (void)buildNodes;
- (NSArray *)getSuperNodes;
- (MRSuperNode *)getStartNode;
- (MRSuperNode *)getEndNode;
- (NSArray *)getStopNodes;

@end
