//
//  TYCBMUploader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPCBMUploader.h"
#import "TYMapEnviroment.h"
#import "IPMapWebUploader.h"
#import "IPMapWebObjectConverter.h"
#import "TYMapCredential_Private.h"

@interface IPCBMUploader() <IPMapWebUploaderDelegate>
{
    TYMapCredential *user;
    IPMapWebUploader *uploader;
}

@end

@implementation IPCBMUploader

- (id)initWithUser:(TYMapCredential *)u
{
    self = [super init];
    if (self) {
        user = u;
        
        NSString *hostName = [TYMapEnvironment getHostName];
        NSAssert(hostName != nil, @"Host Name must not be nil!");
        
        uploader = [[IPMapWebUploader alloc] initWithHostName:hostName];
        uploader.delegate = self;
    }
    return self;
}

- (void)uploadCities:(NSArray *)cities
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"userID"] = user.userID;
    param[@"cities"] = [IPMapWebObjectConverter prepareJsonString:[IPMapWebObjectConverter prepareCityObjectArray:cities]];
    [uploader uploadWithApi:TY_API_UPLOAD_ALL_CITIES Parameters:param];
}

- (void)uploadBuildings:(NSArray *)buildings
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"userID"] = user.userID;
    param[@"buildings"] = [IPMapWebObjectConverter prepareJsonString:[IPMapWebObjectConverter prepareBuildingObjectArray:buildings]];
    [uploader uploadWithApi:TY_API_UPLOAD_ALL_BUILDINGS Parameters:param];
}

- (void)uploadMapInfos:(NSArray *)mapInfos
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"userID"] = user.userID;
    param[@"mapinfos"] = [IPMapWebObjectConverter prepareJsonString:[IPMapWebObjectConverter prepareMapInfoObjectArray:mapInfos]];
    [uploader uploadWithApi:TY_API_UPLOAD_ALL_MAPINFOS Parameters:param];
}

- (void)addCities:(NSArray *)cities
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"userID"] = user.userID;
    param[@"cities"] = [IPMapWebObjectConverter prepareJsonString:[IPMapWebObjectConverter prepareCityObjectArray:cities]];
    [uploader uploadWithApi:TY_API_ADD_CITIES Parameters:param];
}

- (void)addBuildings:(NSArray *)buildings
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"userID"] = user.userID;
    param[@"buildings"] = [IPMapWebObjectConverter prepareJsonString:[IPMapWebObjectConverter prepareBuildingObjectArray:buildings]];
    [uploader uploadWithApi:TY_API_ADD_BUILDINGS Parameters:param];

}

- (void)addMapInfos:(NSArray *)mapInfos
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValuesForKeysWithDictionary:[user buildDictionary]];
    param[@"mapinfos"] = [IPMapWebObjectConverter prepareJsonString:[IPMapWebObjectConverter prepareMapInfoObjectArray:mapInfos]];
    [uploader uploadWithApi:TY_API_ADD_MAPINFOS Parameters:param];
}

- (void)uploadSymbolsWithFill:(NSArray *)fills Icons:(NSArray *)icons
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValuesForKeysWithDictionary:[user buildDictionary]];
    param[@"fill"] = [IPMapWebObjectConverter prepareJsonString:[IPMapWebObjectConverter prepareFillSymbolObjectArray:fills]];
    param[@"icon"] = [IPMapWebObjectConverter prepareJsonString:[IPMapWebObjectConverter prepareIconSymbolObjectArray:icons]];
    [uploader uploadWithApi:TY_API_UPLOAD_SYMBOLS Parameters:param];
}

- (void)addCompleteCBMWithCity:(TYCity *)city Building:(TYBuilding *)builing MapInfos:(NSArray *)mapInfos
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValuesForKeysWithDictionary:[user buildDictionary]];
    param[@"cities"] = [IPMapWebObjectConverter prepareJsonString:[IPMapWebObjectConverter prepareCityObjectArray:@[city]]];
    param[@"buildings"] = [IPMapWebObjectConverter prepareJsonString:[IPMapWebObjectConverter prepareBuildingObjectArray:@[builing]]];
    param[@"mapinfos"] = [IPMapWebObjectConverter prepareJsonString:[IPMapWebObjectConverter prepareMapInfoObjectArray:mapInfos]];
    [uploader uploadWithApi:TY_API_ADD_CBM Parameters:param];
}

- (void)WebUploaderDidFailedUploading:(IPMapWebUploader *)uploader WithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyFailedUploadingWithApi:api WithError:error];
}

- (void)WebUploaderDidFinishUploading:(IPMapWebUploader *)uploader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString
{
    NSError *error = nil;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        [self notifyFailedUploadingWithApi:api WithError:error];
        return;
    }
    
    BOOL success = [resultDict[TY_RESPONSE_STATUS] boolValue];
    NSString *description = resultDict[TY_RESPONSE_DESCRIPTION];

    if (success) {
        int records = [resultDict[TY_RESPONSE_RECORDS] intValue];
        NSLog(@"Upload: %d", records);
        [self notifyUploadingWithApi:api WithDescription:description];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description                                                                     forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"com.ty.mapsdk" code:0 userInfo:userInfo];
        [self notifyFailedUploadingWithApi:api WithError:error];
    }
}

- (void)notifyUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(CBMUploader:DidFinishUploadingWithApi:WithDescription:)]) {
        [self.delegate CBMUploader:self DidFinishUploadingWithApi:api WithDescription:description];
    }
}

- (void)notifyFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(CBMUploader:DidFailedUploadingWithApi:WithError:)]) {
        [self.delegate CBMUploader:self DidFailedUploadingWithApi:api WithError:error];
    }
}

@end
