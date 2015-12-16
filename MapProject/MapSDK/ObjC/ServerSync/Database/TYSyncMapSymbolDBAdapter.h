//
//  TYSyncMapSymbolDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/12/16.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYSyncSymbolRecord.h"

@interface TYSyncMapSymbolDBAdapter : NSObject

- (id)initWithPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

- (BOOL)eraseSymbolTable;

- (BOOL)insertFillSymbol:(TYSyncFillSymbolRecord *)fillRecord;
- (int)insertFillSymbols:(NSArray *)fillSymbols;
- (NSArray *)getAllFillSymbols;

- (BOOL)insertIconSymbol:(TYSyncIconSymbolRecord *)iconRecord;
- (int)insertIconSymbols:(NSArray *)iconSymbols;
- (NSArray *)getAllIconSymbols;

@end
