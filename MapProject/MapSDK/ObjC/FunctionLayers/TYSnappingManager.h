//
//  TYSnappingManager.h
//  MapProject
//
//  Created by innerpeacer on 2016/11/25.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import <TYMapData/TYMapData.h>

@interface TYSnappingManager : NSObject

-(id)initWithBuilding:(TYBuilding *)building MapInfo:(NSArray *)mapInfoArray;

- (AGSPoint *)getSnappedPoint:(TYLocalPoint *)location;
- (AGSProximityResult *)getSnappedResult:(TYLocalPoint *)location;
- (AGSProximityResult *)getSnappedVertexResult:(TYLocalPoint *)location;

- (NSDictionary *)getRouteGeometries;

@end
