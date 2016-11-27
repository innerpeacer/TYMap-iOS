//
//  TYTraceLocalPoint.h
//  MapProject
//
//  Created by innerpeacer on 2016/11/26.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import <TYMapData/TYMapData.h>

@interface TYTraceLocalPoint : NSObject

@property (nonatomic, strong) NSString *themeID;
@property (nonatomic, assign) BOOL inTheme;
@property (nonnull, strong) TYLocalPoint *location;
@end
