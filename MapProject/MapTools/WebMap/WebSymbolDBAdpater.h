//
//  WebSymbolDBAdpater.h
//  MapProject
//
//  Created by innerpeacer on 16/1/27.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebSymbolDBAdpater : NSObject

- (id)initWithPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

- (NSDictionary *)readIconSymbols;
- (NSDictionary *)readFillSymbols;

@end
