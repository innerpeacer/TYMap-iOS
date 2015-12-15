//
//  TYRenderingScheme.m
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYRenderingScheme.h"
#import "TYSymbolDBAdapter.h"

@implementation TYRenderingScheme

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        
        _fillSymbolDictionary = [[NSMutableDictionary alloc] init];
        _iconSymbolDictionary = [[NSMutableDictionary alloc] init];
        
        [self readRenderingSchemeFromDatabase:path];
    }
    return self;
}

- (void)readRenderingSchemeFromDatabase:(NSString *)path
{
    TYSymbolDBAdapter *db = [[TYSymbolDBAdapter alloc] initWithPath:path];
    [db open];
    
    NSDictionary *fillDict = [db readFillSymbols];
    NSDictionary *iconDict = [db readIconSymbols];
    
    _defaultFillSymbol = [fillDict objectForKey:@(9999)];
    _defaultHighlightFillSymbol = [fillDict objectForKey:@(9998)];
    _fillSymbolDictionary = fillDict;
    _iconSymbolDictionary = iconDict;
    
    [db close];
}

@end
