//
//  MRSuperRouteNetworkDataset.h
//  MapProject
//
//  Created by innerpeacer on 2017/11/9.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "MRSuperLink.h"
#import "MRSuperNode.h"

@interface MRSuperRouteNetworkDataset : NSObject

@property (nonatomic, strong) NSMutableArray *linkArray;
@property (nonatomic, strong) NSMutableArray *nodeArray;

@property (nonatomic, strong) NSMutableDictionary *allNodeDict;
@property (nonatomic, strong) NSMutableDictionary *allLinkDict;

- (id)initWithNodes:(NSArray *)nodes Links:(NSArray *)links;
- (AGSPolyline *)getShorestPathFrom:(MRSuperNode *)start To:(MRSuperNode *)end;

@end
