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

@property (nonatomic, strong) NSMutableArray *linkArray;
@property (nonatomic, strong) NSMutableArray *virtualLinkArray;
@property (nonatomic, strong) NSMutableArray *nodeArray;
@property (nonatomic, strong) NSMutableArray *virtualNodeArray;

@property (nonatomic, readonly) AGSPolyline *unionLine;

@property (nonatomic, strong) NSMutableDictionary *allNodeDict;
@property (nonatomic, strong) NSMutableDictionary *allLinkDict;

- (id)initWithNodes:(NSArray *)nodes Links:(NSArray *)links;
- (AGSPolyline *)getShorestPathFrom:(AGSPoint *)start To:(AGSPoint *)end;


@end