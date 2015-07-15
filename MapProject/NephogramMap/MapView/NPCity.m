#import "NPCity.h"
#import "NPMapFileManager.h"

#define KEY_CITIES @"Cities"
#define KEY_CITY_ID @"id"
#define KEY_CITY_NAME @"name"
#define KEY_CITY_SHORT_NAME @"sname"
#define KEY_CITY_LONGITUDE @"longitude"
#define KEY_CITY_LATITUDE @"latitude"
#define KEY_CITY_STATUS @"status"

@implementation NPCity

- (id)initWithCityID:(NSString *)cityId Name:(NSString *)name SName:(NSString *)sname Lon:(double)lon Lat:(double)lat
{
    self = [super init];
    if (self) {
        _cityID = cityId;
        _name = name;
        _sname = sname;
        _longitude = lon;
        _latitude = lat;
    }
    return self;
}

+ (NSArray *)parseAllCities
{
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];

    NSError *error = nil;
    NSString *fullPath = [NPMapFileManager getCityJsonPath];
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    NSDictionary *cityDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    NSArray *cityArray = [cityDict objectForKey:KEY_CITIES];
    for (NSDictionary *dict in cityArray) {
        NSString *cid = [dict objectForKey:KEY_CITY_ID];
        NSString *name = [dict objectForKey:KEY_CITY_NAME];
        NSString *sname = [dict objectForKey:KEY_CITY_SHORT_NAME];
        NSNumber *lonNumber = [dict objectForKey:KEY_CITY_LONGITUDE];
        NSNumber *latNumber = [dict objectForKey:KEY_CITY_LATITUDE];
        NSNumber *satNumber = [dict objectForKey:KEY_CITY_STATUS];
            
        NPCity *city = [[NPCity alloc] initWithCityID:cid Name:name SName:sname Lon:lonNumber.doubleValue Lat:latNumber.doubleValue];
        city.status = satNumber.intValue;
        [toReturn addObject:city];
    }
    return toReturn;
}

+ (NPCity *)parseCity:(NSString *)cityID
{
    NPCity *city = nil;
    
    if (cityID == nil) {
        return city;
    }
    
    NSError *error = nil;
    NSString *fullPath = [NPMapFileManager getCityJsonPath];
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    NSDictionary *cityDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    NSArray *cityArray = [cityDict objectForKey:KEY_CITIES];
    for (NSDictionary *dict in cityArray) {
        NSString *cid = [dict objectForKey:KEY_CITY_ID];
        
        if ([cid isEqualToString:cityID]) {
            NSString *name = [dict objectForKey:KEY_CITY_NAME];
            NSString *sname = [dict objectForKey:KEY_CITY_SHORT_NAME];
            NSNumber *lonNumber = [dict objectForKey:KEY_CITY_LONGITUDE];
            NSNumber *latNumber = [dict objectForKey:KEY_CITY_LATITUDE];
            NSNumber *staNumber = [dict objectForKey:KEY_CITY_STATUS];
            
            city = [[NPCity alloc] initWithCityID:cid Name:name SName:sname Lon:lonNumber.doubleValue Lat:latNumber.doubleValue];
            city.status = staNumber.intValue;
            break;
        }
    }
    
    return city;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", _name, _cityID];

}

@end
