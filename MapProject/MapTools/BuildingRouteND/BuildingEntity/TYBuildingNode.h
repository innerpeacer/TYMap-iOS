//
//  TYBuildingNode.h
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

#import "TYBuildingLink.h"

@interface TYBuildingNode : NSObject

@property (nonatomic, readonly) int nodeID;
@property (nonatomic, strong) NSData *geometryData;
@property (nonatomic, strong) NSMutableArray *adjacencies;
@property (nonatomic, readonly) BOOL isVirtual;

@property (nonatomic, strong) AGSPoint *pos;

- (id)initWithNodeID:(int)nodeID isVirtual:(BOOL)isVir;
- (void)addLink:(TYBuildingLink *)link;

@end