//
//  TYTextLabel.h
//  MapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYPoint.h"
#import <ArcGIS/ArcGIS.h>

@interface IPTextLabel : NSObject

@property (nonatomic, strong) TYPoint *position;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) CGSize labelSize;

@property (nonatomic, strong) AGSGraphic *textGraphic;
@property (nonatomic, strong) AGSSymbol *textSymbol;

@property (nonatomic, assign) BOOL isHidden;
@property (nonatomic, assign) int maxLevel;
@property (nonatomic, assign) int minLevel;

- (id)initWithName:(NSString *)name Position:(TYPoint *)pos;

@end
