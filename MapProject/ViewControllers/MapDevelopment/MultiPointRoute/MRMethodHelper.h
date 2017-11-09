//
//  MethodHelper.h
//  MapProject
//
//  Created by innerpeacer on 2017/11/7.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapView.h"
#import "TYMapEnviroment.h"
#import "RouteNetworkDataset.h"
#import "LayerGroup.h"

@interface MRMethodHelper : NSObject

+ (void)map:(TYMapView *)mapView zoomToAllExtent:(NSArray *)allMapInfos;
+ (void)routeNetwork:(RouteNetworkDataset *)routeNetwork showNodesAndLinksOnLayer:(LayerGroup *)layergroup;

@end
