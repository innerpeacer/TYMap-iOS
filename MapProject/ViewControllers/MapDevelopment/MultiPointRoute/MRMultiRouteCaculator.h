//
//  MRMultiRouteCaculator.h
//  MapProject
//
//  Created by innerpeacer on 2017/11/9.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRSuperNode.h"
#import "MRSuperLink.h"
#import "MRParams.h"

@interface MRMultiRouteCaculator : NSObject

//- (id)initWithStart:(MRSuperNode *)start End:(MRSuperNode *)end Stops:(NSArray *)stops Dict:(NSDictionary *)dict;

- (id)initWithRouteParam:(MRParams *)params Dict:(NSDictionary *)dict;
- (AGSPolyline *)calculate;
- (NSArray *)getRouteCollection;

@end
