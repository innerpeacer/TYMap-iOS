//
//  NPTextLabel.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPPoint.h"
#import <ArcGIS/ArcGIS.h>

typedef enum {
    NP_SHOW_TL1,
    NP_SHOW_TL2,
    NP_HIDE,
} NPTextLabelStatus;

@interface NPTextLabel : NSObject

@property (nonatomic, strong) NSString *geoID;
@property (nonatomic, strong) NSString *poiID;

@property (nonatomic, strong) NPPoint *position;

@property (nonatomic, readonly) double switchingWidth;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, readonly) CGSize textSize;

@property (nonatomic, strong) AGSGraphic *textGraphic;
@property (nonatomic, strong) AGSTextSymbol *textSymbol;

- (id)initWithGeoID:(NSString *)gid PoiID:(NSString *)pid Name:(NSString *)name Position:(NPPoint *)pos switchignWidth:(double)w;

@end
