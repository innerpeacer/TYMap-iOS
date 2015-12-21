//
//  SymbolGroup.h
//  MapProject
//
//  Created by innerpeacer on 15/10/8.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface SymbolGroup : NSObject

@property (nonatomic, strong) AGSSimpleMarkerSymbol *testSimpleMarkerSymbol;
@property (nonatomic, strong) AGSSimpleFillSymbol *testSimpleFillSymbol;
@property (nonatomic, strong) AGSSimpleLineSymbol *testSimpleLineSymbol;

@property (nonatomic, strong) AGSPictureMarkerSymbol *startSymbol;
@property (nonatomic, strong) AGSPictureMarkerSymbol *endSymbol;

@end
