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

@property (nonatomic, strong) NSArray *allNodeArray;
@property (nonatomic, strong) NSArray *allLinkArray;
@property (nonatomic, strong) NSDictionary *allNodeDict;
@property (nonatomic, strong) NSDictionary *allLinkDict;

- (void)computePaths:(TYNode *)source;
- (NSArray *)getShorestPathTo:(TYNode *)target;
- (void)reset;

@end