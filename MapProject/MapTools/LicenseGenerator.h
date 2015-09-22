//
//  LicenseGenerator.h
//  MapProject
//
//  Created by innerpeacer on 15/9/21.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

@interface LicenseGenerator : NSObject

+ (NSString *)generateLicenseForUserID:(NSString *)userID Building:(NSString *)building ExpiredDate:(NSString *)expiredDate;

@end
