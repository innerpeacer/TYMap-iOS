//
//  TYBase64Encoding.m
//  MapProject
//
//  Created by innerpeacer on 15/11/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPBase64Encoding.h"

@implementation IPBase64Encoding

+ (NSData *)decodingString:(NSString *)string
{
    return [[NSData alloc] initWithBase64EncodedString:string options:0];
}

+ (NSString *)encodeingData:(NSData *)data
{
    return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

+ (NSString *)encodeStringForString:(NSString *)string
{
    return [[string dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

@end
