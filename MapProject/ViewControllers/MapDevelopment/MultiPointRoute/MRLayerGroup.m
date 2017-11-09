//
//  MultiRouteLayerGroup.m
//  MapProject
//
//  Created by innerpeacer on 2017/11/8.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import "MRLayerGroup.h"
#import "TYMapView.h"
#import "MRParams.h"

@interface MRLayerGroup()
{
    MRSymbolGroup *symbolGroup;
}
@end

@implementation MRLayerGroup

- (id)initWithSymbolGroup:(MRSymbolGroup *)sg
{
    self = [super init];
    if (self) {
        symbolGroup = sg;
        {
            self.routeLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor magentaColor] width:1];
            self.routeLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:sls];
        }
        
        {
            self.paramLayer = [AGSGraphicsLayer graphicsLayer];
        }
        
        {
            self.startCombinationLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor greenColor] width:0.5];
            self.startCombinationLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:sls];
        }
        
        {
            self.endCombinationLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor] width:0.5];
            self.endCombinationLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:sls];
        }
        
        {
            self.stopsCombinationLayer = [AGSGraphicsLayer graphicsLayer];
            AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor orangeColor] width:0.5];
            self.stopsCombinationLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:sls];
        }
        //
        //        {
        //            self.virtualNodeLayer = [AGSGraphicsLayer graphicsLayer];
        //            AGSSimpleMarkerSymbol *virtualSms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
        //            virtualSms.size = CGSizeMake(2, 2);
        //            self.virtualNodeLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:virtualSms];
        //        }
        //
        //        {
        //            self.junctionNodeLayer = [AGSGraphicsLayer graphicsLayer];
        //            AGSSimpleMarkerSymbol *junctionSms = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
        //            junctionSms.size = CGSizeMake(2, 2);
        //            self.junctionNodeLayer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:junctionSms];
        //        }
    }
    return self;
}

- (void)addToMap:(TYMapView *)mapView
{
    [mapView addMapLayer:self.routeLayer];
    [mapView addMapLayer:self.paramLayer];
    
    [mapView addMapLayer:self.startCombinationLayer];
    [mapView addMapLayer:self.endCombinationLayer];
    [mapView addMapLayer:self.stopsCombinationLayer];

}

- (void)showRoute:(AGSPolyline *)line WithStart:(AGSPoint *)startPoint End:(AGSPoint *)endPoint
{
    [self.routeLayer removeAllGraphics];
    
    [self.routeLayer addGraphic:[AGSGraphic graphicWithGeometry:line symbol:symbolGroup.routeLineSymbol attributes:nil]];
    
    //    [self.routeLayer addGraphic:[AGSGraphic graphicWithGeometry:startPoint symbol:symbolGroup.yellowMarkerSymbol attributes:nil]];
    //    [self.routeLayer addGraphic:[AGSGraphic graphicWithGeometry:endPoint symbol:symbolGroup.yellowMarkerSymbol attributes:nil]];
    
    //    [self.routeLayer addGraphic:[AGSGraphic graphicWithGeometry:startPoint symbol:symbolGroup.startSymbol attributes:nil]];
    //    [self.routeLayer addGraphic:[AGSGraphic graphicWithGeometry:endPoint symbol:symbolGroup.endSymbol attributes:nil]];
    
    //    for (int i = 0; i < line.numPoints; ++i) {
    //        AGSTextSymbol *ts = [AGSTextSymbol textSymbolWithText:[NSString stringWithFormat:@"%d", i] color:[UIColor blackColor]];
    //        ts.offset = CGPointMake(0, 5);
    //        ts.fontSize = 10;
    //
    //        [self.routeLayer addGraphic:[AGSGraphic graphicWithGeometry:[line pointOnPath:0 atIndex:i] symbol:ts attributes:nil]];
    //    }
}

- (void)showRouteCollections:(NSArray *)routeArray WithStart:(AGSPoint *)startPoint End:(AGSPoint *)endPoint
{
    NSLog(@"%d parts in route", (int)routeArray.count);
    [self.routeLayer removeAllGraphics];
    
    for (int i = 0; i < routeArray.count; ++i) {
        AGSPolyline *line = routeArray[i];
        [self.routeLayer addGraphic:[AGSGraphic graphicWithGeometry:line symbol:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[self randomColor] width:2.0f] attributes:nil]];
    }
    
//    [self.routeLayer addGraphic:[AGSGraphic graphicWithGeometry:line symbol:symbolGroup.routeLineSymbol attributes:nil]];
}

- (UIColor *)randomColor
{
    return [UIColor colorWithRed:(arc4random() % 255)/255.0 green:(arc4random() % 255)/255.0 blue:(arc4random() % 255)/255.0 alpha:1.0f];
}
;
- (void)showMultiRouteParams:(MRParams *)params
{
    [self.paramLayer removeAllGraphics];
    
    [self.paramLayer addGraphic:[AGSGraphic graphicWithGeometry:params.startPoint symbol:symbolGroup.startParamSymbol attributes:nil]];
    [self.paramLayer addGraphic:[AGSGraphic graphicWithGeometry:params.endPoint symbol:symbolGroup.endParamSymbol attributes:nil]];
    for(int i = 0; i < [params stopCount]; ++i) {
        [self.paramLayer addGraphic:[AGSGraphic graphicWithGeometry:[params getStopPoint:i] symbol:symbolGroup.stopParamSymbol attributes:nil]];
    }
}

- (void)showCombinations:(NSArray *)combinations withName:(NSString *)name
{
    NSLog(@"show %@ combinations: %d", name, (int)combinations.count);
    if ([name isEqualToString:@"start"]) {
        [self.startCombinationLayer removeAllGraphics];
        for (int i = 0; i < combinations.count; ++i) {
            [self.startCombinationLayer addGraphic:[AGSGraphic graphicWithGeometry:combinations[i] symbol:nil attributes:nil]];
        }
    } else if ([name isEqualToString:@"end"]) {
        [self.endCombinationLayer removeAllGraphics];
        for (int i = 0; i < combinations.count; ++i) {
            [self.endCombinationLayer addGraphic:[AGSGraphic graphicWithGeometry:combinations[i] symbol:nil attributes:nil]];
        }
    } else if ([name isEqualToString:@"stops"]) {
        [self.stopsCombinationLayer removeAllGraphics];
        for (int i = 0; i < combinations.count; ++i) {
            [self.stopsCombinationLayer addGraphic:[AGSGraphic graphicWithGeometry:combinations[i] symbol:nil attributes:nil]];
        }
    }
}

@end

