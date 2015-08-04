//
//  MD5Utils.m
//  MapProject
//
//  Created by innerpeacer on 15/7/21.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "MD5Utils.h"
#include "MD5.hpp"

@implementation MD5Utils

+ (NSString *)md5:(NSString *)str
{
    MD5 md5([str UTF8String]);
    return [NSString stringWithUTF8String:md5.toString().c_str()];
}

@end
