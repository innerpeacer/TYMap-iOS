//
//  MultiRouteLayerGroup.h
//  MapProject
//
//  Created by innerpeacer on 2017/11/8.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "MRSymbolGroup.h"
@class TYMapView;
@class MRParams;

@interface MRLayerGroup : NSObject

- (id)initWithSymbolGroup:(MRSymbolGroup *)sg;

@property (nonatomic, strong) AGSGraphicsLayer *routeLayer;
@property (nonatomic, strong) AGSGraphicsLayer *paramLayer;

@property (nonatomic, strong) AGSGraphicsLayer *startCombinationLayer;
@property (nonatomic, strong) AGSGraphicsLayer *endCombinationLayer;
@property (nonatomic, strong) AGSGraphicsLayer *stopsCombinationLayer;

- (void)addToMap:(TYMapView *)mapView;

- (void)showRoute:(AGSPolyline *)line WithStart:(AGSPoint *)startPoint End:(AGSPoint *)endPoint;
- (void)showRouteCollections:(NSArray *)routeArray WithStart:(AGSPoint *)startPoint End:(AGSPoint *)endPoint;

- (void)showMultiRouteParams:(MRParams *)params;
- (void)showCombinations:(NSArray *)combinations withName:(NSString *)name;

@end
