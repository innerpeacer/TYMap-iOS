//
//  NPLocationLayer.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/2.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "NPMarkerSymbol.h"

@interface NPLocationLayer : AGSGraphicsLayer

- (void)setLocationSymbol:(NPMarkerSymbol *)symbol;

@end
