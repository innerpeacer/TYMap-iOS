//
//  TYPoiDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/3/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYPoiDBAdapter : NSObject

+ (TYPoiDBAdapter *)sharedDBAdapter:(NSString *)buildingID;

- (BOOL)open;
- (BOOL)close;

@end
