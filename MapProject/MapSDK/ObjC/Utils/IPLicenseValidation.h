//
//  IPLicenseValidation.h
//  MapProject
//
//  Created by innerpeacer on 15/9/22.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

@interface IPLicenseValidation : NSObject

+ (BOOL)checkValidityWithUserID:(NSString *)userID License:(NSString *)license Building:(TYBuilding *)building;
+ (NSDate *)evaluateLicenseWithUserID:(NSString *)userID License:(NSString *)license Building:(TYBuilding *)building;

@end
