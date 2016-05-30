//
//  IPMapFeatureData.m
//  MapProject
//
//  Created by innerpeacer on 15/10/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPMapFeatureData.h"
#import "IPXMapDataDBAdapter.hpp"
#import "IPMapFileManager.h"

#import "TYMapEnviroment.h"
#import <ArcGIS/ArcGIS.h>

#import "IPGeos2AgsConverter.h"

using namespace Innerpeacer::MapSDK;
using namespace std;

@interface IPMapFeatureData()
{
    TYBuilding *building;
}

@end

@implementation IPMapFeatureData

- (id)initWithBuilding:(TYBuilding *)b
{
    self = [super init];
    if (self) {
        building = b;
    }
    return self;
}

- (NSDictionary *)getAllMapDataOnFloor:(int)floor
{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    NSString *dbPath = [IPMapFileManager getMapDataDBPath:building];
    IPXMapDataDBAdapter *db = new IPXMapDataDBAdapter([dbPath UTF8String]);
    db->open();
    vector<IPXFeatureRecord *> allRecords = db->getAllRecordsOnFloor(floor);
    db->close();
    delete db;
    
    NSMutableArray *floorArray = [NSMutableArray array];
    NSMutableArray *roomArray = [NSMutableArray array];
    NSMutableArray *assetArray = [NSMutableArray array];
    NSMutableArray *facilityArray = [NSMutableArray array];
    NSMutableArray *labelArray = [NSMutableArray array];

    for(vector<IPXFeatureRecord *>::iterator iter = allRecords.begin(); iter != allRecords.end(); ++iter) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:[NSString stringWithCString:(*iter)->geoID.c_str() encoding:NSUTF8StringEncoding] forKey:@"GEO_ID"];
        [attributes setObject:[NSString stringWithCString:(*iter)->poiID.c_str() encoding:NSUTF8StringEncoding] forKey:@"POI_ID"];
        [attributes setObject:[NSString stringWithCString:(*iter)->categoryID.c_str() encoding:NSUTF8StringEncoding] forKey:@"CATEGORY_ID"];
        [attributes setObject:@((*iter)->symbolID) forKey:@"COLOR"];
        
        if ((*iter)->name.length() > 0) {
            [attributes setObject:[NSString stringWithCString:(*iter)->name.c_str() encoding:NSUTF8StringEncoding] forKey:@"NAME"];
        }
        
        [attributes setObject:@((*iter)->levelMax) forKey:@"LEVEL_MAX"];
        [attributes setObject:@((*iter)->levelMin) forKey:@"LEVEL_MIN"];
        
        AGSGeometry *geometry = [IPMapFeatureData agsGeometryFromRecord:(*iter)];
        AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:geometry symbol:nil attributes:attributes];
        switch ((*iter)->layer) {
            case 1:
                [floorArray addObject:graphic];
                break;
                
            case 2:
                [roomArray addObject:graphic];
                break;
            case 3:
                [assetArray addObject:graphic];
                break;
            
            case 4:
                [facilityArray addObject:graphic];
                break;
            
            case 5:
                [labelArray addObject:graphic];
                break;
                
            default:
                break;
        }
        
    }
    
    for(vector<IPXFeatureRecord *>::iterator iter = allRecords.begin(); iter != allRecords.end(); ++iter) {
        delete (*iter);
    }
    
//    [resultDict setObject:[[AGSFeatureSet alloc] initWithFeatures:floorArray] forKey:@"floor"];
//    [resultDict setObject:[[AGSFeatureSet alloc] initWithFeatures:roomArray] forKey:@"room"];
//    [resultDict setObject:[[AGSFeatureSet alloc] initWithFeatures:assetArray] forKey:@"asset"];
//    [resultDict setObject:[[AGSFeatureSet alloc] initWithFeatures:facilityArray] forKey:@"facility"];
//    [resultDict setObject:[[AGSFeatureSet alloc] initWithFeatures:labelArray] forKey:@"label"];
    [resultDict setObject:[[AGSFeatureSet alloc] initWithDisplayFieldName:nil features:floorArray fieldAliases:nil spatialReference:[TYMapEnvironment defaultSpatialReference] geometryType:AGSGeometryTypeUndefined] forKey:@"floor"];
    [resultDict setObject:[[AGSFeatureSet alloc] initWithDisplayFieldName:nil features:roomArray fieldAliases:nil spatialReference:[TYMapEnvironment defaultSpatialReference] geometryType:AGSGeometryTypeUndefined] forKey:@"room"];
    [resultDict setObject:[[AGSFeatureSet alloc] initWithDisplayFieldName:nil features:assetArray fieldAliases:nil spatialReference:[TYMapEnvironment defaultSpatialReference] geometryType:AGSGeometryTypeUndefined] forKey:@"asset"];
    [resultDict setObject:[[AGSFeatureSet alloc] initWithDisplayFieldName:nil features:facilityArray fieldAliases:nil spatialReference:[TYMapEnvironment defaultSpatialReference] geometryType:AGSGeometryTypeUndefined] forKey:@"facility"];
    [resultDict setObject:[[AGSFeatureSet alloc] initWithDisplayFieldName:nil features:labelArray fieldAliases:nil spatialReference:[TYMapEnvironment defaultSpatialReference] geometryType:AGSGeometryTypeUndefined] forKey:@"label"];
    return resultDict;
}

+ (AGSGeometry *)agsGeometryFromRecord:(IPXFeatureRecord *)record
{
    return [IPGeos2AgsConverter agsGeometryFromGeosGeometry:record->geometry];
}

@end
