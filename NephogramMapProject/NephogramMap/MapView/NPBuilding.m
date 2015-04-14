#import "NPBuilding.h"
#import "NPMapFileManager.h"

#define KEY_BUILDINGS @"Buildings"
#define KEY_BUILDING_CITY_ID @"cityID"
#define KEY_BUILDING_ID @"id"
#define KEY_BUILDING_NAME @"name"
#define KEY_BUILDING_LONGITUDE @"longitude"
#define KEY_BUILDING_LATITUDE @"latitude"
#define KEY_BUILDING_ADDRESS @"address"
#define KEY_BUILDING_STATUS @"status"

@implementation NPBuilding

- (id)initWithCityID:(NSString *)cityID BuildingID:(NSString *)buildingID Name:(NSString *)name Lon:(double)lon Lat:(double)lat Address:(NSString *)address
{
    self = [super init];
    if (self) {
        _cityID = cityID;
        _buildingID = buildingID;
        _name = name;
        _longitude = lon;
        _latitude = lat;
        _address = address;
    }
    return self;
}

+ (NPBuilding *)parseBuilding:(NSString *)buildingID InCity:(NPCity *)city
{
    NPBuilding *building = nil;
    
    if (city == nil || buildingID == nil) {
        return building;
    }
    
    NSError *error = nil;
    NSString *fullPath = [NPMapFileManager getBuildingJsonPath:city.cityID];
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    NSDictionary *buildingDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    NSArray *buildingArray = [buildingDict objectForKey:KEY_BUILDINGS];
    for (NSDictionary *dict  in buildingArray) {
        NSString *mid = [dict objectForKey:KEY_BUILDING_ID];
        
        if ([mid isEqualToString:buildingID]) {
            NSString *name = [dict objectForKey:KEY_BUILDING_NAME];
            NSNumber *lonNumber = [dict objectForKey:KEY_BUILDING_LONGITUDE];
            NSNumber *latNumber = [dict objectForKey:KEY_BUILDING_LATITUDE];
            NSString *address = [dict objectForKey:KEY_BUILDING_ADDRESS];
            NSNumber *staNumber = [dict objectForKey:KEY_BUILDING_STATUS];
            
            building = [[NPBuilding alloc] initWithCityID:city.cityID BuildingID:mid Name:name Lon:lonNumber.doubleValue Lat:latNumber.doubleValue Address:address];
            building.status = staNumber.intValue;
            break;
        }
    }
    
    return building;
}

+ (NSArray *)parseAllBuildings:(NPCity *)city
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    
    if (city == nil) {
        return toReturn;
    }
    
    NSError *error = nil;
    NSString *fullPath = [NPMapFileManager getBuildingJsonPath:city.cityID];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        NSDictionary *buildingDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        NSArray *buildingArray = [buildingDict objectForKey:KEY_BUILDINGS];
        for (NSDictionary *dict  in buildingArray) {
            NSString *mid = [dict objectForKey:KEY_BUILDING_ID];
            NSString *name = [dict objectForKey:KEY_BUILDING_NAME];
            NSNumber *lonNumber = [dict objectForKey:KEY_BUILDING_LONGITUDE];
            NSNumber *latNumber = [dict objectForKey:KEY_BUILDING_LATITUDE];
            NSString *address = [dict objectForKey:KEY_BUILDING_ADDRESS];
            NSNumber *staNumber = [dict objectForKey:KEY_BUILDING_STATUS];
            
            NPBuilding *building = [[NPBuilding alloc] initWithCityID:city.cityID BuildingID:mid Name:name Lon:lonNumber.doubleValue Lat:latNumber.doubleValue Address:address];
            building.status = staNumber.intValue;
            
            [toReturn addObject:building];
        }
    }
    return toReturn;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", _name, _buildingID];
}

@end
