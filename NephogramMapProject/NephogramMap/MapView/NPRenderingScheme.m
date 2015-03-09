//
//  NPRenderingScheme.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPRenderingScheme.h"

#define JSON_FIELD_ROOT_RENDERING_SCHEME @"RenderingScheme"

#define JSON_FIELD_FIRST_DEFAULT_SYMBOL @"DefaultSymbol"
#define JSON_FIELD_FIRST_FILL_SYMBOL @"FillSymbol"
#define JSON_FIELD_FIRST_ICON_SYMBOL @"IconSymbol"

#define JSON_FIELD_SECOND_DEFAULT_FILL_SYMBOL @"DefaultFillSymbol"
#define JSON_FIELD_SECOND_DEFAULT_HIGHLIGHT_SYMBOL @"DefaultHighlightFillSymbol"
#define JSON_FIELD_SECOND_DEFAULT_LINE_SYMBOL @"DefaultLineSymbol"
#define JSON_FIELD_SECOND_DEFAULT_HIGHLIGHT_LINE_SYMBOL @"DefaultHighlightLineSymbol"

#define JSON_FIELD_LEAVE_COLOR_ID @"colorID"
#define JSON_FIELD_LEAVE_FILL_COLOR @"fillColor"
#define JSON_FIELD_LEAVE_OUTLINE_COLOR @"outlineColor"
#define JSON_FIELD_LEAVE_LINE_WIDTH @"lineWidth"
#define JSON_FIELD_LEAVE_ICON @"icon"


@implementation NPRenderingScheme

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        
        _fillSymbolDictionary = [[NSMutableDictionary alloc] init];
        _iconSymbolDictionary = [[NSMutableDictionary alloc] init];
        
        [self parseRenderingSchemeFile:path];
    }
    return self;
}

- (void)parseRenderingSchemeFile:(NSString *)path
{
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    NSDictionary *rootDict = [dict objectForKey:JSON_FIELD_ROOT_RENDERING_SCHEME];
    
    NSDictionary *firstDefaultSymbolDict = [rootDict objectForKey:JSON_FIELD_FIRST_DEFAULT_SYMBOL];
    NSArray *firstFillSymbolArray = [rootDict objectForKey:JSON_FIELD_FIRST_FILL_SYMBOL];
    NSArray *firstIconSymbolArray = [rootDict objectForKey:JSON_FIELD_FIRST_ICON_SYMBOL];
    
    
    // Default Symbol
    {
        NSDictionary *defaultFillSymbolDict = [firstDefaultSymbolDict objectForKey:JSON_FIELD_SECOND_DEFAULT_FILL_SYMBOL];
        UIColor *fillColor = [self parseColor:[defaultFillSymbolDict objectForKey:JSON_FIELD_LEAVE_FILL_COLOR]];
        UIColor *outlineColor = [self parseColor:[defaultFillSymbolDict objectForKey:JSON_FIELD_LEAVE_OUTLINE_COLOR]];
        float lineWidth = [[defaultFillSymbolDict objectForKey:JSON_FIELD_LEAVE_LINE_WIDTH] floatValue];
        _defaultFillSymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:fillColor outlineColor:outlineColor];
        _defaultFillSymbol.outline.width = lineWidth;
    }
    
    // Default Highlight Fill Symbol
    {
        NSDictionary *defaultHighlightFillSymbolDict = [firstDefaultSymbolDict objectForKey:JSON_FIELD_SECOND_DEFAULT_HIGHLIGHT_SYMBOL];
        UIColor *fillColor = [self parseColor:[defaultHighlightFillSymbolDict objectForKey:JSON_FIELD_LEAVE_FILL_COLOR]];
        UIColor *outlineColor = [self parseColor:[defaultHighlightFillSymbolDict objectForKey:JSON_FIELD_LEAVE_OUTLINE_COLOR]];
        float lineWidth = [[defaultHighlightFillSymbolDict objectForKey:JSON_FIELD_LEAVE_LINE_WIDTH] floatValue];
        _defaultHighlightFillSymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:fillColor outlineColor:outlineColor];
        _defaultHighlightFillSymbol.outline.width = lineWidth;
    }
    
    // Fill Symbol
    {
        NSMutableDictionary *fillSymbolDict = [NSMutableDictionary dictionary];
        for (NSDictionary *secondDict in firstFillSymbolArray) {
            NSNumber *colorID = [secondDict objectForKey:JSON_FIELD_LEAVE_COLOR_ID];
            UIColor *fillColor = [self parseColor:[secondDict objectForKey:JSON_FIELD_LEAVE_FILL_COLOR]];
            UIColor *outlineColor = [self parseColor:[secondDict objectForKey:JSON_FIELD_LEAVE_OUTLINE_COLOR]];
            float lineWidth = [[secondDict objectForKey:JSON_FIELD_LEAVE_LINE_WIDTH] floatValue];
            
            AGSSimpleFillSymbol *sfs = [AGSSimpleFillSymbol simpleFillSymbolWithColor:fillColor outlineColor:outlineColor];
            sfs.outline.width = lineWidth;
            [fillSymbolDict setObject:sfs forKey:colorID];
        }
        _fillSymbolDictionary = fillSymbolDict;
    }
    
    
    // Icon Symbol
    {
        NSMutableDictionary *iconDict = [NSMutableDictionary dictionary];
        for (NSDictionary *secondDict in firstIconSymbolArray) {
            NSNumber *colorID = [secondDict objectForKey:JSON_FIELD_LEAVE_COLOR_ID];
            NSString *icon = [secondDict objectForKey:JSON_FIELD_LEAVE_ICON];
            [iconDict setObject:icon forKey:colorID];
        }
        _iconSymbolDictionary = iconDict;
    }
    
    
}



/**
 *  从字符串中解析颜色值
 *
 *  @param colorString 颜色字符串，格式："#AARRGGBB"
 *
 *  @return 颜色值
 */
- (UIColor *)parseColor:(NSString *)colorString
{
    float alpha = strtoul([[colorString substringWithRange:NSMakeRange(1, 2)] UTF8String], 0, 16) / 255.0f;
    float red = strtoul([[colorString substringWithRange:NSMakeRange(3, 2)] UTF8String], 0, 16) / 255.0f;
    float green = strtoul([[colorString substringWithRange:NSMakeRange(5, 2)] UTF8String], 0, 16) / 255.0f;
    float blue = strtoul([[colorString substringWithRange:NSMakeRange(7, 2)] UTF8String], 0, 16) / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
