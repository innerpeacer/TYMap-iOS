//
//  MD5Utils.h
//  MapProject
//
//  Created by innerpeacer on 15/7/21.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5Utils : NSObject

+ (NSString *)md5:(NSString *)str;

+ (NSString *)md5ForFile:(NSString *)path;

+ (NSString *)md5ForDirectory:(NSString *)dir;

@end
