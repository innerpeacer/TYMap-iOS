//
//  LayerGroup.h
//  MapProject
//
//  Created by innerpeacer on 15/10/5.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@class TYMapView;

@interface LayerGroup : NSObject

@property (nonatomic, strong) AGSGraphicsLayer *nodeLayer;
@property (nonatomic, strong) AGSGraphicsLayer *virtualNodeLayer;
@property (nonatomic, strong) AGSGraphicsLayer *junctionNodeLayer;

@property (nonatomic, strong) AGSGraphicsLayer *linkLayer;
@property (nonatomic, strong) AGSGraphicsLayer *virtualLinkLayer;

- (void)addToMap:(TYMapView *)mapView;

@end
