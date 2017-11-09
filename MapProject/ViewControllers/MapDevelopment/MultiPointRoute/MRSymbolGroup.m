//
//  MRSymbolGroup.m
//  MapProject
//
//  Created by innerpeacer on 2017/11/8.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import "MRSymbolGroup.h"

@implementation MRSymbolGroup

- (id)init
{
    self = [super init];
    if (self) {
        self.routeLineSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor magentaColor] width:2];
        self.yellowMarkerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor yellowColor]];
        self.yellowMarkerSymbol.size = CGSizeMake(5, 5);
        
        {
            self.startParamSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
            self.startParamSymbol.style = AGSSimpleMarkerSymbolStyleTriangle;
            
            self.endParamSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
            self.endParamSymbol.style = AGSSimpleMarkerSymbolStyleTriangle;
            
            self.stopParamSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor orangeColor]];
            self.stopParamSymbol.style = AGSSimpleMarkerSymbolStyleDiamond;
        }

        self.startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
        self.startSymbol.offset = CGPointMake(0, 22);
        
        self.endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
        self.endSymbol.offset = CGPointMake(0, 22);
        
    }
    return self;
}

@end
