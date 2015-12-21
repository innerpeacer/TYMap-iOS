//
//  OfflineRouteManager.h
//  MapProject
//
//  Created by innerpeacer on 15/10/10.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYRouteResult.h"
#import <TYMapData/TYMapData.h>
#import <ArcGIS/ArcGIS.h>

@class OfflineRouteManager;

@protocol OfflineRouteManagerDelegate <NSObject>

- (void)routeManager:(OfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)routeResult OriginalLine:(AGSPolyline *)line;

- (void)routeManager:(OfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error;

@end

@interface OfflineRouteManager : NSObject

@property (nonatomic, strong, readonly) AGSPoint *startPoint;
@property (nonatomic, strong, readonly) AGSPoint *endPoint;
@property (nonatomic, weak) id<OfflineRouteManagerDelegate> delegate;


+ (OfflineRouteManager *)routeManagerWithBuilding:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray;
- (void)requestRouteWithStart:(TYLocalPoint *)start End:(TYLocalPoint *)end;

@end
