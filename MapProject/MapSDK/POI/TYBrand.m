//
//  TYBrand.m
//  MapProject
//
//  Created by innerpeacer on 15/5/29.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "TYBrand.h"

#import "TYMapFileManager.h"

#define KEY_BRANDS @"Brands"

#define KEY_BRAND_POI_ID @"poiID"
#define KEY_BRAND_NAME @"name"
#define KEY_BRAND_LOGO @"logo"
#define KEY_BRAND_SIZE_X @"width"
#define KEY_BRAND_SIZE_Y @"height"

@implementation TYBrand

+ (NSArray *)parseAllBrands:(TYBuilding *)building
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    
    if (building == nil) {
        return toReturn;
    }
    
    NSString *path = [TYMapFileManager getBrandJsonPath:building];
    
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        NSArray *brandArray = [rootDict objectForKey:KEY_BRANDS];
        for (NSDictionary *brandDict in brandArray) {
            NSString *poiID = [brandDict objectForKey:KEY_BRAND_POI_ID];
            NSString *name = [brandDict objectForKey:KEY_BRAND_NAME];
            NSString *logo = [brandDict objectForKey:KEY_BRAND_LOGO];
            
            double width = [[brandDict objectForKey:KEY_BRAND_SIZE_X] doubleValue];
            double height = [[brandDict objectForKey:KEY_BRAND_SIZE_Y] doubleValue];
            
            TYBrand *brand = [[TYBrand alloc] init];
            brand.poiID = poiID;
            brand.name = name;
            brand.logo = logo;
            brand.logoSize = CGSizeMake(width, height);
            
            [toReturn addObject:brand];
        }
    }
    
    return toReturn;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"PoiID: %@, Name: %@, Logo: %@", _poiID, _name, _logo];
}

@end
