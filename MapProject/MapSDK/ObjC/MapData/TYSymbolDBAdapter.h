//
//  TYSymbolDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/12/14.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYRenderingScheme.h"

@interface TYSymbolDBAdapter : NSObject

- (id)initWithPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

- (NSDictionary *)readIconSymbols;
- (NSDictionary *)readFillSymbols;

@end
