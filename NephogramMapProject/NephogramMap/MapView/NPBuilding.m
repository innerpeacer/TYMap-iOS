#import "NPBuilding.h"

#define FILE_BUILDINGS @"Buildings_City"
#define KEY_BUILDINGS @"Buildings"
#define KEY_BUILDING_ID @"id"
#define KEY_BUILDING_NAME @"name"
#define KEY_BUILDING_LONGITUDE @"longitude"
#define KEY_BUILDING_LATITUDE @"latitude"
#define KEY_BUILDING_ADDRESS @"address"
#define KEY_BUILDING_STATUS @"status"

@implementation NPBuilding

- (id)initWithBuildingID:(NSString *)buildingID Name:(NSString *)name Lon:(double)lon Lat:(double)lat Address:(NSString *)address
{
    self = [super init];
    if (self) {
        _buildingID = buildingID;
        _name = name;
        _longitude = lon;
        _latitude = lat;
        _address = address;
    }
    return self;
}

+ (NPBuilding *)parseBuilding:(NSString *)buildingID InCity:(NSString *)cityID
{
    NPBuilding *building = nil;
    
    if (cityID == nil || buildingID == nil) {
        return building;
    }
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_%@", FILE_BUILDINGS, cityID] ofType:@"json"];
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

            building = [[NPBuilding alloc] initWithBuildingID:mid Name:name Lon:lonNumber.doubleValue Lat:latNumber.doubleValue Address:address];
            building.status = staNumber.intValue;
            break;
        }
    }
    
    return building;
}

+ (NSArray *)parseAllBuildingsInCity:(NSString *)cityID
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    
    if (cityID == nil) {
        return toReturn;
    }
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_%@", FILE_BUILDINGS, cityID] ofType:@"json"];
    
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
            
            NPBuilding *building = [[NPBuilding alloc] initWithBuildingID:mid Name:name Lon:lonNumber.doubleValue Lat:latNumber.doubleValue Address:address];
            building.status = staNumber.intValue;
            
            [toReturn addObject:building];
        }
    }
    return toReturn;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", _name, _buildingID];
//    return [NSString stringWithFormat:@"%@: %@, %@, %f, %f, %d", _name, _buildingID, _address, _longitude, _latitude, _status];
    
}

@end
