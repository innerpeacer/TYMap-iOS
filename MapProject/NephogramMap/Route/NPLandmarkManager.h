//
//  NPLandMarkManager.h
//  MapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPMapInfo.h"
#import "NPLandmark.h"

@interface NPLandmarkManager : NSObject

+ (NPLandmarkManager *)sharedManager;

- (void)loadLandmark:(NPMapInfo *)info;

- (NPLandmark *)searchLandmark:(NPLocalPoint *)location Tolerance:(double)tolerance;

@end
