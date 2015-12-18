//
//  TYLicenseValidation.m
//  MapProject
//
//  Created by innerpeacer on 15/9/22.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYLicenseValidation.h"
#import "IPXLicenseValidation.h"

using namespace Innerpeacer::MapSDK;

@implementation TYLicenseValidation

+ (BOOL)checkValidityWithUserID:(NSString *)userID License:(NSString *)license Building:(TYBuilding *)building;
{
    if (userID == nil || license == nil || building == nil) {
        return NO;
    }
    return checkValidity([userID UTF8String], [license UTF8String], [building.buildingID UTF8String]);
}

+ (NSDate *)evaluateLicenseWithUserID:(NSString *)userID License:(NSString *)license Building:(TYBuilding *)building
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *expiredDate = [NSString stringWithUTF8String:getExpiredDate([userID UTF8String], [license UTF8String], [building.buildingID UTF8String]).c_str()];
    
    if (expiredDate == nil || expiredDate.length == 0) {
        //        NSLog(@"Invalid Date");
        return nil;
    }
    
    NSDate* date = [dateFormatter dateFromString:expiredDate];
    if (date == nil) {
        //        NSLog(@"Invalid Date");
        return nil;
    }
    return date;
}

@end
