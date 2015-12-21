//
//  LicenseGenerator.m
//  MapProject
//
//  Created by innerpeacer on 15/9/21.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "MapLicenseGenerator.h"
#import "IPEncryption.h"
#import "IPMD5Utils.h"

@implementation MapLicenseGenerator

+ (NSString *)generateLicenseForUserID:(NSString *)userID Building:(NSString *)building ExpiredDate:(NSString *)expiredDate
{
    if (userID == nil || userID.length < 18) {
        NSLog(@"Invalid UserID.");
        return nil;
    }
    
    if (expiredDate == nil) {
        NSLog(@"Expired Date Cannot be nil.");
        return nil;
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        NSDate* date = [dateFormatter dateFromString:expiredDate];
        if (date == nil) {
            NSLog(@"Cannot parse Expired Date");
            return nil;
        }
    }
    
    NSString *key1 = [userID substringWithRange:NSMakeRange(2, 8)];
    NSString *key2 = [userID substringWithRange:NSMakeRange(10, 8)];
    NSString *encryptedBuildingID = [IPEncryption encryptString:[building substringWithRange:NSMakeRange(0, 8)] withKey:key1];
    NSString *encryptedExpiredDate = [IPEncryption encryptString:expiredDate withKey:key2];
    NSString *md5ForBuildingID = [IPMD5Utils md5:encryptedBuildingID];
    NSString *originalMD5 = [NSString stringWithFormat:@"MAP%@%@", encryptedBuildingID, encryptedExpiredDate];
    
    NSString *md5String = [IPMD5Utils md5:originalMD5];
    NSString *license = [NSString stringWithFormat:@"%@%@%@%@", [md5String substringWithRange:NSMakeRange(0, 8)], [IPEncryption encryptString:encryptedBuildingID withKey:md5ForBuildingID], [IPEncryption encryptString:encryptedExpiredDate withKey:md5ForBuildingID], [md5String substringWithRange:NSMakeRange(24, 8)]];
    
//    NSLog(@"Key1: %@", key1);
//    NSLog(@"Key2: %@", key2);
//    NSLog(@"encryptedBuildingID: %@", encryptedBuildingID);
//    NSLog(@"encryptedExpiredDate: %@", encryptedExpiredDate);
//    NSLog(@"md5ForBuildingID: %@", md5ForBuildingID);
//    NSLog(@"originalMD5: %@", originalMD5);
//    NSLog(@"md5String: %@", md5String);
//    NSLog(@"license: %@", license);
    return license;
}

@end
