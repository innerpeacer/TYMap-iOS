//
//  TYLink.h
//  MapProject
//
//  Created by innerpeacer on 15/9/30.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@class TYNode;

@interface TYLink : NSObject

@property (nonatomic, assign) int currentNodeID;
@property (nonatomic, assign) int nextNodeID;
@property (nonatomic, readonly) int linkID;
@property (nonatomic, readonly) BOOL isVirtual;

@property (nonatomic, strong) TYNode *nextNode;
@property (nonatomic, assign) double length;

@property (nonatomic, strong) AGSPolyline *line;

- (id)initWithLinkID:(int)linkID isVirtual:(BOOL)isVir;

@end
