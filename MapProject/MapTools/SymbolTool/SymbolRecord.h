//
//  SymbolRecord.h
//  MapProject
//
//  Created by innerpeacer on 15/12/14.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FillSymbolRecord : NSObject

@property (nonatomic, assign) int symbolID;
@property (nonatomic, strong) NSString *fillColor;
@property (nonatomic, strong) NSString *outlineColor;
@property (nonatomic, assign) double lineWidth;

@end


@interface IconSymbolRecord : NSObject

@property (nonatomic, assign) int symbolID;
@property (nonatomic, strong) NSString *icon;

@end