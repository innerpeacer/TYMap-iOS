//
//  TYApi.h
//  MapProject
//
//  Created by innerpeacer on 15/11/17.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef TYApi_h
#define TYApi_h

#define TY_API_GET_LOCATING_BEACONS @"/TYMapServerManager/beacon/GetLocatingBeacons"


#pragma mark Manager API
#define TY_API_UPLOAD_ALL_CITIES @"/TYMapServerManager/manager/UploadAllCityData"
#define TY_API_UPLOAD_ALL_BUILDINGS @"/TYMapServerManager/manager/UploadAllBuildingData"
#define TY_API_UPLOAD_ALL_MAPINFOS @"/TYMapServerManager/manager/UploadAllMapInfoData"

#define TY_API_ADD_CITIES @"/TYMapServerManager/manager/AddCities"
#define TY_API_ADD_BUILDINGS @"/TYMapServerManager/manager/AddBuildings"
#define TY_API_ADD_MAPINFOS @"/TYMapServerManager/manager/AddMapInfos"
#define TY_API_ADD_CBM @"/TYMapServerManager/manager/AddCBM"

#define TY_API_UPLOAD_ROUTE_DATA @"/TYMapServerManager/manager/UploadRouteData"
#define TY_API_UPLOAD_MAP_DATA @"/TYMapServerManager/manager/UploadMapData"


#pragma mark User API
#define TY_API_GET_ALL_CITIES @"/TYMapServerManager/user/GetAllCities"
#define TY_API_GET_ALL_BUILDINGS @"/TYMapServerManager/user/GetAllBuildings"
#define TY_API_GET_ALL_MAPINFOS @"/TYMapServerManager/user/GetAllMapInfos"

#define TY_API_GET_TARGET_CITY @"/TYMapServerManager/user/GetCity"
#define TY_API_GET_TARGET_BUILDING @"/TYMapServerManager/user/GetBuilding"
#define TY_API_GET_TARGET_MAPINFO @"/TYMapServerManager/user/GetMapInfo"
#define TY_API_GET_TARGET_CBM @"/TYMapServerManager/user/GetCBM"

#define TY_API_GET_TARGET_MAPDATA @"/TYMapServerManager/user/GetMapData"
#define TY_API_GET_TARGET_ROUTE_DATA @"/TYMapServerManager/user/GetRouteData"


#define TY_RESPONSE_STATUS @"success"
#define TY_RESPONSE_DESCRIPTION @"description"
#define TY_RESPONSE_RECORDS @"records"

#endif /* TYApi_h */
