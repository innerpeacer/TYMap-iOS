//
//  NPMapEnviroment.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPMapEnviroment.h"

@implementation NPMapEnvironment

+ (AGSSpatialReference *)defaultSpatialReference
{
    static AGSSpatialReference *spatialReference;
    if (spatialReference == nil) {
        spatialReference = [AGSSpatialReference spatialReferenceWithWKID:3395];
    }
    return spatialReference;
}

+ (AGSCredential *)defaultCredential
{
    static AGSCredential *credential;
    if (credential == nil) {
        credential = [[AGSCredential alloc] initWithUser:@"arcgis" password:@"666666"];
    }
    return credential;
}

+ (void)initMapEnvironment
{
    NSError *error;
    NSString* clientID = @"aBYcI5ED55pNyHQ8";
    [AGSRuntimeEnvironment setClientID:clientID error:&error];
    if(error){
        NSLog(@"Error using client ID : %@",[error localizedDescription]);
    }
}

@end
