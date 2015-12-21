//
//  TYSyncSymbolRecord.h
//  MapProject
//
//  Created by innerpeacer on 15/12/15.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPSyncFillSymbolRecord : NSObject

@property (nonatomic, assign) int symbolID;
@property (nonatomic, strong) NSString *fillColor;
@property (nonatomic, strong) NSString *outlineColor;
@property (nonatomic, assign) double lineWidth;

+ (IPSyncFillSymbolRecord *)parseFillSymbolRecord:(NSDictionary *)recordObject;
+ (NSDictionary *)buildFillSymbolObject:(IPSyncFillSymbolRecord *)record;

@end


@interface IPSyncIconSymbolRecord : NSObject

@property (nonatomic, assign) int symbolID;
@property (nonatomic, strong) NSString *icon;

+ (IPSyncIconSymbolRecord *)parseIconSymbolRecord:(NSDictionary *)recordObject;
+ (NSDictionary *)buildIconSymbolObject:(IPSyncIconSymbolRecord *)record;

@end
