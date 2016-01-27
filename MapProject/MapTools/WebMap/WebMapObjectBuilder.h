//
//  WebMapBuilder.h
//  MapProject
//
//  Created by innerpeacer on 16/1/25.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>
#import "TYMapInfo.h"
#import "TYRenderingScheme.h"

@interface WebMapObjectBuilder : NSObject

+ (id)generateWebBuildingObject:(TYBuilding *)building;
+ (id)generateWebCityObject:(TYCity *)city;
+ (id)generateWebMapInfoObject:(TYMapInfo *)mapInfo;
+ (id)generateWebRenderingSchemeObjectWithFill:(NSDictionary *)fillDict Icon:(NSDictionary *)iconDict;
@end
