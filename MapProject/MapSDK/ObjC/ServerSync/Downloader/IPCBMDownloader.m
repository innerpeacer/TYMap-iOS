//
//  TYCBMDownloader.m
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "IPCBMDownloader.h"
#import "TYMapEnviroment.h"
#import "IPMapWebDownloader.h"
#import "IPMapWebObjectConverter.h"
#import "IPMapApi.h"

@interface IPCBMDownloader() <IPMapWebDownloaderDelegate>
{
    TYMapCredential *user;
    IPMapWebDownloader *downloader;
}

@end

@implementation IPCBMDownloader

- (id)initWithUser:(TYMapCredential *)u
{
    self = [super init];
    if (self) {
        user = u;
        
        NSString *hostName = [TYMapEnvironment getHostName];
        NSAssert(hostName != nil, @"Host Name must not be nil!");
        
        downloader = [[IPMapWebDownloader alloc] initWithHostName:hostName];
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

- (void)getAllCityBuildings
{
    [downloader downloadWithApi:TY_API_GET_ALL_CITY_BUILDINGS Parameters:[user buildDictionary]];
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

- (void)getSymbols
{
    [downloader downloadWithApi:TY_API_GET_TARGET_SYMBOLS Parameters:[user buildDictionary]];
}

- (void)WebDownloaderDidFinishDownloading:(IPMapWebDownloader *)dataDownloader WithApi:(NSString *)api WithResponseData:(NSData *)responseData ResponseString:(NSString *)responseString
{
    NSError *error = nil;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        [self notifyFailedDownloadingWithApi:api WithError:error];
        return;
    }
    
    BOOL success = [resultDict[TY_RESPONSE_STATUS] boolValue];
    NSString *description = resultDict[TY_RESPONSE_DESCRIPTION];
    int records = [resultDict[TY_RESPONSE_RECORDS] intValue];
    
    if (success) {
        if ([api isEqualToString:TY_API_GET_TARGET_CITY] || [api isEqualToString:TY_API_GET_ALL_CITIES]) {
            NSArray *cityArray = [IPMapWebObjectConverter parseCityArray:resultDict[@"cities"]];
            [self notifyDownloadingWithApi:api WithResult:cityArray Records:records];
        }
        
        if ([api isEqualToString:TY_API_GET_TARGET_BUILDING] || [api isEqualToString:TY_API_GET_ALL_BUILDINGS]) {
            NSArray *buildingArray = [IPMapWebObjectConverter parseBuildingArray:resultDict[@"buildings"]];
            [self notifyDownloadingWithApi:api WithResult:buildingArray Records:records];
        }
        
        if ([api isEqualToString:TY_API_GET_ALL_CITY_BUILDINGS]) {
            NSArray *cityArray = [IPMapWebObjectConverter parseCityArray:resultDict[@"cities"]];
            NSArray *buildingArray = [IPMapWebObjectConverter parseBuildingArray:resultDict[@"buildings"]];
            [self notifyDownloadingCityBuildingsWithApi:api WithCities:cityArray Buildings:buildingArray];
        }
        
        if ([api isEqualToString:TY_API_GET_TARGET_MAPINFO] || [api isEqualToString:TY_API_GET_ALL_MAPINFOS]) {
            NSArray *mapInfoArray = [IPMapWebObjectConverter parseMapInfoArray:resultDict[@"mapinfos"]];
            [self notifyDownloadingWithApi:api WithResult:mapInfoArray Records:records];
        }
        
        if ([api isEqualToString:TY_API_GET_TARGET_SYMBOLS]) {
            NSArray *fillArray = [IPMapWebObjectConverter parseFillSymbolArray:resultDict[@"fill"]];
            NSArray *iconArray = [IPMapWebObjectConverter parseIconSymbolArray:resultDict[@"icon"]];
            [self notifyDownloadingSymbolsWithApi:api WithFillSymbols:fillArray WithIconSymbols:iconArray];
        }
        
        if ([api isEqualToString:TY_API_GET_TARGET_CBM]) {
            NSArray *cityArray = [IPMapWebObjectConverter parseCityArray:resultDict[@"cities"]];
            NSArray *buildingArray = [IPMapWebObjectConverter parseBuildingArray:resultDict[@"buildings"]];
            NSArray *mapInfoArray = [IPMapWebObjectConverter parseMapInfoArray:resultDict[@"mapinfos"]];
            
            TYCity *city = nil;
            if (cityArray && cityArray.count > 0) {
                city = cityArray[0];
            }
            
            TYBuilding *building = nil;
            if (buildingArray && buildingArray.count > 0) {
                building = buildingArray[0];
            }

            [self notifyDownloadingCBMWithApi:api WithCity:city Building:building MapInfos:mapInfoArray];
        }

    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description                                                                     forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"com.ty.mapsdk" code:0 userInfo:userInfo];
        [self notifyFailedDownloadingWithApi:api WithError:error];
    }
    
}


- (void)WebDownloaderDidFailedDownloading:(IPMapWebDownloader *)dataDownloader WithApi:(NSString *)api WithError:(NSError *)error
{
    [self notifyFailedDownloadingWithApi:api WithError:error];
}

- (void)notifyDownloadingSymbolsWithApi:(NSString *)api WithFillSymbols:(NSArray *)fillArray WithIconSymbols:(NSArray *)iconArray
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(CBMDownloader:DidFinishDownloadingSymbolsWithApi:WithFillSymbols:WithIconSymbols:)]) {
        [self.delegate CBMDownloader:self DidFinishDownloadingSymbolsWithApi:api WithFillSymbols:fillArray WithIconSymbols:iconArray];
    }
}

- (void)notifyDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(CBMDownloader:DidFinishDownloadingWithApi:WithResult:Records:)]) {
        [self.delegate CBMDownloader:self DidFinishDownloadingWithApi:api WithResult:resultArray Records:records];
    }
}

- (void)notifyDownloadingCBMWithApi:(NSString *)api WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(CBMDownloader:DidFinishDownloadingCBMWithApi:WithCity:Building:MapInfos:)]) {
        [self.delegate CBMDownloader:self DidFinishDownloadingCBMWithApi:api WithCity:city Building:building MapInfos:mapInfoArray];
    }
}

- (void)notifyDownloadingCityBuildingsWithApi:(NSString *)api WithCities:(NSArray *)cityArray Buildings:(NSArray *)buildingArray
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(CBMDownlaoder:DidFinishDownloadingCityBuildingsWithApi:WithCities:Buildings:)]) {
        [self.delegate CBMDownlaoder:self DidFinishDownloadingCityBuildingsWithApi:api WithCities:cityArray Buildings:buildingArray];
    }
}

- (void)notifyFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(CBMDownloader:DidFailedDownloadingWithApi:WithError:)]) {
        [self.delegate CBMDownloader:self DidFailedDownloadingWithApi:api WithError:error];
    }
}

@end