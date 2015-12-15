//
//  TYSyncRouteRecord.h
//  MapProject
//
//  Created by innerpeacer on 15/11/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYSyncRouteNodeRecord : NSObject

@property (nonatomic, assign) int nodeID;
@property (nonatomic, strong) NSData *geometryData;
@property (nonatomic, assign) BOOL isVirtual;


+ (TYSyncRouteNodeRecord *)parseRouteNodeRecord:(NSDictionary *)recordObject;
+ (NSDictionary *)buildRouteNodeObject:(TYSyncRouteNodeRecord *)record;


@end

@interface TYSyncRouteLinkRecord : NSObject

@property (nonatomic, assign) int linkID;
@property (nonatomic, strong) NSData *geometryData;
@property (nonatomic, assign) double length;
@property (nonatomic, assign) int headNode;
@property (nonatomic, assign) int endNode;
@property (nonatomic, assign) BOOL isVirtual;
@property (nonatomic, assign) BOOL isOneWay;


+ (TYSyncRouteLinkRecord *)parseRouteLinkRecord:(NSDictionary *)recordObject;
+ (NSDictionary *)buildRouteLinkObject:(TYSyncRouteLinkRecord *)record;

@end
