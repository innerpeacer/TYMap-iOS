//
//  TYSyncSymbolRecord.h
//  MapProject
//
//  Created by innerpeacer on 15/12/15.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYSyncFillSymbolRecord : NSObject

@property (nonatomic, assign) int symbolID;
@property (nonatomic, strong) NSString *fillColor;
@property (nonatomic, strong) NSString *outlineColor;
@property (nonatomic, assign) double lineWidth;

+ (TYSyncFillSymbolRecord *)parseFillSymbolRecord:(NSDictionary *)recordObject;
+ (NSDictionary *)buildFillSymbolObject:(TYSyncFillSymbolRecord *)record;

@end


@interface TYSyncIconSymbolRecord : NSObject

@property (nonatomic, assign) int symbolID;
@property (nonatomic, strong) NSString *icon;

+ (TYSyncIconSymbolRecord *)parseIconSymbolRecord:(NSDictionary *)recordObject;
+ (NSDictionary *)buildIconSymbolObject:(TYSyncIconSymbolRecord *)record;

@end
