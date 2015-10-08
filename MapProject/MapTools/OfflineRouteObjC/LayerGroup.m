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
            AGSSimpleLineSymbol *virtualSls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor grayColor] width:1];
            self.virtualLinkLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:virtualSls];
        }
        
        {
            self.nodeLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor blueColor]];
            sms.size = CGSizeMake(5, 5);
            self.nodeLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:sms];
        }
        
        {
            self.virtualNodeLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleMarkerSymbol *virtualSms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor yellowColor]];
            virtualSms.size = CGSizeMake(5, 5);
            self.virtualNodeLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:virtualSms];
        }
        
        {
            self.junctionNodeLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleMarkerSymbol *junctionSms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
            junctionSms.size = CGSizeMake(5, 5);
            self.junctionNodeLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:junctionSms];
        }
    }
    return self;
}

- (void)addToMap:(TYMapView *)mapView
{
    [mapView addMapLayer:self.linkLayer];
    [mapView addMapLayer:self.virtualLinkLayer];
    [mapView addMapLayer:self.nodeLayer];
    [mapView addMapLayer:self.virtualNodeLayer];
    [mapView addMapLayer:self.junctionNodeLayer];
    
}

@end
