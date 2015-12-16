//
//  TYCBMDownloader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapUser.h"
#import <TYMapData/TYMapData.h>

@class TYCBMDownloader;

@protocol TYCBMDownloaderDelegate <NSObject>

@optional
- (void)TYCBMDownloader:(TYCBMDownloader *)downloader DidFinishDownloadingWithApi:(NSString *)api WithResult:(NSArray *)resultArray Records:(int)records;
- (void)TYCBMDownloader:(TYCBMDownloader *)downloader DidFinishDownloadingSymbolsWithApi:(NSString *)api WithFillSymbols:(NSArray *)fillArray WithIconSymbols:(NSArray *)iconArray;
- (void)TYCBMDownloader:(TYCBMDownloader *)downloader DidFinishDownloadingCBMWithApi:(NSString *)api WithCity:(TYCity *)city Building:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray;
- (void)TYCBMDownloader:(TYCBMDownloader *)downloader DidFailedDownloadingWithApi:(NSString *)api WithError:(NSError *)error;
@end

@interface TYCBMDownloader : NSObject

- (id)initWithUser:(TYMapUser *)user;

@property (nonatomic, weak) id<TYCBMDownloaderDelegate> delegate;

- (void)getAllCities;
- (void)getAllBuildings;
- (void)getAllMapInfos;

- (void)getCity:(NSString *)cityID;
- (void)getBuildings;
- (void)getMapInfos;
- (void)getSymbols;
- (void)getCBM;

@end
