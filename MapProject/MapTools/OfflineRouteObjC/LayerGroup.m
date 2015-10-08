//
//  LayerGroup.m
//  MapProject
//
//  Created by innerpeacer on 15/10/5.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "LayerGroup.h"
#import "TYMapView.h"

@implementation LayerGroup

- (id)init
{
    self = [super init];
    if (self) {
        
        {
            self.linkLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor greenColor] width:1];
            self.linkLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:sls];
        }
        
        {
            self.virtualLinkLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleLineSymbol *virtualSls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor blueColor] width:1];
            self.virtualLinkLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:virtualSls];
        }
        
        {
            self.unionLineLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleLineSymbol *virtualSls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor yellowColor] width:0.5];
            self.unionLineLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:virtualSls];
        }
        
        {
            self.nodeLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor blueColor]];
            sms.size = CGSizeMake(2, 2);
            self.nodeLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:sms];
        }
        
        {
            self.virtualNodeLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleMarkerSymbol *virtualSms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
            virtualSms.size = CGSizeMake(2, 2);
            self.virtualNodeLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:virtualSms];
        }
        
        {
            self.junctionNodeLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleMarkerSymbol *junctionSms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
            junctionSms.size = CGSizeMake(2, 2);
            self.junctionNodeLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:junctionSms];
        }
    }
    return self;
}

- (void)addToMap:(TYMapView *)mapView
{
    [mapView addMapLayer:self.linkLayer];
    [mapView addMapLayer:self.virtualLinkLayer];
    
    [mapView addMapLayer:self.unionLineLayer];
    
    [mapView addMapLayer:self.nodeLayer];
    [mapView addMapLayer:self.virtualNodeLayer];
    [mapView addMapLayer:self.junctionNodeLayer];
    
}

@end
