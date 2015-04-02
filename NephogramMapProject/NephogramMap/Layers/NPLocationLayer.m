//
//  NPLocationLayer.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/2.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPLocationLayer.h"

@interface NPLocationLayer()
{
    NPMarkerSymbol *locationSymbol;
}

@end


@implementation NPLocationLayer

- (id)initWithSpatialReference:(AGSSpatialReference *)sr
{
    self = [super initWithSpatialReference:sr];
    if (self) {
        locationSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
        locationSymbol.size = CGSizeMake(5, 5);
        
        AGSSimpleRenderer *renderer = [AGSSimpleRenderer simpleRendererWithSymbol:locationSymbol];
        self.renderer = renderer;
    }
    return self;
}

- (void)setLocationSymbol:(NPMarkerSymbol *)symbol
{
    locationSymbol = symbol;
    AGSSimpleRenderer *renderer = [AGSSimpleRenderer simpleRendererWithSymbol:locationSymbol];
    self.renderer = renderer;

}

@end
