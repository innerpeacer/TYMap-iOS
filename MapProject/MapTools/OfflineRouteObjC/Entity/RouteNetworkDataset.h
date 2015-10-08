//
//  RouteNetworkDataset.h
//  MapProject
//
//  Created by innerpeacer on 15/9/30.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <TYMapData/TYMapData.h>
#import "TYNode.h"
#import "TYLink.h"

@interface RouteNetworkDataset : NSObject

- (id)initWithNodes:(NSArray *)nodes Links:(NSArray *)links;

@property (nonatomic, strong) NSMutableArray *linkArray;
@property (nonatomic, strong) NSMutableArray *virtualLinkArray;
@property (nonatomic, strong) NSMutableArray *nodeArray;
@property (nonatomic, strong) NSMutableArray *virtualNodeArray;

@property (nonatomic, readonly) AGSPolyline *unionLine;

//@property (nonatomic, strong) NSArray *allNodeArray;
//@property (nonatomic, strong) NSArray *allLinkArray;
@property (nonatomic, strong) NSMutableDictionary *allNodeDict;
@property (nonatomic, strong) NSMutableDictionary *allLinkDict;


- (AGSPoint *)getNearestPoint:(AGSPoint *)point;
- (NSArray *)getNearestLinks:(AGSPoint *)point;
- (NSArray *)getNearestNodes:(AGSPoint *)point;

- (void)computePaths:(TYNode *)source;
//- (NSArray *)getShorestPathTo:(TYNode *)target;
- (AGSPolyline *)getShorestPathTo:(TYNode *)target;

- (void)reset;

- (AGSPolyline *)getShorestPathFrom:(AGSPoint *)start To:(AGSPoint *)end;

@end