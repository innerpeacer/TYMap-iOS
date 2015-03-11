//
//  NPPoiDBAdapter.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/3/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NPPoiDBAdapter : NSObject

+ (NPPoiDBAdapter *)sharedDBAdapter:(NSString *)buildingID;

- (BOOL)open;
- (BOOL)close;

@end
