//
//  RouteNetworkDBEntity.h
//  MapProject
//
//  Created by innerpeacer on 15/10/8.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface LinkRecord : NSObject

@property (nonatomic, assign) int linkID;
@property (nonatomic, strong) NSData *geometryData;
@property (nonatomic, strong) AGSPolyline *line;
@property (nonatomic, assign) double length;
@property (nonatomic, assign) int headNode;
@property (nonatomic, assign) int endNode;
@property (nonatomic, assign) BOOL isVirtual;
@property (nonatomic, assign) BOOL isOneWay;

@end

@interface NodeRecord : NSObject

@property (nonatomic, assign) int nodeID;
@property (nonatomic, strong) NSData *geometryData;
@property (nonatomic, strong) AGSPoint *pos;
@property (nonatomic, assign) BOOL isVirtual;

@end