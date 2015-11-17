//
//  CallingApiVC.m
//  MapProject
//
//  Created by innerpeacer on 15/11/15.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import "CallingApiVC.h"

#import <TYMapData/TYMapData.h>
#import <ArcGIS/ArcGIS.h>
#import "TYUserDefaults.h"
#import "TYMapInfo.h"
#import "LicenseGenerator.h"
#import "TYArcGISDrawer.h"
//#import "MKNetworkKit.h"
#import <MKNetworkKit/MKNetworkKit.h>

#import "TYPointConverter.h"

@interface CallingApiVC()
{
    TYCity *currentCity;
    TYBuilding *currentBuilding;
    
    NSArray *allMapInfos;
    
    AGSGraphicsLayer *beaconLayer;
    
    NSString *userID;
    NSString *buildingID;
    NSString *license;
    
    NSString *hostName;
    NSString *apiPath;
}

@end

@implementation CallingApiVC

- (void)viewDidLoad
{
    self.currentCity = [TYUserDefaults getDefaultCity];
    self.currentBuilding = [TYUserDefaults getDefaultBuilding];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    
    [super viewDidLoad];
    
    self.title = currentBuilding.name;
    
    
    beaconLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:beaconLayer];
    
    userID = TRIAL_USER_ID;
    buildingID = self.currentBuilding.buildingID;
    license = [LicenseGenerator generateLicenseForUserID:userID Building:buildingID ExpiredDate:TRIAL_EXPRIED_DATE];
    
    hostName = LOCAL_HOST_NAME;
    hostName = SERVER_HOST_NAME;
    apiPath = [[NSString alloc] initWithFormat:@"/TYMapServerManager/beacon/GetLocatingBeacons"];

    [self testGetLocatingBeaconsUsingHttpPost];
}


- (void)testGetLocatingBeaconsUsingHttpPost
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:userID forKey:@"userID"];
    [param setValue:buildingID forKey:@"buildingID"];
    [param setValue:license forKey:@"license"];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:hostName];
    MKNetworkOperation *op = [engine operationWithPath:apiPath params:param httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
//        NSLog(@"ResponseData: %@", [operation responseString]);
        NSData *data = [operation responseData];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [self showBeaconResult:dict];
//        NSLog(@"%@", [NSString stringWithFormat:@"%@", dict]);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
    
    [engine enqueueOperation:op];
}

- (void)showBeaconResult:(NSDictionary *)dict
{
    [beaconLayer removeAllGraphics];
    
    NSArray *beaconArray = [dict objectForKey:@"beacons"];
    for (NSDictionary *beaconDict in beaconArray) {
        int floor = [[beaconDict objectForKey:@"floor"] intValue];
//        int major = [[beaconDict objectForKey:@"major"] intValue];
        int minor = [[beaconDict objectForKey:@"minor"] intValue];
//        double x = [[beaconDict objectForKey:@"x"] intValue];
//        double y = [[beaconDict objectForKey:@"y"] intValue];
//        NSLog(@"%@", [beaconDict objectForKey:@"geometry"]);
//        NSLog(@"%@", [[beaconDict objectForKey:@"geometry"] class]);
        NSArray *geometryByteArray = [beaconDict objectForKey:@"geometry"];
        int length = (int)geometryByteArray.count;
        Byte geometryBytes[length];
        for (int i = 0; i < length; ++i) {
            geometryBytes[i] = (Byte)[[geometryByteArray objectAtIndex:i] intValue];
        }
        NSData *geometryData = [NSData dataWithBytes:geometryBytes length:length];
        double *xyz = [TYPointConverter xyzFromNSData:geometryData];
        
        double x = xyz[0];
        double y = xyz[1];
        
        if (floor != self.currentMapInfo.floorNumber) {
            continue;
        }
        
        TYPoint *p = [TYPoint pointWithX:x y:y spatialReference:self.mapView.spatialReference];
        [TYArcGISDrawer drawPoint:p AtLayer:(TYGraphicsLayer *)beaconLayer WithColor:[UIColor redColor]];
        
        AGSTextSymbol *ts = [AGSTextSymbol textSymbolWithText:[NSString stringWithFormat:@"%d", minor] color:[UIColor magentaColor]];
        [ts setOffset:CGPointMake(5, -10)];
        [beaconLayer addGraphic:[AGSGraphic graphicWithGeometry:p symbol:ts attributes:nil]];
    }
}

@end
