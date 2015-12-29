//
//  TYMapApi.h
//  MapProject
//
//  Created by innerpeacer on 15/11/17.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#ifndef TYMapApi_h
#define TYMapApi_h

#pragma mark -
#pragma mark User API

#define TY_API_GET_ALL_CITIES                   @"/TYMapServerManager/user/map/GetAllCities"
#define TY_API_GET_ALL_BUILDINGS                @"/TYMapServerManager/user/map/GetAllBuildings"
#define TY_API_GET_ALL_CITY_BUILDINGS           @"/TYMapServerManager/user/map/GetAllCityBuildings"
#define TY_API_GET_ALL_MAPINFOS                 @"/TYMapServerManager/user/map/GetAllMapInfos"

#define TY_API_GET_TARGET_CITY                  @"/TYMapServerManager/user/map/GetCity"
#define TY_API_GET_TARGET_BUILDING              @"/TYMapServerManager/user/map/GetBuilding"
#define TY_API_GET_TARGET_MAPINFO               @"/TYMapServerManager/user/map/GetMapInfo"
#define TY_API_GET_TARGET_CBM                   @"/TYMapServerManager/user/map/GetCBM"

#define TY_API_GET_TARGET_MAPDATA               @"/TYMapServerManager/user/map/GetMapData"
#define TY_API_GET_TARGET_ROUTE_DATA            @"/TYMapServerManager/user/map/GetRouteData"
#define TY_API_GET_TARGET_SYMBOLS               @"/TYMapServerManager/user/map/GetSymbols"

#pragma mark -
#pragma mark Response
#define TY_RESPONSE_STATUS @"success"
#define TY_RESPONSE_DESCRIPTION @"description"
#define TY_RESPONSE_RECORDS @"records"

#endif /* TYMapApi_h */
