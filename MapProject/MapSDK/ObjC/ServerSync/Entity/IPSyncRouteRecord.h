//
//  TYSyncRouteRecord.h
//  MapProject
//
//  Created by innerpeacer on 15/11/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPSyncRouteNodeRecord : NSObject

@property (nonatomic, assign) int nodeID;
@property (nonatomic, strong) NSData *geometryData;
@property (nonatomic, assign) BOOL isVirtual;


+ (IPSyncRouteNodeRecord *)parseRouteNodeRecord:(NSDictionary *)recordObject;
+ (NSDictionary *)buildRouteNodeObject:(IPSyncRouteNodeRecord *)record;


@end

@interface IPSyncRouteLinkRecord : NSObject

@property (nonatomic, assign) int linkID;
@property (nonatomic, strong) NSData *geometryData;
@property (nonatomic, assign) double length;
@property (nonatomic, assign) int headNode;
@property (nonatomic, assign) int endNode;
@property (nonatomic, assign) BOOL isVirtual;
@property (nonatomic, assign) BOOL isOneWay;


+ (IPSyncRouteLinkRecord *)parseRouteLinkRecord:(NSDictionary *)recordObject;
+ (NSDictionary *)buildRouteLinkObject:(IPSyncRouteLinkRecord *)record;

@end
