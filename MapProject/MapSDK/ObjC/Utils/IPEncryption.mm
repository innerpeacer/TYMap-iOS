//
//  IPEncryption.m
//  TYDecryption
//
//  Created by innerpeacer on 15/7/21.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPEncryption.h"
#import "IPXEncryption.hpp"

using namespace Innerpeacer::MapSDK;

@implementation IPEncryption

+ (void)encryptFile:(NSString *)originalPath toFile:(NSString *)encryptedFile
{
    encryptFile([originalPath UTF8String], [encryptedFile UTF8String]);
}

+ (void)encryptFile:(NSString *)originalPath toFile:(NSString *)encryptedFile  withKey:(NSString *)key
{
    encryptFile([originalPath UTF8String], [encryptedFile UTF8String], [key UTF8String]);
}


+ (NSString *)descriptFile:(NSString *)file
{
    return [NSString stringWithUTF8String:decryptFile([file UTF8String]).c_str()];
}

+ (NSString *)descriptFile:(NSString *)file withKey:(NSString *)key
{
    return [NSString stringWithUTF8String:decryptFile([file UTF8String], [key UTF8String]).c_str()];
}

+ (void)decryptFile:(NSString *)encryptedFile toFile:(NSString *)decryptedFile
{
    [IPEncryption encryptFile:encryptedFile toFile:decryptedFile];
}

+ (void)decryptFile:(NSString *)encryptedFile toFile:(NSString *)decryptedFile withKey:(NSString *)key;
{
    [IPEncryption encryptFile:encryptedFile toFile:decryptedFile withKey:key];
}

+ (NSString *)decryptString:(NSString *)string
{
    return [NSString stringWithCString:encryptString([string UTF8String]).c_str() encoding:NSUTF8StringEncoding];
}

+ (NSString *)decryptString:(NSString *)string withKey:(NSString *)key
{
    return [NSString stringWithCString:encryptString([string UTF8String], [key UTF8String]).c_str() encoding:NSUTF8StringEncoding];
}

+ (NSString *)encryptString:(NSString *)string
{
    return [IPEncryption decryptString:string];
}

+ (NSString *)encryptString:(NSString *)string withKey:(NSString *)key
{
    return [IPEncryption decryptString:string withKey:key];
}

@end
