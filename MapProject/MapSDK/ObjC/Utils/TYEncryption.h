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
+ (NSString *)decryptString:(NSString *)string withKey:(NSString *)key;

+ (NSString *)encryptString:(NSString *)string;
+ (NSString *)encryptString:(NSString *)string withKey:(NSString *)key;

+ (void)encryptFile:(NSString *)originalPath toFile:(NSString *)encryptedFile;
+ (void)encryptFile:(NSString *)originalPath toFile:(NSString *)encryptedFile  withKey:(NSString *)key;


+ (void)decryptFile:(NSString *)encryptedFile toFile:(NSString *)decryptedFile;
+ (void)decryptFile:(NSString *)encryptedFile toFile:(NSString *)decryptedFile withKey:(NSString *)key;

                                                                                       
+ (NSString *)descriptFile:(NSString *)file;
+ (NSString *)descriptFile:(NSString *)file withKey:(NSString *)key;

@end
