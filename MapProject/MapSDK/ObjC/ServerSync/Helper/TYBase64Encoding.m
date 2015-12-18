//
//  TYBase64Encoding.m
//  MapProject
//
//  Created by innerpeacer on 15/11/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYBase64Encoding.h"

@implementation TYBase64Encoding

+ (NSData *)decodingString:(NSString *)string
{
    return [[NSData alloc] initWithBase64EncodedString:string options:0];
}

+ (NSString *)encodeingData:(NSData *)data
{
    return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

@end
