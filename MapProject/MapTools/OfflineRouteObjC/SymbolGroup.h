//
//  SymbolGroup.h
//  MapProject
//
//  Created by innerpeacer on 15/10/8.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "TYPictureMarkerSymbol.h"

@interface SymbolGroup : NSObject

@property (nonatomic, strong) AGSSimpleMarkerSymbol *testSimpleMarkerSymbol;
@property (nonatomic, strong) AGSSimpleFillSymbol *testSimpleFillSymbol;
@property (nonatomic, strong) AGSSimpleLineSymbol *testSimpleLineSymbol;

@property (nonatomic, strong) TYPictureMarkerSymbol *startSymbol;
@property (nonatomic, strong) TYPictureMarkerSymbol *endSymbol;

@end
