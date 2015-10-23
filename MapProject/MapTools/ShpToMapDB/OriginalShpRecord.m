//
//  OriginalShpRecord.m
//  MapProject
//
//  Created by innerpeacer on 15/10/23.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "OriginalShpRecord.h"

@implementation OriginalShpRecord

- (NSString *)description
{
    NSMutableString *result = [NSMutableString stringWithFormat:@"["];
    
    [result appendFormat:@"GeoID: %@,\t", _geoID];
    [result appendFormat:@"PoiID: %@,\t", _poiID];
    [result appendFormat:@"FloorID: %@,\t", _floorID];
    [result appendFormat:@"BuildingID: %@,\t", _buildingID];
    [result appendFormat:@"CategoryID: %@,\t", _categoryID];
    [result appendFormat:@"Name: %@,\t", _name];
    [result appendFormat:@"SymbolID: %@,\t", _symbolID];
    [result appendFormat:@"FloorNumber: %@,\t", _floorNumber];
    [result appendFormat:@"FloorName: %@,\t", _floorName];
    [result appendFormat:@"ShapeLength: %@,\t", _shapeLength];
    [result appendFormat:@"ShapeArea: %@,\t", _shapeArea];
    [result appendFormat:@"LabelX: %@,\t", _labelX];
    [result appendFormat:@"LabelY: %@,\t", _labelY];
    [result appendFormat:@"Layer: %@,\t", _layer];
    [result appendString:@"]"];
    
    return result;
}

@end
