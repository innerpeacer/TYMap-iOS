//
//  SymbolRecord.m
//  MapProject
//
//  Created by innerpeacer on 15/12/14.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "SymbolRecord.h"
#import "WebMapFields.h"

@implementation FillSymbolRecord

- (id)buildWebFillObject
{
    NSMutableDictionary *fillObject = [[NSMutableDictionary alloc] init];
    [fillObject setObject:@(_symbolID) forKey:KEY_SYMBOL_ID];
    [fillObject setObject:_fillColor forKey:KEY_FILL_COLOR];
    [fillObject setObject:_outlineColor forKey:KEY_OUTLINE_COLOR];
    [fillObject setObject:@(_lineWidth) forKey:KEY_LINE_WIDTH];
    return fillObject;
}

@end


@implementation IconSymbolRecord

- (id)buildWebIconObject
{
    NSMutableDictionary *iconObject = [[NSMutableDictionary alloc] init];
    [iconObject setObject:@(_symbolID) forKey:KEY_SYMBOL_ID];
    [iconObject setObject:_icon forKey:KEY_ICON];
    return iconObject;
}

@end