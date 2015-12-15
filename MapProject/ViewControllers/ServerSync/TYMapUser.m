//
//  TYMapUser.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYMapUser.h"



@implementation TYMapUser

+ (TYMapUser *)userWithID:(NSString *)uid BuildingID:(NSString *)bid License:(NSString *)l
{
    return [[TYMapUser alloc] initWithUserID:uid BuildingID:bid License:l];
}

- (id)initWithUserID:(NSString *)uid BuildingID:(NSString *)bid License:(NSString *)l
{
    self = [super init];
    if (self) {
        _userID = uid;
        _buildingID = bid;
        _license = l;
    }
    return self;
}

- (NSDictionary *)buildDictionary
{
    return @{@"userID":_userID, @"buildingID":_buildingID, @"license":_license};
}

@end
