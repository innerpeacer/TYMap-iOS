//
//  TYMapCoordConverter.h
//  BRT-RTMap
//
//  Created by innerpeacer on 2016/10/10.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYMapCoordConverter : NSObject
- (id)initWithTranformFile:(NSString *)path;
- (NSArray *)getTransformedDataFromTYMap:(NSArray *)tyData;

@property (nonatomic, strong) NSDictionary *floorMap;
@end
