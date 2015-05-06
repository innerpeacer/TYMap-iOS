//
//  NPLandMark.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <NephogramData/NephogramData.h>

@interface NPLandmark : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NPLocalPoint *location;

@end
