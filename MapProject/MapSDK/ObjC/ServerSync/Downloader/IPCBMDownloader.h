//
//  TYCBMDownloader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapCredential.h"
#import <TYMapData/TYMapData.h>

@class IPCBMDownloader;

@protocol IPCBMDownloaderDelegate <NSObject>

@optional
- (void)CBMDownloader:(IPCBMDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records;
- (void)CBMDownloader:(IPCBMDownloader *)downloader DidFinishDownloadingSymbolsWithApi:(NSString *)api WithFillSymbols:(NSArray *)fillArray WithIconSymbols:(NSArray *)iconArray;
- (void)CBMDownloader:(IPCBMDownloader *)downloader DidFinishDownloadingCBMWithApi:(NSString *)api WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray;
- (void)CBMDownlaoder:(IPCBMDownloader *)downloader DidFinishDownloadingCityBuildingsWithApi:(NSString *)api WithCities:(NSArray *)cityArray Buildings:(NSArray *)buildingArray;
- (void)CBMDownloader:(IPCBMDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error;
@end

@interface IPCBMDownloader : NSObject

- (id)initWithUser:(TYMapCredential *)user;

@property (nonatomic, weak) id<IPCBMDownloaderDelegate> delegate;

- (void)getAllCities;
- (void)getAllBuildings;
- (void)getAllMapInfos;
- (void)getAllCityBuildings;

- (void)getCity:(NSString *)cityID;
- (void)getBuildings;
- (void)getMapInfos;
- (void)getSymbols;
- (void)getCBM;

@end
