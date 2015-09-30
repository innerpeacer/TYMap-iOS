//
//  TYBuildingLink.h
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface TYBuildingLink : NSObject

@property (nonatomic, readonly) int linkID;
@property (nonatomic, strong) NSData *geometryData;
@property (nonatomic, assign) double length;
@property (nonatomic, assign) int headNodeID;
@property (nonatomic, assign) int endNodeID;
@property (nonatomic, readonly) BOOL isVirtual;
@property (nonatomic, readonly) BOOL isOneWay;

@property (nonatomic, strong) AGSPolyline *line;

- (id)initWithLinkID:(int)linkID isVirtual:(BOOL)isVir isOneWay:(BOOL)isOW;

@end
