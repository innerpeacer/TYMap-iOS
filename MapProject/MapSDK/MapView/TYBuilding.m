#import "TYBuilding.h"
#import "TYMapFileManager.h"

#define KEY_BUILDINGS @"Buildings"
#define KEY_BUILDING_CITY_ID @"cityID"
#define KEY_BUILDING_ID @"id"
#define KEY_BUILDING_NAME @"name"
#define KEY_BUILDING_LONGITUDE @"longitude"
#define KEY_BUILDING_LATITUDE @"latitude"
#define KEY_BUILDING_ADDRESS @"address"
#define KEY_BUILDING_INIT_ANGLE @"initAngle"
#define KEY_BUILDING_ROUTE_URL @"routeURL"
#define KEY_BUILDING_OFFSET_X @"offsetX"
#define KEY_BUILDING_OFFSET_Y @"offsetY"

#define KEY_BUILDING_STATUS @"status"

@implementation TYBuilding

- (id)initWithCityID:(NSString *)cityID BuildingID:(NSString *)buildingID Name:(NSString *)name Lon:(double)lon Lat:(double)lat Address:(NSString *)address InitAngle:(double)initAngle RouteURL:(NSString *)url Offset:(MapSize)offset
{
    self = [super init];
    if (self) {
        _cityID = cityID;
        _buildingID = buildingID;
        _name = name;
        _longitude = lon;
        _latitude = lat;
        _address = address;
        _initAngle = initAngle;
        _routeURL = url;
        _offset = offset;
    }
    return self;
}

+ (TYBuilding *)parseBuilding:(NSString *)buildingID InCity:(TYCity *)city
{
    TYBuilding *building = nil;
    
    if (city == nil || buildingID == nil) {
        return building;
    }
    
    NSError *error = nil;
    NSString *fullPath = [TYMapFileManager getBuildingJsonPath:city.cityID];
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
            
            NSNumber *initStr = [dict objectForKey:KEY_BUILDING_INIT_ANGLE];
            NSString *url = [dict objectForKey:KEY_BUILDING_ROUTE_URL];
            
            NSNumber *offsetX = [dict objectForKey:KEY_BUILDING_OFFSET_X];
            NSNumber *offsetY = [dict objectForKey:KEY_BUILDING_OFFSET_Y];
            MapSize offset = { offsetX.doubleValue, offsetY.doubleValue };
            
            NSNumber *staNumber = [dict objectForKey:KEY_BUILDING_STATUS];
            
            
            building = [[TYBuilding alloc] initWithCityID:city.cityID BuildingID:mid Name:name Lon:lonNumber.doubleValue Lat:latNumber.doubleValue Address:address InitAngle:initStr.doubleValue RouteURL:url Offset:offset];
            building.status = staNumber.intValue;
            break;
        }
    }
    
    return building;
}

+ (NSArray *)parseAllBuildings:(TYCity *)city
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    
    if (city == nil) {
        return toReturn;
    }
    
    NSError *error = nil;
    NSString *fullPath = [TYMapFileManager getBuildingJsonPath:city.cityID];
    
    
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
            
            NSNumber *initStr = [dict objectForKey:KEY_BUILDING_INIT_ANGLE];
            
            NSString *url = [dict objectForKey:KEY_BUILDING_ROUTE_URL];
            
            NSNumber *offsetX = [dict objectForKey:KEY_BUILDING_OFFSET_X];
            NSNumber *offsetY = [dict objectForKey:KEY_BUILDING_OFFSET_Y];
            MapSize offset = { offsetX.doubleValue, offsetY.doubleValue };
            

            NSNumber *staNumber = [dict objectForKey:KEY_BUILDING_STATUS];
            
            TYBuilding *building = [[TYBuilding alloc] initWithCityID:city.cityID BuildingID:mid Name:name Lon:lonNumber.doubleValue Lat:latNumber.doubleValue Address:address InitAngle:initStr.doubleValue RouteURL:url Offset:offset];
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