//
//  TYNode.h
//  MapProject
//
//  Created by innerpeacer on 15/9/30.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@class TYLink;

@interface TYNode : NSObject

@property (nonatomic, readonly) int nodeID;
@property (nonatomic, strong) NSMutableArray *adjacencies;
@property (nonatomic, strong) AGSPoint *pos;
@property (nonatomic, readonly) BOOL isVirtual;

@property (nonatomic, assign) double minDistance;
@property (nonatomic, strong) TYNode *previousNode;


- (id)initWithNodeID:(int)nodeID isVirtual:(BOOL)isVir;
- (void)addLink:(TYLink *)link;
- (void)removeLink:(TYLink *)link;

- (void)reset;

@end