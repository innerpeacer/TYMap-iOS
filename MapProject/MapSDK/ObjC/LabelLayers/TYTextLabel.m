//
//  TYTextLabel.m
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYTextLabel.h"

#define DEFAULT_MAX_LEVEL 10000
#define DEFAULT_MIN_LEVEL -1

@interface TYTextLabel()
{
    
}

@end

@implementation TYTextLabel

static UIFont *font = nil;

static AGSSimpleMarkerSymbol *pointSymbol = nil;

//- (id)initWithGeoID:(NSString *)gid PoiID:(NSString *)pid Name:(NSString *)name Position:(TYPoint *)pos switchignWidth:(double)w
//{
//    self = [super init];
//    if (self) {
//        _geoID = gid;
//        _poiID = pid;
//        
//        _position = pos;
//        _switchingWidth = w;
//        
//        _text = name;
//        _textSize = [name sizeWithAttributes:@{NSFontAttributeName : [TYTextLabel getDefaultFont]}];
//    }
//    return self;
//}

- (id)initWithName:(NSString *)name Position:(TYPoint *)pos
{
    self = [super init];
    if (self) {
        _position = pos;
        
        _text = name;
        _labelSize = [name sizeWithAttributes:@{NSFontAttributeName : [TYTextLabel getDefaultFont]}];
        _maxLevel = DEFAULT_MAX_LEVEL;
        _minLevel = DEFAULT_MIN_LEVEL;
    }
    return self;
}


+ (UIFont *)getDefaultFont
{
    if (font == nil) {
        font = [UIFont fontWithName:@"Heiti SC" size:10.0];
    }
    return font;
}

+ (AGSSimpleMarkerSymbol *)getDefaultPointSymbol
{
    if (pointSymbol == nil) {
        pointSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
        pointSymbol.size = CGSizeMake(5, 5);
    }
    return pointSymbol;
}

@end
