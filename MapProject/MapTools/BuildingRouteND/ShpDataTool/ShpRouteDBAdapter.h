//
//  ShpRouteDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/9/29.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShpRouteDBAdapter : NSObject

- (id)initWithPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

//- (NSArray *)readAllShpRouteRecords:(NSString *)table;

- (NSArray *)readAllLinkShpRouteRecords:(NSString *)table;
- (NSArray *)readAllNodeShpRouteRecords:(NSString *)table;


@end