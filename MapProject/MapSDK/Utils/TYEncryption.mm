//
//  TYEncryption.m
//  TYDecryption
//
//  Created by innerpeacer on 15/7/21.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYEncryption.h"
#import "IPEncryption.hpp"

static NSString *KEY = @"6^)(9-p35@%3#4S!4S0)$Y%%^&5(j.&^&o(*0)$Y%!#O@*GpG@=+@j.&6^)(0-=+";
static NSString *PASSWORD_FOR_CONTENT = @"innerpeacer-content";

@implementation TYEncryption

+ (void)encryptFile:(NSString *)originalPath toFile:(NSString *)encryptedFile
{
//    NSString *originalString = [NSString stringWithContentsOfFile:originalPath encoding:NSUTF8StringEncoding error:nil];
//    NSString *encryptedString = [TYEncryption encryptString:originalString];
//    [encryptedString writeToFile:encryptedFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
    encryptFile([originalPath UTF8String], [encryptedFile UTF8String]);
}

+ (NSString *)descriptFile:(NSString *)file
{
//    NSString *encryptedString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
//    return [TYEncryption encryptString:encryptedString];
    
    return [NSString stringWithUTF8String:decryptFile([file UTF8String]).c_str()];
}

+ (void)decryptFile:(NSString *)encryptedFile toFile:(NSString *)decryptedFile
{
    [TYEncryption encryptFile:encryptedFile toFile:decryptedFile];
}

+ (NSString *)decryptString:(NSString *)string
{
    return [TYEncryption encryptString:string];
}

static NSStringEncoding encoding = NSUnicodeStringEncoding;

+ (NSString *)encryptString:(NSString *)string
{
//    NSLog(@"%@", string);
//    std::string encryptedString = encryptString([string UTF8String]);
//    return [NSString stringWithUTF8String:encryptedString.c_str()];
    
    NSData *passData = [PASSWORD_FOR_CONTENT dataUsingEncoding:encoding];
    int passLength = (int)passData.length;
    Byte passValue[passLength];
    
    NSData *keyData = [KEY dataUsingEncoding:encoding];
    int keyLength = (int)keyData.length;
    Byte keyValue[keyLength];
    
    {
        Byte *passBytes = (Byte *)[passData bytes];
        memcpy(&passValue[0], passBytes, passLength);
        
        Byte *keyBytes = (Byte *)[keyData bytes];
        memcpy(&keyValue[0], keyBytes, keyLength);
    }
    
    
    int pa_pos = 0;
    for (int i = 0; i < keyLength; ++i) {
        keyValue[i] ^= passValue[pa_pos];
        pa_pos++;
        
        if (pa_pos == passLength) {
            pa_pos = 0;
        }
    }
    
    NSData *originalData = [string dataUsingEncoding:encoding allowLossyConversion:YES];
    long originalLength = originalData.length;
    Byte originalValue[originalLength];
    {
        Byte *originalBytes = (Byte *)[originalData bytes];
        memcpy(&originalValue[0], originalBytes, originalLength);
    }
    
    int key_pos = 0;
    for (int i = 0; i < originalLength ; ++i) {
        originalValue[i] ^= keyValue[key_pos];
        key_pos++;
        if (key_pos == keyLength) {
            key_pos = 0;
        }
    }
    
    NSData *resultData = [NSData dataWithBytes:originalValue length:originalLength];
    return [[NSString alloc] initWithData:resultData encoding:encoding];
    
}

@end
