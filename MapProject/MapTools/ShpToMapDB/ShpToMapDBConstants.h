//
//  ShpToMapDBConstants.h
//  MapProject
//
//  Created by innerpeacer on 15/10/23.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef ShpToMapDBConstants_h
#define ShpToMapDBConstants_h

// ======================================
#pragma mark Shp DB File Name
// ======================================
//#define SHP_DB_FILE_FLOOR @"%@_FLOOR"
//#define SHP_DB_FILE_ROOM @"%@_ROOM"
//#define SHP_DB_FILE_ASSET @"%@_ASSET"
//#define SHP_DB_FILE_FACILITY @"%@_FACILITY"
//#define SHP_DB_FILE_LABEL @"%@_LABEL"

#define SHP_DB_FILE @"%@_SHP"

// ======================================
#pragma mark Shp DB Table
// ======================================
#define TABLE_SHP_FLOOR @"floor"
#define TABLE_SHP_ROOM @"room"
#define TABLE_SHP_ASSET @"asset"
#define TABLE_SHP_FACILITY @"facility"
#define TABLE_SHP_LABEL @"label"

// ======================================
#pragma mark Shp DB Field
// ======================================
#define SHP_DB_FIELD_OBJECT_ID @"OGC_FID"
#define SHP_DB_FIELD_GEOMETRY @"GEOMETRY"
#define SHP_DB_FIELD_GEO_ID @"geo_id"
#define SHP_DB_FIELD_POI_ID @"poi_id"
#define SHP_DB_FIELD_FLOOR_ID @"floor_id"
#define SHP_DB_FIELD_BUILDING_ID @"building_i"
#define SHP_DB_FIELD_CATEGORY_ID @"category_i"
#define SHP_DB_FIELD_NAME @"name"
#define SHP_DB_FIELD_SYMBOL_ID @"color"
#define SHP_DB_FIELD_FLOOR_NUMBER @"floor_inde"
#define SHP_DB_FIELD_FLOOR_NAME @"floor_name"
#define SHP_DB_FIELD_SHAPE_LENGTH @"shape_leng"
#define SHP_DB_FIELD_SHAPE_AREA @"shape_area"
#define SHP_DB_FIELD_LEVEL_MAX @"level_max"
#define SHP_DB_FIELD_LEVEL_MIN @"level_min"


#endif /* ShpToMapDBConstants_h */
