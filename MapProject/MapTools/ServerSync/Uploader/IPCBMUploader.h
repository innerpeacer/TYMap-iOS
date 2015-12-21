//
//  TYCBMUploader.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapCredential.h"
#import <TYMapData/TYMapData.h>

@class IPCBMUploader;

@protocol IPCBMUploaderDelegate <NSObject>
- (void)CBMUploader:(IPCBMUploader *)uploader DidFinishUploadingWithApi:(NSString *)api WithDescription:(NSString *)description;
- (void)CBMUploader:(IPCBMUploader *)uploader DidFailedUploadingWithApi:(NSString *)api WithError:(NSError *)error;
@end

@interface IPCBMUploader : NSObject

- (id)initWithUser:(TYMapCredential *)user;
@property (nonatomic, weak) id<IPCBMUploaderDelegate> delegate;

- (void)uploadCities:(NSArray *)cities;
- (void)uploadBuildings:(NSArray *)buildings;
- (void)uploadMapInfos:(NSArray *)mapInfos;

- (void)addCities:(NSArray *)cities;
- (void)addBuildings:(NSArray *)buildings;
- (void)addMapInfos:(NSArray *)mapInfos;
- (void)uploadSymbolsWithFill:(NSArray *)fills Icons:(NSArray *)icons;


- (void)addCompleteCBMWithCity:(TYCity *)city Building:(TYBuilding *)builing MapInfos:(NSArray *)mapInfos;

@end
