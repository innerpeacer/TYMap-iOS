//
//  IPSyncMapSymbolDBAdapter.h
//  MapProject
//
//  Created by innerpeacer on 15/12/16.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPSyncSymbolRecord.h"

@interface IPSyncMapSymbolDBAdapter : NSObject

- (id)initWithPath:(NSString *)path;

- (BOOL)open;
- (BOOL)close;

- (BOOL)eraseSymbolTable;

- (BOOL)insertFillSymbol:(IPSyncFillSymbolRecord *)fillRecord;
- (int)insertFillSymbols:(NSArray *)fillSymbols;
- (NSArray *)getAllFillSymbols;

- (BOOL)insertIconSymbol:(IPSyncIconSymbolRecord *)iconRecord;
- (int)insertIconSymbols:(NSArray *)iconSymbols;
- (NSArray *)getAllIconSymbols;

@end
