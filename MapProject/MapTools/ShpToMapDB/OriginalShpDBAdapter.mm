
//
//  OriginalShpDBAdapter.m
//  MapProject
//
//  Created by innerpeacer on 15/10/23.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "OriginalShpDBAdapter.h"
#import "FMDatabase.h"
#import "OriginalShpRecord.h"
#import "ShpToMapDBConstants.h"

#include <geos.h>
#include <sstream>

#import <ArcGIS/ArcGIS.h>
#import "Geos2AgsConverter.h"

using namespace std;
using namespace geos::io;

@interface OriginalShpDBAdapter()
{
    NSString *mapID;
    FMDatabase *db;
}

@end

@implementation OriginalShpDBAdapter

- (id)initWithMapInfo:(TYMapInfo *)info Type:(ShpDBType)type
{
    self = [super init];
    if (self) {
        mapID = info.mapID;
        _dbType = type;
        
        NSString *shpPath = [[NSBundle mainBundle] pathForResource:@"OriginalShpDB" ofType:nil];
        NSString *bundlePath = [shpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_shp.bundle", info.buildingID]];
        NSBundle *dbBundle = [[NSBundle alloc] initWithPath:bundlePath];
        NSString *dbPath = [dbBundle pathForResource:[self getDBPathForType:_dbType] ofType:@"db"];
        
        db = [FMDatabase databaseWithPath:dbPath];
    }
    return self;
}

- (NSArray *)readPointRecords
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    NSString *tableName = [self getTableNameForType:_dbType];
    if (![self existTable:tableName]) {
        return resultArray;
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select distinct %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@ from %@", SHP_DB_FIELD_OBJECT_ID, SHP_DB_FIELD_GEOMETRY, SHP_DB_FIELD_GEO_ID, SHP_DB_FIELD_POI_ID, SHP_DB_FIELD_FLOOR_ID, SHP_DB_FIELD_BUILDING_ID, SHP_DB_FIELD_CATEGORY_ID, SHP_DB_FIELD_NAME, SHP_DB_FIELD_SYMBOL_ID, SHP_DB_FIELD_FLOOR_NUMBER, SHP_DB_FIELD_FLOOR_NAME, SHP_DB_FIELD_LEVEL_MAX, SHP_DB_FIELD_LEVEL_MIN, tableName];
    FMResultSet *rs = [db executeQuery:sql];
    
    WKBReader reader;
    stringstream s;

    while ([rs next]) {
        OriginalShpRecord *record = [[OriginalShpRecord alloc] init];
        
        record.objectID = [NSNumber numberWithInt:[rs intForColumn:SHP_DB_FIELD_OBJECT_ID]];
        record.geometryData = [rs dataForColumn:SHP_DB_FIELD_GEOMETRY];
        record.geoID = [rs stringForColumn:SHP_DB_FIELD_GEO_ID];
        record.poiID = [rs stringForColumn:SHP_DB_FIELD_POI_ID];
        record.floorID = [rs stringForColumn:SHP_DB_FIELD_FLOOR_ID];
        record.buildingID = [rs stringForColumn:SHP_DB_FIELD_BUILDING_ID];
//        record.categoryID = [NSNumber numberWithInt:[rs intForColumn:SHP_DB_FIELD_CATEGORY_ID]];
        record.categoryID = [rs stringForColumn:SHP_DB_FIELD_CATEGORY_ID];
        record.name = [rs stringForColumn:SHP_DB_FIELD_NAME];
        record.symbolID = [NSNumber numberWithInt:[rs intForColumn:SHP_DB_FIELD_SYMBOL_ID]];
        record.floorNumber = [NSNumber numberWithInt:[rs intForColumn:SHP_DB_FIELD_FLOOR_NUMBER]];
        record.floorName = [rs stringForColumn:SHP_DB_FIELD_FLOOR_NAME];
        record.shapeLength = @0;
        record.shapeArea = @0;
        record.layer = @(_dbType);
        record.levelMax = [NSNumber numberWithInt:[rs intForColumn:SHP_DB_FIELD_LEVEL_MAX]];
        record.levelMin = [NSNumber numberWithInt:[rs intForColumn:SHP_DB_FIELD_LEVEL_MIN]];
        
    
        s.clear();
        s.write((const char *)record.geometryData.bytes, record.geometryData.length);
        geos::geom::Point *p = dynamic_cast<geos::geom::Point *>(reader.read(s));
        record.labelX = @(p->getX());
        record.labelY = @(p->getY());
        
        delete p;
    
        [resultArray addObject:record];
    }
    return resultArray;
}

- (NSArray *)readPolygonRecords
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSString *tableName = [self getTableNameForType:_dbType];
    if (![self existTable:tableName]) {
        return resultArray;
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select distinct %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@ from %@", SHP_DB_FIELD_OBJECT_ID, SHP_DB_FIELD_GEOMETRY, SHP_DB_FIELD_GEO_ID, SHP_DB_FIELD_POI_ID, SHP_DB_FIELD_FLOOR_ID, SHP_DB_FIELD_BUILDING_ID, SHP_DB_FIELD_CATEGORY_ID, SHP_DB_FIELD_NAME, SHP_DB_FIELD_SYMBOL_ID, SHP_DB_FIELD_FLOOR_NUMBER, SHP_DB_FIELD_FLOOR_NAME, SHP_DB_FIELD_SHAPE_LENGTH, SHP_DB_FIELD_SHAPE_AREA, SHP_DB_FIELD_LEVEL_MAX, SHP_DB_FIELD_LEVEL_MIN, SHP_DB_FIELD_LEVEL_EXTENSION_1, tableName];
    FMResultSet *rs = [db executeQuery:sql];
    
    WKBReader reader;
    stringstream s;
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    
    while ([rs next]) {
        OriginalShpRecord *record = [[OriginalShpRecord alloc] init];
        
        record.objectID = [NSNumber numberWithInt:[rs intForColumn:SHP_DB_FIELD_OBJECT_ID]];
        record.geometryData = [rs dataForColumn:SHP_DB_FIELD_GEOMETRY];
        record.geoID = [rs stringForColumn:SHP_DB_FIELD_GEO_ID];
        record.poiID = [rs stringForColumn:SHP_DB_FIELD_POI_ID];
        record.floorID = [rs stringForColumn:SHP_DB_FIELD_FLOOR_ID];
        record.buildingID = [rs stringForColumn:SHP_DB_FIELD_BUILDING_ID];
//        record.categoryID = [NSNumber numberWithInt:[rs intForColumn:SHP_DB_FIELD_CATEGORY_ID]];
        record.categoryID = [rs stringForColumn:SHP_DB_FIELD_CATEGORY_ID];
        record.name = [rs stringForColumn:SHP_DB_FIELD_NAME];
        record.symbolID = [NSNumber numberWithInt:[rs intForColumn:SHP_DB_FIELD_SYMBOL_ID]];
        record.floorNumber = [NSNumber numberWithInt:[rs intForColumn:SHP_DB_FIELD_FLOOR_NUMBER]];
        record.floorName = [rs stringForColumn:SHP_DB_FIELD_FLOOR_NAME];
        record.shapeLength = [NSNumber numberWithDouble:[rs doubleForColumn:SHP_DB_FIELD_SHAPE_LENGTH]];
        record.shapeArea = [NSNumber numberWithDouble:[rs doubleForColumn:SHP_DB_FIELD_SHAPE_AREA]];
        record.layer = @(_dbType);
        record.levelMax = [NSNumber numberWithInt:[rs intForColumn:SHP_DB_FIELD_LEVEL_MAX]];
        record.levelMin = [NSNumber numberWithInt:[rs intForColumn:SHP_DB_FIELD_LEVEL_MIN]];
        
        
#pragma mark Special Treamments
        NSString *extension1 = [rs stringForColumn:SHP_DB_FIELD_LEVEL_EXTENSION_1];
        if([extension1 isEqualToString:@"8"]){
            record.layer = @8;
            NSLog(@"%@: Layer %@", record.name, record.layer);
        } else  if([extension1 isEqualToString:@"9"]){
            record.layer = @9;
            NSLog(@"%@: Layer %@", record.name, record.layer);
        }
        
        s.clear();
        s.write((const char *)record.geometryData.bytes, record.geometryData.length);
        
//        printf("%s\n", [record.geoID UTF8String]);
        geos::geom::Geometry *g = reader.read(s);
        AGSGeometry *polygon = [Geos2AgsConverter agsgeometryFromGeosGeometry:g];
        AGSPoint *p = [engine labelPointForPolygon:(AGSPolygon *)polygon];
        
        record.labelX = @(p.x);
        record.labelY = @(p.y);
        delete g;
        
        [resultArray addObject:record];
    }
    return resultArray;
}

- (NSArray *)readAllRecords
{
    switch (_dbType) {
        case SHP_DB_FLOOR:
        case SHP_DB_ROOM:
        case SHP_DB_ASSET:
        case SHP_DB_SHADE:
            return [self readPolygonRecords];
            break;
            
        case SHP_DB_FACILITY:
        case SHP_DB_LABEL:
            return [self readPointRecords];
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSString *)getTableNameForType:(ShpDBType)type
{
    NSString *result = nil;
    switch (type) {
        case SHP_DB_FLOOR:
            result = TABLE_SHP_FLOOR;
            break;
            
        case SHP_DB_ROOM:
            result = TABLE_SHP_ROOM;
            break;
            
        case SHP_DB_ASSET:
            result = TABLE_SHP_ASSET;
            break;
            
        case SHP_DB_FACILITY:
            result = TABLE_SHP_FACILITY;
            break;
            
        case SHP_DB_LABEL:
            result = TABLE_SHP_LABEL;
            break;
            
        case SHP_DB_SHADE:
            result = TABLE_SHP_SHAPE;
            break;
        default:
            break;
    }
    return result;
}

- (NSString *)getDBPathForType:(ShpDBType)type
{
    NSString *result = nil;
    switch (type) {
        case SHP_DB_FLOOR:
        case SHP_DB_ROOM:
        case SHP_DB_ASSET:
        case SHP_DB_FACILITY:
        case SHP_DB_LABEL:
        case SHP_DB_SHADE:
            result = [NSString stringWithFormat:SHP_DB_FILE, mapID];
            break;
            
        default:
            break;
    }
    return result;
}

- (BOOL)existTable:(NSString *)table
{
    if (!table) {
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",table];
    
    FMResultSet *set = [db executeQuery:sql];
    if([set next])
    {
        NSInteger count = [set intForColumnIndex:0];
        if (count > 0) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}


- (BOOL)open
{
    return [db open];
}

- (BOOL)close
{
    return [db close];
}


@end
