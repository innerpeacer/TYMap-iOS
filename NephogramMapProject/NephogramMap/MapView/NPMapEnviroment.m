//
//  NPMapEnviroment.m
//  NephogramMapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import "NPMapEnviroment.h"

#define DEFAULT_MAP_ROOT @"Map"

@implementation NPMapEnvironment

static NSString *mapFileRootDirectory;

+ (NSString *)getRootDirectoryForMapFiles
{
    if (mapFileRootDirectory == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        mapFileRootDirectory = [documentDirectory stringByAppendingPathComponent:DEFAULT_MAP_ROOT];
    }
    return mapFileRootDirectory;
}

+ (void)setRootDirectoryForMapFiles:(NSString *)dir
{
    mapFileRootDirectory = [NSString stringWithString:dir];
}

+ (NPSpatialReference *)defaultSpatialReference
{
    static NPSpatialReference *spatialReference;
    if (spatialReference == nil) {
        spatialReference = [NPSpatialReference spatialReferenceWithWKID:3395];
    }
    return spatialReference;
}

+ (NPCredential *)defaultCredential
{
    static NPCredential *credential;
    if (credential == nil) {
        credential = [[NPCredential alloc] initWithUser:@"arcgis" password:@"666666"];
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
