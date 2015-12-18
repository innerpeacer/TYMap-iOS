//
//  TYMapDataManager.h
//  MapProject
//
//  Created by innerpeacer on 15/12/18.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>


@class TYMapDataManager;

@protocol TYMapDataManagerDelegate <NSObject>

- (void)TYMapDataManagerDidFinishFetchingData:(TYMapDataManager *)manager;
- (void)TYMapDataManagerDidFailedFetchingData:(TYMapDataManager *)manager WithError:(NSError *)error;

@end

@interface TYMapDataManager : NSObject

@property (nonatomic, weak) id<TYMapDataManagerDelegate> delegate;

- (id)initWithUserID:(NSString *)userID BuildingID:(NSString *)buildingID License:(NSString *)license;

- (void)fetchMapData;

@end
