//
//  TYSyncRouteRecord.m
//  MapProject
//
//  Created by innerpeacer on 15/11/24.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPSyncRouteRecord.h"
#import "IPBase64Encoding.h"
#import "NSData+GZIP.h"
#import "IPMapDBConstants.h"

@implementation IPSyncRouteNodeRecord

+ (IPSyncRouteNodeRecord *)parseRouteNodeRecord:(NSDictionary *)recordObject
{
    IPSyncRouteNodeRecord *record = [[IPSyncRouteNodeRecord alloc] init];
    record.nodeID = [recordObject[FIELD_ROUTE_NODE_1_NODE_ID] intValue];
//    record.geometryData = [TYBase64Encoding decodingString:recordObject[FIELD_ROUTE_NODE_2_GEOMETRY]];
    record.geometryData = [[IPBase64Encoding decodingString:recordObject[FIELD_ROUTE_NODE_2_GEOMETRY]] gunzippedData];
    record.isVirtual = [recordObject[FIELD_ROUTE_NODE_3_VIRTUAL] boolValue];
    return record;
}

+ (NSDictionary *)buildRouteNodeObject:(IPSyncRouteNodeRecord *)record
{
    NSMutableDictionary *recordObject = [NSMutableDictionary dictionary];
    [recordObject setObject:@(record.nodeID) forKey:FIELD_ROUTE_NODE_1_NODE_ID];
//    [recordObject setObject:[TYBase64Encoding encodeingData:record.geometryData] forKey:FIELD_ROUTE_NODE_2_GEOMETRY];
    [recordObject setObject:[IPBase64Encoding encodeingData:[record.geometryData gzippedData]] forKey:FIELD_ROUTE_NODE_2_GEOMETRY];

    [recordObject setObject:@(record.isVirtual) forKey:FIELD_ROUTE_NODE_3_VIRTUAL];
    return recordObject;
}

@end

@implementation IPSyncRouteLinkRecord

+ (IPSyncRouteLinkRecord *)parseRouteLinkRecord:(NSDictionary *)recordObject
{
    IPSyncRouteLinkRecord *record = [[IPSyncRouteLinkRecord alloc] init];
    record.linkID = [recordObject[FIELD_ROUTE_LINK_1_LINK_ID] intValue];
//    record.geometryData = [TYBase64Encoding decodingString:recordObject[FIELD_ROUTE_LINK_2_GEOMETRY]];
    record.geometryData = [[IPBase64Encoding decodingString:recordObject[FIELD_ROUTE_LINK_2_GEOMETRY]]gunzippedData];
    record.length = [recordObject[FIELD_ROUTE_LINK_3_LENGTH] doubleValue];
    record.headNode = [recordObject[FIELD_ROUTE_LINK_4_HEAD_NODE] intValue];
    record.endNode = [recordObject[FIELD_ROUTE_LINK_5_END_NODE] intValue];
    record.isVirtual = [recordObject[FIELD_ROUTE_LINK_6_VIRTUAL] boolValue];
    record.isOneWay = [recordObject[FIELD_ROUTE_LINK_7_ONE_WAY] boolValue];
    return record;
}

+ (NSDictionary *)buildRouteLinkObject:(IPSyncRouteLinkRecord *)record
{
    NSMutableDictionary *recordObject = [NSMutableDictionary dictionary];
    [recordObject setObject:@(record.linkID) forKey:FIELD_ROUTE_LINK_1_LINK_ID];
//    [recordObject setObject:[TYBase64Encoding encodeingData:record.geometryData] forKey:FIELD_ROUTE_LINK_2_GEOMETRY];
    [recordObject setObject:[IPBase64Encoding encodeingData:[record.geometryData gzippedData]] forKey:FIELD_ROUTE_LINK_2_GEOMETRY];

    [recordObject setObject:@(record.length) forKey:FIELD_ROUTE_LINK_3_LENGTH];
    [recordObject setObject:@(record.headNode) forKey:FIELD_ROUTE_LINK_4_HEAD_NODE];
    [recordObject setObject:@(record.endNode) forKey:FIELD_ROUTE_LINK_5_END_NODE];
    [recordObject setObject:@(record.isVirtual) forKey:FIELD_ROUTE_LINK_6_VIRTUAL];
    [recordObject setObject:@(record.isOneWay) forKey:FIELD_ROUTE_LINK_7_ONE_WAY];
    return recordObject;
}
@end