//
//  MRSuperNode.h
//  MapProject
//
//  Created by innerpeacer on 2017/11/9.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@class MRSuperLink;

@interface MRSuperNode : NSObject

@property (nonatomic, readonly) int nodeID;
@property (nonatomic, strong) NSMutableArray *adjacencies;
@property (nonatomic, strong) AGSPoint *pos;

@property (nonatomic, assign) double minDistance;
@property (nonatomic, strong) MRSuperNode *previousNode;


- (id)initWithNodeID:(int)nodeID;
- (void)addLink:(MRSuperLink *)link;
- (void)removeLink:(MRSuperLink *)link;

- (void)reset;

@end
