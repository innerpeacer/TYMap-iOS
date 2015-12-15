//
//  TYCBMDownloader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "TYCBMDownloader.h"
#import "TYMapEnviroment.h"
#import "TYWebDownloader.h"
#import "TYWebObjectConverter.h"

@interface TYCBMDownloader() <TYWebDownloaderDelegate>
{
    TYMapUser *user;
    TYWebDownloader *downloader;
}

@end

@implementation TYCBMDownloader

- (id)initWithUser:(TYMapUser *)u
{
    self = [super init];
    if (self) {
        user = u;
        
        NSString *hostName = [TYMapEnvironment getHostName];
        NSAssert(hostName != nil, @"Host Name must not be nil!");
        
        downloader = [[TYWebDownloader alloc] initWithHostName:hostName];
        downloader.delegate = self;
    }
    return self;
}

- (void)getAllCities
{
    [downloader downloadWithApi:TY_API_GET_ALL_CITIES Parameters:[user buildDictionary]];
}

- (void)getAllBuildings
{
    [downloader downloadWithApi:TY_API_GET_ALL_BUILDINGS Parameters:[user buildDictionary]];
}

- (void)getAllMapInfos
{
    [downloader downloadWithApi:TY_API_GET_ALL_MAPINFOS Parameters:[user buildDictionary]];
}

- (void)getCBM
{
    [downloader downloadWithApi:TY_API_GET_TARGET_CBM Parameters:[user buildDictionary]];
}

- (void)getCity:(NSString *)cityID
{
    [downloader downloadWithApi:TY_API_GET_TARGET_CITY Parameters:@{@"cityID" : cityID}];
}

- (void)getBuildings
{
    [downloader downloadWithApi:TY_API_GET_TARGET_BUILDING Parameters:[user buildDictionary]];
}

- (void)getMapInfos
{
    [downloader downloadWithApi:TY_API_GET_TARGET_MAPINFO Parameters:[user buildDictionary]];
}


- (void)TYWebDownloaderDidFinishDownloading:(TYWebDownloader *)dataDownloader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString
{
    NSError *error = nil;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        [self notifyDidFailedDownloadingWithApi:api WithError:error];
        return;
    }
    
    BOOL success = [resultDict[TY_RESPONSE_STATUS] boolValue];
    NSString *description = resultDict[TY_RESPONSE_DESCRIPTION];
    int records = [resultDict[TY_RESPONSE_RECORDS] intValue];
    
    if (success) {
        if ([api isEqualToString:TY_API_GET_TARGET_CITY] || [api isEqualToString:TY_API_GET_ALL_CITIES]) {
            NSArray *cityArray = [TYWebObjectConverter parseCityArray:resultDict[@"cities"]];
            [self notifyDidFinishDownloadingWithApi:api WithResult:cityArray Records:records];
        }
        
        if ([api isEqualToString:TY_API_GET_TARGET_BUILDING] || [api isEqualToString:TY_API_GET_ALL_BUILDINGS]) {
            NSArray *buildingArray = [TYWebObjectConverter parseBuildingArray:resultDict[@"buildings"]];
            [self notifyDidFinishDownloadingWithApi:api WithResult:buildingArray Records:records];
        }
        
        if ([api isEqualToString:TY_API_GET_TARGET_MAPINFO] || [api isEqualToString:TY_API_GET_ALL_MAPINFOS]) {
            NSArray *mapInfoArray = [TYWebObjectConverter parseMapInfoArray:resultDict[@"mapinfos"]];
            [self notifyDidFinishDownloadingWithApi:api WithResult:mapInfoArray Records:records];
        }
        
        if ([api isEqualToString:TY_API_GET_TARGET_CBM]) {
            NSArray *cityArray = [TYWebObjectConverter parseCityArray:resultDict[@"cities"]];
            NSArray *buildingArray = [TYWebObjectConverter parseBuildingArray:resultDict[@"buildings"]];
            NSArray *mapInfoArray = [TYWebObjectConverter parseMapInfoArray:resultDict[@"mapinfos"]];
            
            TYCity *city = nil;
            if (cityArray && cityArray.count > 0) {
                city = cityArray[0];
            }
            
            TYBuilding *building = nil;
            if (buildingArray && buildingArray.count > 0) {
                building = buildingArray[0];
            }

            [self notifyDidFinishDownloadingCBMWithApi:api WithCity:city Building:building MapInfos:mapInfoArray];
        }

    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description                                                                     forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"com.ty.mapsdk" code:0 userInfo:userInfo];
        [self notifyDidFailedDownloadingWithApi:api WithError:error];
    }
    
}


- (void)TYWebDownloaderDidFailedDownloading:(TYWebDownloader *)dataDownloader WithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyDidFailedDownloadingWithApi:api WithError:error];
}

- (void)notifyDidFinishDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYCBMDownloader:DidFinishDownloadingWithApi:WithResult:Records:)]) {
        [self.delegate TYCBMDownloader:self DidFinishDownloadingWithApi:api WithResult:resultArray Records:records];
    }
}

- (void)notifyDidFinishDownloadingCBMWithApi:(NSString *)api WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYCBMDownloader:DidFinishDownloadingCBMWithApi:WithCity:Building:MapInfos:)]) {
        [self.delegate TYCBMDownloader:self DidFinishDownloadingCBMWithApi:api WithCity:city Building:building MapInfos:mapInfoArray];
    }
}

- (void)notifyDidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TYCBMDownloader:DidFailedDownloadingWithApi:WithError:)]) {
        [self.delegate TYCBMDownloader:self DidFailedDownloadingWithApi:api WithError:error];
    }
}

@end