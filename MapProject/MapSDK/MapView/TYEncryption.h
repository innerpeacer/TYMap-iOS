//
//  TYEncryption.h
//  TYDecryption
//
//  Created by innerpeacer on 15/7/21.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYEncryption : NSObject

+ (NSString *)decryptString:(NSString *)string;
+ (NSString *)encryptString:(NSString *)string;

+ (void)encryptFile:(NSString *)originalPath toFile:(NSString *)encryptedFile;
+ (void)decryptFile:(NSString *)encryptedFile toFile:(NSString *)decryptedFile;

@end
