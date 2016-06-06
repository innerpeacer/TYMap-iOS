//
//  TYBase64Encoding.h
//  MapProject
//
//  Created by innerpeacer on 15/11/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPBase64Encoding : NSObject

+ (NSData *)decodingString:(NSString *)string;
+ (NSString *)encodeingData:(NSData *)data;

+ (NSString *)encodeStringForString:(NSString *)string;

@end
