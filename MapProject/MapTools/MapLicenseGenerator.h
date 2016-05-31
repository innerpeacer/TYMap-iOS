//
//  LicenseGenerator.h
//  MapProject
//
//  Created by innerpeacer on 15/9/21.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

@interface MapLicenseGenerator : NSObject

+ (NSString *)generateBase64License40ForUserID:(NSString *)userID Building:(NSString *)building ExpiredDate:(NSString *)expiredDate;
+ (NSString *)generateLicense32ForUserID:(NSString *)userID Building:(NSString *)building ExpiredDate:(NSString *)expiredDate;

@end
