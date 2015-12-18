//
//  MD5Utils.m
//  MapProject
//
//  Created by innerpeacer on 15/7/21.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "MD5Utils.h"
#include "IPXMD5.hpp"

@implementation MD5Utils

+ (NSString *)md5:(NSString *)str
{
    IPXMD5 md5([str UTF8String]);
    return [NSString stringWithUTF8String:md5.toString().c_str()];
}

+ (NSString *)md5ForFile:(NSString *)path
{
    std::ifstream in([path UTF8String], std::ios::in|std::ios::binary);
    IPXMD5 md5(in);
    
    return [NSString stringWithUTF8String:md5.toString().c_str()];
}

+ (NSString *)md5ForDirectory:(NSString *)dir
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator;
    enumerator = [fileManager enumeratorAtPath:dir];

    NSString *name;
    IPXMD5 fileMD5;

    while (name = [enumerator nextObject]) {
        NSString *sourcePath = [dir stringByAppendingPathComponent:name];
        std::ifstream in([sourcePath UTF8String], std::ios::in|std::ios::binary);
        fileMD5.update(in);
    }
    
    return [NSString stringWithUTF8String:fileMD5.toString().c_str()];
}

@end
