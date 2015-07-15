//
//  NPFacilityLabel.h
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "NPPoint.h"

@interface NPFacilityLabel : NSObject

@property (nonatomic, strong) NPPoint *position;
@property (nonatomic, readonly) int categoryID;

@property (nonatomic, strong) AGSGraphic *facilityGraphic;

@property (nonatomic, strong) AGSPictureMarkerSymbol *normalFacilitySymbol;
@property (nonatomic, strong) AGSPictureMarkerSymbol *highlightedFacilitySymbol;

@property (nonatomic, strong) AGSPictureMarkerSymbol *currentSymbol;

@property (nonatomic, assign) BOOL isHidden;

- (void)setHighlighted:(BOOL)highlighted;
- (BOOL)isHighlighted;

- (id)initWithCategoryID:(int)categoryID Position:(NPPoint *)pos;

- (CGSize)getFacilityLabelSize;

@end
