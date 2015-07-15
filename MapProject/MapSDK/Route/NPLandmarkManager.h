//
//  TYLandMarkManager.h
//  MapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapInfo.h"
#import "NPLandmark.h"

@interface NPLandmarkManager : NSObject

+ (NPLandmarkManager *)sharedManager;

- (void)loadLandmark:(TYMapInfo *)info;

- (NPLandmark *)searchLandmark:(NPLocalPoint *)location Tolerance:(double)tolerance;

@end
