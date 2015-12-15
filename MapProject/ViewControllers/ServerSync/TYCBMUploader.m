//
//  TYCBMUploader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYCBMUploader.h"
#import "TYMapEnviroment.h"
#import "TYWebUploader.h"
#import "TYWebObjectConverter.h"

@interface TYCBMUploader() <TYWebUploaderDelegate>
{
    TYMapUser *user;
    TYWebUploader *uploader;
}

@end

@implementation TYCBMUploader

- (id)initWithUser:(TYMapUser *)u
{
    self = [super init];
    if (self) {
        user = u;
        
        NSString *hostName = [TYMapEnvironment getHostName];
        NSAssert(hostName != nil, @"Host Name must not be nil!");
        
        uploader = [[TYWebUploader alloc] initWithHostName:hostName];
        uploader.delegate = self;
    }
    return self;
}

- (void)uploadCities:(NSArray *)cities
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"userID"] = user.userID;
    param[@"cities"] = [TYWebObjectConverter prepareJsonString:[TYWebObjectConverter prepareCityObjectArray:cities]];
    [uploader uploadWithApi:TY_API_UPLOAD_ALL_CITIES Parameters:param];
}

- (void)uploadBuildings:(NSArray *)buildings
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"userID"] = user.userID;
    param[@"buildings"] = [TYWebObjectConverter prepareJsonString:[TYWebObjectConverter prepareBuildingObjectArray:buildings]];
    [uploader uploadWithApi:TY_API_UPLOAD_ALL_BUILDINGS Parameters:param];
}

- (void)uploadMapInfos:(NSArray *)mapInfos
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"userID"] = user.userID;
    param[@"mapinfos"] = [TYWebObjectConverter prepareJsonString:[TYWebObjectConverter prepareMapInfoObjectArray:mapInfos]];
    [uploader uploadWithApi:TY_API_UPLOAD_ALL_MAPINFOS Parameters:param];
}

- (void)addCities:(NSArray *)cities
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"userID"] = user.userID;
    param[@"cities"] = [TYWebObjectConverter prepareJsonString:[TYWebObjectConverter prepareCityObjectArray:cities]];
    [uploader uploadWithApi:TY_API_ADD_CITIES Parameters:param];
}

- (void)addBuildings:(NSArray *)buildings
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"userID"] = user.userID;
    param[@"buildings"] = [TYWebObjectConverter prepareJsonString:[TYWebObjectConverter prepareBuildingObjectArray:buildings]];
    [uploader uploadWithApi:TY_API_ADD_BUILDINGS Parameters:param];

}

- (void)addMapInfos:(NSArray *)mapInfos
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValuesForKeysWithDictionary:[user buildDictionary]];
    param[@"mapinfos"] = [TYWebObjectConverter prepareJsonString:[TYWebObjectConverter prepareMapInfoObjectArray:mapInfos]];
    [uploader uploadWithApi:TY_API_ADD_MAPINFOS Parameters:param];
}

- (void)addCompleteCBMWithCity:(TYCity *)city Building:(TYBuilding *)builing MapInfos:(NSArray *)mapInfos
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValuesForKeysWithDictionary:[user buildDictionary]];
    param[@"cities"] = [TYWebObjectConverter prepareJsonString:[TYWebObjectConverter prepareCityObjectArray:@[city]]];
    param[@"buildings"] = [TYWebObjectConverter prepareJsonString:[TYWebObjectConverter prepareBuildingObjectArray:@[builing]]];
    param[@"mapinfos"] = [TYWebObjectConverter prepareJsonString:[TYWebObjectConverter prepareMapInfoObjectArray:mapInfos]];
    [uploader uploadWithApi:TY_API_ADD_CBM Parameters:param];
}

- (void)TYWebUploaderDidFailedUploading:(TYWebUploader *)uploader WithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyDidFailedUploadingWithApi:api WithError:error];
}

- (void)TYWebUploaderDidFinishUploading:(TYWebUploader *)uploader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString
{
    NSError *error = nil;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        [self notifyDidFailedUploadingWithApi:api WithError:error];
        return;
    }
    
    BOOL success = [resultDict[TY_RESPONSE_STATUS] boolValue];
    NSString *description = resultDict[TY_RESPONSE_DESCRIPTION];

    if (success) {
        int records = [resultDict[TY_RESPONSE_RECORDS] intValue];
        NSLog(@"Upload: %d", records);
        [self notifyDidFinishUploadingWithApi:api WithDescription:description];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description                                                                     forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"com.ty.mapsdk" code:0 userInfo:userInfo];
        [self notifyDidFailedUploadingWithApi:api WithError:error];
    }
}

- (void)notifyDidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYCBMUploader:DidFinishUploadingWithApi:WithDescription:)]) {
        [self.delegate TYCBMUploader:self DidFinishUploadingWithApi:api WithDescription:description];
    }
}

- (void)notifyDidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYCBMUploader:DidFailedUploadingWithApi:WithError:)]) {
        [self.delegate TYCBMUploader:self DidFailedUploadingWithApi:api WithError:error];
    }
}

@end
