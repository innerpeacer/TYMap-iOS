//
//  MapDBConstants.h
//  MapProject
//
//  Created by innerpeacer on 15/10/23.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef MapDBConstants_h
#define MapDBConstants_h


#define MAP_DB_FILE_NAME @"%@.tymap"

// ======================================
#pragma mark Tables
// ======================================
#define TABLE_MAPINFO @"MAPINFO"
//#define TABLE_FLOOR @"FLOOR"
//#define TABLE_ROOM @"ROOM"
//#define TABLE_ASSET @"ASSET"
//#define TABLE_FACILITY @"FACILITY"
//#define TABLE_LABEL @"LABEL"
#define TABLE_MAP_DATA @"MAPDATA"


// ======================================
#pragma mark Map Info Field
// ======================================
#define MAPINFO_FIELD_ID @"_id"
#define MAPINFO_FIELD_CITY_ID @"CITY_ID"
#define MAPINFO_FIELD_BUILDING_ID @"BUILDING_ID"
#define MAPINFO_FIELD_MAP_ID @"MAP_ID"
#define MAPINFO_FIELD_FLOOR_NAME @"FLOOR_NAME"
#define MAPINFO_FIELD_FLOOR_NUMBER @"FLOOR_NUMBER"
#define MAPINFO_FIELD_SIZE_X @"SIZE_X"
#define MAPINFO_FIELD_SIZE_Y @"SIZE_Y"
#define MAPINFO_FIELD_X_MIN @"XMIN"
#define MAPINFO_FIELD_Y_MIN @"YMIN"
#define MAPINFO_FIELD_X_MAX @"XMAX"
#define MAPINFO_FIELD_Y_MAX @"YMAX"

// ======================================
#pragma mark Map Content Field
// ======================================
#define MAP_CONTENT_FIELD_ID @"_id"
#define MAP_CONTENT_FIELD_OBJECT_ID @"OBJECT_ID"
#define MAP_CONTENT_FIELD_GEOMETRY @"GEOMETRY"
#define MAP_CONTENT_FIELD_GEO_ID @"GEO_ID"
#define MAP_CONTENT_FIELD_POI_ID @"POI_ID"
#define MAP_CONTENT_FIELD_FLOOR_ID @"FLOOR_ID"
#define MAP_CONTENT_FIELD_BUILDING_ID @"BUILDING_ID"
#define MAP_CONTENT_FIELD_CATEGORY_ID @"CATEGORY_ID"
#define MAP_CONTENT_FIELD_NAME @"NAME"
#define MAP_CONTENT_FIELD_SYMBOL_ID @"SYMBOL_ID"
#define MAP_CONTENT_FIELD_FLOOR_NUMBER @"FLOOR_NUMBER"
#define MAP_CONTENT_FIELD_FLOOR_NAME @"FLOOR_NAME"
#define MAP_CONTENT_FIELD_SHAPE_LENGTH @"SHAPE_LENGTH"
#define MAP_CONTENT_FIELD_SHAPE_AREA @"SHAPE_AREA"
#define MAP_CONTENT_FIELD_LABEL_X @"LABEL_X"
#define MAP_CONTENT_FIELD_LABEL_Y @"LABEL_Y"
#define MAP_CONTENT_FIELD_LAYER @"LAYER"

#endif /* MapDBConstants_h */
