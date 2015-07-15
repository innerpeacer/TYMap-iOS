//
//  TYLandMarkManager.h
//  MapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapInfo.h"
#import "TYLandmark.h"

@interface TYLandmarkManager : NSObject

+ (TYLandmarkManager *)sharedManager;

- (void)loadLandmark:(TYMapInfo *)info;

- (TYLandmark *)searchLandmark:(TYLocalPoint *)location Tolerance:(double)tolerance;

@end
