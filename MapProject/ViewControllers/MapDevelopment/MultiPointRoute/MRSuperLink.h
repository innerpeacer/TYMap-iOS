//
//  MRSuperLink.h
//  MapProject
//
//  Created by innerpeacer on 2017/11/9.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@class MRSuperNode;

@interface MRSuperLink : NSObject

@property (nonatomic, assign) int currentNodeID;
@property (nonatomic, assign) int nextNodeID;
@property (nonatomic, readonly) int linkID;

@property (nonatomic, strong) MRSuperNode *nextNode;
@property (nonatomic, assign) double length;

@property (nonatomic, strong) AGSPolyline *line;

- (id)initWithLinkID:(int)linkID;

@end
