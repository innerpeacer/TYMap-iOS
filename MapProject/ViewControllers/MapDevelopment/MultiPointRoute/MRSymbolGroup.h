//
//  MRSymbolGroup.h
//  MapProject
//
//  Created by innerpeacer on 2017/11/8.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface MRSymbolGroup : NSObject

@property (nonatomic, strong) AGSSimpleMarkerSymbol *yellowMarkerSymbol;

@property (nonatomic, strong) AGSSimpleMarkerSymbol *startParamSymbol;
@property (nonatomic, strong) AGSSimpleMarkerSymbol *endParamSymbol;
@property (nonatomic, strong) AGSSimpleMarkerSymbol *stopParamSymbol;

@property (nonatomic, strong) AGSSimpleLineSymbol *routeLineSymbol;
@property (nonatomic, strong) AGSPictureMarkerSymbol *startSymbol;
@property (nonatomic, strong) AGSPictureMarkerSymbol *endSymbol;

@end
