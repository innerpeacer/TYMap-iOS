//
//  WebMapBuilder.h
//  MapProject
//
//  Created by innerpeacer on 16/1/27.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

@class WebMapBuilder;

@protocol WebMapBuilderDelegate <NSObject>

- (void)WebMapBuilder:(WebMapBuilder *)builder processUpdated:(NSString *)process;

@end

@interface WebMapBuilder : NSObject

@property (nonatomic, weak) id<WebMapBuilderDelegate> delegate;

- (id)initWithCity:(TYCity *)city Building:(TYBuilding *)building WithWebRoot:(NSString *)root;
- (void)buildWebMap;

+ (void)generateCityJson:(NSArray *)cityArray WithRoot:(NSString *)root;
+ (void)generateBuildingJsonWithCity:(TYCity *)city Buildings:(NSArray *)buildingArray WithRoot:(NSString *)root;

@end
