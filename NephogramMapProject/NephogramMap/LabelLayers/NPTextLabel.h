//
//  NPTextLabel.h
//  NephogramMapProject
//
//  Created by innerpeacer on 15/4/14.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPPoint.h"
#import <ArcGIS/ArcGIS.h>

@interface NPTextLabel : NSObject

@property (nonatomic, strong) NPPoint *position;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, readonly) CGSize textSize;

@property (nonatomic, strong) AGSGraphic *textGraphic;
@property (nonatomic, strong) AGSTextSymbol *textSymbol;

@property (nonatomic, assign) BOOL isHidden;

- (id)initWithName:(NSString *)name Position:(NPPoint *)pos;

@end
