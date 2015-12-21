//
//  SymbolGroup.m
//  MapProject
//
//  Created by innerpeacer on 15/10/8.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "SymbolGroup.h"

@implementation SymbolGroup

- (id)init
{
    self = [super init];
    if (self) {
        self.testSimpleLineSymbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor magentaColor] width:3];
        self.testSimpleMarkerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor yellowColor]];
        self.testSimpleMarkerSymbol.size = CGSizeMake(5, 5);
        
        self.startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
        self.startSymbol.offset = CGPointMake(0, 22);
        
        self.endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
        self.endSymbol.offset = CGPointMake(0, 22);
        
    }
    return self;
}

@end
